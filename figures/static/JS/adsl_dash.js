class Dashboard {
    constructor() {
        const CI = this;
        CI.CV_dashboard_element = d3.select("#dashboard");

        CI.IV_data_stash = [];
        CI.IV_filtered_data = [];

        CI.IV_filters_selection = d3.select("#filters").select("ul")
        CI.IV_filters = [];
        CI.IV_table_filter = null;
        CI.IV_filters_list = [];
        CI.IV_all_charts = [];

        CI.IV_table_selection = CI.CV_dashboard_element.select("#table");

        CI.IV_table_elements = [];

        CI.IV_tooltip = d3.select("body")// select element in the DOM with id 'chart'
            .append('div') // append a div element to the element we've selected
            .attr('class', 'tooltip'); // add class 'tooltip' on the divs we just selected

        CI.IV_tooltip.append('div') // add divs to the tooltip defined above
            .attr('class', 'label'); // add class 'label' on the selection

        CI.IV_tooltip.append('div') // add divs to the tooltip defined above
            .attr('class', 'count'); // add class 'count' on the selection

        CI.IV_tooltip.append('div') // add divs to the tooltip defined above
            .attr('class', 'percent'); // add class 'percent' on the selection

        CI.IV_transition_duration = 1000;

    }

    loadData(data) {
        const CI = this;
        data.forEach(d => d.enabled = true);
        CI.IV_data_stash = data
        CI.IV_filtered_data = data;
    }

    createFilters(keys) {
        const CI = this;
        keys.forEach(d => {
            CI.IV_filters_list.push(d.keyId)
            CI.IV_filters.push({keyId: d.keyId, keyLabel: d.keyLabel, values: []})
        })
        CI.IV_data_stash.forEach(d => {
            CI.IV_filters.forEach(f => {
                if (f.values.find(v => v.val === d[f.keyId]) === undefined) f.values.push({val: d[f.keyId], enabled: true})
            })
        })

        CI.updateFilters();

    }

    updateFilters() {
        const CI = this;

        const keysList = CI.IV_filters_selection
            .selectAll("li.list-group-item")
            .data(CI.IV_filters);

        const keysListEnter = keysList
            .enter()
            .append("li")
            .attr("class", "list-group-item")
            .append("div").attr("class", "row")

        keysListEnter
            .append("div").attr("class", "col-md-2 head")
            .append("div").attr("class", "key filtKey")
            .html(d => d.keyLabel)

        keysListEnter
            .append("div").attr("class", "col-md-9 row values")

        // const buttons_cont = keysListEnter
        //     .append("div").attr("class", "col-md-1")
        //
        // buttons_cont
        //     .append('button')
        //     .attr("class", "btn btn-success")
        //     .html("show")
        //     .on("click", function (d) {
        //         CI.filterData({keyId: d.keyId, values: true})
        //     })
        //
        // buttons_cont
        //     .append('button')
        //     .attr("class", "btn btn-danger")
        //     .html("hide")
        //     .on("click", function (d) {
        //         CI.filterData({keyId: d.keyId, values: false})
        //     })

        const keyListUpdate = keysListEnter.merge(keysList)

        keyListUpdate.each(function (datum) {
            const parent_selection = d3.select(this)
            const valueList = parent_selection
                .select("div.values")
                .selectAll("div.val")
                .data(datum.values)

            const valuesListEnter = valueList
                .enter()
                .append("div")
                .attr("class", "col-md-2 val")
                .on("click", function (datum_click) {
                    CI.IV_filters.forEach(v => {
                        if (v.keyId === datum.keyId) {
                            v.values.forEach(v => {
                                if (v.val === datum_click.val) {
                                    v.enabled = !v.enabled
                                }
                            })
                        }
                    });
                    CI.filterData(false)
                })

            valuesListEnter
                
                .append("div").attr("class", "val-body")
                .html(d => d.val)

            const valuesListUpdate = valuesListEnter.merge(valueList);

            valuesListUpdate
                .classed("enabled", d => d.enabled)
                .select(".val-body")
                .style("background-color", d => d.enabled ? "lightblue" : "lightcoral")
        })

        const selected = CI.CV_dashboard_element.select("#selectedFilters")
            .selectAll("div.cont")
            .data(CI.IV_filters);

        const selectedEnter = selected
            .enter()
            .append("div")
            .attr("class", "cont")

        const selectedUpdate = selectedEnter.merge(selected)

        selectedUpdate
            .html(d => {
                let text = "<span class='filtKey'>" + d.keyLabel + ": " + "</span>",
                    filt = d.values.filter(d0 => d0.enabled)
                if (filt.length !== d.values.length) text += filt.map(d0 => d0.val).join(", ")
                else text += "All"
                return text
            })

        CI.CV_dashboard_element.select("#tableFilter")
            .html(() => {
                let text = "<span class='filtKey'>Population: " + "</span>";
                if (!CI.IV_table_filter) return text + "All";
                else return text + CI.IV_table_filter.k
            })

    }

    appendTable(table_extracts) {
        const CI = this;

        table_extracts.forEach(d => {
            CI.IV_table_elements.push(new TableElement(CI).loadElements(d.key.label).setupData(d))
        })
    }

    filterData(keyVal) {
        const CI = this;
        if (keyVal) {
            const currFilter = CI.IV_filters.find(d => d.keyId === keyVal.keyId);
            if (keyVal.values === true) currFilter.values.forEach(d => d.enabled = true);
            else if (keyVal.values === false) currFilter.values.forEach(d => d.enabled = false);
            else currFilter.values.forEach(d => {
                d.enabled = keyVal.values.indexOf(d.val) !== -1
            });
        }
        CI.IV_filtered_data.forEach(d => {
            let enabled = true;
            for (let i = 0; i < CI.IV_filters.length; i++) {
                const key = CI.IV_filters[i].keyId
                enabled = CI.IV_filters[i].values.find(v => v.val === d[key]).enabled

                if (!enabled) break
            }

            if (CI.IV_table_filter && CI.IV_table_filter.k !== "total") {
                if (d[CI.IV_table_filter.k] !== CI.IV_table_filter.v) {
                    enabled = false;
                }
            }
            d.enabled = enabled;
        })


        CI.update()
    }

    update() {
        const CI = this;
        console.log("filters: ", CI.IV_filters)
        console.log("filters_table: ", CI.IV_table_filter)
        CI.IV_all_charts.forEach(chart => {
            chart.setupData();
            chart.update();
        })

        CI.IV_table_elements.forEach(item => item.update())
        CI.updateFilters()
    }

}

