if Meteor.isClient


  Meteor.startup ->

    w = 960
    h = 540

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

    @tooltip = d3.select("body").append("div")   
      .attr("class", "tooltip")
      .style("opacity", 0);

    @line = d3.svg.line()
      .interpolate("cardinal")
      .x( (d) -> d.x )
      .y( (d) -> d.y )
      
    @nl_coords = ->
      nl = _.find(geoData.features, (country) -> country.properties.iso_a3 == "NLD" )
      {x: d3.geo.path().projection(projection).centroid(nl)[0], y: d3.geo.path().projection(projection).centroid(nl)[1], w: 1}

    projection = d3.geo.mercator()
      .scale((w + 1) / 2 / Math.PI * 3.8)
      .translate([w / 3, h * 1.73])
      .precision(.1)


    svg = d3.select("body").append("svg")
    .attr("class", "chart")
    .attr("width", w)
    .attr("height", h)

    svg.selectAll("path")
      .data(geoData.features)
      .enter().append("path") 
      .attr("class", "country")
      .attr("id", (d) -> d.properties.iso_a3)
      .attr("d", d3.geo.path().projection(projection))
      .style("fill", (d) -> colors[d.properties.mapcolor9-1])
      .on "mouseover", (d, i) ->
        d3.select(this).transition().duration(300).style('fill', 'red')
        tooltip.transition()        
          .duration(300)      
          .style("opacity", .9);     
        tooltip.html("TOOLTIP")  
          .style("left", (d3.geo.path().projection(projection).centroid(d)[0])-28 + "px")     
          .style("top", (d3.geo.path().projection(projection).centroid(d)[1]) + "px")
      .on "mouseout", (d, i) ->
        d3.select(this).transition().duration(300).style('fill', (d) -> colors[d.properties.mapcolor9-1])
        tooltip.transition()        
          .duration(300)      
          .style("opacity", 0)




if Meteor.isServer
  Meteor.startup ->