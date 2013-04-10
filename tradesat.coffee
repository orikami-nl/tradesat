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

    @tradecolor = (xport) ->
      ramp = d3.scale.log().domain([100,1000000]).range(["white","blue"]);
      ramp(xport)

    svg = d3.select(".span12")
    .append("div")
      .attr("class","chart-container")
    .append("svg")
    .attr("class", "chart")
    .attr("width", w)
    .attr("height", h)

    @metric = d3.select(".chart-container").append("div")
      .attr("class", "metric")
      .append("h3")

    @date = d3.select(".chart-container").append("div")
      .attr("class", "date")
      .append("h3")
      .html("2012-2")

    @t = 2

    svg.selectAll("path")
      .data(geoData.features)
      .enter().append("path") 
      .attr("class", "country")
      .attr("id", (d) -> d.properties.iso_a3)
      .attr("d", d3.geo.path().projection(projection))
      # .style("fill", (d) -> colors[d.properties.mapcolor9-1])
      .style "fill", (d) -> 
        if data[d.properties.iso_a3]
          tradecolor(data[d.properties.iso_a3].export["2012-#{t}"])
        else
          "#aaaaaa"

      .on "mouseover", (d, i) ->
        d3.select(this).transition().duration(300).style('stroke', 'red')
        metric.style("opacity", 1)
          .html () => 
            xport = ""
            if data[d.properties.iso_a3]
              xport = data[d.properties.iso_a3].export["2012-#{t}"]
            d.properties.iso_a3 + " " + xport
      .on "mouseout", (d, i) ->
        d3.select(this).transition().duration(300).style('stroke', "")
        metric.style("opacity", 0)


    d3.select(".chart-container").append("input")
      .attr("type", "range")
      .attr("min", 1)
      .attr("max", 12)
      .attr("value", 2)
      .on("change", () -> redraw(this.value))

    redraw = (value) =>
      t = value
      date.html("2012-#{t}")
      svg.selectAll("path")
        .attr("a", (d) -> console.log d)
        # .style("opacity", value / 100)
        .style "fill", (d) -> 
          if data[d.properties.iso_a3]
            tradecolor(data[d.properties.iso_a3].export["2012-#{t}"])
          else
            "#aaaaaa"


if Meteor.isServer
  Meteor.startup ->