class BarChart {

    constructor(dash) {
        const CI = this;
        CI.CV_dash = dash;

        CI.IV_selection_id = "";
        CI.IV_selection = null;
        CI.CV_svg = {};
        CI.CV_focus = {}
        CI.CV_svgGroup = {};
        CI.CV_margin = {};
        CI.CV_width = 0
        CI.CV_height = 0;

        CI.IV_d3_x = {};  // changing x domain to scaleBand
        CI.IV_d3_y = {};

        CI.IV_d3_xAxis = {};
        CI.IV_d3_yAxis = {};

        CI.IV_tooltip = {};
        CI.IV_chart_mix = {};

        CI.IV_data_stash = [];
        CI.IV_extract = [];
        CI.IV_data_len = 0;

        CI.IV_bar_color = "";
    }

    loadElements(elm_id, x_label, y_label, bar_color, ticksHidden) {
        const CI = this;
        //// set dimensions
        CI.IV_selection_id = elm_id
        CI.IV_selection = d3.select("#" + elm_id)
        if (CI.IV_selection._groups[0][0] === null) console.log("selection failed, no element id: " + elm_id)
        CI.CV_svg = CI.IV_selection.append("svg").attr("width", 400).attr("height", 350);

        CI.CV_margin = {top: 20, right: 40, bottom: 40, left: 70};
        CI.CV_width = +CI.CV_svg.attr("width") - CI.CV_margin.left - CI.CV_margin.right;
        CI.CV_height = +CI.CV_svg.attr("height") - CI.CV_margin.top - CI.CV_margin.bottom;

        CI.IV_d3_x = d3.scaleBand().rangeRound([0, CI.CV_width]).padding(0.1);  // changing x domain to scaleBand
        CI.IV_d3_y = d3.scaleLinear().range([CI.CV_height, 0]);

        CI.IV_d3_xAxis = d3.axisBottom(CI.IV_d3_x)
            .tickFormat(text => {
                const max = (CI.CV_width / 10) / CI.IV_data_stash.length;

                if (text.length > (max)) {
                    return text.slice(0, max) + "..."
                }
                return text;
            });
        CI.IV_d3_yAxis = d3.axisLeft(CI.IV_d3_y);

        const randomId = Math.random();
        CI.CV_svg.append("defs").append("clipPath")  // clip path for zoom function
            .attr("id", randomId)
            .append("rect")
            .attr("width", CI.CV_width)
            .attr("height", CI.CV_height);

        CI.CV_focus = CI.CV_svg.append("g")
            .attr("class", "focus")
            .attr("transform", "translate(" + CI.CV_margin.left + "," + CI.CV_margin.top + ")")

        // CI.CV_focus.append("rect")
        //     .attr("class", "zoom")
        //     .attr("width", CI.CV_width)
        //     .attr("height", CI.CV_height)

        CI.CV_svgGroup = CI.CV_focus.append("g")
            .classed("svgGroup", true)
            .style("clip-path", "url(#" + randomId + ")");

        CI.CV_focus.append("g")
            .attr("class", "axis axis--x")
            .attr("transform", "translate(0," + CI.CV_height + ")")
            .append("text")
            // .attr("transform", "translate(" + width+30 +"," + 0 + ")")
            .attr("x", CI.CV_width / 2)
            .attr("y", 20)
            .attr("dy", "0.71em")
            .attr("fill", "#000")
            .style("font-size", "1.9em")
            .style("text-anchor", "middle")
            .text(x_label);

        CI.CV_focus.append("g")
            .attr("class", "axis axis--y")

        CI.CV_focus.select("g.axis.axis--y")
            .append("text")
            .attr("transform", "rotate(-90)")
            .attr("y", -45)
            .attr("x", -CI.CV_height / 2)
            .attr("dy", "0.71em")
            .attr("fill", "#000")
            .style("font-size", "1.8em")
            .style("text-anchor", "middle")
            .text(y_label);

        CI.IV_tooltip = d3.select("div.tooltip")

        CI.IV_bar_color = bar_color;

        if (ticksHidden) {
            CI.IV_d3_xAxis.tickValues([]);
        }
    }

    setupData(extract) {
        const CI = this;
        if (!extract) {
            if (!CI.IV_extract) console.log("no extract")
        } else {
            CI.IV_extract = extract;
        }

        const data = CI.CV_dash.IV_filtered_data;

        CI.IV_data_stash = []

        data.forEach(d => {

            const k = CI.IV_extract.key.id,
                v = CI.IV_extract.value.id,
                unique_key = CI.IV_extract.key.self ? k : d[k];
            let element = CI.IV_data_stash.find(d0 => d0.unique_key === unique_key)
            if (!element) {
                CI.IV_data_stash.push({
                    [k]: unique_key,
                    unique_key: unique_key,
                    key: k,
                    values: [],
                    count: 0,
                    all_count: 0,
                    keyLabel: CI.IV_extract.key.label,
                    positive: CI.IV_extract.key.positive,
                    valueLabel: CI.IV_extract.value.label,
                    to_filter: {
                        k: k,
                        v: (CI.IV_extract.key.self ? CI.IV_extract.key.positive : d[k]),
                        label: CI.IV_extract.key.label
                    },
                })
            }
            element = CI.IV_data_stash.find(d0 => d0.unique_key === unique_key)

            if (d.enabled) element.values.push(d[v])

            //// calculate all_values count for stable y axis
            if (element.positive === true) element.all_count += 1
            else if (element.positive === "value") element.all_count = d[v]
            else element.count += v === element.positive ? 1 : 0
            //// </end> calculate all_values count for stable y axis
        })

        CI.IV_data_stash.forEach(d => {
            if (d.positive === true) d.count = d.values.length
            else if (d.positive === "value") d.count = d.values.length !== 0 ? d.values[0] : 0
            else d.count = d.values.filter(v => v === d.positive).length
        })

        CI.IV_data_len = data.length;

    }

