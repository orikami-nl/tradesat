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
    
    month_names = ["Januari","Februari","Maart","April","Mei","Juni","Juli","Augustus","September","Oktober","November","December"]

    accounting.settings = _.defaults
      currency:
        symbol : "€"
        format: "%s%v"
        decimal : ","
        thousand: "."
        precision : 0 
    ,accounting.settings
      
    t = 0
    xport = "import"

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

    @tradecolor = (data, date) ->
      ramp = d3.scale.log().domain([10,5000000]).range(["white","#08306b"]);
      if data
        if xport == "export"
          ramp(data.export[date])
        else if xport == "import"
          ramp(data.import[date])
      else
        "#aaaaaa"

    @cash = (data) ->
      if data
        export_cash = data.export[month(t)] * 1000
        import_cash = data.import[month(t)] * 1000
        "<h5>
          Export: #{accounting.formatMoney(export_cash)}
        </h5>
        <h5>
          Import: #{accounting.formatMoney(import_cash)}
        </h5>"
      else
        ""

    month = (t) ->
      t = parseInt(t)
      if t < 6
        "2011-#{t+7}"
      else
        "2012-#{t-5}"

    month_invalid_date_fix = (t) ->
      t = parseInt(t)
      if t < 6
        if t+7 < 10
          "2011-0#{t+7}"
        else
          "2011-#{t+7}"
      else
        if t-5 < 10
          "2012-0#{t-5}"
        else
          "2012-#{t-5}"

    svg = d3.select(".span12")
    .append("div")
      .attr("class","chart-container")
    .append("svg")
    .attr("class", "chart")
    .attr("width", w)
    .attr("height", h)

    @metric = d3.select(".chart-container").append("div")
      .attr("class", "metric")

    @date = d3.select(".chart-container").append("div")
      .attr("class", "date")
      .append("h3")
      .html("Juli 2011")


    svg.selectAll("path")
      .data(geoData.features)
      .enter().append("path") 
      .attr("class", "country")
      .attr("id", (d) -> d.properties.iso_a3)
      .attr("d", d3.geo.path().projection(projection))
      # .style("fill", (d) -> colors[d.properties.mapcolor9-1])
      .style "fill", (d) -> 
        tradecolor(data[d.properties.iso_a3], month(t))

      .on "mouseover", (d, i) ->
        svg.selectAll("path").sort (a,b) ->
          if a.properties.iso_a3 != d.properties.iso_a3
            -1
          else
            1
        d3.select(this).transition().duration(0).style('stroke', '#aa0000').style("stroke-width",2)
        metric.style("opacity", 1)
          .html () => 
            "<h3>#{d.properties.name}</h3>#{cash(data[d.properties.iso_a3])}"
      .on "mouseout", (d, i) ->
        d3.select(this).transition().duration(200).style('stroke', "").style("stroke-width",1)
        metric.style("opacity", 0)

    d3.select(".chart-container").append("div").attr("id","slider")

    $("#slider").slider
      min: 0
      max: 15
      value: 0
      slide: (e,ui) ->
        redraw(ui.value)

    xport_toggle_div = d3.select(".chart-container").append("div")
      .attr("class", "btn-group").attr("data-toggle", "buttons-radio")
    xport_toggle_div.append("button").attr("type", "button").attr("class", "btn active").text("Import")
      .on "click", () ->
        xport = "import"
        redraw()
    xport_toggle_div.append("button").attr("type", "button").attr("class", "btn").text("Export")
      .on "click", () ->
        xport = "export"
        redraw()


    redraw = (value) =>
      if value
        t = value
      t = parseInt(t)
      date.html("#{month_names[(new Date(month_invalid_date_fix(t))).getMonth()]} #{(new Date(month_invalid_date_fix(t))).getFullYear()}")
      svg.selectAll("path")
        .transition(100)
        .style "fill", (d) -> 
          tradecolor(data[d.properties.iso_a3], month(t))


if Meteor.isServer
  Meteor.startup ->