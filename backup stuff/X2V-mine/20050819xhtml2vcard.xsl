<?xml version="1.0"?>
<xsl:stylesheet 
 xmlns:xsl ="http://www.w3.org/1999/XSL/Transform" 
 version="1.0"
>

<xsl:output
  encoding="UTF-8"
  indent="no"
  media-type="text/x-vcard"
  method="text"
/>
<!--
brian suda
brian@suda.co.uk
http://suda.co.uk/

XHTML-2-vCard
Version 0.5.1
2005-07-08

Copyright 2005 Brian Suda
This work is licensed under the Creative Commons Attribution-ShareAlike License. 
To view a copy of this license, visit 
http://creativecommons.org/licenses/by-sa/1.0/

NOTES:
Until the hCard spec has been finalised this is a work in progress.
I'm not an XSLT expert, so there are no guarantees to quality of this code!
The PHP xslt libraies and Mozilla libraies differ in implementation, so some code
might not be optimized so it works with PHP. Specifically '.', './/','.[...]'

@@ I need to add ESCAPING (func-comma-cleaner) to all templates!

@@ Need to check for additional attributes of ADR|LABEL (type=[work|home|postal|...], etc.
@@ check for profile in head element
@@ decode only the first instance of a singular property
-->

<xsl:param name="x-from-url" >(Best Practices states this should be the URL the calendar was transformed from)</xsl:param>
<xsl:param name="x-anchor" />

<!-- there is no root element in vCard -->
<xsl:template match="/">
<xsl:variable name="tab">&#x9;</xsl:variable>
<xsl:variable name="nl" >&#xA;</xsl:variable>
<xsl:variable name="rl" >&#xD;</xsl:variable>

<xsl:apply-templates select="//head[contains(@profile,'foobar')]"/>
<xsl:choose>
<xsl:when test="string-length($x-anchor) &gt; 0">
<xsl:apply-templates select="//*[@id=$x-anchor]//*[contains(concat(' ',translate(translate(translate(@class, $tab ,' '), $nl ,' '), $rl ,' '),' '),' vcard ')]|//*[contains(concat(' ',translate(translate(translate(@class, $tab ,' '), $nl ,' '), $rl ,' '),' '),'vcard')][@id=$x-anchor]"/>
</xsl:when>
<xsl:otherwise>
<xsl:apply-templates select="//*[contains(concat(' ',translate(translate(translate(@class, $tab ,' '), $nl ,' '), $rl ,' '),' '),' vcard ')]"/>
</xsl:otherwise>
</xsl:choose>



</xsl:template>

<!-- check for profile in head element -->
<xsl:template match="head[contains(concat(' ',@profile,' '),' http://foorbar ')]">
<!-- 
==================== CURRENTLY DISABLED ====================
This will call the vCard template, 
Without the correct profile you cannot assume the class values are intended for the vCard microformat.
-->
<!-- <xsl:apply-templates select="//*[contains(@class,'vcard')]"/> -->
</xsl:template>

<!-- Each vCard is listed in succession -->
<xsl:template match="*[contains(concat(' ',@class,' '),' vcard ')]">
<xsl:param name="vcard-lang">
	<xsl:choose>
		<xsl:when test="@xml:lang != ''"><xsl:value-of select="@xml:lang" /></xsl:when>
		<xsl:when test="@lang != ''"><xsl:value-of select="@lang" /></xsl:when>
	</xsl:choose>
</xsl:param>
<xsl:variable name="tab">&#x9;</xsl:variable>
<xsl:variable name="nl" >&#xA;</xsl:variable>
<xsl:variable name="rl" >&#xD;</xsl:variable>

<xsl:text>BEGIN:VCARD
PRODID:-//suda.co.uk//X2V 0.5.1 (BETA)//EN
SOURCE: </xsl:text><xsl:value-of select="$x-from-url"/>
<xsl:apply-templates select="//*[name() = 'title']" mode="htmltitle"/>
<xsl:text>
VERSION:3.0</xsl:text>
<!--<xsl:apply-templates select="@id" mode="uid"/>-->
<xsl:apply-templates select="*[contains(concat(' ',translate(translate(translate(@class, $tab ,' '), $nl ,' '), $rl ,' '),' '),' n ')]|*//*[contains(concat(' ',translate(translate(translate(@class, $tab ,' '), $nl ,' '), $rl ,' '),' '),' n ')]" mode="n">
<xsl:with-param name="vcard-lang"><xsl:value-of select="$vcard-lang" /></xsl:with-param>
</xsl:apply-templates>
<!-- Build N from FN is no N was found -->
<xsl:if test="count(*[contains(concat(' ',translate(translate(translate(@class, $tab ,' '), $nl ,' '), $rl ,' '),' '),' n ')]) = 0">
<xsl:if test="count(*//*[contains(concat(' ',translate(translate(translate(@class, $tab ,' '), $nl ,' '), $rl ,' '),' '),' n ')]) = 0">
<xsl:apply-templates select="*[contains(concat(' ',translate(translate(translate(@class, $tab ,' '), $nl ,' '), $rl ,' '),' '),' fn ')]|*//*[contains(concat(' ',translate(translate(translate(@class, $tab ,' '), $nl ,' '), $rl ,' '),' '),' fn ')]" mode="n-builder">
<xsl:with-param name="vcard-lang"><xsl:value-of select="$vcard-lang" /></xsl:with-param>
</xsl:apply-templates>
</xsl:if>
</xsl:if>
<xsl:apply-templates select="*[contains(concat(' ',translate(translate(translate(@class, $tab ,' '), $nl ,' '), $rl ,' '),' '),' fn ')]|*//*[contains(concat(' ',translate(translate(translate(@class, $tab ,' '), $nl ,' '), $rl ,' '),' '),' fn ')]" mode="fn">
<xsl:with-param name="vcard-lang"><xsl:value-of select="$vcard-lang" /></xsl:with-param>
</xsl:apply-templates>
<xsl:apply-templates select="*[contains(concat(' ',translate(translate(translate(@class, $tab ,' '), $nl ,' '), $rl ,' '),' '),' nickname ')]|*//*[contains(concat(' ',translate(translate(translate(@class, $tab ,' '), $nl ,' '), $rl ,' '),' '),' nickname ')]" mode="nickname">
<xsl:with-param name="vcard-lang"><xsl:value-of select="$vcard-lang" /></xsl:with-param>
</xsl:apply-templates>
<xsl:apply-templates select="*[contains(concat(' ',translate(translate(translate(@class, $tab ,' '), $nl ,' '), $rl ,' '),' '),' photo ')]|*//*[contains(concat(' ',translate(translate(translate(@class, $tab ,' '), $nl ,' '), $rl ,' '),' '),' photo ')]" mode="photo"/>
<xsl:apply-templates select="*[contains(concat(' ',translate(translate(translate(@class, $tab ,' '), $nl ,' '), $rl ,' '),' '),' bday ')]|*//*[contains(concat(' ',translate(translate(translate(@class, $tab ,' '), $nl ,' '), $rl ,' '),' '),' bday ')]" mode="bday"/>
<xsl:apply-templates select="*[contains(concat(' ',translate(translate(translate(@class, $tab ,' '), $nl ,' '), $rl ,' '),' '),' adr ')]|*//*[contains(concat(' ',translate(translate(translate(@class, $tab ,' '), $nl ,' '), $rl ,' '),' '),' adr ')]" mode="adr">
<xsl:with-param name="vcard-lang"><xsl:value-of select="$vcard-lang" /></xsl:with-param>
</xsl:apply-templates>
<!-- LABEL needs work! -->
<xsl:apply-templates select="*[contains(concat(' ',translate(translate(translate(@class, $tab ,' '), $nl ,' '), $rl ,' '),' '),' label ')]|*//*[contains(concat(' ',translate(translate(translate(@class, $tab ,' '), $nl ,' '), $rl ,' '),' '),' label ')]" mode="label"/>
<xsl:apply-templates select="*[contains(concat(' ',translate(translate(translate(@class, $tab ,' '), $nl ,' '), $rl ,' '),' '),' tel ')]|*//*[contains(concat(' ',translate(translate(translate(@class, $tab ,' '), $nl ,' '), $rl ,' '),' '),' tel ')]" mode="tel"/>
<xsl:apply-templates select="*[contains(concat(' ',translate(translate(translate(@class, $tab ,' '), $nl ,' '), $rl ,' '),' '),' email ')]|*//*[contains(concat(' ',translate(translate(translate(@class, $tab ,' '), $nl ,' '), $rl ,' '),' '),' email ')]" mode="email"/>
<xsl:apply-templates select="*[contains(concat(' ',translate(translate(translate(@class, $tab ,' '), $nl ,' '), $rl ,' '),' '),' mailer ')]|*//*[contains(concat(' ',translate(translate(translate(@class, $tab ,' '), $nl ,' '), $rl ,' '),' '),' mailer ')]" mode="mailer">
<xsl:with-param name="vcard-lang"><xsl:value-of select="$vcard-lang" /></xsl:with-param>
</xsl:apply-templates>
<!-- <xsl:apply-templates select="*[contains(concat(' ',translate(translate(translate(@class, $tab ,' '), $nl ,' '), $rl ,' '),' '),' tz ')]|*//*[contains(concat(' ',translate(translate(translate(@class, $tab ,' '), $nl ,' '), $rl ,' '),' '),' tz ')]" mode="tz"/> -->
<!-- <xsl:apply-templates select="*[contains(concat(' ',translate(translate(translate(@class, $tab ,' '), $nl ,' '), $rl ,' '),' '),' geo ')]|*//*[contains(concat(' ',translate(translate(translate(@class, $tab ,' '), $nl ,' '), $rl ,' '),' '),' geo ')]" mode="geo"/> -->
<xsl:apply-templates select="*[contains(concat(' ',translate(translate(translate(@class, $tab ,' '), $nl ,' '), $rl ,' '),' '),' title ')]|*//*[contains(concat(' ',translate(translate(translate(@class, $tab ,' '), $nl ,' '), $rl ,' '),' '),' title ')]" mode="title">
<xsl:with-param name="vcard-lang"><xsl:value-of select="$vcard-lang" /></xsl:with-param>
</xsl:apply-templates>
<xsl:apply-templates select="*[contains(concat(' ',translate(translate(translate(@class, $tab ,' '), $nl ,' '), $rl ,' '),' '),' role ')]|*//*[contains(concat(' ',translate(translate(translate(@class, $tab ,' '), $nl ,' '), $rl ,' '),' '),' role ')]" mode="role">
<xsl:with-param name="vcard-lang"><xsl:value-of select="$vcard-lang" /></xsl:with-param>
</xsl:apply-templates>
<xsl:apply-templates select="*[contains(concat(' ',translate(translate(translate(@class, $tab ,' '), $nl ,' '), $rl ,' '),' '),' logo ')]|*//*[contains(concat(' ',translate(translate(translate(@class, $tab ,' '), $nl ,' '), $rl ,' '),' '),' logo ')]" mode="logo"/>
<!-- <xsl:apply-templates select="*[contains(concat(' ',translate(translate(translate(@class, $tab ,' '), $nl ,' '), $rl ,' '),' '),' agent ')]|*//*[contains(concat(' ',translate(translate(translate(@class, $tab ,' '), $nl ,' '), $rl ,' '),' '),' agent ')]" mode="agent"/> -->
<xsl:apply-templates select="*[contains(concat(' ',translate(translate(translate(@class, $tab ,' '), $nl ,' '), $rl ,' '),' '),' org ')]|*//*[contains(concat(' ',translate(translate(translate(@class, $tab ,' '), $nl ,' '), $rl ,' '),' '),' org ')]" mode="org">
<xsl:with-param name="vcard-lang"><xsl:value-of select="$vcard-lang" /></xsl:with-param>
</xsl:apply-templates>
<xsl:apply-templates select="*[contains(concat(' ',translate(translate(translate(@class, $tab ,' '), $nl ,' '), $rl ,' '),' '),' categories ')]|*//*[contains(concat(' ',translate(translate(translate(@class, $tab ,' '), $nl ,' '), $rl ,' '),' '),' categories ')]" mode="categories">
<xsl:with-param name="vcard-lang"><xsl:value-of select="$vcard-lang" /></xsl:with-param>
</xsl:apply-templates>
<xsl:apply-templates select="*[contains(concat(' ',translate(translate(translate(@class, $tab ,' '), $nl ,' '), $rl ,' '),' '),' note ')]|*//*[contains(concat(' ',translate(translate(translate(@class, $tab ,' '), $nl ,' '), $rl ,' '),' '),' note ')]" mode="note">
<xsl:with-param name="vcard-lang"><xsl:value-of select="$vcard-lang" /></xsl:with-param>
</xsl:apply-templates>
<xsl:apply-templates select="*[contains(concat(' ',translate(translate(translate(@class, $tab ,' '), $nl ,' '), $rl ,' '),' '),' rev ')]|*//*[contains(concat(' ',translate(translate(translate(@class, $tab ,' '), $nl ,' '), $rl ,' '),' '),' rev ')]" mode="rev"/>
<xsl:apply-templates select="*[contains(concat(' ',translate(translate(translate(@class, $tab ,' '), $nl ,' '), $rl ,' '),' '),' sort-string ')]|*//*[contains(concat(' ',translate(translate(translate(@class, $tab ,' '), $nl ,' '), $rl ,' '),' '),' sort-string ')]" mode="sort-string">
<xsl:with-param name="vcard-lang"><xsl:value-of select="$vcard-lang" /></xsl:with-param>
</xsl:apply-templates>
<xsl:apply-templates select="*[contains(concat(' ',translate(translate(translate(@class, $tab ,' '), $nl ,' '), $rl ,' '),' '),' sound ')]|*//*[contains(concat(' ',translate(translate(translate(@class, $tab ,' '), $nl ,' '), $rl ,' '),' '),' sound ')]" mode="sound"/>
<xsl:apply-templates select="*[contains(concat(' ',translate(translate(translate(@class, $tab ,' '), $nl ,' '), $rl ,' '),' '),' url ')]|*//*[contains(concat(' ',translate(translate(translate(@class, $tab ,' '), $nl ,' '), $rl ,' '),' '),' url ')]" mode="url"/>
<xsl:apply-templates select="*[contains(concat(' ',translate(translate(translate(@class, $tab ,' '), $nl ,' '), $rl ,' '),' '),' class ')]|*//*[contains(concat(' ',translate(translate(translate(@class, $tab ,' '), $nl ,' '), $rl ,' '),' '),' class ')]" mode="class"/>
<xsl:apply-templates select="*[contains(concat(' ',translate(translate(translate(@class, $tab ,' '), $nl ,' '), $rl ,' '),' '),' key ')]|*//*[contains(concat(' ',translate(translate(translate(@class, $tab ,' '), $nl ,' '), $rl ,' '),' '),' key ')]" mode="key"/>
<xsl:text>
END:VCARD
</xsl:text>
</xsl:template>

<!-- ============== working templates ================= -->
<!-- UID property -->
<xsl:template match="@id" mode="uid">
UID:<xsl:value-of select="." />
</xsl:template>

<!-- REV property -->
<xsl:template match="*[contains(@class,'rev')]" mode="rev">
<xsl:text>
REV:</xsl:text>
<xsl:choose>
	<xsl:when test="@longdesc != ''">
		<xsl:call-template name="func-comma-cleaner">
			<xsl:with-param name="text-string"><xsl:value-of select="normalize-space(@longdesc)" /></xsl:with-param>
		</xsl:call-template>
	</xsl:when>
	<xsl:when test="@alt != ''">
		<xsl:call-template name="func-comma-cleaner">
			<xsl:with-param name="text-string"><xsl:value-of select="normalize-space(@alt)" /></xsl:with-param>
		</xsl:call-template>
	</xsl:when>
	<xsl:when test="@title != ''">
		<xsl:call-template name="func-comma-cleaner">
			<xsl:with-param name="text-string"><xsl:value-of select="normalize-space(@title)" /></xsl:with-param>
		</xsl:call-template>
	</xsl:when>
	<xsl:otherwise>
		<xsl:call-template name="func-comma-cleaner">
			<xsl:with-param name="text-string"><xsl:value-of select="normalize-space(.)" /></xsl:with-param>
		</xsl:call-template>
	</xsl:otherwise>
</xsl:choose>
</xsl:template>

<!-- FN property -->
<xsl:template match="*[contains(@class,'fn')]" mode="fn">
<xsl:param name="vcard-lang" />
<xsl:text>
FN</xsl:text>
<xsl:choose>
	<xsl:when test="@xml:lang != ''">
		<xsl:text>;LANGUAGE=</xsl:text><xsl:value-of select="@xml:lang" />
	</xsl:when>
	<xsl:when test="@lang != ''">
		<xsl:text>;LANGUAGE=</xsl:text><xsl:value-of select="@lang" />
	</xsl:when>
	<xsl:when test="$vcard-lang != ''">
		<xsl:text>;LANGUAGE=</xsl:text><xsl:value-of select="$vcard-lang" />
	</xsl:when>
</xsl:choose>
<xsl:text>:</xsl:text>
<xsl:choose>
	<xsl:when test="@longdesc != ''">
		<xsl:call-template name="func-comma-cleaner">
			<xsl:with-param name="text-string"><xsl:value-of select="normalize-space(@longdesc)" /></xsl:with-param>
		</xsl:call-template>
	</xsl:when>
	<xsl:when test="@alt != ''">
		<xsl:call-template name="func-comma-cleaner">
			<xsl:with-param name="text-string"><xsl:value-of select="normalize-space(@alt)" /></xsl:with-param>
		</xsl:call-template>
	</xsl:when>
	<xsl:when test="@title != ''">
		<xsl:call-template name="func-comma-cleaner">
			<xsl:with-param name="text-string"><xsl:value-of select="normalize-space(@title)" /></xsl:with-param>
		</xsl:call-template>
	</xsl:when>
	<xsl:otherwise>
		<xsl:call-template name="func-comma-cleaner">
			<xsl:with-param name="text-string"><xsl:value-of select="normalize-space(.)" /></xsl:with-param>
		</xsl:call-template>
	</xsl:otherwise>
</xsl:choose>
</xsl:template>

<!-- MAILER property -->
<xsl:template match="*[contains(@class,'mailer')]" mode="mailer">
<xsl:param name="vcard-lang" />
<xsl:text>
MAILER</xsl:text>
<xsl:choose>
	<xsl:when test="@xml:lang != ''">
		<xsl:text>;LANGUAGE=</xsl:text><xsl:value-of select="@xml:lang" />
	</xsl:when>
	<xsl:when test="@lang != ''">
		<xsl:text>;LANGUAGE=</xsl:text><xsl:value-of select="@lang" />
	</xsl:when>
	<xsl:when test="$vcard-lang != ''">
		<xsl:text>;LANGUAGE=</xsl:text><xsl:value-of select="$vcard-lang" />
	</xsl:when>
</xsl:choose>
<xsl:text>:</xsl:text>
<xsl:choose>
	<xsl:when test="@longdesc != ''">
		<xsl:call-template name="func-comma-cleaner">
			<xsl:with-param name="text-string"><xsl:value-of select="normalize-space(@longdesc)" /></xsl:with-param>
		</xsl:call-template>
	</xsl:when>
	<xsl:when test="@alt != ''">
		<xsl:call-template name="func-comma-cleaner">
			<xsl:with-param name="text-string"><xsl:value-of select="normalize-space(@alt)" /></xsl:with-param>
		</xsl:call-template>
	</xsl:when>
	<xsl:when test="@title != ''">
		<xsl:call-template name="func-comma-cleaner">
			<xsl:with-param name="text-string"><xsl:value-of select="normalize-space(@title)" /></xsl:with-param>
		</xsl:call-template>
	</xsl:when>
	<xsl:otherwise>
		<xsl:call-template name="func-comma-cleaner">
			<xsl:with-param name="text-string"><xsl:value-of select="normalize-space(.)" /></xsl:with-param>
		</xsl:call-template>
	</xsl:otherwise>
</xsl:choose>
</xsl:template>

<!-- TITLE property -->
<xsl:template match="*[contains(@class,'title')]" mode="title">
<xsl:param name="vcard-lang" />
<xsl:text>
TITLE</xsl:text>
<xsl:choose>
	<xsl:when test="@xml:lang != ''">
		<xsl:text>;LANGUAGE=</xsl:text><xsl:value-of select="@xml:lang" />
	</xsl:when>
	<xsl:when test="@lang != ''">
		<xsl:text>;LANGUAGE=</xsl:text><xsl:value-of select="@lang" />
	</xsl:when>
	<xsl:when test="$vcard-lang != ''">
		<xsl:text>;LANGUAGE=</xsl:text><xsl:value-of select="$vcard-lang" />
	</xsl:when>
</xsl:choose>
<xsl:text>:</xsl:text>
<xsl:choose>
	<xsl:when test="@longdesc != ''">
		<xsl:call-template name="func-comma-cleaner">
			<xsl:with-param name="text-string"><xsl:value-of select="normalize-space(@longdesc)" /></xsl:with-param>
		</xsl:call-template>
	</xsl:when>
	<xsl:when test="@alt != ''">
		<xsl:call-template name="func-comma-cleaner">
			<xsl:with-param name="text-string"><xsl:value-of select="normalize-space(@alt)" /></xsl:with-param>
		</xsl:call-template>
	</xsl:when>
	<xsl:when test="@title != ''">
		<xsl:call-template name="func-comma-cleaner">
			<xsl:with-param name="text-string"><xsl:value-of select="normalize-space(@title)" /></xsl:with-param>
		</xsl:call-template>
	</xsl:when>
	<xsl:otherwise>
		<xsl:call-template name="func-comma-cleaner">
			<xsl:with-param name="text-string"><xsl:value-of select="normalize-space(.)" /></xsl:with-param>
		</xsl:call-template>
	</xsl:otherwise>
</xsl:choose>
</xsl:template>

<!-- ROLE property -->
<xsl:template match="*[contains(@class,'role')]" mode="role">
<xsl:param name="vcard-lang" />
<xsl:text>
ROLE</xsl:text>
<xsl:choose>
	<xsl:when test="@xml:lang != ''">
		<xsl:text>;LANGUAGE=</xsl:text><xsl:value-of select="@xml:lang" />
	</xsl:when>
	<xsl:when test="@lang != ''">
		<xsl:text>;LANGUAGE=</xsl:text><xsl:value-of select="@lang" />
	</xsl:when>
	<xsl:when test="$vcard-lang != ''">
		<xsl:text>;LANGUAGE=</xsl:text><xsl:value-of select="$vcard-lang" />
	</xsl:when>

</xsl:choose>
<xsl:text>:</xsl:text>
<xsl:choose>
	<xsl:when test="@longdesc != ''">
		<xsl:call-template name="func-comma-cleaner">
			<xsl:with-param name="text-string"><xsl:value-of select="normalize-space(@longdesc)" /></xsl:with-param>
		</xsl:call-template>
	</xsl:when>
	<xsl:when test="@alt != ''">
		<xsl:call-template name="func-comma-cleaner">
			<xsl:with-param name="text-string"><xsl:value-of select="normalize-space(@alt)" /></xsl:with-param>
		</xsl:call-template>
	</xsl:when>
	<xsl:when test="@title != ''">
		<xsl:call-template name="func-comma-cleaner">
			<xsl:with-param name="text-string"><xsl:value-of select="normalize-space(@title)" /></xsl:with-param>
		</xsl:call-template>
	</xsl:when>
	<xsl:otherwise>
		<xsl:call-template name="func-comma-cleaner">
			<xsl:with-param name="text-string"><xsl:value-of select="normalize-space(.)" /></xsl:with-param>
		</xsl:call-template>
	</xsl:otherwise>
</xsl:choose>
</xsl:template>


<!-- SORT-STRING property -->
<xsl:template match="*[contains(@class,'sort-string')]" mode="sort-string">
<xsl:param name="vcard-lang" />
<xsl:text>
SORT-STRING</xsl:text>
<xsl:choose>
	<xsl:when test="@xml:lang != ''">
		<xsl:text>;LANGUAGE=</xsl:text><xsl:value-of select="@xml:lang" />
	</xsl:when>
	<xsl:when test="@lang != ''">
		<xsl:text>;LANGUAGE=</xsl:text><xsl:value-of select="@lang" />
	</xsl:when>
	<xsl:when test="$vcard-lang != ''">
		<xsl:text>;LANGUAGE=</xsl:text><xsl:value-of select="$vcard-lang" />
	</xsl:when>
</xsl:choose>
<xsl:text>:</xsl:text>
<xsl:choose>
	<xsl:when test="@longdesc != ''">
		<xsl:call-template name="func-comma-cleaner">
			<xsl:with-param name="text-string"><xsl:value-of select="normalize-space(@longdesc)" /></xsl:with-param>
		</xsl:call-template>
	</xsl:when>
	<xsl:when test="@alt != ''">
		<xsl:call-template name="func-comma-cleaner">
			<xsl:with-param name="text-string"><xsl:value-of select="normalize-space(@alt)" /></xsl:with-param>
		</xsl:call-template>
	</xsl:when>
	<xsl:when test="@title != ''">
		<xsl:call-template name="func-comma-cleaner">
			<xsl:with-param name="text-string"><xsl:value-of select="normalize-space(@title)" /></xsl:with-param>
		</xsl:call-template>
	</xsl:when>
	<xsl:otherwise>
		<xsl:call-template name="func-comma-cleaner">
			<xsl:with-param name="text-string"><xsl:value-of select="normalize-space(.)" /></xsl:with-param>
		</xsl:call-template>
	</xsl:otherwise>
</xsl:choose>
</xsl:template>

<!-- NOTE property -->
<xsl:template match="*[contains(@class,'note')]" mode="note">
<xsl:param name="vcard-lang" />
<xsl:text>
NOTE</xsl:text>
<xsl:choose>
	<xsl:when test="@xml:lang != ''">
		<xsl:text>;LANGUAGE=</xsl:text><xsl:value-of select="@xml:lang" />
	</xsl:when>
	<xsl:when test="@lang != ''">
		<xsl:text>;LANGUAGE=</xsl:text><xsl:value-of select="@lang" />
	</xsl:when>
	<xsl:when test="$vcard-lang != ''">
		<xsl:text>;LANGUAGE=</xsl:text><xsl:value-of select="$vcard-lang" />
	</xsl:when>
</xsl:choose>
<xsl:text>:</xsl:text>
<xsl:choose>
	<xsl:when test="@longdesc != ''">
		<xsl:call-template name="func-comma-cleaner">
			<xsl:with-param name="text-string"><xsl:value-of select="normalize-space(@longdesc)" /></xsl:with-param>
		</xsl:call-template>
	</xsl:when>
	<xsl:when test="@alt != ''">
		<xsl:call-template name="func-comma-cleaner">
			<xsl:with-param name="text-string"><xsl:value-of select="normalize-space(@alt)" /></xsl:with-param>
		</xsl:call-template>
	</xsl:when>
	<xsl:when test="@title != ''">
		<xsl:call-template name="func-comma-cleaner">
			<xsl:with-param name="text-string"><xsl:value-of select="normalize-space(@title)" /></xsl:with-param>
		</xsl:call-template>
	</xsl:when>
	<xsl:otherwise>
		<xsl:call-template name="func-comma-cleaner">
			<xsl:with-param name="text-string"><xsl:value-of select="normalize-space(.)" /></xsl:with-param>
		</xsl:call-template>
	</xsl:otherwise>
</xsl:choose>
</xsl:template>

<!-- TEL property -->
<xsl:template match="*[contains(@class,'tel')]" mode="tel">
<xsl:choose>
	<xsl:when test="*[contains(concat(' ',@class,' '),' home ')]|*[contains(concat(' ',@class,' '),' work ')]|*[contains(concat(' ',@class,' '),' pref ')]|*[contains(concat(' ',@class,' '),' voice ')]|*[contains(concat(' ',@class,' '),' fax ')]|*[contains(concat(' ',@class,' '),' msg ')]|*[contains(concat(' ',@class,' '),' cell ')]|*[contains(concat(' ',@class,' '),' pager ')]|*[contains(concat(' ',@class,' '),' bbs ')]|*[contains(concat(' ',@class,' '),' modem ')]|*[contains(concat(' ',@class,' '),' car ')]|*[contains(concat(' ',@class,' '),' isdn ')]|*[contains(concat(' ',@class,' '),' video ')]|*[contains(concat(' ',@class,' '),' pcs ')]">
		<xsl:for-each select="*">
			<xsl:text>
TEL;TYPE=</xsl:text>
			<xsl:if test="descendant-or-self::node()[contains(concat(' ',@class,' '),' home ')]"><xsl:text>home</xsl:text>
			<xsl:if test="descendant-or-self::node()[contains(concat(' ',@class,' '),' work ')]|descendant-or-self::node()[contains(concat(' ',@class,' '),' pref ')]|descendant-or-self::node()[contains(concat(' ',@class,' '),' voice ')]|descendant-or-self::node()[contains(concat(' ',@class,' '),' fax ')]|descendant-or-self::node()[contains(concat(' ',@class,' '),' msg ')]|descendant-or-self::node()[contains(concat(' ',@class,' '),' cell ')]|descendant-or-self::node()[contains(concat(' ',@class,' '),' pager ')]|descendant-or-self::node()[contains(concat(' ',@class,' '),' bbs ')]|descendant-or-self::node()[contains(concat(' ',@class,' '),' modem ')]|descendant-or-self::node()[contains(concat(' ',@class,' '),' car ')]|descendant-or-self::node()[contains(concat(' ',@class,' '),' isdn ')]|descendant-or-self::node()[contains(concat(' ',@class,' '),' video ')]|descendant-or-self::node()[contains(concat(' ',@class,' '),' pcs ')]">,</xsl:if></xsl:if>
			<xsl:if test="descendant-or-self::node()[contains(concat(' ',@class,' '),' work ')]"><xsl:text>work</xsl:text>
			<xsl:if test="descendant-or-self::node()[contains(concat(' ',@class,' '),' pref ')]|descendant-or-self::node()[contains(concat(' ',@class,' '),' voice ')]|descendant-or-self::node()[contains(concat(' ',@class,' '),' fax ')]|descendant-or-self::node()[contains(concat(' ',@class,' '),' msg ')]|descendant-or-self::node()[contains(concat(' ',@class,' '),' cell ')]|descendant-or-self::node()[contains(concat(' ',@class,' '),' pager ')]|descendant-or-self::node()[contains(concat(' ',@class,' '),' bbs ')]|descendant-or-self::node()[contains(concat(' ',@class,' '),' modem ')]|descendant-or-self::node()[contains(concat(' ',@class,' '),' car ')]|descendant-or-self::node()[contains(concat(' ',@class,' '),' isdn ')]|descendant-or-self::node()[contains(concat(' ',@class,' '),' video ')]|descendant-or-self::node()[contains(concat(' ',@class,' '),' pcs ')]">,</xsl:if></xsl:if>
			<xsl:if test="descendant-or-self::node()[contains(concat(' ',@class,' '),' pref ')]"><xsl:text>pref</xsl:text>
			<xsl:if test="descendant-or-self::node()[contains(concat(' ',@class,' '),' voice ')]|descendant-or-self::node()[contains(concat(' ',@class,' '),' fax ')]|descendant-or-self::node()[contains(concat(' ',@class,' '),' msg ')]|descendant-or-self::node()[contains(concat(' ',@class,' '),' cell ')]|descendant-or-self::node()[contains(concat(' ',@class,' '),' pager ')]|descendant-or-self::node()[contains(concat(' ',@class,' '),' bbs ')]|descendant-or-self::node()[contains(concat(' ',@class,' '),' modem ')]|descendant-or-self::node()[contains(concat(' ',@class,' '),' car ')]|descendant-or-self::node()[contains(concat(' ',@class,' '),' isdn ')]|descendant-or-self::node()[contains(concat(' ',@class,' '),' video ')]|descendant-or-self::node()[contains(concat(' ',@class,' '),' pcs ')]">,</xsl:if></xsl:if>
			<xsl:if test="descendant-or-self::node()[contains(concat(' ',@class,' '),' voice ')]"><xsl:text>voice</xsl:text>
			<xsl:if test="descendant-or-self::node()[contains(concat(' ',@class,' '),' fax ')]|descendant-or-self::node()[contains(concat(' ',@class,' '),' msg ')]|descendant-or-self::node()[contains(concat(' ',@class,' '),' cell ')]|descendant-or-self::node()[contains(concat(' ',@class,' '),' pager ')]|descendant-or-self::node()[contains(concat(' ',@class,' '),' bbs ')]|descendant-or-self::node()[contains(concat(' ',@class,' '),' modem ')]|descendant-or-self::node()[contains(concat(' ',@class,' '),' car ')]|descendant-or-self::node()[contains(concat(' ',@class,' '),' isdn ')]|descendant-or-self::node()[contains(concat(' ',@class,' '),' video ')]|descendant-or-self::node()[contains(concat(' ',@class,' '),' pcs ')]">,</xsl:if></xsl:if>
			<xsl:if test="descendant-or-self::node()[contains(concat(' ',@class,' '),' fax ')]"><xsl:text>fax</xsl:text>
			<xsl:if test="descendant-or-self::node()[contains(concat(' ',@class,' '),' msg ')]|descendant-or-self::node()[contains(concat(' ',@class,' '),' cell ')]|descendant-or-self::node()[contains(concat(' ',@class,' '),' pager ')]|descendant-or-self::node()[contains(concat(' ',@class,' '),' bbs ')]|descendant-or-self::node()[contains(concat(' ',@class,' '),' modem ')]|descendant-or-self::node()[contains(concat(' ',@class,' '),' car ')]|descendant-or-self::node()[contains(concat(' ',@class,' '),' isdn ')]|descendant-or-self::node()[contains(concat(' ',@class,' '),' video ')]|descendant-or-self::node()[contains(concat(' ',@class,' '),' pcs ')]">,</xsl:if></xsl:if>
			<xsl:if test="descendant-or-self::node()[contains(concat(' ',@class,' '),' msg ')]"><xsl:text>msg</xsl:text>
			<xsl:if test="descendant-or-self::node()[contains(concat(' ',@class,' '),' cell ')]|descendant-or-self::node()[contains(concat(' ',@class,' '),' pager ')]|descendant-or-self::node()[contains(concat(' ',@class,' '),' bbs ')]|descendant-or-self::node()[contains(concat(' ',@class,' '),' modem ')]|descendant-or-self::node()[contains(concat(' ',@class,' '),' car ')]|descendant-or-self::node()[contains(concat(' ',@class,' '),' isdn ')]|descendant-or-self::node()[contains(concat(' ',@class,' '),' video ')]|descendant-or-self::node()[contains(concat(' ',@class,' '),' pcs ')]">,</xsl:if></xsl:if>
			<xsl:if test="descendant-or-self::node()[contains(concat(' ',@class,' '),' cell ')]"><xsl:text>cell</xsl:text>
			<xsl:if test="descendant-or-self::node()[contains(concat(' ',@class,' '),' pager ')]|descendant-or-self::node()[contains(concat(' ',@class,' '),' bbs ')]|descendant-or-self::node()[contains(concat(' ',@class,' '),' modem ')]|descendant-or-self::node()[contains(concat(' ',@class,' '),' car ')]|descendant-or-self::node()[contains(concat(' ',@class,' '),' isdn ')]|descendant-or-self::node()[contains(concat(' ',@class,' '),' video ')]|descendant-or-self::node()[contains(concat(' ',@class,' '),' pcs ')]">,</xsl:if></xsl:if>			
			<xsl:if test="descendant-or-self::node()[contains(concat(' ',@class,' '),' pager ')]"><xsl:text>pager</xsl:text>
			<xsl:if test="descendant-or-self::node()[contains(concat(' ',@class,' '),' bbs ')]|descendant-or-self::node()[contains(concat(' ',@class,' '),' modem ')]|descendant-or-self::node()[contains(concat(' ',@class,' '),' car ')]|descendant-or-self::node()[contains(concat(' ',@class,' '),' isdn ')]|descendant-or-self::node()[contains(concat(' ',@class,' '),' video ')]|descendant-or-self::node()[contains(concat(' ',@class,' '),' pcs ')]">,</xsl:if></xsl:if>				<xsl:if test="descendant-or-self::node()[contains(concat(' ',@class,' '),' bbs ')]"><xsl:text>bbs</xsl:text>
			<xsl:if test="descendant-or-self::node()[contains(concat(' ',@class,' '),' modem ')]|descendant-or-self::node()[contains(concat(' ',@class,' '),' car ')]|descendant-or-self::node()[contains(concat(' ',@class,' '),' isdn ')]|descendant-or-self::node()[contains(concat(' ',@class,' '),' video ')]|descendant-or-self::node()[contains(concat(' ',@class,' '),' pcs ')]">,</xsl:if></xsl:if>			
			<xsl:if test="descendant-or-self::node()[contains(concat(' ',@class,' '),' modem ')]"><xsl:text>modem</xsl:text>
			<xsl:if test="descendant-or-self::node()[contains(concat(' ',@class,' '),' car ')]|descendant-or-self::node()[contains(concat(' ',@class,' '),' isdn ')]|descendant-or-self::node()[contains(concat(' ',@class,' '),' video ')]|descendant-or-self::node()[contains(concat(' ',@class,' '),' pcs ')]">,</xsl:if></xsl:if>			
			<xsl:if test="descendant-or-self::node()[contains(concat(' ',@class,' '),' car ')]"><xsl:text>car</xsl:text>
			<xsl:if test="descendant-or-self::node()[contains(concat(' ',@class,' '),' isdn ')]|descendant-or-self::node()[contains(concat(' ',@class,' '),' video ')]|descendant-or-self::node()[contains(concat(' ',@class,' '),' pcs ')]">,</xsl:if></xsl:if>			
			<xsl:if test="descendant-or-self::node()[contains(concat(' ',@class,' '),' isdn ')]"><xsl:text>isdn</xsl:text>
			<xsl:if test="descendant-or-self::node()[contains(concat(' ',@class,' '),' video ')]|descendant-or-self::node()[contains(concat(' ',@class,' '),' pcs ')]">,</xsl:if></xsl:if>			
			<xsl:if test="descendant-or-self::node()[contains(concat(' ',@class,' '),' video ')]"><xsl:text>video</xsl:text>
			<xsl:if test="descendant-or-self::node()[contains(concat(' ',@class,' '),' pcs ')]">,</xsl:if></xsl:if>			
			<xsl:if test="descendant-or-self::node()[contains(concat(' ',@class,' '),' pcs ')]"><xsl:text>pcs</xsl:text></xsl:if>
			<xsl:text>:</xsl:text>
			<xsl:choose>
				<xsl:when test="@href != ''">
					<xsl:value-of select="substring-after(@href,':')" />
				</xsl:when>
				<xsl:when test="@src != ''">
					<xsl:value-of select="normalize-space(substring-after(@src,':'))" />
				</xsl:when>
				<xsl:when test="@longdesc != ''">
					<xsl:value-of select="normalize-space(@longdesc)" />
				</xsl:when>
				<xsl:when test="@alt != ''">
					<xsl:value-of select="normalize-space(@alt)" />
				</xsl:when>
				<xsl:when test="@title != ''">
					<xsl:value-of select="normalize-space(@title)" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="normalize-space(.)" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>
	</xsl:when>
	<xsl:otherwise>
<xsl:text>
TEL:</xsl:text>
	<xsl:choose>
		<xsl:when test="@href != ''">
			<xsl:call-template name="func-comma-cleaner">
				<xsl:with-param name="text-string"><xsl:value-of select="normalize-space(substring-after(@href,':'))" /></xsl:with-param>
			</xsl:call-template>
		</xsl:when>
		<xsl:when test="@src != ''">
			<xsl:call-template name="func-comma-cleaner">
				<xsl:with-param name="text-string"><xsl:value-of select="normalize-space(substring-after(@src,':'))" /></xsl:with-param>
			</xsl:call-template>
		</xsl:when>
		<xsl:when test="@longdesc != ''">
			<xsl:call-template name="func-comma-cleaner">
				<xsl:with-param name="text-string"><xsl:value-of select="normalize-space(@longdesc)" /></xsl:with-param>
			</xsl:call-template>
		</xsl:when>
		<xsl:when test="@alt != ''">
			<xsl:call-template name="func-comma-cleaner">
				<xsl:with-param name="text-string"><xsl:value-of select="normalize-space(@alt)" /></xsl:with-param>
			</xsl:call-template>
		</xsl:when>
		<xsl:when test="@title != ''">
			<xsl:call-template name="func-comma-cleaner">
				<xsl:with-param name="text-string"><xsl:value-of select="normalize-space(@title)" /></xsl:with-param>
			</xsl:call-template>
		</xsl:when>
		<xsl:otherwise>
			<xsl:call-template name="func-comma-cleaner">
				<xsl:with-param name="text-string"><xsl:value-of select="normalize-space(.)" /></xsl:with-param>
			</xsl:call-template>
		</xsl:otherwise>
	</xsl:choose>
</xsl:otherwise>
</xsl:choose>
<!--
<xsl:for-each select="*[contains(@class,'work')]|*[contains(@class,'home')]|*[contains(@class,'pref')]|*[contains(@class,'cell')]">
		<xsl:if test="not(position()=1)">
			<xsl:text>,</xsl:text>
		</xsl:if>
		<xsl:if test="position()=1">
		<xsl:text>;TYPE=</xsl:text></xsl:if>
<xsl:value-of select="@class"/>
</xsl:for-each>
-->
<!--
<xsl:text>:</xsl:text>
<xsl:choose>
	<xsl:when test="@href != ''">
		<xsl:value-of select="substring-after(@href,':')" />
	</xsl:when>
	<xsl:when test="@src != ''">
		<xsl:value-of select="substring-after(@src,':')" />
	</xsl:when>
	<xsl:when test="@longdesc != ''">
		<xsl:value-of select="@longdesc" />
	</xsl:when>
	<xsl:when test="@alt != ''">
		<xsl:value-of select="@alt" />
	</xsl:when>
	<xsl:when test="@title != ''">
		<xsl:value-of select="@title" />
	</xsl:when>
	<xsl:otherwise>
		<xsl:value-of select="normalize-space(.)" />
	</xsl:otherwise>
</xsl:choose>
-->
</xsl:template>

<!-- URL property -->
<xsl:template match="*[contains(@class,'url')]" mode="url">
<xsl:text>
URL:</xsl:text>
<xsl:choose>
	<xsl:when test="@href != ''">
		<xsl:choose>
			<xsl:when test="substring-before(@href,':') = 'http'">
				<xsl:value-of select="normalize-space(@href)" />
			</xsl:when>
			<xsl:otherwise>
				<!-- convert to absolute url -->
				<xsl:call-template name="make-absolute">
					<xsl:with-param name="relative-string">
						<xsl:value-of select="normalize-space(@href)" />
					</xsl:with-param>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:when>
	<xsl:when test="@src != ''">
		<xsl:call-template name="func-comma-cleaner">
			<xsl:with-param name="text-string"><xsl:value-of select="normalize-space(@src)" /></xsl:with-param>
		</xsl:call-template>
	</xsl:when>
	<xsl:when test="@longdesc != ''">
		<xsl:call-template name="func-comma-cleaner">
			<xsl:with-param name="text-string"><xsl:value-of select="normalize-space(@longdesc)" /></xsl:with-param>
		</xsl:call-template>
	</xsl:when>
	<xsl:when test="@alt != ''">
		<xsl:call-template name="func-comma-cleaner">
			<xsl:with-param name="text-string"><xsl:value-of select="normalize-space(@alt)" /></xsl:with-param>
		</xsl:call-template>
	</xsl:when>
	<xsl:when test="@title != ''">
		<xsl:call-template name="func-comma-cleaner">
			<xsl:with-param name="text-string"><xsl:value-of select="normalize-space(@title)" /></xsl:with-param>
		</xsl:call-template>
	</xsl:when>
	<xsl:otherwise>
		<xsl:call-template name="func-comma-cleaner">
			<xsl:with-param name="text-string"><xsl:value-of select="normalize-space(.)" /></xsl:with-param>
		</xsl:call-template>
	</xsl:otherwise>
</xsl:choose>
</xsl:template>

<!-- CLASS property -->
<xsl:template match="*[contains(@class,'class')]" mode="class">
<xsl:text>
CLASS:</xsl:text>
<xsl:choose>
	<xsl:when test="@longdesc != ''">
		<xsl:call-template name="func-comma-cleaner">
			<xsl:with-param name="text-string"><xsl:value-of select="normalize-space(@longdesc)" /></xsl:with-param>
		</xsl:call-template>
	</xsl:when>
	<xsl:when test="@alt != ''">
		<xsl:call-template name="func-comma-cleaner">
			<xsl:with-param name="text-string"><xsl:value-of select="normalize-space(@alt)" /></xsl:with-param>
		</xsl:call-template>
	</xsl:when>
	<xsl:when test="@title != ''">
		<xsl:call-template name="func-comma-cleaner">
			<xsl:with-param name="text-string"><xsl:value-of select="normalize-space(@title)" /></xsl:with-param>
		</xsl:call-template>
	</xsl:when>
	<xsl:otherwise>
		<xsl:call-template name="func-comma-cleaner">
			<xsl:with-param name="text-string"><xsl:value-of select="normalize-space(.)" /></xsl:with-param>
		</xsl:call-template>
	</xsl:otherwise>
</xsl:choose>
</xsl:template>

<!-- BDAY property -->
<xsl:template match="*[contains(@class,'bday')]" mode="bday">
<xsl:text>
BDAY:</xsl:text>
<xsl:choose>
	<xsl:when test="@longdesc != ''">
		<xsl:call-template name="func-comma-cleaner">
			<xsl:with-param name="text-string"><xsl:value-of select="normalize-space(@longdesc)" /></xsl:with-param>
		</xsl:call-template>
	</xsl:when>
	<xsl:when test="@alt != ''">
		<xsl:call-template name="func-comma-cleaner">
			<xsl:with-param name="text-string"><xsl:value-of select="normalize-space(@alt)" /></xsl:with-param>
		</xsl:call-template>
	</xsl:when>
	<xsl:when test="@title != ''">
		<xsl:call-template name="func-comma-cleaner">
			<xsl:with-param name="text-string"><xsl:value-of select="normalize-space(@title)" /></xsl:with-param>
		</xsl:call-template>
	</xsl:when>
	<xsl:otherwise>
		<xsl:call-template name="func-comma-cleaner">
			<xsl:with-param name="text-string"><xsl:value-of select="normalize-space(.)" /></xsl:with-param>
		</xsl:call-template>
	</xsl:otherwise>
</xsl:choose>
</xsl:template>

<!-- =============== SPECIAL CASE ================ -->

<!-- construct N from just FN @@ not 100% complete! -->
<xsl:template match="*[contains(@class,'fn')]" mode="n-builder">
<xsl:param name="vcard-lang" />
<xsl:text>
N</xsl:text>
<xsl:choose>
	<xsl:when test="@xml:lang != ''">
		<xsl:text>;LANGUAGE=</xsl:text><xsl:value-of select="@xml:lang" />
	</xsl:when>
	<xsl:when test="@lang != ''">
		<xsl:text>;LANGUAGE=</xsl:text><xsl:value-of select="@lang" />
	</xsl:when>
	<xsl:when test="$vcard-lang != ''">
		<xsl:text>;LANGUAGE=</xsl:text><xsl:value-of select="$vcard-lang" />
	</xsl:when>
</xsl:choose>
<xsl:text>:</xsl:text>
<xsl:choose>
	<xsl:when test="contains(.,',') = true()">
		<xsl:value-of select="substring-before(normalize-space(.),',')"/>
		<xsl:text>;</xsl:text>
		<xsl:value-of select="substring-after(normalize-space(.),' ')"/>
	</xsl:when>
	<xsl:otherwise>
		<xsl:value-of select="substring-after(normalize-space(.),' ')"/>
		<xsl:text>;</xsl:text>
		<xsl:value-of select="substring-before(normalize-space(.),' ')"/>
	</xsl:otherwise>
</xsl:choose>
<xsl:text>;</xsl:text>
<xsl:text>;</xsl:text>
<xsl:text>;</xsl:text>
<xsl:text>;</xsl:text>
</xsl:template>

<!-- N Property -->
<xsl:template match="*[contains(@class,'n')]" mode="n">
<xsl:param name="vcard-lang" />
<xsl:variable name="tab">&#x9;</xsl:variable>
<xsl:variable name="nl" >&#xA;</xsl:variable>
<xsl:variable name="rl" >&#xD;</xsl:variable>

<xsl:text>
N</xsl:text>
<xsl:choose>
	<xsl:when test="@xml:lang != ''">
		<xsl:text>;LANGUAGE=</xsl:text><xsl:value-of select="@xml:lang" />
	</xsl:when>
	<xsl:when test="@lang != ''">
		<xsl:text>;LANGUAGE=</xsl:text><xsl:value-of select="@lang" />
	</xsl:when>
	<xsl:when test="$vcard-lang != ''">
		<xsl:text>;LANGUAGE=</xsl:text><xsl:value-of select="$vcard-lang" />
	</xsl:when>
</xsl:choose>
<xsl:text>:</xsl:text>

<xsl:apply-templates select="*[contains(concat(' ',translate(translate(translate(@class, $tab ,' '), $nl ,' '), $rl ,' '),' '),' Family-Name ')]|*[contains(concat(' ',translate(translate(translate(@class, $tab ,' '), $nl ,' '), $rl ,' '),' '),' family-name ')]" mode="sub-n" /><xsl:apply-templates select="*//*[contains(concat(' ',translate(translate(translate(@class, $tab ,' '), $nl ,' '), $rl ,' '),' '),' Family-Name ')]|*//*[contains(concat(' ',translate(translate(translate(@class, $tab ,' '), $nl ,' '), $rl ,' '),' '),' family-name ')]" mode="sub-n"/><xsl:text>;</xsl:text>
<xsl:apply-templates select="*[contains(concat(' ',translate(translate(translate(@class, $tab ,' '), $nl ,' '), $rl ,' '),' '),' Given-Name ')]|*[contains(concat(' ',translate(translate(translate(@class, $tab ,' '), $nl ,' '), $rl ,' '),' '),' given-name ')]" mode="sub-n"/><xsl:apply-templates select="*//*[contains(concat(' ',translate(translate(translate(@class, $tab ,' '), $nl ,' '), $rl ,' '),' '),' Given-Name ')]|*//*[contains(concat(' ',translate(translate(translate(@class, $tab ,' '), $nl ,' '), $rl ,' '),' '),' given-name ')]" mode="sub-n"/><xsl:text>;</xsl:text><xsl:apply-templates select="*[contains(concat(' ',translate(translate(translate(@class, $tab ,' '), $nl ,' '), $rl ,' '),' '),' Additional-Names ')]|*[contains(concat(' ',translate(translate(translate(@class, $tab ,' '), $nl ,' '), $rl ,' '),' '),' additional-names ')]" mode="sub-n-multiple-name"/><xsl:apply-templates select="*//*[contains(concat(' ',translate(translate(translate(@class, $tab ,' '), $nl ,' '), $rl ,' '),' '),' Additional-Names ')]|*//*[contains(concat(' ',translate(translate(translate(@class, $tab ,' '), $nl ,' '), $rl ,' '),' '),' additional-names ')]" mode="sub-n-multiple-name"/><xsl:text>;</xsl:text><xsl:apply-templates select="*[contains(concat(' ',translate(translate(translate(@class, $tab ,' '), $nl ,' '), $rl ,' '),' '),' Honorific-Prefixes ')]|*[contains(concat(' ',translate(translate(translate(@class, $tab ,' '), $nl ,' '), $rl ,' '),' '),' honorific-prefixes ')]" mode="sub-n-multiple-name"/><xsl:apply-templates select="*//*[contains(concat(' ',translate(translate(translate(@class, $tab ,' '), $nl ,' '), $rl ,' '),' '),' Honorific-Prefixes ')]|*//*[contains(concat(' ',translate(translate(translate(@class, $tab ,' '), $nl ,' '), $rl ,' '),' '),' honorific-prefixes ')]" mode="sub-n-multiple-name"/><xsl:text>;</xsl:text><xsl:apply-templates select="*[contains(concat(' ',translate(translate(translate(@class, $tab ,' '), $nl ,' '), $rl ,' '),' '),' Honorific-Suffixes ')]|*[contains(concat(' ',translate(translate(translate(@class, $tab ,' '), $nl ,' '), $rl ,' '),' '),' honorific-suffixes ')]" mode="sub-n-multiple-name"/><xsl:apply-templates select="*//*[contains(concat(' ',translate(translate(translate(@class, $tab ,' '), $nl ,' '), $rl ,' '),' '),' Honorific-Suffixes ')]|*//*[contains(concat(' ',translate(translate(translate(@class, $tab ,' '), $nl ,' '), $rl ,' '),' '),' honorific-suffixes ')]" mode="sub-n-multiple-name"/><xsl:text>;</xsl:text>
</xsl:template>

<!-- N:* (sub-properties of N) -->
<xsl:template match="*[contains(@class,'Family-Name')]|*[contains(@class,'Given-Name')]|*[contains(@class,'family-name')]|*[contains(@class,'given-name')]" mode="sub-n">
	<xsl:call-template name="func-comma-cleaner">
		<xsl:with-param name="text-string"><xsl:value-of select="normalize-space(.)" /></xsl:with-param>
	</xsl:call-template>
</xsl:template>

<!-- N* (multiple list) property -->
<xsl:template match="*[contains(@class,'Additional-Names')]|*[contains(@class,'additional-names')]|*[contains(@class,'Honorific-Prefixes')]|*[contains(@class,'Honorific-Suffixes')]|*[contains(@class,'honorific-prefixes')]|*[contains(@class,'honorific-suffixes')]" mode="sub-n-multiple-name">
<xsl:choose>
	<xsl:when test="name()='ol'">
		<xsl:for-each select="*">
			<xsl:if test="not(position()=1)">
				<xsl:text>,</xsl:text>
			</xsl:if>
			<xsl:call-template name="func-comma-cleaner">
				<xsl:with-param name="text-string"><xsl:value-of select="normalize-space(.)"/></xsl:with-param>
			</xsl:call-template>
		</xsl:for-each>
	</xsl:when>
	<xsl:when test="name()='ul'">
		<xsl:for-each select="*">
			<xsl:if test="not(position()=1)">
				<xsl:text>,</xsl:text>
			</xsl:if>
			<xsl:call-template name="func-comma-cleaner">
				<xsl:with-param name="text-string"><xsl:value-of select="normalize-space(.)"/></xsl:with-param>
			</xsl:call-template>
		</xsl:for-each>
	</xsl:when>
	<xsl:otherwise>
		<xsl:choose>
			<xsl:when test="@longdesc != ''">
				<xsl:call-template name="func-comma-cleaner">
					<xsl:with-param name="text-string"><xsl:value-of select="normalize-space(@longdesc)" /></xsl:with-param>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="@alt != ''">
				<xsl:call-template name="func-comma-cleaner">
					<xsl:with-param name="text-string"><xsl:value-of select="normalize-space(@alt)" /></xsl:with-param>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="@title != ''">
				<xsl:call-template name="func-comma-cleaner">
					<xsl:with-param name="text-string"><xsl:value-of select="normalize-space(@title)" /></xsl:with-param>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="func-comma-cleaner">
					<xsl:with-param name="text-string"><xsl:value-of select="normalize-space(.)" /></xsl:with-param>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:otherwise>
</xsl:choose>
</xsl:template>

<!-- ADR Property -->
<xsl:template match="*[contains(@class,'adr')]" mode="adr">
<xsl:param name="vcard-lang" />
<xsl:variable name="tab">&#x9;</xsl:variable>
<xsl:variable name="nl" >&#xA;</xsl:variable>
<xsl:variable name="rl" >&#xD;</xsl:variable>

<xsl:text>
ADR</xsl:text>
<xsl:choose>
	<xsl:when test="@xml:lang != ''">
		<xsl:text>;LANGUAGE=</xsl:text><xsl:value-of select="@xml:lang" />
	</xsl:when>
	<xsl:when test="@lang != ''">
		<xsl:text>;LANGUAGE=</xsl:text><xsl:value-of select="@lang" />
	</xsl:when>
	<xsl:when test="$vcard-lang != ''">
		<xsl:text>;LANGUAGE=</xsl:text><xsl:value-of select="$vcard-lang" />
	</xsl:when>

</xsl:choose>
<xsl:text>:</xsl:text><xsl:apply-templates select="*[contains(concat(' ',translate(translate(translate(@class, $tab ,' '), $nl ,' '), $rl ,' '),' '),' Post-Office-Box ')]|*[contains(concat(' ',translate(translate(translate(@class, $tab ,' '), $nl ,' '), $rl ,' '),' '),' post-office-box ')]" mode="sub-adr"/><xsl:apply-templates select="*//*[contains(concat(' ',translate(translate(translate(@class, $tab ,' '), $nl ,' '), $rl ,' '),' '),' Post-Office-Box ')]|*//*[contains(concat(' ',translate(translate(translate(@class, $tab ,' '), $nl ,' '), $rl ,' '),' '),' post-office-box ')]" mode="sub-adr"/><xsl:text>;</xsl:text><xsl:apply-templates select="*[contains(concat(' ',translate(translate(translate(@class, $tab ,' '), $nl ,' '), $rl ,' '),' '),' Extended-Address ')]|*[contains(concat(' ',translate(translate(translate(@class, $tab ,' '), $nl ,' '), $rl ,' '),' '),' extended-address ')]" mode="sub-adr"/><xsl:apply-templates select="*//*[contains(concat(' ',translate(translate(translate(@class, $tab ,' '), $nl ,' '), $rl ,' '),' '),' Extended-Address ')]|*//*[contains(concat(' ',translate(translate(translate(@class, $tab ,' '), $nl ,' '), $rl ,' '),' '),' extended-address ')]" mode="sub-adr"/><xsl:text>;</xsl:text><xsl:apply-templates select="*[contains(concat(' ',translate(translate(translate(@class, $tab ,' '), $nl ,' '), $rl ,' '),' '),' Street-Address ')]|*[contains(concat(' ',translate(translate(translate(@class, $tab ,' '), $nl ,' '), $rl ,' '),' '),' street-address ')]" mode="sub-adr"/><xsl:apply-templates select="*//*[contains(concat(' ',translate(translate(translate(@class, $tab ,' '), $nl ,' '), $rl ,' '),' '),' Street-Address ')]|*//*[contains(concat(' ',translate(translate(translate(@class, $tab ,' '), $nl ,' '), $rl ,' '),' '),' street-address ')]" mode="sub-adr"/><xsl:text>;</xsl:text><xsl:apply-templates select="*[contains(concat(' ',translate(translate(translate(@class, $tab ,' '), $nl ,' '), $rl ,' '),' '),' Locality ')]|*[contains(concat(' ',translate(translate(translate(@class, $tab ,' '), $nl ,' '), $rl ,' '),' '),' locality ')]" mode="sub-adr"/><xsl:apply-templates select="*//*[contains(concat(' ',translate(translate(translate(@class, $tab ,' '), $nl ,' '), $rl ,' '),' '),' Locality ')]|*//*[contains(concat(' ',translate(translate(translate(@class, $tab ,' '), $nl ,' '), $rl ,' '),' '),' locality ')]" mode="sub-adr"/><xsl:text>;</xsl:text><xsl:apply-templates select="*[contains(concat(' ',translate(translate(translate(@class, $tab ,' '), $nl ,' '), $rl ,' '),' '),' Region ')]|*[contains(concat(' ',translate(translate(translate(@class, $tab ,' '), $nl ,' '), $rl ,' '),' '),' region ')]" mode="sub-adr"/><xsl:apply-templates select="*//*[contains(concat(' ',translate(translate(translate(@class, $tab ,' '), $nl ,' '), $rl ,' '),' '),' Region ')]|*//*[contains(concat(' ',translate(translate(translate(@class, $tab ,' '), $nl ,' '), $rl ,' '),' '),' region ')]" mode="sub-adr"/><xsl:text>;</xsl:text><xsl:apply-templates select="*[contains(concat(' ',translate(translate(translate(@class, $tab ,' '), $nl ,' '), $rl ,' '),' '),' Postal-Code ')]|*[contains(concat(' ',translate(translate(translate(@class, $tab ,' '), $nl ,' '), $rl ,' '),' '),' postal-code ')]" mode="sub-adr"/><xsl:apply-templates select="*//*[contains(concat(' ',translate(translate(translate(@class, $tab ,' '), $nl ,' '), $rl ,' '),' '),' Postal-Code ')]|*//*[contains(concat(' ',translate(translate(translate(@class, $tab ,' '), $nl ,' '), $rl ,' '),' '),' postal-code ')]" mode="sub-adr"/><xsl:text>;</xsl:text><xsl:apply-templates select="*[contains(concat(' ',translate(translate(translate(@class, $tab ,' '), $nl ,' '), $rl ,' '),' '),' Country ')]|*[contains(concat(' ',translate(translate(translate(@class, $tab ,' '), $nl ,' '), $rl ,' '),' '),' country ')]" mode="sub-adr"/><xsl:apply-templates select="*//*[contains(concat(' ',translate(translate(translate(@class, $tab ,' '), $nl ,' '), $rl ,' '),' '),' Country ')]|*//*[contains(concat(' ',translate(translate(translate(@class, $tab ,' '), $nl ,' '), $rl ,' '),' '),' country ')]" mode="sub-adr"/><xsl:text>;</xsl:text>
</xsl:template>

<!-- ADR:* (sub-properties of ADR) -->
<xsl:template match="*[contains(@class,'Post-Office-Box')]|*[contains(@class,'Extended-Address')]|*[contains(@class,'Street-Address')]|*[contains(@class,'Locality')]|*[contains(@class,'Region')]|*[contains(@class,'Postal-Code')]|*[contains(@class,'Country')]|*[contains(@class,'post-office-box')]|*[contains(@class,'extended-address')]|*[contains(@class,'street-address')]|*[contains(@class,'locality')]|*[contains(@class,'region')]|*[contains(@class,'postal-code')]|*[contains(@class,'country')]" mode="sub-adr">
	<xsl:call-template name="func-comma-cleaner">
		<xsl:with-param name="text-string"><xsl:value-of select="normalize-space(.)" /></xsl:with-param>
	</xsl:call-template>
</xsl:template>

<!-- EMAIL property -->
<xsl:template match="*[contains(@class,'email')]" mode="email">
<xsl:choose>
	<xsl:when test="*[contains(concat(' ',@class,' '),' internet ')]|*[contains(concat(' ',@class,' '),' x400 ')]|*[contains(concat(' ',@class,' '),' pref ')]">
		<xsl:for-each select="*">
			<xsl:text>
EMAIL;TYPE=</xsl:text>
			<xsl:if test="descendant-or-self::node()[contains(concat(' ',@class,' '),' internet ')]"><xsl:text>internet</xsl:text>
			<xsl:if test="descendant-or-self::node()[contains(concat(' ',@class,' '),' x400 ')]|descendant-or-self::node()[contains(concat(' ',@class,' '),' pref ')]">,</xsl:if></xsl:if>
			<xsl:if test="descendant-or-self::node()[contains(concat(' ',@class,' '),' x400 ')]"><xsl:text>x400</xsl:text>
			<xsl:if test="descendant-or-self::node()[contains(concat(' ',@class,' '),' pref ')]">,</xsl:if></xsl:if>
			<xsl:if test="descendant-or-self::node()[contains(concat(' ',@class,' '),' pref ')]"><xsl:text>pref</xsl:text></xsl:if>
			<xsl:text>:</xsl:text>
			<xsl:choose>
				<xsl:when test="@href != ''">
					<xsl:value-of select="substring-after(@href,':')" />
				</xsl:when>
				<xsl:when test="@src != ''">
					<xsl:value-of select="normalize-space(substring-after(@src,':'))" />
				</xsl:when>
				<xsl:when test="@longdesc != ''">
					<xsl:value-of select="normalize-space(@longdesc)" />
				</xsl:when>
				<xsl:when test="@alt != ''">
					<xsl:value-of select="normalize-space(@alt)" />
				</xsl:when>
				<xsl:when test="@title != ''">
					<xsl:value-of select="normalize-space(@title)" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="normalize-space(.)" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>
	</xsl:when>
	<xsl:otherwise>
<xsl:text>
EMAIL:</xsl:text>
	<xsl:choose>
		<xsl:when test="@href != ''">
			<xsl:call-template name="func-comma-cleaner">
				<xsl:with-param name="text-string"><xsl:value-of select="normalize-space(substring-after(@href,':'))" /></xsl:with-param>
			</xsl:call-template>
		</xsl:when>
		<xsl:when test="@src != ''">
			<xsl:call-template name="func-comma-cleaner">
				<xsl:with-param name="text-string"><xsl:value-of select="normalize-space(substring-after(@src,':'))" /></xsl:with-param>
			</xsl:call-template>
		</xsl:when>
		<xsl:when test="@longdesc != ''">
			<xsl:call-template name="func-comma-cleaner">
				<xsl:with-param name="text-string"><xsl:value-of select="normalize-space(@longdesc)" /></xsl:with-param>
			</xsl:call-template>
		</xsl:when>
		<xsl:when test="@alt != ''">
			<xsl:call-template name="func-comma-cleaner">
				<xsl:with-param name="text-string"><xsl:value-of select="normalize-space(@alt)" /></xsl:with-param>
			</xsl:call-template>
		</xsl:when>
		<xsl:when test="@title != ''">
			<xsl:call-template name="func-comma-cleaner">
				<xsl:with-param name="text-string"><xsl:value-of select="normalize-space(@title)" /></xsl:with-param>
			</xsl:call-template>
		</xsl:when>
		<xsl:otherwise>
			<xsl:call-template name="func-comma-cleaner">
				<xsl:with-param name="text-string"><xsl:value-of select="normalize-space(.)" /></xsl:with-param>
			</xsl:call-template>
		</xsl:otherwise>
	</xsl:choose>
</xsl:otherwise>
</xsl:choose>
</xsl:template>

<xsl:template match="*[contains(@class,'photo')]" mode="photo">
<xsl:text>
PHOTO</xsl:text>
<xsl:choose>
	<xsl:when test="@src != ''">
		<xsl:choose>
			<xsl:when test="substring-before(@src,':') = 'http'">
				<xsl:text>;VALUE=uri:</xsl:text><xsl:value-of select="@src" />
			</xsl:when>
			<xsl:when test="substring-before(@src,':') = 'data'">
				<xsl:text>;ENCODING=b;TYPE=</xsl:text><xsl:value-of select="substring-after(substring-before(@src,';'),':')"/><xsl:text>:</xsl:text><xsl:value-of select="substring-after(@src,',')"/>
			</xsl:when>
			<xsl:when test="@src != ''">
				<xsl:text>;VALUE=uri:</xsl:text>
				<!-- convert to absolute url -->
				<xsl:call-template name="make-absolute">
					<xsl:with-param name="relative-string">
						<xsl:value-of select="normalize-space(@src)" />
					</xsl:with-param>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>:</xsl:text>
				<xsl:value-of select="normalize-space(.)"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:when>
	<xsl:otherwise>
		<xsl:text>:</xsl:text>
		<xsl:value-of select="normalize-space(.)" />
	</xsl:otherwise>
</xsl:choose>
</xsl:template>


<!-- LOGO property -->
<xsl:template match="*[contains(@class,'logo')]" mode="logo">
<xsl:text>
LOGO</xsl:text>
<xsl:choose>
	<xsl:when test="@src != ''">
		<xsl:choose>
			<xsl:when test="substring-before(@src,':') = 'http'">
				<xsl:text>;VALUE=uri:</xsl:text><xsl:value-of select="@src" />
			</xsl:when>
			<xsl:when test="substring-before(@src,':') = 'data'">
				<xsl:text>;ENCODING=b;TYPE=</xsl:text><xsl:value-of select="substring-after(substring-before(@src,';'),':')"/><xsl:text>:</xsl:text><xsl:value-of select="substring-after(@src,',')"/>
			</xsl:when>
			<xsl:when test="@src != ''">
				<xsl:text>;VALUE=uri:</xsl:text>
				<!-- convert to absolute url -->
				<xsl:call-template name="make-absolute">
					<xsl:with-param name="relative-string">
					<xsl:value-of select="normalize-space(@src)" />
					</xsl:with-param>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>:</xsl:text>
				<xsl:value-of select="normalize-space(.)"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:when>
	<xsl:otherwise>
		<xsl:text>:</xsl:text>
		<xsl:value-of select="normalize-space(.)" />
	</xsl:otherwise>
</xsl:choose>
</xsl:template>

<!-- SOUND property @@ not sure if this is correct? -->
<xsl:template match="*[contains(@class,'sound')]" mode="sound">
<xsl:text>
SOUND</xsl:text>
<xsl:choose>
	<xsl:when test="@src != ''">
		<xsl:choose>
			<xsl:when test="substring-before(@src,':') = 'http'">
				<xsl:text>;VALUE=uri:</xsl:text><xsl:value-of select="@src" />
			</xsl:when>
			<xsl:when test="substring-before(@src,':') = 'data'">
				<xsl:text>;ENCODING=b;TYPE=</xsl:text><xsl:value-of select="substring-after(substring-before(@src,';'),':')"/><xsl:text>:</xsl:text><xsl:value-of select="substring-after(@src,',')"/>
			</xsl:when>
			<xsl:when test="@src != ''">
				<xsl:text>;VALUE=uri:</xsl:text>
				<!-- convert to absolute url -->
				<xsl:call-template name="make-absolute">
					<xsl:with-param name="relative-string">
					<xsl:value-of select="normalize-space(@src)" />
					</xsl:with-param>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>:</xsl:text>
				<xsl:value-of select="normalize-space(.)"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:when>
	<xsl:otherwise>
		<xsl:text>:</xsl:text>
		<xsl:value-of select="normalize-space(.)" />
	</xsl:otherwise>
</xsl:choose>
</xsl:template>

<!-- NICKNAME property -->
<xsl:template match="*[contains(@class,'nickname')]" mode="nickname">
<xsl:param name="vcard-lang" />

<xsl:text>
NICKNAME</xsl:text>
<xsl:choose>
	<xsl:when test="@xml:lang != ''">
		<xsl:text>;LANGUAGE=</xsl:text><xsl:value-of select="@xml:lang" />
	</xsl:when>
	<xsl:when test="@lang != ''">
		<xsl:text>;LANGUAGE=</xsl:text><xsl:value-of select="@lang" />
	</xsl:when>
	<xsl:when test="$vcard-lang != ''">
		<xsl:text>;LANGUAGE=</xsl:text><xsl:value-of select="$vcard-lang" />
	</xsl:when>

</xsl:choose>
<xsl:text>:</xsl:text>
<xsl:choose>
	<xsl:when test="name()='ol'">
		<xsl:for-each select="*">
			<xsl:if test="not(position()=1)">
				<xsl:text>,</xsl:text>
			</xsl:if>
			<xsl:call-template name="func-comma-cleaner">
				<xsl:with-param name="text-string"><xsl:value-of select="normalize-space(.)"/></xsl:with-param>
			</xsl:call-template>
		</xsl:for-each>
	</xsl:when>
	<xsl:when test="name()='ul'">
		<xsl:for-each select="*">
			<xsl:if test="not(position()=1)">
				<xsl:text>,</xsl:text>
			</xsl:if>
			<xsl:call-template name="func-comma-cleaner">
				<xsl:with-param name="text-string"><xsl:value-of select="normalize-space(.)"/></xsl:with-param>
			</xsl:call-template>
		</xsl:for-each>
	</xsl:when>
	<xsl:otherwise>
		<xsl:choose>
			<xsl:when test="@longdesc != ''">
				<xsl:call-template name="func-comma-cleaner">
					<xsl:with-param name="text-string"><xsl:value-of select="normalize-space(@longdesc)" /></xsl:with-param>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="@alt != ''">
				<xsl:call-template name="func-comma-cleaner">
					<xsl:with-param name="text-string"><xsl:value-of select="normalize-space(@alt)" /></xsl:with-param>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="@title != ''">
				<xsl:call-template name="func-comma-cleaner">
					<xsl:with-param name="text-string"><xsl:value-of select="normalize-space(@title)" /></xsl:with-param>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="func-comma-cleaner">
					<xsl:with-param name="text-string"><xsl:value-of select="normalize-space(.)" /></xsl:with-param>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:otherwise>
</xsl:choose>
</xsl:template>

<!-- CATEGORIES property -->
<xsl:template match="*[contains(@class,'categories')]" mode="categories">
<xsl:param name="vcard-lang" />

<xsl:text>
CATEGORIES</xsl:text>
<xsl:choose>
	<xsl:when test="@xml:lang != ''">
		<xsl:text>;LANGUAGE=</xsl:text><xsl:value-of select="@xml:lang" />
	</xsl:when>
	<xsl:when test="@lang != ''">
		<xsl:text>;LANGUAGE=</xsl:text><xsl:value-of select="@lang" />
	</xsl:when>
	<xsl:when test="$vcard-lang != ''">
		<xsl:text>;LANGUAGE=</xsl:text><xsl:value-of select="$vcard-lang" />
	</xsl:when>
</xsl:choose>
<xsl:text>:</xsl:text>
<xsl:choose>
	<xsl:when test="name()='ol'">
		<xsl:for-each select="*">
			<xsl:if test="not(position()=1)">
				<xsl:text>,</xsl:text>
			</xsl:if>
			<xsl:call-template name="func-comma-cleaner">
					<xsl:with-param name="text-string"><xsl:value-of select="normalize-space(.)"/></xsl:with-param>
			</xsl:call-template>
		</xsl:for-each>
	</xsl:when>
	<xsl:when test="name()='ul'">
		<xsl:for-each select="*">
			<xsl:if test="not(position()=1)">
				<xsl:text>,</xsl:text>
			</xsl:if>
			<xsl:call-template name="func-comma-cleaner">
					<xsl:with-param name="text-string"><xsl:value-of select="normalize-space(.)"/></xsl:with-param>
			</xsl:call-template>
		</xsl:for-each>
	</xsl:when>
	<xsl:otherwise>
		<xsl:choose>
			<xsl:when test="@longdesc != ''">
				<xsl:call-template name="func-comma-cleaner">
					<xsl:with-param name="text-string"><xsl:value-of select="normalize-space(@longdesc)" /></xsl:with-param>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="@alt != ''">
				<xsl:call-template name="func-comma-cleaner">
					<xsl:with-param name="text-string"><xsl:value-of select="normalize-space(@alt)" /></xsl:with-param>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="@title != ''">
				<xsl:call-template name="func-comma-cleaner">
					<xsl:with-param name="text-string"><xsl:value-of select="normalize-space(@title)" /></xsl:with-param>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="func-comma-cleaner">
					<xsl:with-param name="text-string"><xsl:value-of select="normalize-space(.)" /></xsl:with-param>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:otherwise>
</xsl:choose>
</xsl:template>

<!-- ORG property -->
<xsl:template match="*[contains(@class,'org')]" mode="org">
<xsl:param name="vcard-lang" />

<xsl:text>
ORG</xsl:text>
<xsl:choose>
	<xsl:when test="@xml:lang != ''">
		<xsl:text>;LANGUAGE=</xsl:text><xsl:value-of select="@xml:lang" />
	</xsl:when>
	<xsl:when test="@lang != ''">
		<xsl:text>;LANGUAGE=</xsl:text><xsl:value-of select="@lang" />
	</xsl:when>
	<xsl:when test="$vcard-lang != ''">
		<xsl:text>;LANGUAGE=</xsl:text><xsl:value-of select="$vcard-lang" />
	</xsl:when>
</xsl:choose>
<xsl:text>:</xsl:text>

<xsl:if test="count(*[contains(concat(' ',@class,' '),' organization-name ')]) = 0 and count(*[contains(concat(' ',@class,' '),' Organization-Name ')]) = 0 and count(*[contains(concat(' ',@class,' '),' organization-name ')]) = 0 and count(*[contains(concat(' ',@class,' '),' Organization-Name ')]) = 0">
	<xsl:call-template name="func-comma-cleaner">
		<xsl:with-param name="text-string"><xsl:value-of select="normalize-space(.)" /></xsl:with-param>
	</xsl:call-template>
</xsl:if>
<xsl:apply-templates select="*[contains(concat(' ',@class,' '),' Organization-Name ')]|*[contains(concat(' ',@class,' '),' organization-name ')]" mode="org-sub"/>
<xsl:apply-templates select="*//*[contains(concat(' ',@class,' '),' Organization-Name ')]|*//*[contains(concat(' ',@class,' '),' organization-name ')]" mode="org-sub"/>
<xsl:for-each select="*[contains(concat(' ',@class,' '),' Organization-Unit ')]|*[contains(concat(' ',@class,' '),' organization-unit ')]">
	<xsl:text>;</xsl:text>
	<xsl:call-template name="func-comma-cleaner">
		<xsl:with-param name="text-string"><xsl:value-of select="normalize-space(.)" /></xsl:with-param>
	</xsl:call-template>
</xsl:for-each>
</xsl:template>

<!-- ORG:* properties -->
<xsl:template match="*[contains(@class,'Organization-Name')]|*[contains(@class,'organization-name')]" mode="org-sub">
<xsl:call-template name="func-comma-cleaner">
	<xsl:with-param name="text-string"><xsl:value-of select="normalize-space(.)" /></xsl:with-param>
</xsl:call-template>
</xsl:template>

<!-- KEY property @@ not sure if this is correct? -->
<xsl:template match="*[contains(@class,'key')]" mode="key">
<xsl:text>
KEY</xsl:text>
<xsl:if test="descendant-or-self::node()[contains(concat(' ',@class,' '),' pgp ')]|descendant-or-self::node()[contains(concat(' ',@class,' '),' PGP ')]"><xsl:text>;TYPE=PGP</xsl:text></xsl:if>
<xsl:if test="descendant-or-self::node()[contains(concat(' ',@class,' '),' x509 ')]|descendant-or-self::node()[contains(concat(' ',@class,' '),' X509 ')]"><xsl:text>;TYPE=X509</xsl:text></xsl:if>
<xsl:text>;ENCODING=b:</xsl:text>
<xsl:value-of select="normalize-space(.)" />
</xsl:template>












<!-- gets the LABEL from any element (might need to escape returns '\n' or PRE element?) -->
<xsl:template match="*[contains(@class,'label')]" mode="label">
LABEL:<xsl:value-of select="." />
</xsl:template>

<!-- function to convert relative urls to absolute urls -->
<xsl:template name="make-absolute">
<xsl:param name="relative-string"></xsl:param>

<xsl:choose>
	<xsl:when test="substring($relative-string,1,1) = '/'">
		<xsl:value-of select="substring-before($x-from-url,'/')"/>
		<xsl:text>//</xsl:text>
		<xsl:value-of select="substring-before(substring-after(substring-after($x-from-url,'/'),'/'),'/')"/>
		<xsl:value-of select="$relative-string"/>
	</xsl:when>
	<xsl:when test="substring($x-from-url,string-length($x-from-url)) = '/' and substring($relative-string,1,1) != '/'">
		<xsl:value-of select="$x-from-url"/>
		<xsl:value-of select="$relative-string"/>
	</xsl:when>
	<xsl:when test="substring($x-from-url,string-length($x-from-url)) != '/' and substring($relative-string,1,1) != '/'">
		<xsl:value-of select="substring-before($x-from-url,'/')"/>
		<xsl:text>//</xsl:text>
		<xsl:call-template name="remove-filename">
			<xsl:with-param name="base-url">
				<xsl:value-of select="substring-after(substring-after($x-from-url,'/'),'/')"/>
			</xsl:with-param>
		</xsl:call-template>
		
		<xsl:value-of select="$relative-string"/>
	</xsl:when>

	<xsl:otherwise>
		<xsl:value-of select="$x-from-url"/>
		<xsl:value-of select="$relative-string"/>
	</xsl:otherwise>
</xsl:choose>
</xsl:template>

<xsl:template name="remove-filename">
<xsl:param name="base-url"/>
<xsl:choose>
	<xsl:when test="substring-before($base-url,'/') = true()">
		<xsl:value-of select="substring-before($base-url,'/')"/><xsl:text>/</xsl:text>
		<xsl:call-template name="remove-filename">
			<xsl:with-param name="base-url"><xsl:value-of select="substring-after($base-url,'/')"/></xsl:with-param>
		</xsl:call-template>
	</xsl:when>
	<xsl:otherwise>
	<!--
		<xsl:value-of select="$text-string"/>
	-->
	</xsl:otherwise>
</xsl:choose>
</xsl:template>


<!-- recursive function to escape commas -->
<xsl:template name="func-comma-cleaner">
<xsl:param name="text-string"></xsl:param>
<xsl:choose>
	<xsl:when test="substring-before($text-string,',') = true()">
		<xsl:value-of select="substring-before($text-string,',')"/><xsl:text>\,</xsl:text>
		<xsl:call-template name="func-comma-cleaner">
			<xsl:with-param name="text-string"><xsl:value-of select="substring-after($text-string,',')"/></xsl:with-param>
		</xsl:call-template>
	</xsl:when>
	<xsl:otherwise>
		<xsl:value-of select="$text-string"/>
	</xsl:otherwise>
</xsl:choose>
</xsl:template>

<!-- NAME for the SOURCE -->
<xsl:template match="//*[name() ='title']" mode="htmltitle">
<xsl:text>
NAME: </xsl:text>
		<xsl:call-template name="func-comma-cleaner">
			<xsl:with-param name="text-string"><xsl:value-of select="normalize-space(.)" /></xsl:with-param>
		</xsl:call-template>
</xsl:template>


<!-- don't pass text thru -->
<xsl:template match="text()"></xsl:template>
</xsl:stylesheet>