    update() {
        const CI = this;

        CI.IV_d3_x.domain(CI.IV_data_stash.map(function (d) {
            return d.unique_key;
        }));

        CI.IV_d3_y.domain([0, d3.max(CI.IV_data_stash, d => d.all_count) * 1.01]);

        CI.CV_focus.select("g.axis.axis--x")
            .transition()
            .call(CI.IV_d3_xAxis)

        CI.CV_focus.select("g.axis.axis--y")
            .transition()
            .call(CI.IV_d3_yAxis)
        //// </end> setting up domains on axises


        //// drawing bar chart
        const bar = CI.CV_svgGroup.selectAll(".bar")
            .data(CI.IV_data_stash)

        bar.exit().remove()

        const barEnter = bar
            .enter().append("rect")
            .attr("class", "bar")
            .style("stroke", "transparent")
            .style("stroke-width", "3px")
            .style("fill", CI.IV_bar_color)
            .on('mouseover', function (d) {  // when mouse enters div
                let total = d3.sum(CI.IV_data_stash.map(function (d) {
                    return d.count
                }));
                CI.IV_tooltip.select('.label').html(CI.IV_extract.key.label + ": " + d.unique_key); // set percent calculated above
                CI.IV_tooltip.select('.count').html("Count: " + d.count); // set current count
                CI.IV_tooltip.select('.percent').html(() => {
                    if (d.positive !== true) return "";
                    return ((d.count / total) * 100).toFixed(2) + '%';
                }); // set percent calculated above
                CI.IV_tooltip.style('display', 'block'); // set display
            })
            .on('mouseout', function () { // when mouse leaves div
                CI.IV_tooltip.style('display', 'none'); // hide tooltip for that element
            })
            .on('mousemove', function (d) { // when mouse moves
                CI.IV_tooltip.style('top', (d3.event.pageY + 10) + 'px') // always 10px below the cursor
                    .style('left', (d3.event.pageX + 10) + 'px'); // always 10px to the right of the mouse
            })
            .on("click", function (datum) {
                const selection = d3.select(this);
                const clicked = selection.classed("clicked")
                CI.IV_selection.selectAll("rect.bar").classed("clicked", false)
                selection.classed("clicked", !clicked)
                if (CI.CV_dash.IV_filters_list.indexOf(datum.key) !== -1) {
                    if (!clicked) {
                        CI.CV_dash.filterData({keyId: datum.key, values: [datum.unique_key]})
                    } else {
                        CI.CV_dash.filterData({keyId: datum.key, values: true})
                    }
                }

            })

        barEnter
            .attr("x", function (d) {
                return CI.IV_d3_x(d.unique_key);
            })
            .attr("y", function (d) {
                return CI.CV_height
            })
            .attr("width", CI.IV_d3_x.bandwidth())
            .attr("height", function (d) {
                return CI.CV_height - CI.IV_d3_y(d.count);
            });

        const barUpdate = barEnter.merge(bar);

        barUpdate
            .transition()
            .duration(CI.CV_dash.IV_transition_duration)
            .attr("x", function (d) {
                return CI.IV_d3_x(d.unique_key);
            })
            .attr("y", function (d) {
                return CI.IV_d3_y(d.count);
            })
            .attr("width", CI.IV_d3_x.bandwidth())
            .attr("height", function (d) {
                return CI.CV_height - CI.IV_d3_y(d.count);
            })
            .style("stroke", function () {
                return d3.select(this).classed("clicked") ? "black" : "transparent"
            })

        //// </end> drawing bar chart
    }

    appendChartMix(chartExtracts) {
        const CI = this;

        CI.IV_chart_mix = chartExtracts;

        const chartList = CI.IV_selection.append("div").classed("chart_mix", true).append("ul").classed("list-group", true)

        CI.IV_chart_mix.forEach((d, i) => {
            const selection = chartList.append("li").classed("list-group-item", true).on("click", function () {
                CI.CV_focus.select("g.axis.axis--x").classed("ticksHidden", d.ticksHidden === true).select("text").text(d.xLabel)
                CI.CV_focus.select("g.axis.axis--y").select("text").text(d.yLabel)
                CI.IV_bar_color = d.barColor;
                CI.setupData(d.extract)
                CI.update()

                d3.select(this).select("input").property("checked", true)
            })

            selection.append("input")
                .property("type", "radio")
                .property("name", CI.IV_selection.attr("id"))
                .property("checked", i === 0)

            selection.append("span").html(d.id)

        })

    }
}

class PieChart {
    constructor(dash) {
        const CI = this;
        CI.CV_dash = dash;

        CI.IV_selection_id = "";
        CI.IV_selection = null;
        CI.CV_svg = {};
        CI.CV_focus = {}
        CI.CV_svgGroup = {};
        CI.CV_margin = {};
        CI.CV_width = 0
        CI.CV_height = 0;
        CI.CV_pie_radius = 0;
        CI.CV_d3_z = {};


        CI.IV_tooltip = {};

        CI.IV_data_stash = [];
        CI.IV_extract = [];

        CI.IV_data_len = 0;
    }

