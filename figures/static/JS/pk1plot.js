
var svg = d3.select("svg");
var margin = {top: 20, right: 20, bottom: 110, left: 80};
var margin2 = {top: 430, right: 20, bottom: 30, left: 80};
var width = +svg.attr("width") - margin.left - margin.right;
var height = +svg.attr("height") - margin.top - margin.bottom;
var height2 = +svg.attr("height") - margin2.top - margin2.bottom;


var x = d3.scaleLinear().range([0, width]),
    y = d3.scaleLinear().range([height, 0]),
    x2 = d3.scaleLinear().range([0, width]),
    y2 = d3.scaleLinear().range([height2, 0]),

    z = d3.scaleOrdinal(d3.schemeCategory10);

var xAxis = d3.axisBottom(x)
    .tickFormat(float_to_time);

var xAxis2 = d3.axisBottom(x2),
    yAxis = d3.axisLeft(y);

var brush = d3.brushX()
    .extent([[0, 0], [width, height2]])
    .on("brush end", brushed);

var zoom = d3.zoom()
    .scaleExtent([1, Infinity])
    .translateExtent([[0, 0], [width, height]])
    .extent([[0, 0], [width, height]])
    .on("zoom", zoomed);

var line = d3.line()
    .curve(d3.curveMonotoneX)
    .x(function(d) {return x(d.time); })
    .y(function(d) {return y(d.value); });

var area2 = d3.area()
    .curve(d3.curveMonotoneX)
    .x(function(d) { return x2(d.date); })
    .y0(height2)
    .y1(function(d) { return y2(d.price); });

const bisect = d3.bisector(function(d) { return d.value}).left;

svg.append("defs").append("clipPath")
    .attr("id", "clip")
    .append("rect")
    .attr("width", width)
    .attr("height", height);

var focus = svg.append("g")
    .attr("class", "focus")
    .call(zoom)
    .attr("transform", "translate(" + margin.left + "," + margin.top + ")")



focus.append("rect")
    .attr("width", width)
    .attr("height", height)
    .attr("class", "zoom")




var svgGroup = focus.append("g")
    .style("clip-path", "url(#clip)");



const verticalLine = focus.append("line")
    .attr("x1", 0)
    .attr("y1", 0)
    .attr("x2", 0)
    .attr("y2", height )
    .classed("verticalLine dashed", true)
    .style("stroke-width", 1)
    .style("stroke", "black")
    .style("fill", "none")
    .style("opacity", 1)
    .style("pointer-events", "none");

const horizontalLine = focus.append("line")
    .attr("x1", 0)
    .attr("y1", 0)
    .attr("x2", width)
    .attr("y2", 0)
    .classed("horizontalLine dashed", true)
    .style("stroke-width", 1)
    .style("stroke", "black")
    .style("fill", "none")
    .style("opacity", 0)
    .style("pointer-events", "none");

var context = svg.append("g")
    .attr("class", "context")
    .attr("transform", "translate(" + margin2.left + "," + margin2.top + ")");

var tooltip = d3.select("body")
    .append("div")
    .classed("tooltip", true)

let dim = {svg:{}}
let dataStash = [];
const displayFilter = {period: {}, analysis: {}, sex: {"all": true}, race: {"all": true}, age: {"all": true}}
d3.csv("/static/tmpdata/ADPC.csv", type, function(error, data) {
    if (error) throw error;
    console.log(data[0])

    data.forEach(d => {
        let subject = dataStash.filter(s => s.id === d.id)[0]
        if (!subject) {
            subject = {id:d.id, values: [d]}
            dataStash.push(subject)
        } else {
            subject.values.push(d)
        }

        for (let key in displayFilter){
            if(d[key]) displayFilter[key][d[key]] = false
        }

    })
    console.log("num of subjects: " + dataStash.length)

    initial()
    createDisplayFilter()
    var bodyRect = document.body.getBoundingClientRect(),
        elemRect = d3.select("svg.main").node().getBoundingClientRect();

    dim.svg.x = elemRect.left - bodyRect.top;
    dim.svg.y = elemRect.top - bodyRect.top;
    console.log(dim, "dim")
});

function createDisplayFilter() {
    const displayCont = d3.select('#displayFilter')
    for (let key in displayFilter){
        const group = displayCont.append("span").attr("id", key)
        group.append("h3").html(key)
        for (let key1 in displayFilter[key]) {
            group.append('label').html(key1)
                .append('input')
                .attr("type", "radio")
                .attr("data-group", key)
                .attr("value", key1)
                .attr("name", key)
                .on("click", function () {
                    const el = d3.select(this),
                        group = el.attr("data-group"),
                        val = el.attr("value")
                    for (let key in displayFilter[group]) {
                        displayFilter[group][key] = key === val
                    }
                    drawChart()
                })

        }
    }
    for (let key in displayFilter){
        if (!key) continue
        let initialValueCheck = ""
        if (displayFilter[key].hasOwnProperty("all")) {initialValueCheck = "all"}
        else {initialValueCheck = Object.keys(displayFilter[key]).sort()[0]}

        displayCont.select("#" + key).select("input[value='" + initialValueCheck + "']").attr("checked", "checked")
        displayFilter[key][initialValueCheck] = true
    }
    drawChart()
}

