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
function addEvent(obj, type, fn) {
	if (obj.addEventListener) {
		obj.addEventListener( type, fn, false );
	} else if (obj.attachEvent) {
		obj["e"+type+fn] = fn;
		obj[type+fn] = function() { obj["e"+type+fn]( window.event ); }
		obj.attachEvent( "on"+type, obj[type+fn] );
	}
}

addEvent(window, 'load', tumblelogInit);

// from http://www.dustindiaz.com/getelementsbyclass/
function getElementsByClass(searchClass,node,tag) {
	var classElements = new Array();
	if ( node == null )
		node = document;
	if ( tag == null )
		tag = '*';
	var els = node.getElementsByTagName(tag);
	var elsLen = els.length;
	var pattern = new RegExp("(^|\\s)"+searchClass+"(\\s|$)");
	for (i = 0, j = 0; i < elsLen; i++) {
		if ( pattern.test(els[i].className) ) {
			classElements[j] = els[i];
			j++;
		}
	}
	return classElements;
}

// totally enable the TinyMCE WYSIWYG editor
function enableEditor(id) {
  wysiwyg_togglers = getElementsByClass('wysiwyg_toggle_link');
  
	if (tinyMCE.getInstanceById(id) == null) {
		tinyMCE.execCommand('mceAddControl', false, id);
		if (wysiwyg_togglers.length > 0) {
		  for (i = 0; i < wysiwyg_togglers.length; i++) {
		    wysiwyg_togglers[i].style.display = 'block';
		    wysiwyg_togglers[i].innerHTML = 'Disable WYSIWYG';
		  }
		}
	}
}

// totally disable the TinyMCE WYSIWYG editor
function disableEditor(id) {
  wysiwyg_togglers = getElementsByClass('wysiwyg_toggle_link');
  
	if (tinyMCE.getInstanceById(id) != null) {
		tinyMCE.execCommand('mceRemoveControl', false, id);	
		if (wysiwyg_togglers.length > 0) {
		  for (i = 0; i < wysiwyg_togglers.length; i++) {
		    wysiwyg_togglers[i].style.display = 'none';
		  }
		}
  }
}

// based on http://wiki.moxiecode.com/examples/tinymce/installation_example_07.php
function toggleEditor(id) {
	var elm = document.getElementById(id);
  wysiwyg_togglers = getElementsByClass('wysiwyg_toggle_link');

	if (tinyMCE.getInstanceById(id) == null) {
		tinyMCE.execCommand('mceAddControl', false, id);
		if (wysiwyg_togglers.length > 0) {
		  for (i = 0; i < wysiwyg_togglers.length; i++) { 
		    wysiwyg_togglers[i].innerHTML = 'Disable WYSIWYG';
		  }
		}
  } 
	else {
		tinyMCE.execCommand('mceRemoveControl', false, id);
		if (wysiwyg_togglers.length > 0) {
		  for (i = 0; i < wysiwyg_togglers.length; i++) {
		    wysiwyg_togglers[i].innerHTML = 'Enable WYSIWYG';
		  }
		}
  }
}
