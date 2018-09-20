 
			
 		
			
(function(global, factory) {
    typeof exports === 'object' && typeof module !== 'undefined'
        ? (module.exports = factory(require('webcharts'), require('d3')))
        : typeof define === 'function' && define.amd
          ? define(['webcharts', 'd3'], factory)
          : (global.simpleCharts = factory(global.webCharts, global.d3));
})(this, function(webcharts, d3$1) {
    'use strict';

    if (typeof Object.assign != 'function') {
        // Must be writable: true, enumerable: false, configurable: true
        Object.defineProperty(Object, 'assign', {
            value: function assign(target, varArgs) {
                // .length of function is 2
                'use strict';

                if (target == null) {
                    // TypeError if undefined or null
                    throw new TypeError('Cannot convert undefined or null to object');
                }

                var to = Object(target);

                for (var index = 1; index < arguments.length; index++) {
                    var nextSource = arguments[index];

                    if (nextSource != null) {
                        // Skip over if undefined or null
                        for (var nextKey in nextSource) {
                            // Avoid bugs when hasOwnProperty is shadowed
                            if (Object.prototype.hasOwnProperty.call(nextSource, nextKey)) {
                                to[nextKey] = nextSource[nextKey];
                            }
                        }
                    }
                }

                return to;
            },
            writable: true,
            configurable: true
        });
    }

    if (!Array.prototype.find) {
        Object.defineProperty(Array.prototype, 'find', {
            value: function value(predicate) {
                // 1. Let O be ? ToObject(this value).
                if (this == null) {
                    throw new TypeError('"this" is null or not defined');
                }

                var o = Object(this);

                // 2. Let len be ? ToLength(? Get(O, 'length')).
                var len = o.length >>> 0;

                // 3. If IsCallable(predicate) is false, throw a TypeError exception.
                if (typeof predicate !== 'function') {
                    throw new TypeError('predicate must be a function');
                }

                // 4. If thisArg was supplied, let T be thisArg; else let T be undefined.
                var thisArg = arguments[1];

                // 5. Let k be 0.
                var k = 0;

                // 6. Repeat, while k < len
                while (k < len) {
                    // a. Let Pk be ! ToString(k).
                    // b. Let kValue be ? Get(O, Pk).
                    // c. Let testResult be ToBoolean(? Call(predicate, T, � kValue, k, O �)).
                    // d. If testResult is true, return kValue.
                    var kValue = o[k];
                    if (predicate.call(thisArg, kValue, k, o)) {
                        return kValue;
                    }
                    // e. Increase k by 1.
                    k++;
                }

                // 7. Return undefined.
                return undefined;
            }
        });
    }

    if (!Array.prototype.findIndex) {
        Object.defineProperty(Array.prototype, 'findIndex', {
            value: function value(predicate) {
                // 1. Let O be ? ToObject(this value).
                if (this == null) {
                    throw new TypeError('"this" is null or not defined');
                }

                var o = Object(this);

                // 2. Let len be ? ToLength(? Get(O, "length")).
                var len = o.length >>> 0;

                // 3. If IsCallable(predicate) is false, throw a TypeError exception.
                if (typeof predicate !== 'function') {
                    throw new TypeError('predicate must be a function');
                }

                // 4. If thisArg was supplied, let T be thisArg; else let T be undefined.
                var thisArg = arguments[1];

                // 5. Let k be 0.
                var k = 0;

                // 6. Repeat, while k < len
                while (k < len) {
                    // a. Let Pk be ! ToString(k).
                    // b. Let kValue be ? Get(O, Pk).
                    // c. Let testResult be ToBoolean(? Call(predicate, T, � kValue, k, O �)).
                    // d. If testResult is true, return k.
                    var kValue = o[k];
                    if (predicate.call(thisArg, kValue, k, o)) {
                        return k;
                    }
                    // e. Increase k by 1.
                    k++;
                }

                // 7. Return -1.
                return -1;
            }
        });
    }

    Math.log10 = Math.log10 =
        Math.log10 ||
        function(x) {
            return Math.log(x) * Math.LOG10E;
        };			
			
			

 

var defaultSettings = {
        //Custom settings for this template
 
        id_col: 'USUBJID',
		value_col: sdtmvar ,
        time_settings: {
            value_col: sdtmvar ,
            label: sdtmvar,
            order: null, // x-axis domain order (array)
            rotate_tick_labels: true,
            vertical_space: 100 },
			
        start_value: null,
        details: null,
        //Standard webcharts settings
        x: {
            column: null, // set in syncSettings()
            type: 'ordinal',
            label: null,
            behavior: 'flex',
            sort: 'alphabetical-ascending',
             
			
        },
        y: {
            type: 'linear',
            label: null,
            behavior: 'flex',
            format: '0.2f'
        },
        marks: [{
            type: 'bar',
			per: [], // set in syncSettings()
			summarizeY: 'count',
            tooltip:sdtmvar2,
            attributes: {
                'stroke-opacity': 0.8
                
            }
        }],
         
        color_by: null, // set in syncSettings()
        resizable: true,
        gridlines: 'y',
        aspect: 2
    };


                
      
 
     // Replicate settings in multiple places in the settings object
    function syncSettings(settings) {
        settings.x.column = settings.time_settings.value_col;
        settings.x.label = settings.time_settings.label;
        settings.x.order = settings.time_settings.order;
	    settings.marks[0].per[0] = settings.time_settings.value_col;

		
		//Define default details.
        var defaultDetails = [{ value_col: settings.id_col, label: 'Subject Identifier' }];
       
        defaultDetails.push(  { value_col: settings.value_col, label: 'Result' });
       

        //If [settings.details] is not specified:
        if (!settings.details) settings.details = defaultDetails;
        else {
            //If [settings.details] is specified:
            //Allow user to specify an array of columns or an array of objects with a column property
            //and optionally a column label.
            settings.details.forEach(function(detail) {
                if (
                    defaultDetails
                        .map(function(d) {
                            return d.value_col;
                        })
                        .indexOf(detail.value_col ? detail.value_col : detail) === -1
                )
                    defaultDetails.push({
                        value_col: detail.value_col ? detail.value_col : detail,
                        label: detail.label
                            ? detail.label
                            : detail.value_col ? detail.value_col : detail
                    });
            });
            settings.details = defaultDetails;
        }

        return settings;
    }
 
 
  
 
 
 
  function countParticipants() {
        var _this = this;

        this.populationCount = d3$1
            .set(
                this.raw_data.map(function(d) {
                    return d[_this.config.id_col];
                })
            )
            .values().length;
    }
 
 
 
 
 
 
 
 
 
 
 
function onInit() {
        var _this = this;
        var config = this.config;
		 // 1. Count total participants prior to data cleaning.
        countParticipants.call(this);
    };

	
	

function onLayout() {
        //Add population count.
        d3.select('.wc-controls').append('span').attr({ 'id': 'populationCount' });
        //Add footnote.
        this.wrap.insert('p', '.wc-chart').attr('class', 'annote').text('Click a bar for details.');
    }	
	
	

function onPreprocess() {
        var _this = this; 	
    }
 
 
function onResize() {
        var _this = this;
        var config = this.config;

        //Rotate x-axis tick labels.
        if (config.time_settings.rotate_tick_labels) this.svg.selectAll('.x.axis .tick text').attr({ 'transform': 'rotate(-45)',
            'dx': -10,
            'dy': 10 }).style('text-anchor', 'end');
    }

	 function getCurrentMeasure() {
        var _this = this;
    }

    function defineMeasureData() {
        var _this = this;
    }

    function setXdomain() {
        if (this.currentMeasure !== this.previousMeasure)
            // new measure
            this.config.x.domain = this.measure_domain;
        else if (this.config.x.domain[0] > this.config.x.domain[1])
            // invalid domain
            this.config.x.domain.reverse();
        else if (this.config.x.domain[0] === this.config.x.domain[1])
            // domain with zero range
            this.config.x.domain = this.config.x.domain.map(function(d, i) {
                return i === 0 ? d - d * 0.01 : d + d * 0.01;
            });
    }

    function setXaxisLabel() {
        this.config.x.label =
            this.currentMeasure +
            (this.config.unit_col && this.measure_data[0][this.config.unit_col]
                ? ' (' + this.measure_data[0][this.config.unit_col] + ')'
                : '');
    }

    function setXprecision() {
        var _this = this;

        //Calculate range of current measure and the log10 of the range to choose an appropriate precision.
        this.config.x.range = this.config.x.domain[1] - this.config.x.domain[0];
        this.config.x.log10range = Math.log10(this.config.x.range);
        this.config.x.roundedLog10range = Math.round(this.config.x.log10range);
        this.config.x.precision1 = -1 * (this.config.x.roundedLog10range - 1);
        this.config.x.precision2 = -1 * (this.config.x.roundedLog10range - 2);

        //Define the format of the x-axis tick labels and x-domain controls.
        this.config.x.format =
            this.config.x.log10range > 0.5 ? '1f' : '.' + this.config.x.precision1 + 'f';
        this.config.x.d3_format = d3.format(this.config.x.format);
        this.config.x.formatted_domain = this.config.x.domain.map(function(d) {
            return _this.config.x.d3_format(d);
        });

        //Define the bin format: one less than the x-axis format.
        this.config.x.format1 =
            this.config.x.log10range > 5 ? '1f' : '.' + this.config.x.precision2 + 'f';
        this.config.x.d3_format1 = d3.format(this.config.x.format1);
    }
	
	
	

 

    function addFootnoteContainer() {
        this.wrap
            .insert('p', '.wc-chart')
            .attr('class', 'annote')
            .text('Click a bar for details.');
    }	

    function onLayout() {
        //Add button that resets x-domain.
      //  addXdomainResetButton.call(this);

        //Add x-axis class to x-axis limit controls.
       //  classXaxisLimitControls.call(this);

        //Add container for population count.
     //   addPopulationCountContainer.call(this);

        //Add container for footnote.
        addFootnoteContainer.call(this);
    }	
	
	
    function getCurrentMeasure() {
        var _this = this;

        this.previousMeasure = this.currentMeasure;
   
    }

    function defineMeasureData() {
        var _this = this;

        this.measure_data = this.raw_data.filter(function(d) {
            return d[_this.config.measure_col] === _this.currentMeasure;
        });
        this.measure_domain = d3$1.extent(this.measure_data, function(d) {
            return +d[_this.config.value_col];
        });
    }

    function setXdomain() {
        if (this.currentMeasure !== this.previousMeasure)
            // new measure
            this.config.x.domain = this.measure_domain;
        else if (this.config.x.domain[0] > this.config.x.domain[1])
            // invalid domain
            this.config.x.domain.reverse();
        else if (this.config.x.domain[0] === this.config.x.domain[1])
            // domain with zero range
            this.config.x.domain = this.config.x.domain.map(function(d, i) {
                return i === 0 ? d - d * 0.01 : d + d * 0.01;
            });
    }

    function setXaxisLabel() {
        this.config.x.label =
            this.currentMeasure +
            (this.config.unit_col && this.measure_data[0][this.config.unit_col]
                ? ' (' + this.measure_data[0][this.config.unit_col] + ')'
                : '');
    }

    function setXprecision() {
        var _this = this;

        //Calculate range of current measure and the log10 of the range to choose an appropriate precision.
        this.config.x.range = this.config.x.domain[1] - this.config.x.domain[0];
        this.config.x.log10range = Math.log10(this.config.x.range);
        this.config.x.roundedLog10range = Math.round(this.config.x.log10range);
        this.config.x.precision1 = -1 * (this.config.x.roundedLog10range - 1);
        this.config.x.precision2 = -1 * (this.config.x.roundedLog10range - 2);

        //Define the format of the x-axis tick labels and x-domain controls.
        this.config.x.format =
            this.config.x.log10range > 0.5 ? '1f' : '.' + this.config.x.precision1 + 'f';
        this.config.x.d3_format = d3.format(this.config.x.format);
        this.config.x.formatted_domain = this.config.x.domain.map(function(d) {
            return _this.config.x.d3_format(d);
        });

        //Define the bin format: one less than the x-axis format.
        this.config.x.format1 =
            this.config.x.log10range > 5 ? '1f' : '.' + this.config.x.precision2 + 'f';
        this.config.x.d3_format1 = d3.format(this.config.x.format1);
    }

    function updateXaxisLimitControls() {
        //Update x-axis limit controls.
        this.controls.wrap
            .selectAll('.control-group')
            .filter(function(f) {
                return f.option === 'x.domain[0]';
            })
            .select('input')
            .property('value', this.config.x.formatted_domain[0]);
        this.controls.wrap
            .selectAll('.control-group')
            .filter(function(f) {
                return f.option === 'x.domain[1]';
            })
            .select('input')
            .property('value', this.config.x.formatted_domain[1]);
    }

    function updateXaxisResetButton() {
        //Update tooltip of x-axis domain reset button.
        if (this.currentMeasure !== this.previousMeasure)
            this.controls.wrap
                .selectAll('.x-axis')
                .property(
                    'title',
                    'Initial Limits: [' +
                        this.config.x.domain[0] +
                        ' - ' +
                        this.config.x.domain[1] +
                        ']'
                );
    }

    function onPreprocess() {
        // 1. Capture currently selected measure.
      //  getCurrentMeasure.call(this);

        // 2. Filter data on currently selected measure.
    //    defineMeasureData.call(this);

        // 3a Set x-domain given currently selected measure.
   //     setXdomain.call(this);

        // 3b Set x-axis label to current measure.
    //    setXaxisLabel.call(this);

        // 4a Define precision of measure.
    //    setXprecision.call(this);

        // 4b Update x-axis reset button when measure changes.
    //    updateXaxisResetButton.call(this);

        // 4c Update x-axis limit controls to match y-axis domain.
    //    updateXaxisLimitControls.call(this);
    }
   function onDatatransform() {}

    // Takes a webcharts object creates a text annotation giving the
    // number and percentage of observations shown in the current view
    // inputs:
    // chart - a webcharts chart object
    // id_col - a column name in the raw data set (chart.raw_data) representing the observation of interest
    // id_unit - a text string to label the units in the annotation (default = "participants")
    // selector - css selector for the annotation
    function updateParticipantCount(chart, selector, id_unit) {
        //count the number of unique ids in the current chart and calculate the percentage
        var currentObs = d3$1
            .set(
                chart.filtered_data.map(function(d) {
                    return d[chart.config.id_col];
                })
            )
            .values().length;
        var percentage = d3$1.format('0.1%')(currentObs / chart.populationCount);

        //clear the annotation
        var annotation = d3$1.select(selector);
        d3$1
            .select(selector)
            .selectAll('*')
            .remove();

        //update the annotation
        var units = id_unit ? ' ' + id_unit : ' participant(s)';
        annotation.text(
            '\n' +
                currentObs +
                ' of ' +
                chart.populationCount +
                units +
                ' shown (' +
                percentage +
                ')'
        );
    }

    function resetRenderer() {
        //Reset listing.
        this.listing.draw([]);
        this.listing.wrap.selectAll('*').style('display', 'none');

        //Reset footnote.
        this.wrap
            .select('.annote')
            .classed('tableTitle', false)
            .text('Click a bar for details.');

        //Reset bar highlighting.
        delete this.highlightedBin;
        this.svg.selectAll('.bar').attr('opacity', 1);
    }

    function onDraw() {
        //Annotate population count.  This function is called on draw() so that it can access the
        //filtered data, i.e. the data with the current filters applied.  However the filtered data is
        //mark-specific, which could cause issues in other scenarios with mark-specific filters via the
        //marks.[].values setting.  chart.filtered_data is set to the last mark data defined rather
        //than the full data with filters applied, irrespective of the mark-specific filters.
        updateParticipantCount(this, '#populationCount');

        //Reset chart and listing.  Doesn't really need to be called on draw() but whatever.
        resetRenderer.call(this);
    }

    function handleSingleObservation() {
        this.svg.select('#custom-bin').remove();
        if (this.current_data.length === 1) {
            var datum = this.current_data[0];
            this.svg
                .append('g')
                .classed('bar-group', true)
                .attr('id', 'custom-bin')
                .append('rect')
                .data([datum])
                .classed('wc-data-mark bar', true)
                .attr({
                    y: 0,
                    height: this.plot_height,
                    'shape-rendering': 'crispEdges',
                    stroke: 'rgb(102,194,165)',
                    fill: 'rgb(102,194,165)',
                    'fill-opacity': '0.75',
                    width: this.x(datum.values.x * 1.01) - this.x(datum.values.x * 0.99),
                    x: this.x(datum.values.x * 0.99)
                });
        }
    }

    function addBinClickListener() {
        var chart = this;
        var config = this.config;
        var bins = this.svg.selectAll('.bar');
        var footnote = this.wrap.select('.annote');

        bins
            .style('cursor', 'pointer')
            .on('click', function(d) {
                chart.highlightedBin = d.key;
                //Update footnote.
                footnote
                    .classed('tableTitle', true)
                    .text(
                        'Table displays ' +
                            d.values.raw.length +
                            ' records  '  +
                            '. Click outside a bar to remove details.'
                    );

                //Draw listing.
                chart.listing.draw(d.values.raw);
                chart.listing.wrap.selectAll('*').style('display', null);

                //Reduce bin opacity and highlight selected bin.
                bins.attr('fill-opacity', 0.5);
                d3$1.select(this).attr('fill-opacity', 1);
            })
            .on('mouseover', function(d) {
                //Update footnote.
                if (footnote.classed('tableTitle') === false)
                    footnote.text(
                        d.values.raw.length +
                            ' records with ' +
                            (chart.filtered_data[0][config.measure_col] + ' values from ') +
                            (chart.config.x.d3_format1(d.rangeLow) +
                                ' to ' +
                                chart.config.x.d3_format1(d.rangeHigh)) +
                            (config.unit_col ? ' ' + chart.filtered_data[0][config.unit_col] : '')
                    );
            })
            .on('mouseout', function(d) {
                //Update footnote.
                if (footnote.classed('tableTitle') === false)
                    footnote.text('Click a bar for details.');
            });
    }

   
    function addClearListing() {
        var chart = this;
        var footnote = this.wrap.select('.annote');
        this.wrap.selectAll('.overlay, .normalRange').on('click', function() {
            delete chart.highlightedBin;
            chart.listing.draw([]);
            chart.listing.wrap.selectAll('*').style('display', 'none');
            chart.svg.selectAll('.bar').attr('fill-opacity', 0.75);

            if (footnote.classed('tableTitle'))
                footnote.classed('tableTitle', false).text('Click a bar for details.');
        });
    }

    function maintainBinHighlighting() {
        var _this = this;

        if (this.highlightedBin)
            this.svg.selectAll('.bar').attr('fill-opacity', function(d) {
                return d.key !== _this.highlightedBin ? 0.5 : 1;
            });
    }

    function hideDuplicateXaxisTickLabels() {
        this.svg.selectAll('.x.axis .tick').each(function(d, i) {
            var tick = d3$1.select(this);
            var value = +d;
            var text = +tick.select('text').text();
            tick.style('display', value === text ? 'block' : 'none');
        });
    }

    function onResize() {
        //Draw custom bin for single observation subsets.
        handleSingleObservation.call(this);

        //Display data listing on bin click.
        addBinClickListener.call(this);

        //Visualize normal ranges.
      //  drawNormalRanges.call(this);

        //Clear listing when clicking outside bins.
        addClearListing.call(this);

        //Keep highlighted bin highlighted on resize.
        maintainBinHighlighting.call(this);

        //Hide duplicate x-axis tick labels (d3 sometimes draws more ticks than the precision allows).
        hideDuplicateXaxisTickLabels.call(this);
    }

    function onDestroy() {}	
	
	
	 
	

function simpleCharts(element, settings) { 

        //Merge user settings onto default settings.
        var mergedSettings = Object.assign({}, defaultSettings, settings);
        var syncedSettings = syncSettings(mergedSettings);		
        //Sync properties within merged settings, e.g. data mappings.
        mergedSettings = syncSettings(mergedSettings);
        var controls = webCharts.createControls('#contain1'); 

        //Define chart.
        var chart = webcharts.createChart(element, mergedSettings);
 
 
 
 
        chart.on('init', onInit);
        chart.on('layout', onLayout);
        chart.on('preprocess', onPreprocess);
        chart.on('datatransform', onDatatransform);
        chart.on('draw', onDraw);
        chart.on('resize', onResize);
        chart.on('destroy', onDestroy);

		
		//Define listing
        var listingSettings = {
            cols: syncedSettings.details.map(function(detail) {
                return detail.value_col;
            }),
            headers: syncedSettings.details.map(function(detail) {
                return detail.label;
            }),
            searchable: syncedSettings.searchable,
            sortable: syncedSettings.sortable,
            pagination: syncedSettings.pagination,
            exportable: syncedSettings.exportable
        };
        var listing = webcharts.createTable(element, listingSettings);

        //Attach listing to chart.
        chart.listing = listing;

        //Initialize listing and hide initially.
        chart.listing.init([]);
        chart.listing.wrap.selectAll('*').style('display', 'none');

        return chart;
 
    }

    return simpleCharts;


});






