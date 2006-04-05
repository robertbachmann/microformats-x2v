<?php
/* --------------------------------------------

Brian Suda
brian@suda.co.uk
22-October-2005

version 1.1

NOTES:
This required PHP XSLT libraries installed

--------------------------------------------- */

// Check for a referrer and to be sure it is is not NULL
$uri='';
if (isSet($_GET['referer'])) { if (getenv("HTTP_REFERER") != ''){ $uri = getenv("HTTP_REFERER"); } }

// Check to see if a URI is passed and that it is not NULL
if (isSet($_GET['uri'])){ if ($_GET['uri'] != ''){ $uri = $_GET['uri']; } } else { $uri =''; }

// Make sure that they are not getting at the file system and $uri is set to something
if ((substr($uri, 0,7) == "http://") || (substr($uri, 0,8) == "https://")) {

	// check to see if a filename is specified
	if (isSet($_GET['filename'])){
	  if ($_GET['filename'] != ''){ $logfile = $_GET['filename']; }
	} else { $logfile = "X2V.ics"; }

	// check $uri for an anchor
	list($temp,$anchor) = explode("#",$uri);

   // Fetch the $uri and read it into $xml variable
	// @@ - if Tidy is available on the server we can avoid using the w3c tidy webservice
	/*
	$handle = fopen($uri, "r");
	*/
	
	$handle = fopen("http://cgi.w3.org/cgi-bin/tidy?docAddr=".urlencode($uri), "r");
	$xml = '';
	while (!feof($handle)) {
		$xml .= fread($handle, 8192);
	}
//	$xml = fread($handle, filesize($uri));
	fclose($handle);

	// Check to see if the BETA XSLT should be used, or the production version
	if (isSet($_GET['beta'])){
		$filename = "xhtml2vcal-beta.xsl";
	} else { $filename = "xhtml2vcal.xsl"; }

	// read in the XSLT file into $xsl
	$handle = fopen($filename, "r");
	$xsl = '';
	$xsl = fread($handle, filesize($filename));
	fclose($handle);

	// create an XSLT processor or Throw and error
	$xp = xslt_create() or trigger_error('Could not create XSLT process.',E_USER_ERROR);
	xslt_set_encoding($xp, 'UTF-8');
                                  
	// set the argument buffer
	$arg_buffer = array('/xml' => $xml, '/xsl' => $xsl);

	// set the parameter buffer
	// pass the $uri and the $anchor if it is available
	$xsl_params = array('x-from-url'=>$uri,'Source'=>$uri,'x-anchor'=>$anchor,'Anchor'=>$anchor);

	$Str = '';
	// process the two files to get the desired output
	if (($Str = @xslt_process($xp, 'arg:/xml', 'arg:/xsl', NULL, $arg_buffer, $xsl_params))){
	   Header("Content-Disposition: attachment; filename=$logfile");
	   Header("Content-Length: ".strlen($Str));
	   Header("Connection: close");
	   Header("Content-Type: text/calendar; name=$logfile");
	   echo $Str;
	} else {
		if (xslt_errno($xp) == 0){
			// No vevents were found on this page
			header("Location: http://suda.co.uk/projects/X2V/index.php?error=1");
		} else {
			// some sort of major error has been encountered
			echo "<html><head><title>ERROR</title></head><body>";
			echo "<p>Sorry, $uri could not be transformed by xtml2vcal.xsl into";
			echo " an iCal file because of " . xslt_error($xp);
			echo " and the error code is " . xslt_errno($xp)."";
			echo " check that this page validates: <a href=\"http://validator.w3.org/check?uri=$uri\">http://validator.w3.org/check?uri=$uri</a>";
			echo "</p></body></html>";
		}
	}
	
	// clean-up XSLT processor
	xslt_free($xp);
} else {
// $uri is not valid
// DISPLAY page to manually enter a URL
   Header("Location: http://suda.co.uk/projects/X2V/index.php");
}

?>