    loadElements(elm_id) {
        const CI = this;

        CI.IV_selection_id = elm_id
        CI.IV_selection = d3.select("#" + elm_id)
        if (CI.IV_selection._groups[0][0] === null) console.log("selection failed, no element id: " + elm_id)
        //// set dimensions
        CI.CV_svg = CI.IV_selection.append("svg").attr("width", 400).attr("height", 350);

        CI.CV_margin = {top: 20, right: 20, bottom: 40, left: 150};
        CI.CV_width = +CI.CV_svg.attr("width") - CI.CV_margin.left - CI.CV_margin.right;
        CI.CV_height = +CI.CV_svg.attr("height") - CI.CV_margin.top - CI.CV_margin.bottom;

        CI.CV_d3_z = d3.scaleOrdinal(d3.schemeCategory20c);
        CI.CV_pie_radius = Math.min(CI.CV_width, CI.CV_height) / 2;

        const randomId = Math.random();
        CI.CV_svg.append("defs").append("clipPath")  // clip path for zoom function
            .attr("id", randomId)
            .append("rect")
            .attr("width", CI.CV_width)
            .attr("height", CI.CV_height);

        CI.CV_focus = CI.CV_svg.append("g")
            .attr("class", "focus")
            .attr("transform", "translate(" + CI.CV_margin.left + "," + CI.CV_margin.top + ")")

        // CI.CV_focus.append("rect")
        //     .attr("class", "zoom")
        //     .attr("width", CI.CV_width)
        //     .attr("height", CI.CV_height)

        CI.CV_svgGroup = CI.CV_focus.append("g")
            .classed("svgGroup", true)
            .attr("transform", "translate(" + CI.CV_width / 2 + "," + CI.CV_height / 2 + ")")
        // .style("clip-path", "url(#" + randomId + ")")

        CI.IV_tooltip = d3.select("div.tooltip")

        CI.IV_d3_arc = d3.arc()
            .innerRadius(0) // none for pie chart
            .outerRadius(CI.CV_pie_radius); // size of overall chart

        CI.IV_d3_pie = d3.pie() // start and end angles of the segments
            .value(function (d) {
                return d.count;
            }) // how to extract the numerical data from each entry in our dataset
            .sort(null); // by default, data sorts in descending value. this will mess with our animation so we set it to null


        const legend = CI.IV_selection.append("div").attr("id", "legend")
        legend.append("button").classed("show_all", true).html("show all")
        legend.append("button").classed("hide_all", true).html("hide all")
        legend.append("div").classed("content2", true)
    }


    setupData(extract) {
        const CI = this;

        if (!extract) {
            if (!CI.IV_extract) console.log("no extract")
        } else {
            CI.IV_extract = extract;
        }

        const data = CI.CV_dash.IV_filtered_data;

        CI.IV_data_stash = [];
        data.forEach(d => {

            const k = CI.IV_extract.key.id,
                v = CI.IV_extract.value.id,
                unique_key = CI.IV_extract.key.self ? k : d[k];
            let element = CI.IV_data_stash.find(d0 => d0.unique_key === unique_key)
            if (!element) {
                CI.IV_data_stash.push({
                    [k]: unique_key,
                    unique_key: unique_key,
                    key: k,
                    values: [],
                    keyLabel: CI.IV_extract.key.label,
                    positive: CI.IV_extract.key.positive,
                    valueLabel: CI.IV_extract.value.label,
                    to_filter: {
                        k: k,
                        v: (CI.IV_extract.key.self ? CI.IV_extract.key.positive : d[k]),
                        label: CI.IV_extract.key.label
                    },
                    enabled: CI.CV_dash.IV_filters.find(d0 => d0.keyId === k).values.find(d1 => d1.val === unique_key).enabled
                })
            }
            element = CI.IV_data_stash.find(d0 => d0.unique_key === unique_key)

            if (d.enabled) element.values.push(d[v])

        })

        CI.IV_data_stash.forEach(d => {
            if (d.positive === true) d.count = d.values.length
            else d.count = d.values.filter(v => v === d.positive).length
        })

        CI.IV_data_len = data.length;
    }

    update(initial = false) {
        const CI = this;

        var legendRectSize = 25; // defines the size of the colored squares in legend
        var legendSpacing = 6; // defines spacing between squares


        var color = CI.CV_d3_z


// creating the chart
        var path = CI.CV_svgGroup.selectAll('g.arc') // select all path elements inside the svg. specifically the 'g' element. they don't exist yet but they will be created below
            .data(CI.IV_d3_pie(CI.IV_data_stash)) //associate dataset wit he path elements we're about to create. must pass through the pie function. it magically knows how to extract values and bakes it into the pie

        path.exit().remove()

        const pathEnter = path
            .enter() //creates placeholder nodes for each of the values
            .append("g")
            .attr("class", "arc")

        pathEnter
            .append('path') // replace placeholders with path elements
            .attr("class", "pie")

        pathEnter
            .append("text")

        const pathUpdate = pathEnter.merge(path)

        pathUpdate
            .select("path.pie")
            .attr('d', CI.IV_d3_arc) // define d attribute with arc function above
            .attr('fill', function (d) {
                return color(d.data[d.data.key]);
            }) // use color scale to define fill of each label in dataset
            .each(function (d) {
                this._current - d;
            }); // creates a smooth animation for each track


        pathUpdate
            .select("path.pie")
            .on('mouseover', function (d) {  // when mouse enters div
                var total = d3.sum(CI.IV_data_stash.map(function (d) {
                    return d.count
                }));
                var percent = Math.round(1000 * d.data.count / total) / 10; // calculate percent
                CI.IV_tooltip.select('.label').html(CI.IV_extract.key.label + ": " + d.data[d.data.key]); // set current label
                CI.IV_tooltip.select('.count').html(d.data.count + " " + d.data.valueLabel); // set current count
                CI.IV_tooltip.select('.percent').html(percent + '% of total displayed'); // set percent calculated above
                CI.IV_tooltip.style('display', 'block'); // set display
            })
            .on('mouseout', function () { // when mouse leaves div
                CI.IV_tooltip.style('display', 'none'); // hide tooltip for that element
            })
            .on('mousemove', function (d) { // when mouse moves
                CI.IV_tooltip.style('top', (d3.event.pageY + 10) + 'px') // always 10px below the cursor
                    .style('left', (d3.event.pageX + 10) + 'px'); // always 10px to the right of the mouse
            })
            .on("click", d => updatePie(d.data));


        pathUpdate.select("text")
            .text(function(d) {
                var total = d3.sum(CI.IV_data_stash.map(function (d) {
                    return d.count
                }));
                var percent = Math.round(1000 * d.data.count / total) / 10; // calculate percent
                return percent > 2 ? percent + "%" : "" })
            .style("fill", "#fff")
            .transition() // transition of redrawn pie
            .duration(CI.CV_dash.IV_transition_duration)
            .attr("transform", function(d) {
                let pos = CI.IV_d3_arc.centroid(d), x = pos[0], y = pos[1];
                x*=1.5;y*=1.5
                return "translate(" + x + ", " + y + ")";
            })

        ////// build legend
        var legend = CI.IV_selection.select("div#legend").select("div.content2").selectAll('.legend') // selecting elements with class 'legend'
            .data(CI.IV_data_stash) // refers to an array of labels from our dataset

        legend.exit().remove()

        const legendEnter = legend
            .enter() // creates placeholder
            .append('div') // replace placeholders with g elements
            .attr('class', 'legend') // each g is given a legend class

        // adding colored squares to legend
        legendEnter.append('div') // append rectangle squares to legend
            .classed("rect", true)
            .classed('disabled', false)
            .style('min-width', legendRectSize + "px") // width of rect size is defined above
            .style('height', legendRectSize + "px") // height of rect size is defined above
            .html("<span class='plus'>+</span><span class='minus'>-</span>")

        legendEnter.append('span')
            .classed("text", true)

        const legendUpdate = legendEnter.merge(legend);

        legendUpdate
            .select(".rect")
            .style('background-color', d => color(d[d.key])) // each fill is passed a color
            .style('border-color', d => color(d[d.key])) // each stroke is passed a color
            .classed("disabled", d => {
                return !d.enabled
            })
            .on('click', d => updatePie(d));

        legendUpdate
            .select("span.text")
            .html(function (d) {
                return d[d.key];
            }); // return label
        ////// </end> build legend

        //// update pie with click on the colored rect or by hide_all, show_all buttons
        function updatePie(datum) {

            if (CI.CV_dash.IV_filters_list.indexOf(CI.IV_extract.key.id) !== -1) {
                CI.CV_dash.IV_filters.forEach(v => {
                    if (v.keyId === CI.IV_extract.key.id) {
                        v.values.forEach(v => {
                            if (v.val === datum[CI.IV_extract.key.id]) {
                                v.enabled = !v.enabled
                            }
                        })
                    }
                });
                CI.CV_dash.filterData(false)
            }
        }

        CI.IV_selection.select("div#legend").select("button.show_all")
            .on("click", () => CI.CV_dash.filterData({keyId: CI.IV_extract.key.id, values: true}))

        CI.IV_selection.select("div#legend").select("button.hide_all")
            .on("click", () => CI.CV_dash.filterData({keyId: CI.IV_extract.key.id, values: false}))

        //// update pie with click on the colored rect or by hide_all, show_all buttons

        //// remove all add all so we can have animation on start

        const drawTransition = () => {
            pathUpdate // update pie with new data
                .select("path.pie")
                .transition() // transition of redrawn pie
                .duration(CI.CV_dash.IV_transition_duration)
                .attrTween('d', function (d) { // 'd' specifies the d attribute that we'll be animating
                    var interpolate = d3.interpolate(this._current, d); // this = current path element
                    this._current = interpolate(0); // interpolate between current value and the new value of 'd'
                    return function (t) {
                        return CI.IV_d3_arc(interpolate(t));
                    };
                });
        }
        drawTransition()
        //// </end> remove all add all so we can have animation on start
    }


}

