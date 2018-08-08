//Load local build if in local environment.
if (window.origin !== 'https://rhoinc.github.io') {
    var head = document.getElementsByTagName('head')[0];
    var script = document.createElement('script');
    script.type = 'text/javascript';
    script.src = "/static/JS/"+CDISC_Obj+""+visutype+".js";
    head.appendChild(script);
}
 
d3.csv(
    "/static/"+study+"/"+objet+"/"+dataset+".csv",
    function(error,data) {
        if (error)
            console.log(error);

        var settings = {};
		
        var instance = aeTimelines(
            '#container',
            settings
        );
        instance.init(data);
    }
);
