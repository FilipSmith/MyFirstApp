//Load local build if in local environment.
if (window.origin !== 'https://rhoinc.github.io') {
    var head = document.getElementsByTagName('head')[0];
    var script = document.createElement('script');
    script.type = 'text/javascript';
    script.src = "/static/JS/SDTM/simpleCharts.js";
    head.appendChild(script);
}

d3.csv(
    "/static/tmpdata/"+domain+".csv",
    function(error,data) {
        if (error)
            console.log(error);
        var settings = {};
        var instance = simpleCharts( '#contain1',   settings );
        instance.init(data);
    }
);


 