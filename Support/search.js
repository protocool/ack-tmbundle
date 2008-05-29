var foundFiles = 0;
var foundLines = 0;

function f() {
  foundFiles += 1;
  document.getElementById('filecount').innerText = ('' + foundFiles).concat(' file').concat( (foundFiles == 1 ) ? '' : 's' );
}

function l() {
  foundLines += 1;
  document.getElementById('linecount').innerText = ('' + foundLines).concat(' line').concat( (foundLines == 1 ) ? '' : 's' );
}

function searchStarted() {
  document.getElementById('teaser').style.display = 'none';
  
}

function searchCompleted() {
  document.getElementById('teaser').style.display = 'block';
}