class CandleSticksChart {

    constructor() {
        const CI = this;
        CI.CV_dash = dash;

        CI.IV_selection = null;
        CI.CV_svg = {};
        CI.CV_focus = {}
        CI.CV_svgGroup = {};
        CI.CV_margin = {};
        CI.CV_width = 0
        CI.CV_height = 0;

        CI.IV_d3_x = {};  // changing x domain to scaleBand
        CI.IV_d3_y = {};

        CI.IV_d3_xAxis = {};
        CI.IV_d3_yAxis = {};

        CI.IV_tooltip = {};

        CI.IV_data_stash = [];
        CI.IV_extract = [];

        CI.IV_data_len = 0;
        CI.IV_table = {};
    }

    loadElements(elm_id, x_label, y_label) {
        const CI = this;
        //// set dimensions
        CI.IV_selection = d3.select("#" + elm_id)
        if (CI.IV_selection._groups[0][0] === null) console.log("selection failed, no element id: " + elm_id)
        CI.CV_svg = CI.IV_selection.append("svg").attr("width", 400).attr("height", 250);

        CI.CV_margin = {top: 20, right: 20, bottom: 40, left: 70};
        CI.CV_width = +CI.CV_svg.attr("width") - CI.CV_margin.left - CI.CV_margin.right;
        CI.CV_height = +CI.CV_svg.attr("height") - CI.CV_margin.top - CI.CV_margin.bottom;

        CI.IV_d3_x = d3.scalePoint().rangeRound([0, CI.CV_width]).padding(.5);  // changing x domain to scaleBand
        CI.IV_d3_y = d3.scaleLinear().range([CI.CV_height, 0]);

        CI.IV_d3_xAxis = d3.axisBottom(CI.IV_d3_x);
        CI.IV_d3_yAxis = d3.axisLeft(CI.IV_d3_y);

        const randomId = Math.random();
        CI.CV_svg.append("defs").append("clipPath")  // clip path for zoom function
            .attr("id", randomId)
            .append("rect")
            .attr("width", CI.CV_width)
            .attr("height", CI.CV_height);

        CI.CV_focus = CI.CV_svg.append("g")
            .attr("class", "focus")
            .attr("transform", "translate(" + CI.CV_margin.left + "," + CI.CV_margin.top + ")")

        // CI.CV_focus.append("rect")
        //     .attr("class", "zoom")
        //     .attr("width", CI.CV_width)
        //     .attr("height", CI.CV_height)

        CI.CV_svgGroup = CI.CV_focus.append("g")
            .classed("svgGroup", true)
            .style("clip-path", "url(#" + randomId + ")");

        CI.CV_focus.append("g")
            .attr("class", "axis axis--x")
            .attr("transform", "translate(0," + CI.CV_height + ")")
            .append("text")
            // .attr("transform", "translate(" + width+30 +"," + 0 + ")")
            .attr("x", CI.CV_width / 2)
            .attr("y", 20)
            .attr("dy", "0.71em")
            .attr("fill", "#000")
            .style("font-size", "1.9em")
            .style("text-anchor", "middle")
            .text(x_label);

        CI.CV_focus.append("g")
            .attr("class", "axis axis--y")

        CI.CV_focus.select("g.axis.axis--y")
            .append("text")
            .attr("transform", "rotate(-90)")
            .attr("y", -45)
            .attr("x", -CI.CV_height / 2)
            .attr("dy", "0.71em")
            .attr("fill", "#000")
            .style("font-size", "1.8em")
            .style("text-anchor", "middle")
            .text(y_label);

        CI.IV_tooltip = d3.select("div.tooltip")

        const reference = CI.IV_selection
            .append("div")
            .classed("reference", true)
            .style("position", "absolute")
            .style("right", "15px")
            .style("top", "60px")

        reference
            .append("p")
            .html("Reference points:")

        const temp1 = reference
            .append("div")
            .style("position", "relative")

        temp1
            .append("span")
            .classed("ref_line", true)
            .style("width", "2.2em")
            .style("height", ".16em")
            .style("background-color", "black")
            .style("position", "absolute")
            .style("left", 0)
            .style("top", ".6em")

        temp1
            .append("span")
            .style("position", "absolute")
            .style("left", "2.6em")
            .html("Median")

        CI.IV_table = CI.IV_selection.append("div")
            .attr("class", "container-fluid table")

        const rows = "<div class='col col-sm-4'>title</div><div class='col col-sm-4'></div><div class='col col-sm-4'></div>"

        CI.IV_table.append("div").attr("class", "row head").html(rows.replace("title", ""))
        CI.IV_table.append("div").attr("class", "row count").html(rows.replace("title", "Count"))
        CI.IV_table.append("div").attr("class", "row median").html(rows.replace("title", "Median"))
        CI.IV_table.append("div").attr("class", "row outliers").html(rows.replace("title", "Outliers"))


    }

