<?php
/* --------------------------------------------

Brian Suda
brian@suda.co.uk
20-Sept-2004

version 1.0

NOTES:
This required PHP XSLT libraries installed


--------------------------------------------- */


$uri='';
if (isSet($_GET['referer'])) {
  if (getenv("HTTP_REFERER") != ''){ $uri = getenv("HTTP_REFERER"); }
}

if (isSet($_GET['uri'])){
  if ($_GET['uri'] != ''){ $uri = $_GET['uri']; }
}


if ($uri != '') {
$logfile = "X2V.vcf";
list($temp,$anchor) = explode("#",$uri);

$handle = fopen($uri, "r");
$xml = '';
while (!feof($handle)) {
  $xml .= fread($handle, 8192);
}
fclose($handle);


$filename = "xhtml2vcard.xsl";
$handle2 = fopen($filename, "r");
$xsl = fread($handle2, filesize($filename));
fclose($handle2);


$Str = '';
$xp = xslt_create() or trigger_error('Could not create XSLT process.',E_USER_ERROR);
xslt_set_encoding($xp, 'UTF-8');

// read the files into memory
$xsl_string = $xsl;
$xml_string = $xml;

// set the argument buffer
$arg_buffer = array('/xml' => $xml_string, '/xsl' => $xsl_string);

// set the parameter buffer
$xsl_params = array('x-from-url'=>$uri,'x-anchor'=>$anchor);


// process the two files to get the desired output
if (($Str = @xslt_process($xp, 'arg:/xml', 'arg:/xsl', NULL, 
$arg_buffer, $xsl_params))){

   Header("Content-Disposition: attachment; filename=$logfile");
   Header("Content-Length: ".strlen($Str));
   Header("Connection: close");
   Header("Content-Type: text/x-text; name=$logfile");
//   Header("Content-Type: text/x-vcard; name=$logfile");
   echo $Str;

//echo ($Str); 
} else {
  $handle = fopen("http://cgi.w3.org/cgi-bin/tidy?docAddr=".$uri, "r");
  $xml = '';
  while (!feof($handle)) {
    $xml .= fread($handle, 8192);
  }
  fclose($handle);

  // read the files into memory
  $xsl_string = $xsl;
  $xml_string = $xml;

  // set the argument buffer
  $arg_buffer = array('/xml' => $xml_string, '/xsl' => $xsl_string);

  if (($Str = xslt_process($xp, 'arg:/xml', 'arg:/xsl', NULL, $arg_buffer, NULL))){

   Header("Content-Disposition: attachment; filename=$logfile");
   Header("Content-Length: ".strlen($Str));
   Header("Connection: close");
   Header("Content-Type: text/x-text; name=$logfile");
//   Header("Content-Type: text/x-vcard; name=$logfile");
   echo "\n\n\n".$Str;

} else {
   echo "<html><head><title>ERROR</title></head><body>";
   echo "<p>Sorry, $uri could not be transformed by xtml2vcard.xsl into";
   echo " an vCard file because of " . xslt_error($xp);
   echo " and the error code is " . xslt_errno($xp)."";
   echo " check that this page validates: <a href=\"http://validator.w3.org/check?uri=$uri\">http://validator.w3.org/check?uri=$uri</a>";
   echo "</p></body></html>";
}
}

xslt_free($xp);

} else {
// DISPLAY page to manually enter a URL
   Header("Location: index.php");
}

?>