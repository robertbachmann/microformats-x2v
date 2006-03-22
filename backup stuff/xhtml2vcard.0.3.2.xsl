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
Version 0.3.2
2005-04-08

Copyright 2005 Brian Suda
This work is licensed under the Creative Commons Attribution-ShareAlike License. 
To view a copy of this license, visit 
http://creativecommons.org/licenses/by-sa/1.0/

NOTES:
Until the hCard spec has been finalised this is a work in progress.
I'm not an XSLT expert, so there are no guarantees to quality of this code!

@@ I need to ESCAPE ',' (commas) with '\,' or things will break on an import
@@ encode the LANGUAGE parameter, this is taken from the xml:lang attribute

@@ check for profile in head element

-->

<!-- there is no root element in vCard -->
<xsl:template match="/">
<xsl:apply-templates select="//head[contains(@profile,'foobar')]"/>
<xsl:apply-templates select="//*[contains(@class,'vcard')]"/>
</xsl:template>

<!-- check for profile in head element -->
<xsl:template match="head[contains(@profile,'foorbar')]">
<!-- 
==================== CURRENTLY DISABLED ====================
This will call the vCard template, 
Without the correct profile you cannot assume the class values are intended for the vCard microformat.
-->
</xsl:template>

<!-- Each vCard is listed in succession -->
<xsl:template match="*[contains(concat(' ',@class,' '),' vcard ')]">
<xsl:text>BEGIN:VCARD
PRODID:-//suda.co.uk//X2V 0.3 (BETA)//EN
X-ORIGINAL-URL: (Best Practice: should be URL that this was ripped from)
VERSION:3.0</xsl:text>
<xsl:apply-templates select="@id" mode="uid"/>
<xsl:apply-templates select="*[contains(concat(' ',@class,' '),' fn ')]|*//*[contains(concat(' ',@class,' '),' fn ')]" mode="fn"/>
<xsl:apply-templates select="*[contains(concat(' ',@class,' '),' n ')]|*//*[contains(concat(' ',@class,' '),' n ')]" mode="n"/>
<xsl:apply-templates select="*[contains(concat(' ',@class,' '),' url ')]|*//*[contains(concat(' ',@class,' '),' url ')]" mode="url"/>
<xsl:apply-templates select="*[contains(concat(' ',@class,' '),' email ')]|*//*[contains(concat(' ',@class,' '),' email ')]" mode="email"/>
<xsl:apply-templates select="*[contains(concat(' ',@class,' '),' adr ')]|*//*[contains(concat(' ',@class,' '),' adr ')]" mode="adr"/>
<xsl:apply-templates select="*[contains(concat(' ',@class,' '),' tel ')]|*//*[contains(concat(' ',@class,' '),' tel ')]" mode="tel"/>
<xsl:apply-templates select="*[contains(concat(' ',@class,' '),' photo ')]|*//*[contains(concat(' ',@class,' '),' photo ')]" mode="photo"/>
<xsl:apply-templates select="*[contains(concat(' ',@class,' '),' bday ')]|*//*[contains(concat(' ',@class,' '),' bday ')]" mode="bday"/>
<xsl:apply-templates select="*[contains(concat(' ',@class,' '),' mailer ')]|*//*[contains(concat(' ',@class,' '),' mailer ')]" mode="mailer"/>
<xsl:apply-templates select="*[contains(concat(' ',@class,' '),' title ')]|*//*[contains(concat(' ',@class,' '),' title ')]" mode="title"/>
<xsl:apply-templates select="*[contains(concat(' ',@class,' '),' role ')]|*//*[contains(concat(' ',@class,' '),' role ')]" mode="role"/>
<xsl:apply-templates select="*[contains(concat(' ',@class,' '),' logo ')]|*//*[contains(concat(' ',@class,' '),' logo ')]" mode="logo"/>
<xsl:apply-templates select="*[contains(concat(' ',@class,' '),' note ')]|*//*[contains(concat(' ',@class,' '),' note ')]" mode="note"/>
<xsl:apply-templates select="*[contains(concat(' ',@class,' '),' sort-string ')]|*//*[contains(concat(' ',@class,' '),' sort-string ')]" mode="sort-string"/>
<xsl:apply-templates select="*[contains(concat(' ',@class,' '),' class ')]|*//*[contains(concat(' ',@class,' '),' class ')]" mode="class"/>
<xsl:apply-templates select="*[contains(concat(' ',@class,' '),' rev ')]|*//*[contains(concat(' ',@class,' '),' rev ')]" mode="rev"/>

