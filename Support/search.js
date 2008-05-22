function matched(files, lines) {
  document.getElementById('filecount').innerText = ('' + files).concat(' file').concat( (files == 1 ) ? '' : 's' );
  document.getElementById('linecount').innerText = ('' + lines).concat(' line').concat( (lines == 1 ) ? '' : 's' );
}