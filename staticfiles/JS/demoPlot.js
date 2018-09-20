


var settings = {
  x: {column: "SITEID", type: "ordinal", label: "Site" },
  y: {column: "HEIGHT", type: "linear", label: function(){return this.config.y.column; } },
  marks: [
    {type: "bar", per: ["SITEID"], split: "SEX", arrange: "grouped"},
    {type: "circle", per: ["SITEID"], summarizeY: "mean", tooltip: "[Name]", attributes: {"fill-opacity": 1, fill: "black", "stroke": "black"}, size: 4}
  ],
  color_by: "SEX",
  max_width: 800,
  gridlines: 'xy'
};

var controls = webCharts.createControls('#container', 
	{	
		location: 'top', 
		inputs:[
	  {type: "dropdown", option: "y.column", label: "Y Values", values: ["WEIGHT", "HEIGHT", "BMI", "AGE"], require: true},
      {type: "subsetter", value_col: "SEX", label: "Filter by Sex"},
 
      {type: "subsetter", value_col: "SITEID", label: "Filter by Site"}
		]
	}
);



 