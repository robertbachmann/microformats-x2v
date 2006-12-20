<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
 xmlns:xsl ="http://www.w3.org/1999/XSL/Transform"
 xmlns:mf  ="http://suda.co.uk/projects/microformats/mf-templates.xsl?template="
 xmlns     ="http://earth.google.com/kml/2.0"
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

XHTML-2-KML
Version 0.2
2006-11-08

Copyright 2006 Brian Suda
This work is relicensed under The W3C Open Source License
http://www.w3.org/Consortium/Legal/copyright-software-19980720

-->

<xsl:param name="Source" />
<xsl:param name="Anchor" />

<xsl:template match="/">
<kml xmlns="http://earth.google.com/kml/2.0">
<Folder>
<name>
<xsl:value-of select="//*[name() = 'title']" />
</name>
	<xsl:apply-templates select=".//*[contains(concat(' ',normalize-space(@class),' '),' vcard ') and descendant::*[contains(concat(' ',normalize-space(@class),' '),' fn ')]]"/>
</Folder>
</kml>
</xsl:template>

<!-- Each vCard is listed in succession -->
<xsl:template match="*[contains(concat(' ',normalize-space(@class),' '),' vcard ') and descendant::*[contains(concat(' ',normalize-space(@class),' '),' fn ')] and descendant::*[contains(concat(' ',normalize-space(@class),' '),' geo ')]]">
	<xsl:if test="not($Anchor) or @id = $Anchor">
		<Placemark>
			<Style>
				<LineStyle>
					<color>cc0000ff</color>
					<width>5.0</width>
				</LineStyle>
			</Style>
		
			<xsl:call-template name="mf:doIncludes"/>
			<xsl:call-template name="properties"/>
		</Placemark>
	</xsl:if>
</xsl:template>

<xsl:template name="properties">
	<xsl:for-each select=".//*[ancestor-or-self::*[name() = 'del'] = false() and contains(concat(' ', normalize-space(@class), ' '),' fn ')][1]">
		<name><xsl:call-template name="mf:extractText" /></name>
	</xsl:for-each>
	
	<xsl:for-each select=".//*[ancestor-or-self::*[name() = 'del'] = false() and contains(concat(' ', normalize-space(@class), ' '),' geo ')][1]">
		<Point>
			<coordinates>
				<xsl:call-template name="mf:extractGeo"/>
			</coordinates>
		</Point>
	</xsl:for-each>
</xsl:template>

<xsl:template name="geoCallBack">
	<xsl:param name="latitude"/>
	<xsl:param name="longitude"/>
	<xsl:param name="altitude"/>
	<xsl:value-of select="$longitude"/>
	<xsl:text>,</xsl:text>
	<xsl:value-of select="$latitude"/>
	<xsl:text>,</xsl:text>
	<xsl:value-of select="$altitude"/>
</xsl:template>

<xsl:template match="comment()"></xsl:template>

<!-- don't pass text thru -->
<xsl:template match="text()"></xsl:template>
</xsl:stylesheet>