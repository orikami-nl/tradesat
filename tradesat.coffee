if Meteor.isClient


  Meteor.startup ->
    svg = d3.select("body").append("svg")
    .attr("class", "chart")
    .attr("width", 1000)
    .attr("height", 800);

    svg.selectAll("path")
      .data(geoData.features)
      .enter().append("path")
      .attr("class", "country")
      .attr("id", (d) -> d.properties.sov_a3)
      .attr("d", d3.geo.path().projection(d3.geo.mercator().scale(1000).translate([470,500])))

    @line = d3.svg.line()
      .interpolate("cardinal")
      .x( (d) -> d.x )
      .y( (d) -> d.y )

    @nl_coords = ->
      bbox = d3.select("#NL1").node().getBBox()
      {x: bbox.x + bbox.width/2, y: bbox.y + bbox.height/2}

    svg.selectAll("g")
      .data(geoData.features)
      .enter().append("path")
      .attr("d", (d) -> line.tension(0.5)([
        nl_coords(),
        {
          x: (d3.geo.path().projection(d3.geo.mercator().scale(1000).translate([470,500])).centroid(d)[0] - nl_coords().x) / 2 + nl_coords().x, 
          y: (d3.geo.path().projection(d3.geo.mercator().scale(1000).translate([470,500])).centroid(d)[1] - nl_coords().y) / 2 + nl_coords().y
        }
        {
          x: d3.geo.path().projection(d3.geo.mercator().scale(1000).translate([470,500])).centroid(d)[0], 
          y: d3.geo.path().projection(d3.geo.mercator().scale(1000).translate([470,500])).centroid(d)[1]
        }
        ]))
      .style("stroke", "red")
      .style("fill", "transparent")






if Meteor.isServer
  Meteor.startup ->