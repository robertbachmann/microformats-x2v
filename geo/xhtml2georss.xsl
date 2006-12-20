<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
 xmlns:xsl ="http://www.w3.org/1999/XSL/Transform"
 xmlns:mf  ="http://suda.co.uk/projects/microformats/mf-templates.xsl?template="
 xmlns:geo ="http://www.w3.org/2003/01/geo/wgs84_pos#"
 version="1.0"
>

<xsl:import href="../mf-templates.xsl" />

<xsl:output
  encoding="UTF-8"
  indent="yes"
  method="xml"
/>

<!--
brian suda
brian@suda.co.uk
http://suda.co.uk/

XHTML-2-GeoRSS
Version 0.2
2006-11-08

Copyright 2006 Brian Suda
This work is relicensed under The W3C Open Source License
http://www.w3.org/Consortium/Legal/copyright-software-19980720

-->


<xsl:param name="Source" />
<xsl:param name="Anchor" />

<xsl:template match="/">
	<rss version="2.0">
		<channel>
			<title><xsl:value-of select="//*[name() = 'title']" /></title>
			<link><xsl:text>http://suda.co.uk/projects/microformats/geo/get-geo.php?type=georss&amp;amp;url=</xsl:text><xsl:value-of select="$Source" /></link>
			<description/>
			<xsl:apply-templates select=".//*[contains(concat(' ',normalize-space(@class),' '),' vcard ') and descendant::*[contains(concat(' ',normalize-space(@class),' '),' fn ')]]"/>
		</channel>
	</rss>
</xsl:template>

<!-- Each vCard is listed in succession -->
<xsl:template match="*[contains(concat(' ',normalize-space(@class),' '),' vcard ') and descendant::*[contains(concat(' ',normalize-space(@class),' '),' fn ')] and descendant::*[contains(concat(' ',normalize-space(@class),' '),' geo ')]]">
	<xsl:if test="not($Anchor) or @id = $Anchor">
		<item>
			<link><xsl:value-of select="$Source" /></link>

			<xsl:call-template name="mf:doIncludes"/>
			
		<xsl:call-template name="properties"/>
		</item>
	</xsl:if>
</xsl:template>


<xsl:template name="properties">
	
	<xsl:for-each select=".//*[ancestor-or-self::*[name() = 'del'] = false() and contains(concat(' ', normalize-space(@class), ' '),' fn ')][1]">
		<title><xsl:call-template name="mf:extractText"/></title>
	</xsl:for-each>

	<xsl:for-each select=".//*[ancestor-or-self::*[name() = 'del'] = false() and contains(concat(' ', normalize-space(@class), ' '),' geo ')][1]">
		<xsl:call-template name="mf:extractGeo">
			<xsl:with-param name="callBackTemplate">geoCallBack</xsl:with-param>
		</xsl:call-template>
	</xsl:for-each>	
</xsl:template>

<xsl:template name="geoCallBack">
	<xsl:param name="latitude"/>
	<xsl:param name="longitude"/>
	<xsl:param name="altitude"/>
	<geo:long><xsl:value-of select="$longitude"/></geo:long>
	<geo:lat><xsl:value-of select="$latitude"/></geo:lat>
		
</xsl:template>

<xsl:template match="comment()"></xsl:template>

<!-- don't pass text thru -->
<xsl:template match="text()"></xsl:template>
</xsl:stylesheet>
