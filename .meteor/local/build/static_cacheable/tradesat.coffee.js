(function(){ 
if (Meteor.isClient) {
  Meteor.startup(function() {
    var colors, h, month, month_invalid_date_fix, month_names, projection, redraw, svg, t, w, xport, xport_toggle_div,
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
    t = 0;
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
      ramp = d3.scale.log().domain([10, 5000000]).range(["white", "#08306b"]);
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
        export_cash = data["export"][month(t)] * 1000;
        import_cash = data["import"][month(t)] * 1000;
        return "<h5>          Export: " + (accounting.formatMoney(export_cash)) + "        </h5>        <h5>          Import: " + (accounting.formatMoney(import_cash)) + "        </h5>";
      } else {
        return "";
      }
    };
    month = function(t) {
      t = parseInt(t);
      if (t < 6) {
        return "2011-" + (t + 7);
      } else {
        return "2012-" + (t - 5);
      }
    };
    month_invalid_date_fix = function(t) {
      t = parseInt(t);
      if (t < 6) {
        if (t + 7 < 10) {
          return "2011-0" + (t + 7);
        } else {
          return "2011-" + (t + 7);
        }
      } else {
        if (t - 5 < 10) {
          return "2012-0" + (t - 5);
        } else {
          return "2012-" + (t - 5);
        }
      }
    };
    svg = d3.select(".chart-span").append("div").attr("class", "chart-container").append("svg").attr("class", "chart").attr("width", w).attr("height", h);
    this.metric = d3.select(".chart-container").append("div").attr("class", "metric");
    this.date = d3.select(".chart-container").append("div").attr("class", "date").append("h3").html("Juli 2011");
    svg.selectAll("path").data(geoData.features).enter().append("path").attr("class", "country").attr("id", function(d) {
      return d.properties.iso_a3;
    }).attr("d", d3.geo.path().projection(projection)).style("fill", function(d) {
      return tradecolor(data[d.properties.iso_a3], month(t));
    }).on("mouseover", function(d, i) {
      var _this = this;
      svg.selectAll("path").sort(function(a, b) {
        if (a.properties.iso_a3 !== d.properties.iso_a3) {
          return -1;
        } else {
          return 1;
        }
      });
      d3.select(this).transition().duration(0).style('stroke', '#aa0000').style("stroke-width", 2);
      return metric.style("opacity", 1).html(function() {
        return "<h3>" + d.properties.name + "</h3>" + (cash(data[d.properties.iso_a3]));
      });
    }).on("mouseout", function(d, i) {
      d3.select(this).transition().duration(200).style('stroke', "").style("stroke-width", 1);
      return metric.style("opacity", 0);
    });
    d3.select(".chart-container").append("div").attr("id", "slider");
    $("#slider").slider({
      min: 0,
      max: 15,
      value: 0,
      slide: function(e, ui) {
        return redraw(ui.value);
      }
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
      t = parseInt(t);
      date.html("" + month_names[(new Date(month_invalid_date_fix(t))).getMonth()] + " " + ((new Date(month_invalid_date_fix(t))).getFullYear()));
      return svg.selectAll("path").transition(100).style("fill", function(d) {
        return tradecolor(data[d.properties.iso_a3], month(t));
      });
    };
  });
}

if (Meteor.isServer) {
  Meteor.startup(function() {});
}

})();
