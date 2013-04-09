if Meteor.isClient


  Meteor.startup ->

    colors = 
    [
      d3.rgb(247,251,255).toString(),
      d3.rgb(222,235,247).toString(),
      d3.rgb(198,219,239).toString(),
      d3.rgb(158,202,225).toString(),
      d3.rgb(107,174,214).toString(),
      d3.rgb(66,146,198).toString(),
      d3.rgb(33,113,181).toString(),
      d3.rgb(8,81,156).toString(),
      d3.rgb(8,48,107).toString()
    ]

    svg = d3.select("body").append("svg")
    .attr("class", "chart")
    .attr("width", 1000)
    .attr("height", 800);

    svg.selectAll("path")
      .data(geoData.features)
      .enter().append("path")
      .attr("class", "country")
      .attr("id", (d) -> d.properties.iso_a3)
      .attr("d", d3.geo.path().projection(d3.geo.mercator().scale(5000).translate([300,1300])))
      .style("fill", (d) -> colors[d.properties.mapcolor9-1])

    @line = d3.svg.line()
      .interpolate("cardinal")
      .x( (d) -> d.x )
      .y( (d) -> d.y )

    @nl_coords = ->
      bbox = d3.select("#NLD").node().getBBox()
      {x: bbox.x + bbox.width/2, y: bbox.y + bbox.height/2}

    svg.selectAll("g")
      .data(geoData.features)
      .enter().append("path")
      .attr("d", (d) -> 
        x = d3.geo.path().projection(d3.geo.mercator().scale(5000).translate([300,1300])).centroid(d)[0]
        y = d3.geo.path().projection(d3.geo.mercator().scale(5000).translate([300,1300])).centroid(d)[1]
        line.tension(0.5)([
          nl_coords(),
          # {
          #   x: (x - nl_coords().x) / 2 + nl_coords().x, 
          #   y: (x - nl_coords().y) / 2 + nl_coords().y
          # }
          {
            x: x, 
            y: y
          }
        ]))
      .style("stroke", "red")
      .style("fill", "transparent")




# <path d="M-124.8182373046875,772.93191528320tqc31L375.02515860833284,447.02153192674" style="stroke: #ff0000; fill: rgba(0, 0, 0, 0);"></path>

if Meteor.isServer
  Meteor.startup ->