<!-- available, but are probably wrong -->
<xsl:apply-templates select="*[contains(concat(' ',@class,' '),' org ')]|*//*[contains(concat(' ',@class,' '),' org ')]" mode="org"/>
<xsl:apply-templates select="*[contains(concat(' ',@class,' '),' categories ')]|*//*[contains(concat(' ',@class,' '),' categories ')]" mode="categories"/>
<xsl:apply-templates select="*[contains(concat(' ',@class,' '),' sound ')]|*//*[contains(concat(' ',@class,' '),' sound ')]" mode="sound"/>
<xsl:apply-templates select="*[contains(concat(' ',@class,' '),' label ')]|*//*[contains(concat(' ',@class,' '),' label ')]" mode="label"/>
<xsl:apply-templates select="*[contains(concat(' ',@class,' '),' nickname ')]|*//*[contains(concat(' ',@class,' '),' nickname ')]" mode="nickname"/>

<!-- UNWRITTEN TEMPLATES -->
<!--
<xsl:apply-templates select="*[contains(concat(' ',@class,' '),' tz ')]" mode="tz"/>
<xsl:apply-templates select="*//*[contains(concat(' ',@class,' '),' tz ')]" mode="tz"/>
<xsl:apply-templates select="*[contains(concat(' ',@class,' '),' geo ')]" mode="geo"/>
<xsl:apply-templates select="*//*[contains(concat(' ',@class,' '),' geo ')]" mode="geo"/>
<xsl:apply-templates select="*[contains(concat(' ',@class,' '),' agent ')]" mode="agent"/>
<xsl:apply-templates select="*//*[contains(concat(' ',@class,' '),' agent ')]" mode="agent"/>
<xsl:apply-templates select="*[contains(concat(' ',@class,' '),' key ')]" mode="key"/>
<xsl:apply-templates select="*//*[contains(concat(' ',@class,' '),' key ')]" mode="key"/>
-->
<xsl:text>
END:VCARD
</xsl:text>
</xsl:template>

<!-- ============== working templates ================= -->
<!-- UID property -->
<xsl:template match="@id" mode="id">
UID:<xsl:value-of select="." />
</xsl:template>

<!-- REV property -->
<xsl:template match="*[contains(@class,'rev')]" mode="rev">
<xsl:text>
REV:</xsl:text>
<xsl:choose>
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
</xsl:template>

<!-- FN property -->
<xsl:template match="*[contains(@class,'fn')]" mode="fn">
<xsl:text>
FN</xsl:text>
<xsl:choose>
	<xsl:when test="@xml:lang != ''">
		<xsl:text>;LANGUAGE=</xsl:text><xsl:value-of select="@xml:lang" />
	</xsl:when>
	<xsl:when test="@lang != ''">
		<xsl:text>;LANGUAGE=</xsl:text><xsl:value-of select="@lang" />
	</xsl:when>
</xsl:choose>
<xsl:text>:</xsl:text>
<xsl:choose>
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
</xsl:template>

<!-- MAILER property -->
<xsl:template match="*[contains(@class,'mailer')]" mode="mailer">
<xsl:text>
MAILER</xsl:text>
<xsl:choose>
	<xsl:when test="@xml:lang != ''">
		<xsl:text>;LANGUAGE=</xsl:text><xsl:value-of select="@xml:lang" />
	</xsl:when>
	<xsl:when test="@lang != ''">
		<xsl:text>;LANGUAGE=</xsl:text><xsl:value-of select="@lang" />
	</xsl:when>
</xsl:choose>
<xsl:text>:</xsl:text>
<xsl:choose>
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
</xsl:template>

<!-- TITLE property -->
<xsl:template match="*[contains(@class,'title')]" mode="title">
<xsl:text>
TITLE</xsl:text>
<xsl:choose>
	<xsl:when test="@xml:lang != ''">
		<xsl:text>;LANGUAGE=</xsl:text><xsl:value-of select="@xml:lang" />
	</xsl:when>
	<xsl:when test="@lang != ''">
		<xsl:text>;LANGUAGE=</xsl:text><xsl:value-of select="@lang" />
	</xsl:when>
