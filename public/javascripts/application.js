// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

// place your unobtrusive javascript calls in here, to be run on window load
function tumblelogInit() {
  relativeDates();
}

// convert dates to relative onload
function relativeDates() {
  var spans = document.getElementsByTagName('span');
  for (var i = 0;i < spans.length;i++) {
    if (spans[i].className != 'post-date') continue;
    if (spans[i].className == 'post-date') {
      spans[i].firstChild.innerHTML = relativeDate(spans[i].firstChild.innerHTML);
    }
  }
}

// relativedates.js
// Nathan Ashby-Kuhlman
// 2002-12-19

var monthAbbreviations = new Array("Jan ", "Feb ", "March ", "April ", "May ", "June ", "July ", "Aug ", "Sept ", "Oct ", "Nov ", "Dec ");
var daysOfTheWeek = new Array("sunday", "monday", "tuesday", "wednesday", "thursday", "friday", "saturday");

// In milliseconds:
ONEDAYAGO = -86400000;
TWODAYSAGO = -172800000;
SEVENDAYSAGO = -604800000;
THREEMONTHSAGO = -8035200000;

function dateReference(dateString) {
  var relative = relativeDate(dateString);
  var explicit = explicitDate(dateString, true);
  if (relative != explicit) {
    document.write("<acronym title=\"" + explicit + "\">" + relative + "</acronym>");
  } else {
    document.write(explicit);
  }
}

function relativeDate(dateString) {
  var now = new Date();
  var reference = new Date(dateString);
  if (isNaN(reference)) return dateString;
  var offset = reference.getTime() - now.getTime();
  if ((offset > ONEDAYAGO) && (offset <= 0)) return "today";
  if ((offset > TWODAYSAGO) && (offset <= ONEDAYAGO)) return "yesterday";
  if ((offset > SEVENDAYSAGO) && (offset <= TWODAYSAGO)) return "last " + daysOfTheWeek[reference.getDay()];
  if (offset > THREEMONTHSAGO) return Math.round((now - reference) / Math.abs(ONEDAYAGO)) + " days ago";

  // None of the above
  return explicitDate(dateString, true);
}

function explicitDate(dateString, includeYearRegardless) {
  var now = new Date();
  var reference = new Date(dateString);
  if (isNaN(reference)) return dateString;
  var date = reference.getDate();
  var month = monthAbbreviations[reference.getMonth()];
  // Unless specified, only include the year if it is different from the current year
  if ((reference.getFullYear() != now.getFullYear()) || includeYearRegardless) {
    var year = ", " + reference.getFullYear();
  } else {
    var year = "";
  }
  return(month + date + year);
}

// By John Resig http://www.quirksmode.org/blog/archives/2005/10/_and_the_winner_1.html
function addEvent( obj, type, fn ) {
	if (obj.addEventListener) {
		obj.addEventListener( type, fn, false );
	} else if (obj.attachEvent) {
		obj["e"+type+fn] = fn;
		obj[type+fn] = function() { obj["e"+type+fn]( window.event ); }
		obj.attachEvent( "on"+type, obj[type+fn] );
	}
}

addEvent(window, 'load', tumblelogInit);