    setupData(extract) {
        const CI = this;

        if (!extract) {
            if (!CI.IV_extract) console.log("no extract")
        } else {
            CI.IV_extract = extract;
        }

        const data = CI.CV_dash.IV_filtered_data;

        CI.IV_data_stash = []
        data.forEach(d => {

            const k = CI.IV_extract.key.id,
                v = CI.IV_extract.value.id,
                unique_key = CI.IV_extract.key.self ? k : d[k];
            let element = CI.IV_data_stash.find(d0 => d0.unique_key === unique_key)
            if (!element) {
                CI.IV_data_stash.push({
                    [k]: unique_key,
                    unique_key: unique_key,
                    key: k,
                    count: 0,
                    all_count: 0,
                    values: [],
                    all_values: [],
                    keyLabel: CI.IV_extract.key.label,
                    positive: CI.IV_extract.key.positive,
                    valueLabel: CI.IV_extract.value.label
                })
            }
            element = CI.IV_data_stash.find(d0 => d0.unique_key === unique_key)

            if (d.enabled) element.values.push(d[v])

            //// calculate all_values count for stable y axis
            element.all_values.push(d[v])
            //// </end> calculate all_values count for stable y axis

        })

        CI.IV_data_stash.forEach(d => {
            if (d.positive === true) d.count = d.values.length
            else d.count = d.values.filter(v => v === d.positive).length
        })

        CI.IV_data_len = data.length;

        CI.IV_data_stash.forEach(d => {
            d.std = 0;
            d.mean = 0;
            d.outliers = 0;
            if (d.values.length === 0) return
            d.std = d3.deviation(d.values, v => v);
            d.mean = d3.median(d.values, v => v);
            d.outliers = d.values.filter(v => (v < d.mean + d.std / 2) && (v > d.mean - d.std / 2)).length
            //// calculate all_values count for stable y axis
            d.all_std = d3.deviation(d.all_values, v => v);
            d.all_mean = d3.median(d.all_values, v => v);
            //// </end> calculate all_values count for stable y axis
        })


    }

    update() {
        const CI = this;

        CI.IV_d3_x.domain(CI.IV_data_stash.map(function (d) {
            return d[d.key];
        }));

        CI.IV_d3_y.domain([
            d3.min(CI.IV_data_stash, d => d3.min(d.all_values, d0 => d0)) * .99,
            d3.max(CI.IV_data_stash, d => d3.max(d.all_values, d0 => d0))* 1.01
        ]);

        CI.IV_d3_xAxis = d3.axisBottom(CI.IV_d3_x);
        CI.IV_d3_yAxis = d3.axisLeft(CI.IV_d3_y);

        CI.CV_focus.select("g.axis.axis--x")
            .transition()
            .duration(CI.CV_dash.IV_transition_duration)
            .call(CI.IV_d3_xAxis)

        CI.CV_focus.select("g.axis.axis--y")
            .transition()
            .duration(CI.CV_dash.IV_transition_duration)
            .call(CI.IV_d3_yAxis)
        //// </end> setting up domains on axises


        //// drawing bar chart
        const candle = CI.CV_svgGroup.selectAll("g.candle")
            .data(CI.IV_data_stash)

        candle.exit().remove()

        const candleEnter = candle
            .enter().append("g")
            .attr("class", "candle")
            .on('mouseover', function (d) {  // when mouse enters div
                CI.IV_tooltip.select('.label').html(CI.IV_extract.key.label + ": " + d.unique_key); // set current count
                CI.IV_tooltip.select('.count').html("Median: " + d.mean.toFixed(2)); // set percent calculated above
                CI.IV_tooltip.select('.percent').html("Std: " + d.std.toFixed(2)); // set percent calculated above
                CI.IV_tooltip.style('display', 'block'); // set display
            })
            .on('mouseout', function () { // when mouse leaves div
                CI.IV_tooltip.style('display', 'none'); // hide tooltip for that element
            })
            .on('mousemove', function (d) { // when mouse moves
                CI.IV_tooltip.style('top', (d3.event.pageY + 10) + 'px') // always 10px below the cursor
                    .style('left', (d3.event.pageX + 10) + 'px'); // always 10px to the right of the mouse
            });

        candleEnter
            .append("line")
            .classed("std", true)
            .attr("x1", d => CI.IV_d3_x(d[d.key]))
            .attr("x2", d => CI.IV_d3_x(d[d.key]))
            .attr("y1", d => CI.IV_d3_y(d.mean))
            .attr("y2", d => CI.IV_d3_y(d.mean))
            .style("stroke", "green")
            .style("stroke-width", "2px")

        candleEnter
            .append("line")
            .classed("mean", true)
            .attr("x1", d => CI.IV_d3_x(d[d.key]))
            .attr("x2", d => CI.IV_d3_x(d[d.key]))
            .attr("y1", d => CI.IV_d3_y(d.mean - 1))
            .attr("y2", d => CI.IV_d3_y(d.mean + 1))

        candleEnter
            .append("line")
            .classed("meanSlim", true)
            .attr("x1", d => CI.IV_d3_x(d[d.key]))
            .attr("x2", d => CI.IV_d3_x(d[d.key]))
            .attr("y1", d => CI.IV_d3_y(d.mean) - 1)
            .attr("y2", d => CI.IV_d3_y(d.mean) + 1)

        const candleUpdate = candleEnter.merge(candle);

        candleUpdate
            .select("line.std")
            .transition()
            .duration(CI.CV_dash.IV_transition_duration)
            .attr("x1", d => CI.IV_d3_x(d[d.key]))
            .attr("x2", d => CI.IV_d3_x(d[d.key]))
            .attr("y1", d => CI.IV_d3_y(d.mean - d.std / 2))
            .attr("y2", d => CI.IV_d3_y(d.mean + d.std / 2))

        candleUpdate
            .select("line.mean")
            .transition()
            .duration(CI.CV_dash.IV_transition_duration)
            .attr("x1", d => CI.IV_d3_x(d[d.key]))
            .attr("x2", d => CI.IV_d3_x(d[d.key]))
            .attr("y1", d => CI.IV_d3_y(d.mean - 1))
            .attr("y2", d => CI.IV_d3_y(d.mean + 1))
            .style("stroke", "green")
            .style("stroke-width", "30px")

        candleUpdate
            .select("line.meanSlim")
            .transition()
            .duration(CI.CV_dash.IV_transition_duration)
            .attr("x1", d => CI.IV_d3_x(d[d.key]))
            .attr("x2", d => CI.IV_d3_x(d[d.key]))
            .attr("y1", d => CI.IV_d3_y(d.mean) - 1)
            .attr("y2", d => CI.IV_d3_y(d.mean) + 1)
            .style("stroke", "white")
            .style("stroke-width", "30px")


        //// </end> drawing candleStick chart

        CI.IV_table.select("div.head").selectAll("div.col")
            .each(function (_, i) {
                if (0 === i) return
                d3.select(this).html(CI.IV_data_stash[i - 1].unique_key)
            })

        CI.IV_table.select("div.count").selectAll("div.col")
            .each(function (_, i) {
                if (0 === i) return
                d3.select(this).html(CI.IV_data_stash[i - 1].count)
            })

        CI.IV_table.select("div.median").selectAll("div.col")
            .each(function (_, i) {
                if (0 === i) return
                d3.select(this).html(CI.IV_data_stash[i - 1].mean)
            })

        CI.IV_table.select("div.outliers").selectAll("div.col")
            .each(function (_, i) {
                if (0 === i) return
                d3.select(this).html(CI.IV_data_stash[i - 1].outliers)
            })
    }

}