</xsl:choose>
<xsl:text>:</xsl:text>
<xsl:choose>
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
</xsl:template>

<!-- ROLE property -->
<xsl:template match="*[contains(@class,'role')]" mode="role">
<xsl:text>
ROLE</xsl:text>
<xsl:choose>
	<xsl:when test="@xml:lang != ''">
		<xsl:text>;LANGUAGE=</xsl:text><xsl:value-of select="@xml:lang" />
	</xsl:when>
	<xsl:when test="@lang != ''">
		<xsl:text>;LANGUAGE=</xsl:text><xsl:value-of select="@lang" />
	</xsl:when>
</xsl:choose>
<xsl:text>:</xsl:text>
<xsl:choose>
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
</xsl:template>


<!-- SORT-STRING property -->
<xsl:template match="*[contains(@class,'sort-string')]" mode="sort-string">
<xsl:text>
SORT-STRING</xsl:text>
<xsl:choose>
	<xsl:when test="@xml:lang != ''">
		<xsl:text>;LANGUAGE=</xsl:text><xsl:value-of select="@xml:lang" />
	</xsl:when>
	<xsl:when test="@lang != ''">
		<xsl:text>;LANGUAGE=</xsl:text><xsl:value-of select="@lang" />
	</xsl:when>
</xsl:choose>
<xsl:text>:</xsl:text>
<xsl:choose>
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
</xsl:template>

<!-- NOTE property -->
<xsl:template match="*[contains(@class,'note')]" mode="note">
<xsl:text>
NOTE</xsl:text>
<xsl:choose>
	<xsl:when test="@xml:lang != ''">
		<xsl:text>;LANGUAGE=</xsl:text><xsl:value-of select="@xml:lang" />
	</xsl:when>
	<xsl:when test="@lang != ''">
		<xsl:text>;LANGUAGE=</xsl:text><xsl:value-of select="@lang" />
	</xsl:when>
</xsl:choose>
<xsl:text>:</xsl:text>
<xsl:choose>
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
</xsl:template>

<!-- TEL property -->
<xsl:template match="*[contains(@class,'tel')]" mode="tel">
<xsl:text>
TEL:</xsl:text>
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
</xsl:template>

<!-- URL property -->
<xsl:template match="*[contains(@class,'url')]" mode="url">
<xsl:text>
URL:</xsl:text>
<xsl:choose>
	<xsl:when test="@href != ''">
		<xsl:value-of select="@href" />
	</xsl:when>
	<xsl:when test="@src != ''">
		<xsl:value-of select="@src" />
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
</xsl:template>

<!-- CLASS property -->
<xsl:template match="*[contains(@class,'class')]" mode="class">
<xsl:text>
CLASS:</xsl:text>
<xsl:choose>
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
</xsl:template>

<!-- BDAY property -->
<xsl:template match="*[contains(@class,'bday')]" mode="bday">
<xsl:text>
BDAY:</xsl:text>
<xsl:choose>
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
</xsl:template>

<!-- =============== SPECIAL CASE ================ -->

<!-- N Property -->
<xsl:template match="*[contains(@class,'n')]" mode="n">
<xsl:text>
N</xsl:text>
<xsl:choose>
	<xsl:when test="@xml:lang != ''">
		<xsl:text>;LANGUAGE=</xsl:text><xsl:value-of select="@xml:lang" />
	</xsl:when>
	<xsl:when test="@lang != ''">
		<xsl:text>;LANGUAGE=</xsl:text><xsl:value-of select="@lang" />
	</xsl:when>