function initial() {

    x.domain(d3.extent(dataStash[0].values, function(d) { return d.time; })).nice();

    y.domain([
        d3.min(dataStash.map(s => d3.min(s.values, function(d) { return d.value; }))),
        d3.max(dataStash.map(s => d3.max(s.values, function(d) { return d.value; })))*2,
    ]);

    x2.domain(x.domain());
    y2.domain(y.domain());

    z.domain(dataStash.map(function(s) { return s.id; }));

    focus.append("g")
        .attr("class", "axis axis--x")
        .attr("transform", "translate(0," + height + ")")
        .call(xAxis)
        .append("text")
        // .attr("transform", "translate(" + width+30 +"," + 0 + ")")
        .attr("x", width/2)
        .attr("y", 20)
        .attr("dy", "0.71em")
        .attr("fill", "#000")
        .style("font-size", "1.9em")
        .text('Time (Hours)');

    focus.append("g")
        .attr("class", "axis axis--y")
        .call(yAxis)
        .append("text")
        .attr("transform", "rotate(-90)")
        .attr("y", -55)
        .attr("x", -70)
        .attr("dy", "0.71em")
        .attr("fill", "#000")
        .style("font-size", "1.9em")
        .text(dataStash[0].values[0]["PARAM"]);

    context.append("g")
        .attr("class", "axis axis--x")
        .attr("transform", "translate(0," + height2 + ")")
        .call(xAxis2);

    context.append("g")
        .attr("class", "brush")
        .call(brush)
    // .call(brush.move, x.range());

    drawChart()
}

let filteredData = [];
let stackedData = []
function drawChart() {
    if (!dataStash || !dataStash[0] || !dataStash[0].values) return
    filteredData = dataStash.map(d0 => ({
        id: d0.id,
        values: d0.values.filter(d1 => {
            for (let key in displayFilter) {
                if (displayFilter[key]["all"]) return true
                if (!displayFilter[key][d1[key]]) return false
            }
            return true
        }),
        line_data: []
    }))

    filteredData = filteredData.map(d0 => {
        if (d0.values.length === 0) return {}
        const line_data = [];
        for (const j in d0.values) {
            if (j == 0 ) continue;
            line_data.push([
                d0.values[j-1].time,
                d0.values[j].time,
                d0.values[j-1].value,
                d0.values[j].value,

            ])
        }

        return {
            id: d0.id,
            line_data: line_data,
            values: d0.values,

            // everything supposed to be same for returning dict
            period: d0.values[0].period,
            analysis: d0.values[0].analysis,
            treatment: d0.values[0].treatment,

            sex: d0.values[0].sex,
            race: d0.values[0].race,
            age: d0.values[0].age

        }
    }).filter(d => d.values)

    let yMax = 1
    for (let i in filteredData) {
        for (let j in filteredData[i].values){
            const d = filteredData[i].values[j]
            if (d.time > x.domain()[0] && d.time < x.domain()[1]){
                if (d.value > yMax) yMax = d.value
            }
        }
    }
    y.domain([0, yMax*1.1]);

    focus.select("g.axis.axis--y")
        .transition()
        .duration(duration)
        .call(yAxis);

    zoom.scaleExtent([1, filteredData.length / 2])

    updateChart(true)

}
let duration = 500

function updateChart(transition) {
    if (!filteredData) return
    if (!filteredData[0]) return
    if (!filteredData[0].values) return
    duration = transition ? 300 : 0


    var node = svgGroup
        .selectAll("g.node")
        .data(filteredData);

    node.exit().remove();

    const nodeEnter = node
        .enter()
        .append("g")
        .attr("class", "node")



    const nodeUpdate = nodeEnter.merge(node)




    nodeUpdate
        .each(function (d, i) {
            const selection = d3.select(this)
                .classed(d.id, true)
                .on("mouseover", () => {
                    tooltip.style("opacity", 1)
                    svgGroup
                        .selectAll("g.node")
                        .classed("over_node", d1 => d1.id === d.id)
                })
                .on("mouseout", () => {
                    tooltip.style("opacity", 0)
                    svgGroup
                        .selectAll("g.node")
                        .classed("over_node", false)
                })
                .on("mousemove", mouseMoved)
                .on("click", displayTableContent)


            const point = selection
                .selectAll("g.point")
                .data(d.line_data)
            try {
                point.exit().remove()
            } catch (e) {
                console.log(point)
                console.log(d.line_data)
                console.log(d)
            }

            const pointEnter = point
                .enter()
                .append("g")
                .classed("point", true)

            pointEnter.append("line")
                .style("stroke", z(d.id))
            pointEnter.append("circle")
                .style("fill", z(d.id))

            const pointUpdate = pointEnter.merge(point);

            pointUpdate
                .each(function (d1, i) {
                    d3.select(this)
                        .select("line")
                        .transition()
                        .duration(duration)
                        .attr("x1", x(d1[0]))
                        .attr("x2", x(d1[1]))
                        .attr("y1", y(d1[2]))
                        .attr("y2", y(d1[3]))

                    d3.select(this)
                        .select("circle")
                        .transition()
                        .duration(duration)
                        .attr("cx", x(d1[0]))
                        .attr("cy", y(d1[2]))
                })

        })


}

