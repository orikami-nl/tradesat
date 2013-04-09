(function(){ 
if (Meteor.isClient) {
  Meteor.startup(function() {
    var colors, projection, svg;
    colors = [d3.rgb(247, 251, 255).toString(), d3.rgb(222, 235, 247).toString(), d3.rgb(198, 219, 239).toString(), d3.rgb(158, 202, 225).toString(), d3.rgb(107, 174, 214).toString(), d3.rgb(66, 146, 198).toString(), d3.rgb(33, 113, 181).toString(), d3.rgb(8, 81, 156).toString(), d3.rgb(8, 48, 107).toString()];
    this.tooltip = d3.select("body").append("div").attr("class", "tooltip").style("opacity", 0);
    this.line = d3.svg.line().interpolate("cardinal").x(function(d) {
      return d.x;
    }).y(function(d) {
      return d.y;
    });
    this.nl_coords = function() {
      var nl;
      nl = _.find(geoData.features, function(country) {
        return country.properties.iso_a3 === "NLD";
      });
      return {
        x: d3.geo.path().projection(d3.geo.mercator()).centroid(nl)[0],
        y: d3.geo.path().projection(d3.geo.mercator()).centroid(nl)[1],
        w: 1
      };
    };
    projection = d3.geo.albers().rotate([98, 0]).center([0, 38]).scale(1000).translate([width / 2, height / 2]).precision(.1);
    svg = d3.select("body").append("svg").attr("class", "chart").attr("width", 960).attr("height", 540);
    return svg.selectAll("path").data(geoData.features).enter().append("path").attr("class", "country").attr("id", function(d) {
      return d.properties.iso_a3;
    }).attr("d", d3.geo.path().projection(projection)).style("fill", function(d) {
      return colors[d.properties.mapcolor9 - 1];
    }).on("mouseover", function(d, i) {
      d3.select(this).transition().duration(300).style('fill', 'red');
      tooltip.transition().duration(300).style("opacity", .9);
      return tooltip.html("TOOLTIP").style("left", (d3.geo.path().projection(d3.geo.mercator().scale(5000).translate([300, 1300])).centroid(d)[0]) - 28 + "px").style("top", (d3.geo.path().projection(d3.geo.mercator().scale(5000).translate([300, 1300])).centroid(d)[1]) + "px");
    }).on("mouseout", function(d, i) {
      d3.select(this).transition().duration(300).style('fill', function(d) {
        return colors[d.properties.mapcolor9 - 1];
      });
      return tooltip.transition().duration(300).style("opacity", 0);
    });
  });
}

if (Meteor.isServer) {
  Meteor.startup(function() {});
}

})();
