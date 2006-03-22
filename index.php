<?php
if ( stristr($_SERVER["HTTP_ACCEPT"],"application/xhtml+xml") ) {
  header("Content-type: application/xhtml+xml; charset=utf-8");
}
else {
  header("Content-type: text/html; charset=utf-8");
}
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">
	<head profile="
		http://www.w3.org/2003/g/data-view
		http://dublincore.org/documents/dcq-html/
		http://gmpg.org/xfn/11"
	>
		<?php
			include '../../includes/meta.inc';
			include '../../includes/utilities.php';
		?>
		<title>suda.co.uk/projects [X2V]</title>
	</head>
	<body id="suda-co-uk">
		<div class="col300">
		<div class="center">
		<a href="http://suda.co.uk" title="suda.co.uk" accesskey="1"><img src="/images/mast.png" id="mast" alt="suda.co.uk" /></a>
		</div>
		<h1>X2V</h1>
<?php
if (isSet($_GET['error'])){
  echo '<h2 class="notice">ERROR IN TRANSFORMATION</h2>';
  switch($_GET['error']){
    case 0: echo '<p class="notice">No vCards could be found to transform. Please check the URL and site to make sure there are properly encoded.</p>'; break;
    case 1: echo '<p class="notice">No iCals could be found to transform. Please check the URL and site to make sure there are properly encoded.</p>'; break;
    case 2: echo '<p class="notice"></p>'; break;
    default: echo '<p class="notice">There has been an error with the transformation.</p>';
  }
}
?>
		<h2 id="introduction">Introduction</h2>
		<p>This is a <em>BETA</em> implementation of an <abbr title="XML Stylesheet Language Transformation" class="initialism">XSLT</abbr> file to transform and hCa* encoded <abbr title="eXtensible Hyper Text Markup Language" class="initialism">XHTML</abbr> file into the corresponding <abbr title="Virtual Card">vCard</abbr>/<abbr title="Internet Calendar">iCalendar</abbr> file. The DRAFT specification for hCa* encodings can be found at the Technorati Delevoper Wiki.</p>
		<ul>
		<li><a href="http://microformats.org/wiki/hcalendar" title="Technorati Wiki entry about hCalendar" class="external">http://microformats.org/wiki/hcalendar</a></li>
		<li><a href="http://microformats.org/wiki/hcard" title="Technorati Wiki entry about hCard" class="external">http://microformats.org/wiki/hcard</a></li>
		</ul>
		<p>As the specification become less of a moving target the <abbr title="XML Stylesheet Language Transformation" class="initialism">XSLT</abbr> file will solidify and a proper html profile created.
		</p>
		<h2 id="H2I"><abbr title="HTML iCalendar">hCalendar</abbr>-2-<abbr title="Internet Calendar">iCalendar</abbr></h2>
		<form action="get-vcal.php" method="get">
		<fieldset>
		<legend>Extract <abbr title="Internet Calendar">iCal</abbr> from <abbr title="Universal Resource Locator" class="initialism">URL</abbr></legend>
		<input type="text" size="45" value="http://suda.co.uk/projects/holidays/" name="uri" /><input type="submit" value="Generate iCal" />
		</fieldset>
		</form>
		<h2 id="H2V"><abbr title="HTML vCard">hCard</abbr>-2-<abbr title="Virtual Card">vCard</abbr></h2>
		<form action="get-vcard.php" method="get">
		<fieldset>
		<legend>Extract <abbr title="Virtual Card">vCard</abbr> from <abbr title="Universal Resource Locator" class="initialism">URL</abbr></legend>
		<input type="text" size="45" value="http://suda.co.uk/contact/" name="uri" /><input type="submit" value="Generate vCard" />
		</fieldset>
		</form>
		<h2 id="tools">Tools</h2>
		<p>These are a few tools for anyone who wants to decode hCa* data.
		</p>
		<dl>
		<dt>hCalendar</dt>
		<dd>
		<p>If you want to create buttons or links to signal that a page is hCal encoded, you can link to the X2V transformation by using the following:
<code>http://suda.co.uk/projects/X2V/get-vcal.php?uri=&lt;COMPLETE-URL-TO-YOUR-SITE&gt;</code></p>


				<p>Drag this bookmarklet to the bookmarks bar so you can grab <abbr title="Internet Calendar">iCal</abbr> data from any <abbr title="HTML iCalendar">hCal</abbr> participating <abbr title="Universal Resource Locator" class="initialism">URL</abbr>.<br />
		<a href="javascript:location.href='http://suda.co.uk/projects/X2V/get-vcal.php?uri='+escape(location.href)">Extract <abbr title="Internet Calendar">iCal</abbr> data</a> (Drag link to the Bookmarks Bar).
		</p>
		<p>The <abbr title="XML Stylesheet Language Transformation" class="initialism">XSLT</abbr> file used to transform the data is available at:</p>
		<ul>
		<li><a href="http://suda.co.uk/projects/X2V/xhtml2vcal.xsl" title="XSLT file for the transformation">http://suda.co.uk/projects/X2V/xhtml2vcal.xsl</a></li>
		</ul>
		</dd>
		<dt>hCard</dt>
		<dd><p>If you want to create buttons or links to signal that a page is hCard encoded, you can link to the X2V transformation by using the following: <code>http://suda.co.uk/projects/X2V/get-vcard.php?uri=&lt;COMPLETE-URL-TO-YOUR-SITE&gt;</code></p>
		<p>Drag this bookmarklet to the bookmarks bar so you can grab <abbr title="Virtual Card">vCard</abbr> data from any <abbr title="HTML vCard">hCard</abbr> participating <abbr title="Universal Resource Locator" class="initialism">URL</abbr>.<br />
		<a href="javascript:location.href='http://suda.co.uk/projects/X2V/get-vcard.php?uri='+escape(location.href)">Extract <abbr title="Virtual Card">vCard</abbr> data</a> (Drag link to the Bookmarks Bar)
		</p>
				<p>The <abbr title="XML Stylesheet Language Transformation" class="initialism">XSLT</abbr> file used to transform the data is available at:</p>
		<ul>
		<li><a href="http://suda.co.uk/projects/X2V/xhtml2vcard.xsl" title="XSLT file for the transformation">http://suda.co.uk/projects/X2V/xhtml2vcard.xsl</a></li>
		</ul>
		</dd>
		</dl>
		<h2 id="implementations">Implementations</h2>
		<p><a href="http://technorati.com/" class="external">Technorati</a> uses these files in two of their feed services. They are using slightly older, stable versions of the <abbr title="XML Stylesheet Language Transformation" class="initialism">XSLT</abbr> files, but their servers are faster and more reliable than my site. Feel free to use either of our web services.</p>
		<ul>
			<li><a href="http://feeds.technorati.com/contacts/" class="external">http://feeds.technorati.org/contacts/</a></li>
			<li><a href="http://feeds.technorati.com/events/" class="external">http://feeds.technorati.com/events/</a></li>
		</ul>
		<h2 id="copyright">Copyleft</h2>
		<p>The <abbr title="XML Stylesheet Language Transformation" class="initialism">XSLT</abbr> files have been relicensed and are available for download under the <a class="external"
href="http://www.w3.org/Consortium/Legal/copyright-software-19980720">
W3C Open Source License</a>.</p>
		<?php
			include '../../includes/foot.inc';
		?>
		</div>
	</body>
</html>