function displayTableContent(d) {
    d3.select("div#moreInfo")
        .html(() => {
            const grid = {}
            const grid_columns = [
                ["id", "SUBJID"],
                ["period", "period"],
                ["analysis", "analysis"],
                ["treatment", "treatment"],
                ["sex", "sex"],
                ["race", "race"],
                ["age", "age"],
                ["time", "TIME"],
                ["value", "Concentration (ng/mL)"]
            ];
            let ul_start = "<ul class='list-group'>"
            for (let i in d.values) {
                for (let colum of grid_columns) {
                    let key = colum[0];
                    if (!grid.hasOwnProperty(key)) grid[key] = ul_start + '<li class="list-group-item">' + colum[1] + '</li>'
                    if (key === 'time') {
                        grid[key] += '<li class="list-group-item">' + float_to_time(d.values[i].time) + 'h' +  '</li>'
                    } else {
                        grid[key] += '<li class="list-group-item">' + d.values[i][key] + '</li>'
                    }
                }
            }

            let content = ""
            for (let key in grid){
                content += grid[key] + '</ul>'
            }
            return content
        })

    svgGroup
        .selectAll("g.node")
        .classed("clicked_node", d1 => d1.id === d.id)
}

function brushed() {
    if (d3.event.sourceEvent && d3.event.sourceEvent.type === "zoom") return; // ignore brush-by-zoom
    var s = d3.event.selection || x2.range();
    x.domain(s.map(x2.invert, x2));
    updateChart(false)
    focus.select(".axis--x").call(xAxis);
    focus.call(zoom.transform, d3.zoomIdentity
        .scale(width / (s[1] - s[0]))
        .translate(-s[0], 0));
}

function zoomed() {
    if (d3.event.sourceEvent && d3.event.sourceEvent.type === "brush") return; // ignore zoom-by-brush
    var t = d3.event.transform;
    x.domain(t.rescaleX(x2).domain());
    updateChart(false)
    focus.select(".axis--x").call(xAxis);
    context.select(".brush").call(brush.move, x.range().map(t.invertX, t));
}


function mouseMoved(d) {
    const mouse = d3.mouse(this)
    let point = {time:0}
    let mouseTime = x.invert(mouse[0])
    for (let i=1; i < d.values.length; i++) {
        if (Math.abs(d.values[i-1].time - mouseTime) < Math.abs(d.values[i].time - mouseTime)){
            point = d.values[i-1]
            break
        }
    }


    tooltip
        .style("left", dim.svg.x + x(point.time) + 130 + "px")
        .style("top", dim.svg.y + y(point.value) + "px")
        .style("display", "inline-block")
        .html(() => {
            let text = 'Subject number: ' + point.id + '<br>' +
                'Treatment sequence: ' + point.treatment + '<br>' +
                'Concentration: ' + point.value.toFixed(2) + '<br>' +
                'Time: ' + float_to_time(point.time)
            return text.trim()
        });
}


function float_to_time(time) {
    time = time.toString()
    const point_index = time.indexOf(".")
    if (point_index !== -1) {
        const minutes = parseInt(parseInt(time.slice(point_index+1)) * 6).toString().slice(0,2)
        time = time.slice(0, point_index) + ":" + minutes
    }
    return time
}

function floatTime_to_float(time) {
    const point_index = time.indexOf(".")
    if (point_index !== -1) {
        const minutes = parseInt(time.slice(point_index+1)) / .6
        time = time.slice(0, point_index) + "." + minutes
    }

    return parseFloat(time)
}



function type(d, _, columns) {

    const new_d = {}
    new_d.time = floatTime_to_float(d.EPLTM)
    new_d.id = d.SUBJID
    new_d.value = parseFloat(d.AVAL)
    new_d.period = d.APERIODC
    new_d.analysis = d.PARCAT1
    new_d.treatment = d.TRTSEQA

    new_d.sex = d.SEX
    new_d.race = d.RACE
    new_d.age = d.AGE

    new_d.PARAM = d.PARAM

    return new_d;
}