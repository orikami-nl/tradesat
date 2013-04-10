
if (Meteor.isClient) {
  Meteor.startup(function() {
    var colors, h, month_names, projection, redraw, svg, t, w, xport, xport_toggle_div,
      _this = this;
    w = 960;
    h = 540;
    colors = [d3.rgb(247, 251, 255).toString(), d3.rgb(222, 235, 247).toString(), d3.rgb(198, 219, 239).toString(), d3.rgb(158, 202, 225).toString(), d3.rgb(107, 174, 214).toString(), d3.rgb(66, 146, 198).toString(), d3.rgb(33, 113, 181).toString(), d3.rgb(8, 81, 156).toString(), d3.rgb(8, 48, 107).toString()];
    month_names = ["Januari", "Februari", "Maart", "April", "Mei", "Juni", "Juli", "Augustus", "September", "Oktober", "November", "December"];
    accounting.settings = _.defaults({
      currency: {
        symbol: "€",
        format: "%s%v",
        decimal: ",",
        thousand: ".",
        precision: 0
      }
    }, accounting.settings);
    t = 2;
    xport = "import";
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
        x: d3.geo.path().projection(projection).centroid(nl)[0],
        y: d3.geo.path().projection(projection).centroid(nl)[1],
        w: 1
      };
    };
    projection = d3.geo.mercator().scale((w + 1) / 2 / Math.PI * 3.8).translate([w / 3, h * 1.73]).precision(.1);
    this.tradecolor = function(data, date) {
      var ramp;
      ramp = d3.scale.log().domain([10, 10000000]).range(["white", "blue"]);
      if (data) {
        if (xport === "export") {
          return ramp(data["export"][date]);
        } else if (xport === "import") {
          return ramp(data["import"][date]);
        }
      } else {
        return "#aaaaaa";
      }
    };
    this.cash = function(data) {
      var export_cash, import_cash;
      if (data) {
        export_cash = data["export"]["2012-" + t] * 1000;
        import_cash = data["import"]["2012-" + t] * 1000;
        return "<h5>          Export: " + (accounting.formatMoney(export_cash)) + "        </h5>        <h5>          Import: " + (accounting.formatMoney(import_cash)) + "        </h5>";
      } else {
        return "";
      }
    };
    svg = d3.select(".span12").append("div").attr("class", "chart-container").append("svg").attr("class", "chart").attr("width", w).attr("height", h);
    this.metric = d3.select(".chart-container").append("div").attr("class", "metric");
    this.date = d3.select(".chart-container").append("div").attr("class", "date").append("h3").html("Januari 2012");
    svg.selectAll("path").data(geoData.features).enter().append("path").attr("class", "country").attr("id", function(d) {
      return d.properties.iso_a3;
    }).attr("d", d3.geo.path().projection(projection)).style("fill", function(d) {
      return tradecolor(data[d.properties.iso_a3], "2012-" + t);
    }).on("mouseover", function(d, i) {
      var _this = this;
      d3.select(this).transition().duration(300).style('stroke', 'red');
      return metric.style("opacity", 1).html(function() {
        return "<h3>" + d.properties.name + "</h3>" + (cash(data[d.properties.iso_a3]));
      });
    }).on("mouseout", function(d, i) {
      d3.select(this).transition().duration(300).style('stroke', "");
      return metric.style("opacity", 0);
    });
    d3.select(".chart-container").append("input").attr("type", "range").attr("min", 1).attr("max", 12).attr("value", 2).on("change", function() {
      return redraw(this.value);
    });
    xport_toggle_div = d3.select(".chart-container").append("div").attr("class", "btn-group").attr("data-toggle", "buttons-radio");
    xport_toggle_div.append("button").attr("type", "button").attr("class", "btn active").text("Import").on("click", function() {
      xport = "import";
      return redraw();
    });
    xport_toggle_div.append("button").attr("type", "button").attr("class", "btn").text("Export").on("click", function() {
      xport = "export";
      return redraw();
    });
    return redraw = function(value) {
      if (value) {
        t = value;
      }
      date.html("" + month_names[t - 1] + " 2012");
      return svg.selectAll("path").style("fill", function(d) {
        return tradecolor(data[d.properties.iso_a3], "2012-" + t);
      });
    };
  });
}

if (Meteor.isServer) {
  Meteor.startup(function() {});
}