</xsl:choose>
<xsl:text>:</xsl:text>
<xsl:apply-templates select="*[contains(@class,'Family-Name')]|*[contains(@class,'family-name')]" mode="sub-n" /><xsl:apply-templates select="*//*[contains(@class,'Family-Name')]|*//*[contains(@class,'family-name')]" mode="sub-n"/><xsl:text>;</xsl:text><xsl:apply-templates select="*[contains(@class,'Given-Name')]|*[contains(@class,'given-name')]" mode="sub-n"/><xsl:apply-templates select="*//*[contains(@class,'Given-Name')]|*//*[contains(@class,'given-name')]" mode="sub-n"/><xsl:text>;</xsl:text><xsl:apply-templates select="*[contains(@class,'Additional-Name')]|*[contains(@class,'additional-name')]" mode="sub-n"/><xsl:apply-templates select="*//*[contains(@class,'Additional-Name')]|*//*[contains(@class,'additional-name')]" mode="sub-n"/><xsl:text>;</xsl:text><xsl:apply-templates select="*[contains(@class,'Prefix')]|*[contains(@class,'prefix')]" mode="sub-n"/><xsl:apply-templates select="*//*[contains(@class,'Prefix')]|*//*[contains(@class,'prefix')]" mode="sub-n"/><xsl:text>;</xsl:text><xsl:apply-templates select="*[contains(@class,'Suffix')]|*[contains(@class,'suffix')]" mode="sub-n"/><xsl:apply-templates select="*//*[contains(@class,'Suffix')]|*//*[contains(@class,'suffix')]" mode="sub-n"/><xsl:text>;</xsl:text>
</xsl:template>

<!-- N:* (sub-properties of N) -->
<xsl:template match="*[contains(@class,'Family-Name')]|*[contains(@class,'Given-Name')]|*[contains(@class,'Additional-Name')]|*[contains(@class,'Prefix')]|*[contains(@class,'Suffix')]|*[contains(@class,'family-name')]|*[contains(@class,'given-name')]|*[contains(@class,'additional-name')]|*[contains(@class,'prefix')]|*[contains(@class,'suffix')]" mode="sub-n">
<xsl:value-of select="." />
</xsl:template>

<!-- ADR Property -->
<xsl:template match="*[contains(@class,'adr')]" mode="adr">
<xsl:text>
ADR</xsl:text>
<xsl:choose>
	<xsl:when test="@xml:lang != ''">
		<xsl:text>;LANGUAGE=</xsl:text><xsl:value-of select="@xml:lang" />
	</xsl:when>
	<xsl:when test="@lang != ''">
		<xsl:text>;LANGUAGE=</xsl:text><xsl:value-of select="@lang" />
	</xsl:when>
</xsl:choose>
<xsl:text>:</xsl:text><xsl:apply-templates select="*[contains(@class,'Post-Office-Box')]|*[contains(@class,'post-office-box')]" mode="sub-adr"/><xsl:apply-templates select="*//*[contains(@class,'Post-Office-Box')]|*//*[contains(@class,'post-office-box')]" mode="sub-adr"/><xsl:text>;</xsl:text><xsl:apply-templates select="*[contains(@class,'Extended-Address')]|*[contains(@class,'extended-address')]" mode="sub-adr"/><xsl:apply-templates select="*//*[contains(@class,'Extended-Address')]|*//*[contains(@class,'extended-address')]" mode="sub-adr"/><xsl:text>;</xsl:text><xsl:apply-templates select="*[contains(@class,'Street-Address')]|*[contains(@class,'street-address')]" mode="sub-adr"/><xsl:apply-templates select="*//*[contains(@class,'Street-Address')]|*//*[contains(@class,'street-address')]" mode="sub-adr"/><xsl:text>;</xsl:text><xsl:apply-templates select="*[contains(@class,'Locality')]|*[contains(@class,'locality')]" mode="sub-adr"/><xsl:apply-templates select="*//*[contains(@class,'Locality')]|*//*[contains(@class,'locality')]" mode="sub-adr"/><xsl:text>;</xsl:text><xsl:apply-templates select="*[contains(@class,'Region')]|*[contains(@class,'region')]" mode="sub-adr"/><xsl:apply-templates select="*//*[contains(@class,'Region')]|*//*[contains(@class,'region')]" mode="sub-adr"/><xsl:text>;</xsl:text><xsl:apply-templates select="*[contains(@class,'Postal-Code')]|*[contains(@class,'postal-code')]" mode="sub-adr"/><xsl:apply-templates select="*//*[contains(@class,'Postal-Code')]|*//*[contains(@class,'postal-code')]" mode="sub-adr"/><xsl:text>;</xsl:text><xsl:apply-templates select="*[contains(@class,'Country')]|*[contains(@class,'country')]" mode="sub-adr"/><xsl:apply-templates select="*//*[contains(@class,'Country')]|*//*[contains(@class,'country')]" mode="sub-adr"/><xsl:text>;</xsl:text>
</xsl:template>

