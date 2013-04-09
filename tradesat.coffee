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
      .on "mouseover", (d, i) ->
        d3.select(this).style('fill', 'red')
      .on "mouseout", (d, i) ->
        d3.select(this).style('fill', (d) -> colors[d.properties.mapcolor9-1])

    @line = d3.svg.line()
      .interpolate("cardinal")
      .x( (d) -> d.x )
      .y( (d) -> d.y )

    @linevar = d3.svg.line.variable()
      .interpolate("basis")
      .w( (d) -> d.w )
      .x( (d) -> d.x )
      .y( (d) -> d.y )


    @nl_coords = ->
      nl = _.find(geoData.features, (country) -> country.properties.iso_a3 == "NLD" )
      {x: d3.geo.path().projection(d3.geo.mercator().scale(5000).translate([300,1300])).centroid(nl)[0], y: d3.geo.path().projection(d3.geo.mercator().scale(5000).translate([300,1300])).centroid(nl)[1], w: 1}

    svg.selectAll("g")
      .data(geoData.features)
      .enter().append("path")
      .attr("d", (d) -> 
        x = d3.geo.path().projection(d3.geo.mercator().scale(5000).translate([300,1300])).centroid(d)[0]
        y = d3.geo.path().projection(d3.geo.mercator().scale(5000).translate([300,1300])).centroid(d)[1]
        linevar.tension(0.5)([
          nl_coords(),
          # {
          #   x: (x - nl_coords().x) / 2 + nl_coords().x, 
          #   y: (x - nl_coords().y) / 2 + nl_coords().y
          # }
          {
            x: x 
            y: y
            w: Math.random()*10
          }
        ]))
      .style("stroke", "red")
      .style("fill", "red")
      # .style("display", "none")
        # svg.select('circle#point-'+i)
        #   .style('fill', d3.rgb(31, 120, 180))

      # .style("stroke-width", (d) -> Math.random()*10)


if Meteor.isServer
  Meteor.startup ->