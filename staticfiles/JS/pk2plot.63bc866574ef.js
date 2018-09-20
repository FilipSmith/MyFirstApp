
var svg = d3.select("svg");
var margin = {top: 20, right: 20, bottom: 110, left: 80};
var margin2 = {top: 430, right: 20, bottom: 30, left: 80};
var width = +svg.attr("width") - margin.left - margin.right;
var height = +svg.attr("height") - margin.top - margin.bottom;
var height2 = +svg.attr("height") - margin2.top - margin2.bottom;
const dim = {svg:{}}

var model_chart = [{id:43, values: [{time:0, value: 2, line_data:[0,0,2,2]}, {time:0.3, value:100, line_data:[0,0.3,2,100]}]}]
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

var context = svg.append("g")
    .attr("class", "context")
    .attr("transform", "translate(" + margin2.left + "," + margin2.top + ")");

var tooltip = d3.select("body")
    .append("div")
    .classed("tooltip", true)

let dataStash = [];
const displayFilter = {period: {}, analysis: {}, trta: {subjects:false}
    // sex: {"all": true}, race: {"all": true}, age: {"all": true}
}

d3.csv("/static/tmpdata/ADPC.csv", type, function(error, data) {
    if (error) throw error;
    console.log(data[0])

    data.forEach(d => {
        let subject = dataStash.filter(s => s.id === d.id)[0]
        if (!subject) {
            subject = {id:d.id, subject: true, values: [d]}
            dataStash.push(subject)
        } else {
            subject.values.push(d)
        }

        for (let key in displayFilter){
            if(d[key]) displayFilter[key][d[key]] = false
        }
    })

    console.log("num of subjects: " + dataStash.length)

    createDisplayFilter()
    initial()
    var bodyRect = document.body.getBoundingClientRect(),
        elemRect = d3.select("svg.main").node().getBoundingClientRect();

    dim.svg.x = elemRect.left - bodyRect.top;
    dim.svg.y = elemRect.top - bodyRect.top;
});