<!-- ADR:* (sub-properties of ADR) -->
<xsl:template match="*[contains(@class,'Post-Office-Box')]|*[contains(@class,'Extended-Address')]|*[contains(@class,'Street-Address')]|*[contains(@class,'Locality')]|*[contains(@class,'Region')]|*[contains(@class,'Postal-Code')]|*[contains(@class,'Country')]|*[contains(@class,'post-office-box')]|*[contains(@class,'extended-address')]|*[contains(@class,'street-address')]|*[contains(@class,'locality')]|*[contains(@class,'region')]|*[contains(@class,'postal-code')]|*[contains(@class,'country')]" mode="sub-adr">
<xsl:value-of select="." />
</xsl:template>

<!-- EMAIL property -->
<xsl:template match="*[contains(@class,'email')]" mode="email">
<xsl:text>
EMAIL:</xsl:text>
<xsl:choose>
	<xsl:when test="@href != ''">
		<xsl:value-of select="substring-after(@href,':')" />
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
		<xsl:value-of select="." />
	</xsl:otherwise>
</xsl:choose>
</xsl:template>

<!-- PHOTO property -->
<xsl:template match="*[contains(@class,'photo')]" mode="photo">
<xsl:text>
PHOTO;</xsl:text>
<xsl:choose>
	<xsl:when test="@src != ''">
		<xsl:choose>
			<xsl:when test="substring-before(@src,':') = 'http'">
				<xsl:text>VALUE=uri:</xsl:text><xsl:value-of select="@src" />
			</xsl:when>
			<xsl:when test="substring-before(@src,':') = 'data'">
				<xsl:text>ENCODING=b;TYPE=</xsl:text><xsl:value-of select="substring-after(substring-before(@src,';'),':')"/><xsl:text>:</xsl:text><xsl:value-of select="substring-after(@src,',')"/>
			</xsl:when>
			<xsl:when test="@src != ''">
				<xsl:value-of select="@src"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="normalize-space(.)"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:when>
	<xsl:otherwise>
		<xsl:value-of select="normalize-space(.)" />
	</xsl:otherwise>
</xsl:choose>
</xsl:template>

<!-- LOGO property -->
<xsl:template match="*[contains(@class,'logo')]" mode="logo">
<xsl:text>
LOGO;</xsl:text>
<xsl:choose>
	<xsl:when test="@src != ''">
		<xsl:choose>
			<xsl:when test="substring-before(@src,':') = 'http'">
				<xsl:text>VALUE=uri:</xsl:text><xsl:value-of select="@src" />
			</xsl:when>
			<xsl:when test="substring-before(@src,':') = 'data'">
				<xsl:text>ENCODING=b;TYPE=</xsl:text><xsl:value-of select="substring-after(substring-before(@src,';'),':')"/><xsl:text>:</xsl:text><xsl:value-of select="substring-after(@src,',')"/>
			</xsl:when>
			<xsl:when test="@src != ''">
				<xsl:value-of select="@src"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="normalize-space(.)"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:when>
	<xsl:otherwise>
		<xsl:value-of select="normalize-space(.)" />
	</xsl:otherwise>
</xsl:choose>
</xsl:template>

<!-- SOUND property @@ not sure if this is correct? -->
<xsl:template match="*[contains(@class,'sound')]" mode="sound">
<xsl:text>
SOUND;</xsl:text>
<xsl:choose>
	<xsl:when test="@src != ''">
		<xsl:choose>
			<xsl:when test="substring-before(@src,':') = 'http'">
				<xsl:text>VALUE=uri:</xsl:text><xsl:value-of select="@src" />
			</xsl:when>
			<xsl:when test="substring-before(@src,':') = 'data'">
				<xsl:text>ENCODING=b;TYPE=</xsl:text><xsl:value-of select="substring-after(substring-before(@src,';'),':')"/><xsl:text>:</xsl:text><xsl:value-of select="substring-after(@src,',')"/>
			</xsl:when>
			<xsl:when test="@src != ''">
				<xsl:value-of select="@src"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="normalize-space(.)"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:when>
	<xsl:otherwise>
		<xsl:value-of select="normalize-space(.)" />
	</xsl:otherwise>
</xsl:choose>
</xsl:template>