class TableElement {
    constructor(dash) {
        const CI = this;
        CI.CV_dash = dash;

        CI.IV_parent_selection = CI.CV_dash.IV_table_selection;

        CI.IV_selection_id = "";
        CI.IV_selection = null;

        CI.IV_semafor = {};

        CI.IV_extract = {};

    }

    loadElements(label, icon) {
        const CI = this;

        CI.IV_selection_id = CI.CV_dash.IV_table_selection.attr("id");

        CI.IV_selection = CI.IV_parent_selection
            .append("div")
            .attr("class", "table-item col-lg-3 col-xs-6")
            .classed("_" + CI.CV_dash.IV_table_elements.length, true)
            .html(
                "<div class='small-box bg-aqua' >" +
                "<div class='item-body   '>" +
                "<div class='semafor '></div>" +
                "<div class='semafor_enabled'></div>" +
                "<span class='icon'>" + (icon ? "<img src='" + icon + "'>" : "") + "</span>" +
                "<div class='label'>" + label + "</div>" +
                "</div>" +
                "<div class='footer'>More info</div>" +
                "</div>"
            );

        CI.IV_selection.select(".small-box").on("click", function () {
            const selection = CI.IV_selection;
            const clicked = selection.classed("clicked")
            CI.CV_dash.IV_table_selection.selectAll(".table-item").classed("clicked", false)
            selection.classed("clicked", !clicked)
            // if (!clicked) {
            //     CI.CV_dash.filterData(CI.IV_selection_id, CI.IV_extract.to_filter)
            // } else {
            //     CI.CV_dash.filterData(CI.IV_selection_id, {})
            // }

            if (CI.CV_dash.IV_table_filter && CI.CV_dash.IV_table_filter.k === CI.IV_extract.key.id) CI.CV_dash.IV_table_filter = null
            else CI.CV_dash.IV_table_filter = {k: CI.IV_extract.key.id, v: CI.IV_extract.key.positive};
            CI.CV_dash.filterData(false)


        })

        CI.IV_semafor = CI.IV_selection.select(".semafor")

        return CI;
    }

    setupData(extract) {
        const CI = this;
        CI.IV_extract = extract
        CI.IV_extract.to_filter = {
            k: CI.IV_extract.key.id,
            v: CI.IV_extract.key.positive,
            label: CI.IV_extract.key.label
        };

        return CI;
    }

    update() {
        const CI = this;

        const k = CI.IV_extract.key.id, positive = CI.IV_extract.key.positive;
        const total_count = CI.CV_dash.IV_filtered_data.length
        const total_enabled = CI.CV_dash.IV_filtered_data.filter(d => d.enabled).length;
        const extract_total = CI.CV_dash.IV_filtered_data.filter(d => d[k] === positive).length
        const extract_enabled = CI.CV_dash.IV_filtered_data.filter(d => d[k] === positive && d.enabled).length
        const percent_total = Math.round((extract_total / total_count) * 100);
        const percent_enabled = Math.round((extract_enabled / total_enabled) * 100);

        if (CI.IV_extract.key.id !== "total") {
            CI.IV_semafor.html(extract_total + " (" + percent_total + "%)")
            CI.IV_selection.select(".semafor_enabled").html(extract_enabled + " displayed")
        } else {
            CI.IV_semafor.html(total_count + " (" + 100 + "%)")
            CI.IV_selection.select(".semafor_enabled").html(total_enabled + " displayed")
        }
    }
}

