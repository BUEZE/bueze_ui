var fill = d3.scale.category20();

window.onload = function () {

  $('#info_tab a').click(function (e) {
    e.preventDefault();
    $(this).tab('show');
  });

  $('#ranking_vis').highcharts({
    yAxis: {
      reversed: true
    }
  });

  $.get( "/ranking_chart", {name: $( '.success' ).find('td#bookname').html()})
    .done(function( data ) {
      new Chartkick.LineChart("ranking_vis", data, {library: {yAxis: {reversed: true, min: 1, max: 10}}});
    });

  $.get( "/bookinfo", {name: $( '.success' ).find('td#bookname').html()})
    .done(function( data ) {
      console.log(data);
      addTagCloud(data.tags[0].tags.tags);
    });

  $('.books').on('click', function(){
    if($( this ).hasClass('success'))
      return;

    var title = $( this ).find('td#bookname').html();
    $('svg').remove();
    $('.books').each(function() {
      $( this ).removeClass('success');
    });
    $( this ).addClass('success');

    $.get( "/bookinfo", {name: title})
      .done(function( data ) {
        addTagCloud(data.tags[0].tags.tags);
      });

    $.get( "/ranking_chart", {name: title})
      .done(function( data ) {
        $('#book_title').html(title);
        new Chartkick.LineChart("ranking_vis", data, {library: {yAxis: {reversed: true, min: 1, max: 10}}});
      });
  });
};

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
};

function draw(words) {
  d3.select("#tag_vis").append("svg")
      .attr("width", 300)
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

function replaceRank() {
  d3.select('svg').selectAll('g')[0].forEach(function(item){
    if (d3.select(item).attr('class') == 'highcharts-axis-labels highcharts-yaxis-labels') {
      $(item.childNodes[item.childNodes.length - 1]).text('x');
    };
  });
}