function createDisplayFilter() {
    const displayCont = d3.select('#displayFilter')
    const translate_title = {period:"period", analysis:"analysis",trta:"display"}
    for (let key in displayFilter){
        const group = displayCont.append("span").attr("id", key)
        group.append("h3").html(translate_title[key])
        const elements_sorted = Object.keys(displayFilter[key]).sort((a, b) => {
            if (a === "subjects") return 1
            else if (a < b) return -1
            else if (a > b) return 1
            else return 0
        } )
        for (let key1 of elements_sorted) {
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
        // else if (displayFilter[key].hasOwnProperty("subjects")) {initialValueCheck = "subjects"}
        else {initialValueCheck = Object.keys(displayFilter[key]).sort()[0]}

        displayCont.select("#" + key).select("input[value='" + initialValueCheck + "']").attr("checked", "checked")
        displayFilter[key][initialValueCheck] = true
    }
    // drawChart()
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
function drawChart() {
    if (!dataStash || !dataStash[0] || !dataStash[0].values) return
    filteredData = dataStash.map(d0 => ({
        id: d0.id,
        subject: d0.subject,
        values: d0.values.filter(d1 => {
            for (let key in displayFilter) {
                if (displayFilter[key]["all"] || displayFilter[key]["subjects"]) return true
                if (!displayFilter[key][d1[key]]) return false
            }
            return true
        }),
        line_data: []
    }))
    //// create median line
    if (!displayFilter["trta"]["subjects"]) {
        for (let trta in displayFilter.trta) {
            const treatment = {id: trta, subject: false, values: []}
            for (let i in filteredData) {
                for (let j in filteredData[i].values) {
                    const d = filteredData[i].values[j]
                    let time = treatment.values.filter(t => t.time === d.time)[0]
                    if (!time) {
                        time = {time: d.time, points: [d]}
                        treatment.values.push(time)
                    } else {
                        time.points.push(d)
                    }

                }
            }
            treatment.values.forEach((d, i) => {
                d.std = d3.deviation(d.points, v => v.value);
                d.value = d3.median(d.points, v => v.value);

            })
            filteredData.push(treatment)
        }

    }

    //// </end> create median line

    filteredData.forEach((d0, i) => {
        d0.values.forEach((d1, j) => {
            if (j == 0) {
                d1.line_data = [
                    d0.values[j].time,
                    d0.values[j].time,
                    d0.values[j].value,
                    d0.values[j].value,
                ];
            } else {
                d1.line_data = [
                    d0.values[j - 1].time,
                    d0.values[j].time,
                    d0.values[j - 1].value,
                    d0.values[j].value,
                ]
            }
        })
    })


    let yMax = 1
    for (let i in filteredData) {
        for (let j in filteredData[i].values){
            const d = filteredData[i].values[j]
            // if (d.time > x.domain()[0] && d.time < x.domain()[1]){
            //     if (d.value > yMax) yMax = d.value
            // }
            if (d.value > yMax) yMax = d.value
        }
    }

    if (!displayFilter["trta"]["subjects"]) {
        filteredData = filteredData.filter(d=>d.values.length > 0).filter((d,i) => !d.subject)
    }

    y.domain([0, yMax*1.1]);

    focus.select("g.axis.axis--y")
        .transition()
        .duration(duration)
        .call(yAxis);

    if (filteredData[0]) zoom.scaleExtent([1, filteredData[0].values.length / 1.5])

    updateChart(true)

}
let duration = 0

function updateChart(transition) {
    // if (!filteredData) return
    // if (!filteredData[0]) return
    // if (!filteredData[0].values) return
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
                    d3.select(this)
                        .classed("over_node", true)
                })
                .on("mouseout", function() {
                    tooltip.style("opacity", 0)
                    d3.select(this)
                        .classed("over_node", false)
                        .selectAll("circle")
                        .classed("over_node", false)

                })
                .on("mousemove", mouseMoved)
                .on("click", displayTableContent)


            const point = selection
                .selectAll("g.point")
                .data(d.values)
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
                .classed("main", true)

            pointEnter.append("circle")


            const pointUpdate = pointEnter.merge(point);

            pointUpdate
                .each(function (d1, i) {
                    const line_data = d1.line_data
                    const selection1 = d3.select(this)
                    selection1
                        .select("line.main")
                        .style("stroke", z(d.id))
                        .transition()
                        .duration(duration)
                        .attr("x1", x(line_data[0]))
                        .attr("x2", x(line_data[1]))
                        .attr("y1", y(line_data[2]))
                        .attr("y2", y(line_data[3]))

                    selection1
                        .select("circle")
                        .style("fill", z(d.id))
                        .transition()
                        .duration(duration)
                        .attr("cx", x(d1.time))
                        .attr("cy", y(d1.value))

                    if (d1.std) {
                        const std = selection1.selectAll("g.std")
                            .data([d])

                        const stdEnter = std.enter().append("g").classed("std", true)

                        stdEnter.append("line").classed("std_vert", true)
                        stdEnter.append("line").classed("std_top", true)
                        stdEnter.append("line").classed("std_bottom", true)

                        const stdUpdate = stdEnter.merge(std)

                        stdUpdate
                            .select("line.std_vert")
                            .style("fill", z(d.id))
                            .transition()
                            .duration(duration)
                            .attr("x1", x(d1.time))
                            .attr("x2", x(d1.time))
                            .attr("y1", y(d1.value + d1.std / 2))
                            .attr("y2", y(d1.value - d1.std /2))

                        stdUpdate
                            .select("line.std_top")
                            .style("fill", z(d.id))
                            .transition()
                            .duration(duration)
                            .attr("x1", x(d1.time)-2)
                            .attr("x2", x(d1.time)+2)
                            .attr("y1", y(d1.value - d1.std / 2))
                            .attr("y2", y(d1.value - d1.std /2))

                        stdUpdate
                            .select("line.std_bottom")
                            .style("fill", z(d.id))
                            .transition()
                            .duration(duration)
                            .attr("x1", x(d1.time)-2)
                            .attr("x2", x(d1.time)+2)
                            .attr("y1", y(d1.value + d1.std / 2))
                            .attr("y2", y(d1.value + d1.std /2))
                    } else {
                        selection1
                            .select("g.std")
                            .remove()
                    }
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
            let values = d.subject ? d.values : mouseOverPoint.points
            for (let i in values) {
                for (let colum of grid_columns) {
                    let key = colum[0];
                    if (!grid.hasOwnProperty(key)) grid[key] = ul_start + '<li class="list-group-item">' + colum[1] + '</li>'
                    if (key === 'time') {
                        grid[key] += '<li class="list-group-item">' + float_to_time(values[i].time) + 'h' + '</li>'
                    } else {
                        grid[key] += '<li class="list-group-item">' + values[i][key] + '</li>'
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

let mouseOverPoint = {}
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
    d3.select(this)
        .selectAll("g.point")
        .select("circle")
        .classed("over_node", d => d.time === mouseOverPoint.time)
    mouseOverPoint = point;

    tooltip
        .style("left", dim.svg.x + x(point.time) + 130 + "px")
        .style("top", dim.svg.y + y(point.value) + "px")
        .style("display", "inline-block")
        .html(() => {
            if (point.hasOwnProperty("std")) {
                return (
                    'Time: ' + float_to_time(point.time) + '<br>' +
                    'Mean: ' + point.value.toFixed(2) + '<br>' +
                    'STD: ' + point.std.toFixed(2)
                )
            }
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
    new_d.trta = d.TRTA

    return new_d;
}