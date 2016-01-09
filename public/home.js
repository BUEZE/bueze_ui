var fill = d3.scale.category20();

window.onload = function () {

  $('#ranking_vis').highcharts({
    yAxis: {
      reversed: true
    }
  });

  $.get( "/ranking_chart")
    .done(function( data ) {
      new Chartkick.LineChart("ranking_vis", JSON.parse(data), {library: {yAxis: {reversed: true, min: 0, max: 10}}});
      addTagCloud(["埋冤人物誌", "2015 TOP 不只100", "台日交流歷史"]);
    });

  $('.books').on('click', function(){
    if($( this ).hasClass('success'))
      return;

    $('svg').remove();
    $('.books').each(function() {
      $( this ).removeClass('success');
    });
    $( this ).addClass('success');

    $.get( "/ranking_chart")
      .done(function( data ) {
        new Chartkick.LineChart("ranking_vis", JSON.parse(data), {library: {yAxis: {reversed: true, min: 0, max: 10}}});
        addTagCloud(["動物", "考古", "歷史"]);
      });
  });

}

// [".NET", "Silverlight", "jQuery", "CSS3", "HTML5", "JavaScript", "SQL","C#"]
var addTagCloud = function(tags) {
  d3.layout.cloud().size([300, 300])
      .words(tags.map(function(d) {
        return {text: d, size: 18 + Math.random() * 12};
      }))
      .rotate(function() { return ~~(Math.random() * 2) * 90; })
      .font("Impact")
      .fontSize(function(d) { return d.size; })
      .on("end", draw)
      .start();
}

function draw(words) {
  d3.select("#tag_vis").append("svg")
      .attr("width", $('#tag_vis').width())
      .attr("height", 300)
    .append("g")
      .attr("transform", "translate(150,150)")
    .selectAll("text")
      .data(words)
    .enter().append("text")
      .style("font-size", function(d) { return d.size + "px"; })
      .style("font-family", "Impact")
      .style("fill", function(d, i) { return fill(i); })
      .attr("text-anchor", "middle")
      .attr("transform", function(d) {
        return "translate(" + [d.x, d.y] + ")rotate(" + d.rotate + ")";
      })
      .text(function(d) { return d.text; });
}