<!-- NICKNAME property -->
<xsl:template match="*[contains(@class,'nickname')]" mode="nickname">
<xsl:text>
NICKNAME</xsl:text>
<xsl:choose>
	<xsl:when test="@xml:lang != ''">
		<xsl:text>;LANGUAGE=</xsl:text><xsl:value-of select="@xml:lang" />
	</xsl:when>
	<xsl:when test="@lang != ''">
		<xsl:text>;LANGUAGE=</xsl:text><xsl:value-of select="@lang" />
	</xsl:when>
</xsl:choose>
<xsl:text>:</xsl:text>
<xsl:choose>
	<xsl:when test="name()='ol'">
		<xsl:for-each select="*">
			<xsl:if test="not(position()=1)">
				<xsl:text>,</xsl:text>
			</xsl:if>
			<xsl:value-of select="."/>
		</xsl:for-each>
	</xsl:when>
	<xsl:when test="name()='ul'">
		<xsl:for-each select="*">
			<xsl:if test="not(position()=1)">
				<xsl:text>,</xsl:text>
			</xsl:if>
			<xsl:value-of select="."/>
		</xsl:for-each>
	</xsl:when>
	<xsl:otherwise>
		<xsl:choose>
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
	</xsl:otherwise>
</xsl:choose>
</xsl:template>

<!-- CATEGORIES property -->
<xsl:template match="*[contains(@class,'categories')]" mode="categories">
<xsl:text>
CATEGORIES</xsl:text>
<xsl:choose>
	<xsl:when test="@xml:lang != ''">
		<xsl:text>;LANGUAGE=</xsl:text><xsl:value-of select="@xml:lang" />
	</xsl:when>
	<xsl:when test="@lang != ''">
		<xsl:text>;LANGUAGE=</xsl:text><xsl:value-of select="@lang" />
	</xsl:when>
</xsl:choose>
<xsl:text>:</xsl:text>
<xsl:choose>
	<xsl:when test="name()='ol'">
		<xsl:for-each select="*">
			<xsl:if test="not(position()=1)">
				<xsl:text>,</xsl:text>
			</xsl:if>
			<xsl:value-of select="."/>
		</xsl:for-each>
	</xsl:when>
	<xsl:when test="name()='ul'">
		<xsl:for-each select="*">
			<xsl:if test="not(position()=1)">
				<xsl:text>,</xsl:text>
			</xsl:if>
			<xsl:value-of select="."/>
		</xsl:for-each>
	</xsl:when>
	<xsl:otherwise>
		<xsl:choose>
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
	</xsl:otherwise>
</xsl:choose>
</xsl:template>

<!-- ORG property -->
<xsl:template match="*[contains(@class,'org')]" mode="org">
<xsl:text>
ORG</xsl:text>
<xsl:choose>
	<xsl:when test="@xml:lang != ''">
		<xsl:text>;LANGUAGE=</xsl:text><xsl:value-of select="@xml:lang" />
	</xsl:when>
	<xsl:when test="@lang != ''">
		<xsl:text>;LANGUAGE=</xsl:text><xsl:value-of select="@lang" />
	</xsl:when>
</xsl:choose>
<xsl:text>:</xsl:text>
<xsl:apply-templates select="*[contains(@class,'Organization-Name')]|*[contains(@class,'organization-name')]" mode="org-sub"/>
<xsl:apply-templates select="*//*[contains(@class,'Organization-Name')]|*//*[contains(@class,'organization-name')]" mode="org-sub"/>
<xsl:for-each select="*[contains(@class,'Organization-Unit')]|*[contains(@class,'organization-unit')]">
	<xsl:text>;</xsl:text><xsl:value-of select="normalize-space(.)"/>
</xsl:for-each>
</xsl:template>

<!-- ORG-* properties -->
<xsl:template match="*[contains(@class,'Organization-Name')]|*[contains(@class,'organization-name')]" mode="org-sub">
<xsl:value-of select="normalize-space(.)"/>
</xsl:template>














<!-- gets the LABEL from any element (might need to escape returns '\n' or PRE element?) -->
<xsl:template match="*[contains(@class,'label')]" mode="label">
LABEL:<xsl:value-of select="." />
</xsl:template>

<!-- don't pass text thru -->
<xsl:template match="text()"></xsl:template>
</xsl:stylesheet>