<?php
/* --------------------------------------------

Brian Suda
brian@suda.co.uk
20-Sept-2004

version 1.0

NOTES:
This required PHP XSLT libraries installed


--------------------------------------------- */

$logfile = "X2V.vcf";

$handle = fopen("http://cgi.w3.org/cgi-bin/tidy?docAddr=".$uri, "r");
$xml = '';
while (!feof($handle)) {
  $xml .= fread($handle, 8192);
}
fclose($handle);

echo $xml;

$filename = "xhtml2vcard.xsl";
$handle2 = fopen($filename, "r");
$xsl = fread($handle2, filesize($filename));
fclose($handle2);

?>