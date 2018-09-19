 
d3.csv(
    "/static/tmpdata/"+domain+".csv",
    function(error,data) {
        if (error)
            console.log(error);

        var settings = {};
        var instance = aeTable.createChart(
            '#container',
            settings
        );
        instance.init(data);
    }
);
