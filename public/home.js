window.onload = function () {
  alignNavbar();
  d3.select("#header-icon").transition().style('opacity', 1).duration(1000)
  d3.select("#header-title").transition().style('opacity', 1).duration(1000).delay(1000)
  d3.select("#header-subtitle").transition().style('opacity', 1).duration(1000).delay(1000)
};

window.onresize = function() {
  alignNavbar();
}

function alignNavbar() {
  var navPadding = ($("body").width() - $(".container").width()) / 2;
  $("a.navbar-brand").css('margin-left', navPadding + 'px');
  $("#booksearch-form").css('margin-right', navPadding + 'px');
}

function hoverChartIcon(element) {
  element.setAttribute('src', '../svg/line_chart_hover.svg');
}
function unhoverChartIcon(element) {
  element.setAttribute('src', '../svg/line_chart.svg');
}

function hoverSearchIcon(element) {
  element.setAttribute('src', '../svg/search_hover.svg');
}
function unhoverSearchIcon(element) {
  element.setAttribute('src', '../svg/search.svg');
}

function hoverPriceIcon(element) {
  element.setAttribute('src', '../svg/price_hover.svg');
}
function unhoverPriceIcon(element) {
  element.setAttribute('src', '../svg/price.svg');
}