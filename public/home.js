window.onload = function () {
  $('#ranking_vis').highcharts({
    yAxis: {
      reversed: true
    }
  });
  $.get( "/ranking_chart")
    .done(function( data ) {
      new Chartkick.LineChart("ranking_vis", JSON.parse(data), {library: {yAxis: {reversed: true, min: 0, max: 10}}});
    });
}