const dash = new Dashboard()
const barChart1 = new BarChart(dash);
const pieChar1 = new PieChart(dash);
const candleSticksChart = new CandleSticksChart(dash);
const barChart2 = new BarChart(dash);
const barChart3 = new BarChart(dash);
const barChart4 = new BarChart(dash);

dash.IV_all_charts = [barChart1, pieChar1, candleSticksChart, barChart2, barChart3, barChart4];

(function (url) {
    d3.csv(url, function (error, data) {
        if (error) throw error;

        dash.loadData(data);
        dash.createFilters(
            [
                {keyId: "SITEID", keyLabel: "SITE"},
                {keyId: "SEX", keyLabel: "SEX"},
                {keyId: "RACE", keyLabel: "RACE"},
                {keyId: "ARM", keyLabel: "Planned Arm Code"},
				
            ]
        );

        //// element 1
        // (function() {
        //     barChart1.loadElements(
        //         "dashboard_elem_1",
        //         "Population",
        //         "Unique Count",
        //         "steelblue"
        //     )
        //
        //     barChart1.setupData(
        //         [
        //             {
        //                 key: {label: "SAFETY", id: "SAFFL", positive: "Y", self: true},
        //                 value: {label: "SAFETY", id: "SAFFL"}
        //             },
        //             {
        //                 key: {label: "Pharmacokinetic", id: "PKFL", positive: "Y", self: true},
        //                 value: {label: "Pharmacokinetic", id: "PKFL"},
        //             },
        //             {
        //                 key: {label: "EFFICAY", id: "EFFFL", positive: "Y", self: true},
        //                 value: {label: "EFFICAY", id: "EFFFL"}
        //             }
        //         ],
        //         true
        //     )
        //
        //     barChart1.update()
        // })();
        //// </end> element 1
        (function () {
            const chartsExtracts = [
                {
                    id: BMIVAR,
                    xLabel: "Subjects",
                    yLabel: "BMI",
                    barColor: "steelblue",
                    ticksHidden: true,
                    extract:
                        {
                            key: {label: "Subject", id: "SUBJID", positive: "value"},
                            value: {label: "BMI", id: BMIVAR}
                        }

                },
                {
                    id: HEIGHTVAR,
                    xLabel: "Subjects",
                    yLabel: "Height",
                    barColor: "steelblue",
                    ticksHidden: true,
                    extract:
                        {
                            key: {label: "Subject", id: "SUBJID", positive: "value"},
                            value: {label: "Height", id: HEIGHTVAR }
                        }

                },
                {
                    id: WEIGHTVAR,
                    xLabel: "Subjects",
                    yLabel: "Weight",
                    barColor: "steelblue",
                    ticksHidden: true,
                    extract:
                        {
                            key: {label: "Subject", id: "SUBJID", positive: "value"},
                            value: {label: "Weight", id: WEIGHTVAR }
                        }

                }
            ]

            barChart1.loadElements(
                "dashboard_elem_1",
                chartsExtracts[0].xLabel,
                chartsExtracts[0].yLabel,
                chartsExtracts[0].barColor,
                chartsExtracts[0].ticksHidden,
            )

            barChart1.setupData(
                chartsExtracts[0].extract
            )


            barChart1.appendChartMix(chartsExtracts)

        })();

        //// element 2
        (function () {
            pieChar1.loadElements("dashboard_elem_2")
            pieChar1.setupData(
                {
                    key: {label: "SITE", id: "SITEID", positive: true},
                    value: {label: "Subject", id: "SUBJID"},
                }
            )

        })();
        ////</end> element 2

        //// element 3
        (function () {
            candleSticksChart.loadElements(
                "dashboard_elem_3",
                "Sex",
                "Age"
            )

            candleSticksChart.setupData(
                {
                    key: {label: "SEX", id: "SEX", positive: true},
                    value: {label: "AGE", id: "AGE"},
                }
            )
        })();
        //// </end> element 3

        //// element 4
        (function () {
            barChart2.loadElements(
                "dashboard_elem_4",
                "Race",
                "Unique Count",
                "steelblue"
            )

            barChart2.setupData(
                {
                    key: {label: "RACE", id: "RACE", positive: true},
                    value: {label: "RACE", id: "RACE"}
                }
            )
        })();
        //// </end> element 4

        //// element 5
        (function () {
            barChart3.loadElements(
                "dashboard_elem_5",
                "Sex",
                "Unique Count",
                "red"
            )

            barChart3.setupData(
                {
                    key: {label: "SEX", id: "SEX", positive: true},
                    value: {label: "SEX", id: "SEX"}
                }
            )

        })();
        //// </end> element 5

        //// element 6
        (function () {
            barChart4.loadElements(
                "dashboard_elem_6",
                "Planned Arm Code",
                "Unique Count",
                "lightblue"
            )

            barChart4.setupData(
                {
                    key: {label: "Planned Arm Code", id: "ARM", positive: true},
                    value: {label: "Planned Arm Code", id: "ARM"}
                }
            )

        })();
        //// </end> element 6

        //// table

        dash.appendTable([
                {
                    key: {label: "TOTAL", id: "total", positive: "Y", self: true},
                    value: {label: "total", id: "total"}
                },
                {
                    key: {label: "SAFETY", id: FLAGSAF , positive: "Y", self: true},
                    value: {label: "SAFETY", id: FLAGSAF }
                },
                {
                    key: {label: "Pharmacokinetic", id: "PKFL", positive: "Y", self: true},
                    value: {label: "Pharmacokinetic", id: "PKFL"},
                },
                {
                    key: {label: "EFFICAY", id: FLAGEFF, positive: "Y", self: true},
                    value: {label: "EFFICAY", id: FLAGEFF}
                }
            ]
        )


        dash.update()

    });
})('/static/tmpdata/ADSL.csv');

document.getElementById("download").addEventListener("click", function () {

    html2canvas(document.querySelector('#dashboard')).then(function (canvas) {

        saveAs(canvas.toDataURL(), 'chart.png');
    });
});


function saveAs(uri, filename) {

    var link = document.createElement('a');

    if (typeof link.download === 'string') {

        link.href = uri;
        link.download = filename;

        //Firefox requires the link to be in the body
        document.body.appendChild(link);

        //simulate click
        link.click();

        //remove the link when done
        document.body.removeChild(link);

    } else {

        window.open(uri);

    }
}