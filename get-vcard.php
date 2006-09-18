<?php
/* --------------------------------------------

Brian Suda
brian@suda.co.uk
20-Sept-2004

version 1.0

NOTES:
This required PHP XSLT libraries installed


--------------------------------------------- */

// Check for URL or a referrer
$uri='';
if (isSet($_GET['referer'])) {
  if (getenv("HTTP_REFERER") != ''){ $uri = getenv("HTTP_REFERER"); }
}

// if a url is specified then use that
if (isSet($_GET['uri'])){
  if ($_GET['uri'] != ''){ $uri = $_GET['uri']; }
}

if ((substr($uri, 0,7) == "http://") || (substr($uri, 0,8) == "https://")) {
set_time_limit(90);
/*
	$info = getURLInfo($uri);

    if ($info['http_code'] == '404'){
        // This is an error, do not attempt to extract a vCard from a 404 page
        exit;
    }

	// check for encoding type
	$outputEncoding = '';
	if (isset($info['content_type'])){ $contentType = $info['content_type']; } else { $contentType = 'text/html;charset=utf-8'; }
	$lang = explode(';',$contentType);
	if (isSet($lang[1])){
        foreach($lang as $key){
            $pairs = explode('=',$key);
            if (isSet($pairs[1])){
                if (trim(strtolower($pairs[0])) == 'charset') { $outputEncoding = $pairs[1];}
            }
        }
	} else { $outputEncoding = 'utf-8'; }
*/
	$outputEncoding = 'utf-8';
	// check to see if a filename is specified
	if (isSet($_GET['filename'])){
	  if ($_GET['filename'] != ''){ $logfile = $_GET['filename']; }
	} else {$logfile = "X2V.vcf";}

	// explode on the '#' to separate the anchor link from the page
	$temp = explode("#",$uri);
    if(isSet($temp[1])){ $anchor = $temp[1]; } else { $anchor = '';}
    $temp = $temp[0];
    
	// get the URL and save that into a variable
//	$handle = fopen($uri, "r");
//	$xml_string = '';
//	while (!feof($handle)) {
//	  $xml_string .= fread($handle, 8192);
//	}
//	fclose($handle);

	$handle_tidy = fopen("http://cgi.w3.org/cgi-bin/tidy?docAddr=".urlencode($uri), "r");
	$xml_string_tidy = '';
	while (!feof($handle_tidy)) {
		$xml_string_tidy .= fread($handle_tidy, 8192);
	}
	fclose($handle_tidy);

	// This is just temporary until something better can be found
//	$xml_string = mb_convert_encoding($xml_string_tidy,$outputEncoding,'us-ascii');
	$xml_string = $xml_string_tidy;

	// this is a backdoor for myself to check new versions
	if (isSet($_GET['beta'])){
		$filename = "xhtml2vcard-beta.xsl";
	} else { 
		$filename = "xhtml2vcard.xsl"; 	
	}

	$filename = "xhtml2vcard.xsl"; 	

	// open the preflight check XSL file
	$filename_preflight = "xhtml2vcard-preflight.xsl"; 
	$handle2 = fopen($filename_preflight, "r");
	$xsl_string_preflight = fread($handle2, filesize($filename_preflight));
	fclose($handle2);

	// open the XSL file
	$handle3 = fopen($filename, "r");
	$xsl_string = fread($handle3, filesize($filename));
	fclose($handle3);

	// create an XSLT transformer instance
	$xp = xslt_create() or trigger_error('Could not create XSLT process.',E_USER_ERROR);
	xslt_set_encoding($xp, $outputEncoding);


	// set the argument buffer
	$arg_buffer_preflight = array('/xml' => $xml_string_tidy, '/xsl' => $xsl_string_preflight);
	$arg_buffer 		  = array('/xml' => $xml_string, '/xsl' => $xsl_string);

	// set the parameter buffer
	$outputEncoding = "UTF-8";
	$xsl_params = array('x-from-url'=>$uri,'Source'=>$uri,'Anchor'=>$anchor,'Encoding'=>$outputEncoding);

	$Str = '';

	// PROCESS FLOW
	// FIRST: run the $xml_string through the preflight XSL to check for major errors
	//  if failed: display HTML output
	//  else: run through other XSL

	if (($Str = @xslt_process($xp, 'arg:/xml', 'arg:/xsl', NULL, $arg_buffer_preflight, $xsl_params))){
		//$Str = mb_convert_encoding($Str,$outputEncoding,'UTF-8');
			Header("Content-Type: text/html; charset=UTF-8");
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">
	<head profile="
		http://www.w3.org/2003/g/data-view
		http://dublincore.org/documents/dcq-html/
		http://gmpg.org/xfn/11"
	>
				<!--

		(N)(O)(N)(H)(T)(M)(L)

		suda.co.uk
		Copyleft 2002-(C)-2005
		Steal Me.
		
		This site validates as xhtml 1.1

		-->

		<meta http-equiv="content-type" content="text/html;charset=UTF-8" />
		<meta http-equiv="content-language" content="en" />
		<meta http-equiv="pics-label" content='(pics-1.1 "http://www.icra.org/ratingsv02.html" comment "ICRAonline v2.0" l gen true for "http://suda.co.uk" r (nz 1 vz 1 lz 1 oz 1 cz 1) "http://www.rsac.org/ratingsv01.html" l gen true for "http://suda.co.uk"  r (n 0 s 0 v 0 l 0))' />
		<meta name="description" content="My very own piece of the web to groom, feed, and play with" />
		<meta name="keywords" content="Brian Suda, brian@suda.co.uk, Computer Science, PHP, EDI, STL, informatician" />
		<meta name="copyright" content="(c)Copyleft 2002-Some Rights Reserved, Brian Suda" />
		<meta name="author" content="Brian Suda" />
		<meta name="ICBM" content="64.1428,-21.874" />
		<meta name="DC.Date" content="2005-08-10 17:30:40Z" />
		<meta name="DC.Identifier" scheme="URI" content="http://suda.co.uk/contact/index.php" />

		<link rel="meta" type="application/rdf+xml" title="metadata" href="/includes/meta.rdf" />
		<link rel="meta" type="application/rdf+xml" title="foaf" href="/contact/brian.suda.foaf.rdf" />
		<link rel="sitemap" type="application/xml" title="sitemap" href="/sitemap.xml.php" />
		<link rel="index" href="http://suda.co.uk/" />
		<link rel="license" href="http://creativecommons.org/licenses/by-sa/1.0/" />
		<link rel="transformation" href="/includes/rdf-metadata.xsl" />		<link rel="shortcut icon" href="/favicon.ico" type="image/ico"/>

		<script type="text/javascript" src="/includes/stdfunctions.js"></script>
		<style type="text/css" media="all">@import "/includes/style.css";</style>
		<style type="text/css" media="screen">@import "/includes/layout.css";</style>
		<style type="text/css" media="print">@import "/includes/print.css";</style>
 		<title>suda.co.uk/projects/X2V/</title>
	</head>
	<body id="suda-co-uk">
		<form action="index.php" method="post">
		<div class="col300 vcard">
		<a href="http://suda.co.uk" title="suda.co.uk" accesskey="1" class="url"><img src="/images/mast.png" id="mast" alt="suda.co.uk" /></a>
		<h1>X2V ERROR</h1>

<?
			echo "<p>Sorry I'm not going to convert $uri for you just now, there are a few issues that need to be solved first.</p><p>";
			echo $Str;
			echo "</p><p>Please review the <a href=\"http://microformats.org/wiki/hcard\" class=\"external\">Microformat hCard specification</a>.";
			echo "</p>";
?>
				<ul class="toc">
			<li><a href="/publications/" title="Publications [alt+5]"             accesskey="5">publications</a></li>
			<li><a href="/projects/"     title="view/download projects [alt+6]"   accesskey="6">projects</a></li>
			<li><a href="/gallery/"      title="exhibition gallery [alt+7]"       accesskey="7">gallery</a></li>
			<li><a href="/cv/"           title="curriculum vit&aelig; [alt+8]"    accesskey="8">cv</a></li>
			<li><a href="/contact/"      title="eMail: brian@suda.co.uk [alt+9]"  accesskey="9">contact</a></li>
			<li><a href="/notes/"        title="website notes [alt+0]"            accesskey="0">notes</a></li>
		</ul>
		<br />
		<span class="printonly">
		<br />
		Copyright 2002-&copy;-2005 Brian Suda<br />
		http://suda.co.uk/projects/X2V/<br />
		Last modified: August 10 2005 17:30:40<br />
		</span>
		</div>
	</form>
	</body>
</html>
<?	
		// wrap this in HTML
		// end wrapping
	
	} else {
		// if you are here it is because there was an error in matching "error templates" (which is good because there is no error in the hCard)
		if (xslt_errno($xp) == 0){
			if (($Str = @xslt_process($xp, 'arg:/xml', 'arg:/xsl', NULL, $arg_buffer, $xsl_params))){
				//$Str = mb_convert_encoding($Str,$outputEncoding,'UTF-8');
				header("Content-Disposition: attachment; filename=$logfile");
				header("Content-Length: ".mb_strlen($Str)+1);
				header("Connection: close");
				header("Content-Type: text/x-vcard; charset=$outputEncoding name=$logfile");
				if ($outputEncoding == "UTF-16LE") { echo chr(255).chr(254); } 
				echo $Str;
			} else {
				// set the argument buffer
				$arg_buffer = array('/xml' => $xml_string_tidy, '/xsl' => $xsl_string);
	
				if (($Str = @xslt_process($xp, 'arg:/xml', 'arg:/xsl', NULL, $arg_buffer, NULL))){
					//$Str = mb_convert_encoding($Str,$outputEncoding,'UTF-8');
					header("Content-Disposition: attachment; filename=$logfile");
					header("Content-Length: ".mb_strlen($Str)+1);
					header("Connection: close");
					header("Content-Type: text/x-vcard; charset=$outputEncoding name=$logfile");
					if ($outputEncoding == "UTF-16LE") { echo chr(255).chr(254); } 
					echo $Str;
				} else {
					if (xslt_errno($xp) == 0){
						header("Location: index.php?error=0");
					} else {
						Header("Content-Type: text/html; charset=UTF-8");
						echo "<html><head><title>ERROR</title></head><body>";
						echo "<p>Sorry, $uri could not be transformed by xtml2vcard.xsl into";
						echo " an vCard file because of " . xslt_error($xp);
						echo " and the error code is " . xslt_errno($xp)."";
						echo " check that this page validates: <a href=\"http://validator.w3.org/check?uri=$uri\">http://validator.w3.org/check?uri=$uri</a>";
						echo "</p></body></html>";
					}
				}
			}
		}
	}

xslt_free($xp);

} else {
// DISPLAY page to manually enter a URL
   header("Location: index.php");
}


	function getURLInfo($url){
	error_reporting(E_ALL);

	/* Get the port for the WWW service. */
	$service_port = getservbyname('www', 'tcp');

	/* Get the IP address for the target host. */
	$hostName = explode("/",$url);
	$address = gethostbyname($hostName[2]);

	$pos = strpos($url, '/',10);

	if ($pos === false) {
	   $path = '/';
	} else {
		$path = substr($url,$pos);
	}

	/* Create a TCP/IP socket. */
	$socket = socket_create(AF_INET, SOCK_STREAM, SOL_TCP);
	if ($socket < 0) {
   	echo "socket_create() failed: reason: " . socket_strerror($socket) . "\n";
	}

	$result = socket_connect($socket, $address, $service_port);
	if ($result < 0) {
   	echo "socket_connect() failed.\nReason: ($result) " . socket_strerror($result) . "<br/>\n";
	}

	$in = "HEAD $path HTTP/1.1\r\n";
	$in .= "User-Agent: suda.co.uk/projects/X2V-0.01b\r\n";
	$in .= "Host: $hostName[2]\r\n";
	$in .= "Connection: Close\r\n\r\n";
	$out = '';
	$message = '';

	socket_write($socket, $in, strlen($in));

	while ($out = socket_read($socket, 2048)) {
   	$message .= $out;
	}

	socket_close($socket);
	$messageArray = array();
	$messageLines = explode("\n",$message);
	foreach($messageLines as $line){
		$keyval = explode(":",$line);
		if (isSet($keyval[1])){
		    switch ($keyval[0]){
		        case "Date": 
			        $messageArray['filetime'] = trim($keyval[1]);
		            break;
		        case "Content-Type": 
    		        $messageArray['content_type'] = trim($keyval[1]);
    	            break;
		        case "Content-Length": 
    		        $messageArray['size_download'] = trim($keyval[1]);
    	            break;
		        default:
    			    $messageArray[trim($keyval[0])] = trim($keyval[1]);
		            break;
		    }
		} elseif (trim($keyval[0]) != '') {
			$numberCode = explode(" ",trim($keyval[0]));
			$messageArray["http_code"] = $numberCode[1];
		}
	}

	return $messageArray;
	}
?>