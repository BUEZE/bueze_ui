var fill = d3.scale.category20();

window.onload = function () {
  $('#info_tab a[href="#tags"]').click(function (e) {
    e.preventDefault();
    $(this).tab('show');
    if (!$( "#tag_vis" ).has( "svg" ).length){
      waitingDialog.show('Fetching tags...', {dialogSize: 'sm', progressType: 'warning'});
      var title = $( '#book_title' ).html();
      $.get( "/bookinfo", {name: title})
        .done(function( data ) {
          addTagCloud(data.tags.tags);
          waitingDialog.hide();
        });
    }
  });

  $('#info_tab a[href="#ranking"]').click(function (e) {
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

  $('.books').on('click', function(){
    if($( this ).hasClass('success'))
      return;

    waitingDialog.show('Loading messages...', {dialogSize: 'sm', progressType: 'success'});
    var title = $( this ).find('td#bookname').html();
    $('svg').remove();
    $('.books').each(function() {
      $( this ).removeClass('success');
    });
    $( this ).addClass('success');

    $.get( "/ranking_chart", {name: title})
      .done(function( data ) {
        $('#book_title').html(title);
        $('#info_tab a[href="#ranking"]').tab('show');
        new Chartkick.LineChart("ranking_vis", data, {library: {yAxis: {reversed: true, min: 1, max: 10}}});
        waitingDialog.hide();
      });
  });

  alignNavbar();
  d3.select("#header-icon").transition().style('opacity', 1).duration(1000)
  d3.select("#header-title").transition().style('opacity', 1).duration(1000).delay(1000)
  d3.select("#header-subtitle").transition().style('opacity', 1).duration(1000).delay(1000)
};

window.onresize = function() {
  alignNavbar();
}

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
    }
  });
}

var waitingDialog = waitingDialog || (function ($) {
    'use strict';

  // Creating modal dialog's DOM
  var $dialog = $(
    '<div class="modal fade" data-backdrop="static" data-keyboard="false" tabindex="-1" role="dialog" aria-hidden="true" style="padding-top:15%; overflow-y:visible;">' +
    '<div class="modal-dialog modal-m">' +
    '<div class="modal-content">' +
      '<div class="modal-header"><h3 style="margin:0;"></h3></div>' +
      '<div class="modal-body">' +
        '<div class="progress progress-striped active" style="margin-bottom:0;"><div class="progress-bar" style="width: 100%"></div></div>' +
      '</div>' +
    '</div></div></div>');

  return {
    /**
     * Opens our dialog
     * @param message Custom message
     * @param options Custom options:
     *          options.dialogSize - bootstrap postfix for dialog size, e.g. "sm", "m";
     *          options.progressType - bootstrap postfix for progress bar type, e.g. "success", "warning".
     */
    show: function (message, options) {
      // Assigning defaults
      if (typeof options === 'undefined') {
        options = {};
      }
      if (typeof message === 'undefined') {
        message = 'Loading';
      }
      var settings = $.extend({
        dialogSize: 'm',
        progressType: '',
        onHide: null // This callback runs after the dialog was hidden
      }, options);

      // Configuring dialog
      $dialog.find('.modal-dialog').attr('class', 'modal-dialog').addClass('modal-' + settings.dialogSize);
      $dialog.find('.progress-bar').attr('class', 'progress-bar');
      if (settings.progressType) {
        $dialog.find('.progress-bar').addClass('progress-bar-' + settings.progressType);
      }
      $dialog.find('h3').text(message);
      // Adding callbacks
      if (typeof settings.onHide === 'function') {
        $dialog.off('hidden.bs.modal').on('hidden.bs.modal', function (e) {
          settings.onHide.call($dialog);
        });
      }
      // Opening dialog
      $dialog.modal();
    },
    /**
     * Closes dialog
     */
    hide: function () {
      $dialog.modal('hide');
    }
  };

})(jQuery);

function alignNavbar() {
  var navPadding = ($("body").width() - $(".container").width()) / 2;
  $("a.navbar-brand").css('margin-left', navPadding + 'px');
  $("#user-form").css('margin-right', navPadding + 'px');
}
