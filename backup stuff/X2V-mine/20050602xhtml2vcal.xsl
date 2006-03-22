<?xml version="1.0"?>
<xsl:stylesheet 
 xmlns:xsl ="http://www.w3.org/1999/XSL/Transform" 
 version="1.0"
>
<xsl:output
  encoding="UTF-8"
  indent="no"
  media-type="text/calendar"
  method="text"
/>
<!--
brian sudaa
brian@suda.co.uk
http://suda.co.uk/

XHTML-2-iCal
Version 0.5.7
2005-05-26

Copyright 2005 Brian Suda
This work is licensed under the Creative Commons Attribution-ShareAlike License. 
To view a copy of this license, visit 
http://creativecommons.org/licenses/by-sa/1.0/

NOTES:
Until the hCal spec has been finalised this is a work in progress.
I'm not an XSLT expert, so there are no guarantees to quality of this code!

-->
<xsl:param name="x-from-url">(Best Practice: should be URL that this was ripped from)</xsl:param>
<xsl:template match="/">
<xsl:text>BEGIN:VCALENDAR
PRODID:-//suda.co.uk//X2V 0.5.7 (BETA)//EN
X-ORIGINAL-URL: </xsl:text><xsl:value-of select="$x-from-url"/>
<xsl:apply-templates select="//*[name() = 'title']" mode="htmltitle"/>
<xsl:text>
VERSION:2.0
</xsl:text>
<xsl:apply-templates select="//*[contains(concat(' ',@class,' '),'vevent')]"/>
<xsl:text>END:VCALENDAR</xsl:text>
</xsl:template>

<!-- Add more templates as they are needed-->
<xsl:template match="*[contains(@class,'vevent')]">
<xsl:param name="vcard-lang">
	<xsl:choose>
		<xsl:when test="@xml:lang != ''"><xsl:value-of select="@xml:lang" /></xsl:when>
		<xsl:when test="@lang != ''"><xsl:value-of select="@lang" /></xsl:when>
	</xsl:choose>
</xsl:param>
<xsl:text>BEGIN:VEVENT</xsl:text>
<xsl:apply-templates select="@id"  mode="uid"/>
<xsl:apply-templates select="*[contains(concat(' ',@class,' '),' attach ')]|*//*[contains(concat(' ',@class,' '),' attach ')]" mode="attach"/>
<xsl:apply-templates select="*[contains(concat(' ',@class,' '),' categories ')]|*//*[contains(concat(' ',@class,' '),' categories ')]" mode="categories">
<xsl:with-param name="vcard-lang"><xsl:value-of select="$vcard-lang" /></xsl:with-param>
</xsl:apply-templates>
<xsl:apply-templates select="*[contains(concat(' ',@class,' '),' class ')]|*//*[contains(concat(' ',@class,' '),' class ')]" mode="class"/>
<xsl:apply-templates select="*[contains(concat(' ',@class,' '),' comment ')]|*//*[contains(concat(' ',@class,' '),' comment ')]" mode="comment">
<xsl:with-param name="vcard-lang"><xsl:value-of select="$vcard-lang" /></xsl:with-param>
</xsl:apply-templates>
<xsl:apply-templates select="*[contains(concat(' ',@class,' '),' description ')]|*//*[contains(concat(' ',@class,' '),' description ')]" mode="description">
<xsl:with-param name="vcard-lang"><xsl:value-of select="$vcard-lang" /></xsl:with-param>
</xsl:apply-templates>
<!-- <xsl:apply-templates select="*[contains(concat(' ',@class,' '),' geo ')]|*//*[contains(concat(' ',@class,' '),' geo ')]" mode="geo"/>  -->
<xsl:apply-templates select="*[contains(concat(' ',@class,' '),' location ')]|*//*[contains(concat(' ',@class,' '),' location ')]" mode="location">
<xsl:with-param name="vcard-lang"><xsl:value-of select="$vcard-lang" /></xsl:with-param>
</xsl:apply-templates>
<xsl:apply-templates select="*[contains(concat(' ',@class,' '),' priority ')]|*//*[contains(concat(' ',@class,' '),' priority ')]" mode="priority"/>
<!-- <xsl:apply-templates select="*[contains(concat(' ',@class,' '),' resources ')]|*//*[contains(concat(' ',@class,' '),' resources ')]" mode="resources"/> -->
<!-- <xsl:apply-templates select="*[contains(concat(' ',@class,' '),' status ')]|*//*[contains(concat(' ',@class,' '),' status ')]" mode="status"/> -->
<xsl:apply-templates select="*[contains(concat(' ',@class,' '),' summary ')]|*//*[contains(concat(' ',@class,' '),' summary ')]" mode="summary">
<xsl:with-param name="vcard-lang"><xsl:value-of select="$vcard-lang" /></xsl:with-param>
</xsl:apply-templates>
<xsl:apply-templates select="*[contains(concat(' ',@class,' '),' dtend ')]|*//*[contains(concat(' ',@class,' '),' dtend ')]" mode="dtend"/>
<xsl:apply-templates select="*[contains(concat(' ',@class,' '),' dtstart ')]|*//*[contains(concat(' ',@class,' '),' dtstart ')]" mode="dtstart"/>
<xsl:apply-templates select="*[contains(concat(' ',@class,' '),' dtstamp ')]|*//*[contains(concat(' ',@class,' '),' dtstamp ')]" mode="dtstamp"/>
<xsl:apply-templates select="*[contains(concat(' ',@class,' '),' duration ')]|*//*[contains(concat(' ',@class,' '),' duration ')]" mode="duration"/>
<!-- <xsl:apply-templates select="*[contains(concat(' ',@class,' '),' transp ')]|*//*[contains(concat(' ',@class,' '),' transp ')]" mode="transp"/> -->
<xsl:apply-templates select="*[contains(concat(' ',@class,' '),' attandee ')]|*//*[contains(concat(' ',@class,' '),' attandee ')]" mode="attandee">
<xsl:with-param name="vcard-lang"><xsl:value-of select="$vcard-lang" /></xsl:with-param>
</xsl:apply-templates>
<xsl:apply-templates select="*[contains(concat(' ',@class,' '),' contact ')]|*//*[contains(concat(' ',@class,' '),' contact ')]" mode="contact">
<xsl:with-param name="vcard-lang"><xsl:value-of select="$vcard-lang" /></xsl:with-param>
</xsl:apply-templates>
<xsl:apply-templates select="*[contains(concat(' ',@class,' '),' organizer ')]|*//*[contains(concat(' ',@class,' '),' organizer ')]" mode="organizer">
<xsl:with-param name="vcard-lang"><xsl:value-of select="$vcard-lang" /></xsl:with-param>
</xsl:apply-templates>
<xsl:apply-templates select="*[contains(concat(' ',@class,' '),' recurrence-id ')]|*//*[contains(concat(' ',@class,' '),' recurrence-id ')]" mode="recurrence-id"/>
<xsl:apply-templates select="*[contains(concat(' ',@class,' '),' related-to ')]|*//*[contains(concat(' ',@class,' '),' related-to ')]" mode="related-to"/>
<xsl:apply-templates select="*[contains(concat(' ',@class,' '),' url ')]|*//*[contains(concat(' ',@class,' '),' url ')]" mode="url"/>
<xsl:apply-templates select="*[contains(concat(' ',@class,' '),' rdate ')]|*//*[contains(concat(' ',@class,' '),' rdate ')]" mode="rdate"/>
<xsl:apply-templates select="*[contains(concat(' ',@class,' '),' exdate ')]|*//*[contains(concat(' ',@class,' '),' exdate ')]" mode="exdate"/>
<xsl:apply-templates select="*[contains(concat(' ',@class,' '),' created ')]|*//*[contains(concat(' ',@class,' '),' created ')]" mode="created"/>
<xsl:apply-templates select="*[contains(concat(' ',@class,' '),' last-modified ')]|*//*[contains(concat(' ',@class,' '),' last-modified ')]" mode="last-modified"/>
<xsl:apply-templates select="*[contains(concat(' ',@class,' '),' sequence ')]|*//*[contains(concat(' ',@class,' '),' sequence ')]" mode="sequence"/>

<!-- UNWRITTEN TEMPLATES -->
<!--

@@ - all the RRULE stuff!

-->
<xsl:text>
END:VEVENT

</xsl:text>
</xsl:template>

<!-- experimental templates -->

<!-- working templates -->
<xsl:template match="*[contains(@class,'tzid')]" mode="tzid">
<xsl:text>;TZID=</xsl:text>
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

<!-- RDATE property -->
<xsl:template match="*[contains(@class,'rdate')]" mode="rdate">
<xsl:text>
RDATE</xsl:text>
<xsl:apply-templates select="*[contains(concat(' ',@class,' '),' tzid ')]" mode="tzid"/>
<xsl:choose>
	<xsl:when test="name()='ol'">
		<xsl:if test="contains(.,'/') = true()">
			<xsl:text>;VALUE=PERIOD</xsl:text>
		</xsl:if>
		<xsl:text>:</xsl:text>
		<xsl:for-each select="*">
			<xsl:if test="not(position()=1)">
				<xsl:text>,</xsl:text>
			</xsl:if>
			<xsl:call-template name="utc-time-converter">
				<xsl:with-param name="time-string"><xsl:value-of select="normalize-space(substring-before(.,'/'))" /></xsl:with-param>
			</xsl:call-template>
			<xsl:text>/</xsl:text>
			<xsl:call-template name="utc-time-converter">
				<xsl:with-param name="time-string"><xsl:value-of select="normalize-space(substring-after(.,'/'))" /></xsl:with-param>
			</xsl:call-template>
		</xsl:for-each>
	</xsl:when>
	<xsl:when test="name()='ul'">
		<xsl:if test="contains(.,'/') = true()">
			<xsl:text>;VALUE=PERIOD</xsl:text>
		</xsl:if>
		<xsl:text>:</xsl:text>
		<xsl:for-each select="*">
			<xsl:if test="not(position()=1)">
				<xsl:text>,</xsl:text>
			</xsl:if>
			<xsl:call-template name="utc-time-converter">
				<xsl:with-param name="time-string"><xsl:value-of select="normalize-space(substring-before(.,'/'))" /></xsl:with-param>
			</xsl:call-template>
			<xsl:text>/</xsl:text>
			<xsl:call-template name="utc-time-converter">
				<xsl:with-param name="time-string"><xsl:value-of select="normalize-space(substring-after(.,'/'))" /></xsl:with-param>
			</xsl:call-template>
		</xsl:for-each>
	</xsl:when>
	<xsl:otherwise>
		<xsl:choose>
			<xsl:when test="@longdesc != ''">
				<xsl:if test="contains(@longdesc,'/') = true()">
					<xsl:text>;VALUE=PERIOD</xsl:text>
				</xsl:if>
				<xsl:text>:</xsl:text>
					<xsl:call-template name="rdate-comma-utc">
						<xsl:with-param name="text-string"><xsl:value-of select="normalize-space(@longdesc)" /></xsl:with-param>
					</xsl:call-template>
			</xsl:when>
			<xsl:when test="@alt != ''">
				<xsl:if test="contains(@alt,'/') = true()">
					<xsl:text>;VALUE=PERIOD</xsl:text>
				</xsl:if>
				<xsl:text>:</xsl:text>
					<xsl:call-template name="rdate-comma-utc">
						<xsl:with-param name="text-string"><xsl:value-of select="normalize-space(@alt)" /></xsl:with-param>
					</xsl:call-template>
			</xsl:when>
			<xsl:when test="@title != ''">
				<xsl:if test="contains(@title,'/') = true()">
					<xsl:text>;VALUE=PERIOD</xsl:text>
				</xsl:if>
				<xsl:text>:</xsl:text>
					<xsl:call-template name="rdate-comma-utc">
						<xsl:with-param name="text-string"><xsl:value-of select="normalize-space(@title)" /></xsl:with-param>
					</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:if test="contains(.,'/') = true()">
					<xsl:text>;VALUE=PERIOD</xsl:text>
				</xsl:if>
				<xsl:text>:</xsl:text>
					<xsl:call-template name="rdate-comma-utc">
						<xsl:with-param name="text-string"><xsl:value-of select="normalize-space(.)" /></xsl:with-param>
					</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:otherwise>
</xsl:choose>
</xsl:template>

<!-- EXRULE property -->
<xsl:template match="*[contains(@class,'exrule')]" mode="exrule">
<xsl:text>
EXRULE</xsl:text>
<xsl:apply-templates select="*[contains(concat(' ',@class,' '),' tzid ')]" mode="tzid"/>
<xsl:text>:</xsl:text>
<xsl:choose>
	<xsl:when test="name()='ol'">
		<xsl:for-each select="*">
			<xsl:if test="not(position()=1)">
				<xsl:text>,</xsl:text>
			</xsl:if>
			<xsl:call-template name="func-comma-cleaner">
				<xsl:with-param name="text-string"><xsl:value-of select="normalize-space(.)" /></xsl:with-param>
			</xsl:call-template>
		</xsl:for-each>
	</xsl:when>
	<xsl:when test="name()='ul'">
		<xsl:for-each select="*">
			<xsl:if test="not(position()=1)">
				<xsl:text>,</xsl:text>
			</xsl:if>
			<xsl:call-template name="func-comma-cleaner">
				<xsl:with-param name="text-string"><xsl:value-of select="normalize-space(.)" /></xsl:with-param>
			</xsl:call-template>
		</xsl:for-each>
	</xsl:when>
	<xsl:otherwise>
		<xsl:choose>
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
				<xsl:with-param name="text-string"><xsl:value-of select="normalize-space(.)" /></xsl:with-param>
			</xsl:call-template>
		</xsl:for-each>
	</xsl:when>
	<xsl:when test="name()='ul'">
		<xsl:for-each select="*">
			<xsl:if test="not(position()=1)">
				<xsl:text>,</xsl:text>
			</xsl:if>
			<xsl:call-template name="func-comma-cleaner">
				<xsl:with-param name="text-string"><xsl:value-of select="normalize-space(.)" /></xsl:with-param>
			</xsl:call-template>
		</xsl:for-each>
	</xsl:when>
	<xsl:otherwise>
		<xsl:choose>
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
	</xsl:otherwise>
</xsl:choose>
</xsl:template>

<!-- CONTACT property -->
<xsl:template match="*[contains(@class,'contact')]" mode="contact">
<xsl:param name="vcard-lang" />
<xsl:text>
CONTACT</xsl:text>
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

<!-- ATTENDEE property -->
<xsl:template match="*[contains(@class,'attendee')]" mode="attendee">
<xsl:param name="vcard-lang" />
<xsl:text>
ATTENDEE</xsl:text>
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
<!-- @@ get all the possible parameters -->
<xsl:text>:MAILTO:</xsl:text>
<xsl:choose>
	<xsl:when test="@href != ''">
		<xsl:call-template name="func-comma-cleaner">
			<xsl:with-param name="text-string"><xsl:value-of select="normalize-space(substring-after(@href,':'))" /></xsl:with-param>
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

<!-- ORGANIZER property -->
<xsl:template match="*[contains(@class,'organizer')]" mode="organizer">
<xsl:param name="vcard-lang" />
<xsl:text>
ORGANIZER</xsl:text>
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
<!-- @@ get all the possible parameters -->
<xsl:text>:MAILTO:</xsl:text>
<xsl:choose>
	<xsl:when test="@href != ''">
		<xsl:call-template name="func-comma-cleaner">
			<xsl:with-param name="text-string"><xsl:value-of select="normalize-space(substring-after(@href,':'))" /></xsl:with-param>
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

<!-- RELATED-TO property -->
<xsl:template match="*[contains(@class,'related-to')]" mode="related-to">
<xsl:text>
RELATED-TO</xsl:text>
<xsl:if test="@rel != ''">
<xsl:text>;</xsl:text><xsl:value-of select="@rel"/>
</xsl:if>
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

<!-- RECURRENCE-ID property -->
<xsl:template match="*[contains(@class,'recurrence-id')]" mode="recurrence-id">
<xsl:text>
RECURRENCE-ID</xsl:text>
<xsl:apply-templates select="*[contains(concat(' ',@class,' '),' tzid ')]" mode="tzid"/>
<xsl:text>:</xsl:text>
<xsl:choose>
	<xsl:when test="@longdesc != ''">
		<xsl:call-template name="utc-time-converter">
			<xsl:with-param name="time-string"><xsl:value-of select="normalize-space(@longdesc)" /></xsl:with-param>
		</xsl:call-template>
	</xsl:when>
	<xsl:when test="@alt != ''">
		<xsl:call-template name="utc-time-converter">
			<xsl:with-param name="time-string"><xsl:value-of select="normalize-space(@alt)" /></xsl:with-param>
		</xsl:call-template>
	</xsl:when>
	<xsl:when test="@title != ''">
		<xsl:call-template name="utc-time-converter">
			<xsl:with-param name="time-string"><xsl:value-of select="normalize-space(@title)" /></xsl:with-param>
		</xsl:call-template>
	</xsl:when>
	<xsl:otherwise>
		<xsl:call-template name="utc-time-converter">
			<xsl:with-param name="time-string"><xsl:value-of select="normalize-space(.)" /></xsl:with-param>
		</xsl:call-template>
	</xsl:otherwise>
</xsl:choose>
</xsl:template>

<!-- LAST-MODIFIED property -->
<xsl:template match="*[contains(@class,'last-modified')]" mode="last-modified">
<xsl:text>
LAST-MODIFIED:</xsl:text>
<xsl:choose>
	<xsl:when test="@longdesc != ''">
		<xsl:call-template name="utc-time-converter">
			<xsl:with-param name="time-string"><xsl:value-of select="normalize-space(@longdesc)" /></xsl:with-param>
		</xsl:call-template>
	</xsl:when>
	<xsl:when test="@alt != ''">
		<xsl:call-template name="utc-time-converter">
			<xsl:with-param name="time-string"><xsl:value-of select="normalize-space(@alt)" /></xsl:with-param>
		</xsl:call-template>
	</xsl:when>
	<xsl:when test="@title != ''">
		<xsl:call-template name="utc-time-converter">
			<xsl:with-param name="time-string"><xsl:value-of select="normalize-space(@title)" /></xsl:with-param>
		</xsl:call-template>
	</xsl:when>
	<xsl:otherwise>
		<xsl:call-template name="utc-time-converter">
			<xsl:with-param name="time-string"><xsl:value-of select="normalize-space(.)" /></xsl:with-param>
		</xsl:call-template>
	</xsl:otherwise>
</xsl:choose>
</xsl:template>

<!-- SEQUENCE property -->
<xsl:template match="*[contains(@class,'sequence')]" mode="sequence">
<xsl:text>
SEQUENCE:</xsl:text>
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

<!-- URL property -->
<xsl:template match="*[contains(@class,'url')]" mode="url">
<xsl:text>
URL:</xsl:text>
<xsl:choose>
	<xsl:when test="@href != ''">
		<xsl:call-template name="func-comma-cleaner">
			<xsl:with-param name="text-string"><xsl:value-of select="normalize-space(@href)" /></xsl:with-param>
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

<!-- DURATION property -->
<xsl:template match="*[contains(@class,'duration')]" mode="duration">
<xsl:text>
DURATION:</xsl:text>
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

<!-- CREATED property -->
<xsl:template match="*[contains(@class,'created')]" mode="created">
<xsl:text>
CREATED:</xsl:text>
<xsl:choose>
	<xsl:when test="@longdesc != ''">
		<xsl:call-template name="utc-time-converter">
			<xsl:with-param name="time-string"><xsl:value-of select="normalize-space(@longdesc)" /></xsl:with-param>
		</xsl:call-template>
	</xsl:when>
	<xsl:when test="@alt != ''">
		<xsl:call-template name="utc-time-converter">
			<xsl:with-param name="time-string"><xsl:value-of select="normalize-space(@alt)" /></xsl:with-param>
		</xsl:call-template>
	</xsl:when>
	<xsl:when test="@title != ''">
		<xsl:call-template name="utc-time-converter">
			<xsl:with-param name="time-string"><xsl:value-of select="normalize-space(@title)" /></xsl:with-param>
		</xsl:call-template>
	</xsl:when>
	<xsl:otherwise>
		<xsl:call-template name="utc-time-converter">
			<xsl:with-param name="time-string"><xsl:value-of select="normalize-space(.)" /></xsl:with-param>
		</xsl:call-template>
	</xsl:otherwise>
</xsl:choose>
</xsl:template>

<!-- DTSTAMP property -->
<xsl:template match="*[contains(@class,'dtstamp')]" mode="dtstamp">
<xsl:text>
DTSTAMP</xsl:text>
<xsl:apply-templates select="*[contains(concat(' ',@class,' '),' tzid ')]" mode="tzid"/>
<xsl:text>:</xsl:text>
<xsl:choose>
	<xsl:when test="@longdesc != ''">
		<xsl:call-template name="utc-time-converter">
			<xsl:with-param name="time-string"><xsl:value-of select="normalize-space(@longdesc)" /></xsl:with-param>
		</xsl:call-template>
	</xsl:when>
	<xsl:when test="@alt != ''">
		<xsl:call-template name="utc-time-converter">
			<xsl:with-param name="time-string"><xsl:value-of select="normalize-space(@alt)" /></xsl:with-param>
		</xsl:call-template>
	</xsl:when>
	<xsl:when test="@title != ''">
		<xsl:call-template name="utc-time-converter">
			<xsl:with-param name="time-string"><xsl:value-of select="normalize-space(@title)" /></xsl:with-param>
		</xsl:call-template>
	</xsl:when>
	<xsl:otherwise>
		<xsl:call-template name="utc-time-converter">
			<xsl:with-param name="time-string"><xsl:value-of select="normalize-space(.)" /></xsl:with-param>
		</xsl:call-template>
	</xsl:otherwise>
</xsl:choose>
</xsl:template>

<!-- DTSTART property -->
<xsl:template match="*[contains(@class,'dtstart')]" mode="dtstart">
<xsl:text>
DTSTART</xsl:text>
<xsl:apply-templates select="*[contains(concat(' ',@class,' '),' tzid ')]" mode="tzid"/>
<xsl:text>:</xsl:text>
<xsl:choose>
	<xsl:when test="@longdesc != ''">
		<xsl:call-template name="utc-time-converter">
			<xsl:with-param name="time-string"><xsl:value-of select="normalize-space(@longdesc)" /></xsl:with-param>
		</xsl:call-template>
	</xsl:when>
	<xsl:when test="@alt != ''">
		<xsl:call-template name="utc-time-converter">
			<xsl:with-param name="time-string"><xsl:value-of select="normalize-space(@alt)" /></xsl:with-param>
		</xsl:call-template>
	</xsl:when>
	<xsl:when test="@title != ''">
		<xsl:call-template name="utc-time-converter">
			<xsl:with-param name="time-string"><xsl:value-of select="normalize-space(@title)" /></xsl:with-param>
		</xsl:call-template>
	</xsl:when>
	<xsl:otherwise>
		<xsl:call-template name="utc-time-converter">
			<xsl:with-param name="time-string"><xsl:value-of select="normalize-space(.)" /></xsl:with-param>
		</xsl:call-template>
	</xsl:otherwise>
</xsl:choose>
</xsl:template>

<!-- DTEND property -->
<xsl:template match="*[contains(@class,'dtend')]" mode="dtend">
<xsl:text>
DTEND</xsl:text>
<xsl:apply-templates select="*[contains(concat(' ',@class,' '),' tzid ')]" mode="tzid"/>
<xsl:text>:</xsl:text>
<xsl:choose>
	<xsl:when test="@longdesc != ''">
		<xsl:call-template name="utc-time-converter">
			<xsl:with-param name="time-string"><xsl:value-of select="normalize-space(@longdesc)" /></xsl:with-param>
		</xsl:call-template>
	</xsl:when>
	<xsl:when test="@alt != ''">
		<xsl:call-template name="utc-time-converter">
			<xsl:with-param name="time-string"><xsl:value-of select="normalize-space(@alt)" /></xsl:with-param>
		</xsl:call-template>
	</xsl:when>
	<xsl:when test="@title != ''">
		<xsl:call-template name="utc-time-converter">
			<xsl:with-param name="time-string"><xsl:value-of select="normalize-space(@title)" /></xsl:with-param>
		</xsl:call-template>
	</xsl:when>
	<xsl:otherwise>
		<xsl:call-template name="utc-time-converter">
			<xsl:with-param name="time-string"><xsl:value-of select="normalize-space(.)" /></xsl:with-param>
		</xsl:call-template>
	</xsl:otherwise>
</xsl:choose>
</xsl:template>

<!-- SUMMARY property -->
<xsl:template match="*[contains(@class,'summary')]" mode="summary">
<xsl:param name="vcard-lang" />
<xsl:text>
SUMMARY</xsl:text>
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

<!-- Priority property -->
<xsl:template match="*[contains(@class,'priority')]" mode="priority">
<xsl:text>
PRIORITY:</xsl:text>
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

<!-- LOCATION property -->
<xsl:template match="*[contains(@class,'location')]"  mode="location">
<xsl:param name="vcard-lang" />
<xsl:text>
LOCATION</xsl:text>
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

<!-- DESCRIPTION property -->
<xsl:template match="*[contains(@class,'description')]" mode="description">
<xsl:param name="vcard-lang" />
<xsl:text>
DESCRIPTION</xsl:text>
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

<!-- COMMENT property -->
<xsl:template match="*[contains(@class,'comment')]" mode="class">
<xsl:param name="vcard-lang" />
<xsl:text>
COMMENT</xsl:text>
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

<!-- ATTACH property -->
<xsl:template match="*[contains(@class,'attach')]" mode="attach">
<xsl:text>
ATTACH</xsl:text>
<xsl:choose>
	<xsl:when test="@href != ''">
		<xsl:choose>
			<xsl:when test="substring-before(@href,':') = 'http'">
				<xsl:text>:</xsl:text><xsl:value-of select="@href" />
			</xsl:when>
			<xsl:when test="substring-before(@href,':') = 'data'">
				<xsl:text>;ENCODING=BASE64;VALUE=BINARY:</xsl:text><xsl:value-of select="substring-after(@src,',')"/>
			</xsl:when>
			<xsl:when test="@href != ''">
				<xsl:text>:</xsl:text><xsl:value-of select="@href"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>:</xsl:text><xsl:value-of select="normalize-space(.)"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:when>
	<xsl:when test="@src != ''">
		<xsl:choose>
			<xsl:when test="substring-before(@src,':') = 'http'">
				<xsl:text>:</xsl:text><xsl:value-of select="@src" />
			</xsl:when>
			<xsl:when test="substring-before(@src,':') = 'data'">
				<xsl:text>ENCODING=BASE64;VALUE=BINARY:</xsl:text><xsl:value-of select="substring-after(@src,',')"/>
			</xsl:when>
			<xsl:when test="@src != ''">
				<xsl:text>:</xsl:text><xsl:value-of select="@src"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>:</xsl:text><xsl:value-of select="normalize-space(.)"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:when>
	<xsl:otherwise>
		<xsl:text>:</xsl:text><xsl:value-of select="normalize-space(.)" />
	</xsl:otherwise>
</xsl:choose>
</xsl:template>

<!-- TITLE for X-WR-CALNAME -->
<xsl:template match="//*[name() ='title']" mode="htmltitle">
<xsl:text>
X-WR-CALNAME: </xsl:text>
		<xsl:call-template name="func-comma-cleaner">
			<xsl:with-param name="text-string"><xsl:value-of select="normalize-space(.)" /></xsl:with-param>
		</xsl:call-template>
</xsl:template>


<!-- UID property-->
<xsl:template match="@id" mode="uid">
<xsl:text>
UID:</xsl:text>
<xsl:call-template name="func-comma-cleaner">
	<xsl:with-param name="text-string"><xsl:value-of select="normalize-space(.)" /></xsl:with-param>
</xsl:call-template>
</xsl:template>

<!-- convert all times to UTC Times -->
<xsl:template name="utc-time-converter">
<xsl:param name="time-string"></xsl:param>
<xsl:choose>
	<xsl:when test="(substring-before($time-string,'T') = true()) and (substring-before($time-string,'+') = true() or substring-before($time-string,'-') = true())">
		<xsl:variable name="event-year"> <xsl:value-of select="substring($time-string,1,4)"/></xsl:variable>
		<xsl:variable name="event-month"><xsl:value-of select="substring($time-string,5,2)"/></xsl:variable>
		<xsl:variable name="event-day">  <xsl:value-of select="substring($time-string,7,2)"/></xsl:variable>
		<xsl:variable name="event-date"><xsl:value-of select="substring-before($time-string,'T')"/></xsl:variable>

		<xsl:if test="substring-before(substring-after($time-string,'T'),'+') = true()">
			<xsl:choose>
				<xsl:when test="string-length(substring-before(substring-after($time-string,'T'),'+')) &lt; 6">
					<xsl:variable name="event-time"><xsl:value-of select="concat(substring-before(substring-after($time-string,'T'),'+'),'00')"/></xsl:variable>
					<xsl:choose>
						<xsl:when test="string-length(substring-after(substring-after($time-string,'T'),'+')) &lt; 6">
							<xsl:variable name="event-timezone"><xsl:value-of select="concat(substring-after(substring-after($time-string,'T'),'+'),'00')"/></xsl:variable>											<xsl:call-template name="build-utc">
								<xsl:with-param name="event-year"><xsl:value-of select="normalize-space($event-year)" /></xsl:with-param>
								<xsl:with-param name="event-month"><xsl:value-of select="normalize-space($event-month)" /></xsl:with-param>
								<xsl:with-param name="event-day"><xsl:value-of select="normalize-space($event-day)" /></xsl:with-param>
								<xsl:with-param name="utc-event-time"><xsl:value-of select="normalize-space($event-time - $event-timezone)" /></xsl:with-param>
							</xsl:call-template>
						</xsl:when>
						<xsl:otherwise>
							<xsl:variable name="event-timezone"><xsl:value-of select="substring-after(substring-after($time-string,'T'),'+')"/></xsl:variable>
							<xsl:call-template name="build-utc">
								<xsl:with-param name="event-year"><xsl:value-of select="normalize-space($event-year)" /></xsl:with-param>
								<xsl:with-param name="event-month"><xsl:value-of select="normalize-space($event-month)" /></xsl:with-param>
								<xsl:with-param name="event-day"><xsl:value-of select="normalize-space($event-day)" /></xsl:with-param>
								<xsl:with-param name="utc-event-time"><xsl:value-of select="normalize-space($event-time - $event-timezone)" /></xsl:with-param>
							</xsl:call-template>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>
					<xsl:variable name="event-time"><xsl:value-of select="substring-before(substring-after($time-string,'T'),'+')"/></xsl:variable>
					<xsl:choose>
						<xsl:when test="string-length(substring-after(substring-after($time-string,'T'),'+')) &lt; 6">
							<xsl:variable name="event-timezone"><xsl:value-of select="concat(substring-after(substring-after($time-string,'T'),'+'),'00')"/></xsl:variable>
							<xsl:call-template name="build-utc">
								<xsl:with-param name="event-year"><xsl:value-of select="normalize-space($event-year)" /></xsl:with-param>
								<xsl:with-param name="event-month"><xsl:value-of select="normalize-space($event-month)" /></xsl:with-param>
								<xsl:with-param name="event-day"><xsl:value-of select="normalize-space($event-day)" /></xsl:with-param>
								<xsl:with-param name="utc-event-time"><xsl:value-of select="normalize-space($event-time - $event-timezone)" /></xsl:with-param>
							</xsl:call-template>
						</xsl:when>
						<xsl:otherwise>
							<xsl:variable name="event-timezone"><xsl:value-of select="substring-after(substring-after($time-string,'T'),'+')"/></xsl:variable>
							<xsl:call-template name="build-utc">
								<xsl:with-param name="event-year"><xsl:value-of select="normalize-space($event-year)" /></xsl:with-param>
								<xsl:with-param name="event-month"><xsl:value-of select="normalize-space($event-month)" /></xsl:with-param>
								<xsl:with-param name="event-day"><xsl:value-of select="normalize-space($event-day)" /></xsl:with-param>
								<xsl:with-param name="utc-event-time"><xsl:value-of select="normalize-space($event-time - $event-timezone)" /></xsl:with-param>
							</xsl:call-template>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
		<xsl:if test="substring-before(substring-after($time-string,'T'),'-') = true()">

			<xsl:choose>
				<xsl:when test="string-length(substring-before(substring-after($time-string,'T'),'-')) &lt; 6">
					<xsl:variable name="event-time"><xsl:value-of select="concat(substring-before(substring-after($time-string,'T'),'-'),'00')"/></xsl:variable>
					<xsl:choose>
						<xsl:when test="string-length(substring-after(substring-after($time-string,'T'),'-')) &lt; 6">
							<xsl:variable name="event-timezone"><xsl:value-of select="concat(substring-after(substring-after($time-string,'T'),'-'),'00')"/></xsl:variable>											<xsl:call-template name="build-utc">
								<xsl:with-param name="event-year"><xsl:value-of select="normalize-space($event-year)" /></xsl:with-param>
								<xsl:with-param name="event-month"><xsl:value-of select="normalize-space($event-month)" /></xsl:with-param>
								<xsl:with-param name="event-day"><xsl:value-of select="normalize-space($event-day)" /></xsl:with-param>
								<xsl:with-param name="utc-event-time"><xsl:value-of select="normalize-space($event-time + $event-timezone)" /></xsl:with-param>
							</xsl:call-template>
						</xsl:when>
						<xsl:otherwise>
							<xsl:variable name="event-timezone"><xsl:value-of select="substring-after(substring-after($time-string,'T'),'-')"/></xsl:variable>
							<xsl:call-template name="build-utc">
								<xsl:with-param name="event-year"><xsl:value-of select="normalize-space($event-year)" /></xsl:with-param>
								<xsl:with-param name="event-month"><xsl:value-of select="normalize-space($event-month)" /></xsl:with-param>
								<xsl:with-param name="event-day"><xsl:value-of select="normalize-space($event-day)" /></xsl:with-param>
								<xsl:with-param name="utc-event-time"><xsl:value-of select="normalize-space($event-time + $event-timezone)" /></xsl:with-param>
							</xsl:call-template>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>
					<xsl:variable name="event-time"><xsl:value-of select="substring-before(substring-after($time-string,'T'),'-')"/></xsl:variable>
					<xsl:choose>
						<xsl:when test="string-length(substring-after(substring-after($time-string,'T'),'-')) &lt; 6">
							<xsl:variable name="event-timezone"><xsl:value-of select="concat(substring-after(substring-after($time-string,'T'),'-'),'00')"/></xsl:variable>
							<xsl:call-template name="build-utc">
								<xsl:with-param name="event-year"><xsl:value-of select="normalize-space($event-year)" /></xsl:with-param>
								<xsl:with-param name="event-month"><xsl:value-of select="normalize-space($event-month)" /></xsl:with-param>
								<xsl:with-param name="event-day"><xsl:value-of select="normalize-space($event-day)" /></xsl:with-param>
								<xsl:with-param name="utc-event-time"><xsl:value-of select="normalize-space($event-time + $event-timezone)" /></xsl:with-param>
							</xsl:call-template>
						</xsl:when>
						<xsl:otherwise>
							<xsl:variable name="event-timezone"><xsl:value-of select="substring-after(substring-after($time-string,'T'),'-')"/></xsl:variable>
							<xsl:call-template name="build-utc">
								<xsl:with-param name="event-year"><xsl:value-of select="normalize-space($event-year)" /></xsl:with-param>
								<xsl:with-param name="event-month"><xsl:value-of select="normalize-space($event-month)" /></xsl:with-param>
								<xsl:with-param name="event-day"><xsl:value-of select="normalize-space($event-day)" /></xsl:with-param>
								<xsl:with-param name="utc-event-time"><xsl:value-of select="normalize-space($event-time + $event-timezone)" /></xsl:with-param>
							</xsl:call-template>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
		
	</xsl:when>
	<xsl:otherwise>
		<xsl:value-of select="$time-string"/>
	</xsl:otherwise>
</xsl:choose>
</xsl:template>

<!-- create a valid UTC date and increments day/month/year as needed -->
<xsl:template name="build-utc">
<xsl:param name="event-year"></xsl:param>
<xsl:param name="event-month"></xsl:param>
<xsl:param name="event-day"></xsl:param>
<xsl:param name="utc-event-time"></xsl:param>

<xsl:choose>
	<xsl:when test="$utc-event-time &gt; 240000">
		<xsl:choose>
			<xsl:when test="($event-month = 12) and ($event-day = 31)">
				<xsl:value-of select="$event-year + 1"/>			
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$event-year"/>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:choose>
			<xsl:when test="(($event-month = 12) and ($event-day = 31))">
				<xsl:text>01</xsl:text>	
			</xsl:when>
			<xsl:when test="(($event-month = 11) and ($event-day = 30)) or (($event-month = 10) and ($event-day = 31)) or (($event-month = 9) and ($event-day = 30))">
				<xsl:value-of select="$event-month + 1"/>	
			</xsl:when>
			<xsl:when test="(($event-month = 8) and ($event-day = 31)) or (($event-month = 7) and ($event-day = 31)) or (($event-month = 6) and ($event-day = 30)) or (($event-month = 5) and ($event-day = 31)) or (($event-month = 4) and ($event-day = 30)) or (($event-month = 3) and ($event-day = 31)) or (($event-month = 1) and ($event-day = 31)) or ($event-month = 2) and ($event-day = 29)">
				<xsl:text>0</xsl:text><xsl:value-of select="$event-month + 1"/>	
			</xsl:when>
			<xsl:when test="(($event-month = 2) and ($event-day = 28) and (($event-year mod 4) != 0) or (($event-year mod 400) != 0) and (($event-year mod 100) = 0))">
				<xsl:text>0</xsl:text><xsl:value-of select="$event-month + 1"/>				
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$event-month"/>
			</xsl:otherwise>		
		</xsl:choose>
		<xsl:choose>
			<xsl:when test="(($event-month = 12) and ($event-day = 31)) or (($event-month = 11) and ($event-day = 30)) or (($event-month = 10) and ($event-day = 31)) or (($event-month = 9) and ($event-day = 30)) or (($event-month = 8) and ($event-day = 31)) or (($event-month = 7) and ($event-day = 31)) or (($event-month = 6) and ($event-day = 30)) or (($event-month = 5) and ($event-day = 31)) or (($event-month = 4) and ($event-day = 30)) or (($event-month = 3) and ($event-day = 31)) or (($event-month = 1) and ($event-day = 31)) or ($event-month = 2) and ($event-day = 29)">
				<xsl:text>01</xsl:text>
			</xsl:when>
			<xsl:when test="(($event-month = 2) and ($event-day = 28) and (($event-year mod 4) != 0) or (($event-year mod 400) != 0) and (($event-year mod 100) = 0))">
				<xsl:text>01</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$event-day + 1"/>			
			</xsl:otherwise>
		</xsl:choose>

		<xsl:text>T</xsl:text>
		<xsl:if test="string-length($utc-event-time mod 240000) &lt; 6">
		<xsl:text>0</xsl:text>
		</xsl:if>
		<xsl:value-of select="$utc-event-time mod 240000"/>
		<xsl:text>Z</xsl:text>
	</xsl:when>
	<xsl:when test="$utc-event-time &lt; 0">
		<xsl:choose>
			<xsl:when test="($event-month = 1) and ($event-day = 1)">
				<xsl:value-of select="$event-year - 1"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$event-year"/>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:choose>
			<xsl:when test="(($event-month = 1) and ($event-day = 1))">
				<xsl:text>12</xsl:text>
			</xsl:when>
			<xsl:when test="(($event-month = 11) and ($event-day = 1)) or (($event-month = 12) and ($event-day = 1))">
				<xsl:value-of select="$event-month - 1"/>
			</xsl:when>
			<xsl:when test="(($event-month = 10) and ($event-day = 1)) or (($event-month = 9) and ($event-day = 1)) or (($event-month = 8) and ($event-day = 1)) or (($event-month = 7) and ($event-day = 1)) or (($event-month = 6) and ($event-day = 1)) or (($event-month = 5) and ($event-day = 1)) or (($event-month = 4) and ($event-day = 1)) or (($event-month = 3) and ($event-day = 1)) or ($event-month = 2) and ($event-day = 1)">
				<xsl:text>0</xsl:text><xsl:value-of select="$event-month - 1"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$event-month"/>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:choose>
			<xsl:when test="(($event-month = 11) and ($event-day = 1)) or (($event-month = 9) and ($event-day = 1)) or (($event-month = 6) and ($event-day = 1)) or (($event-month = 4) and ($event-day = 1)) or (($event-month = 2) and ($event-day = 1)) or (($event-month = 1) and ($event-day = 1))">
				<xsl:text>31</xsl:text>
			</xsl:when>
			<xsl:when test="(($event-month = 12) and ($event-day = 1)) or (($event-month = 10) and ($event-day = 1)) or (($event-month = 7) and ($event-day = 1)) or (($event-month = 5) and ($event-day = 1))">
				<xsl:text>30</xsl:text>
			</xsl:when>
			<xsl:when test="(($event-month = 3) and ($event-day = 1) and (($event-year mod 4) != 0) or (($event-year mod 400) != 0) and (($event-year mod 100) = 0))">
				<xsl:text>28</xsl:text>
			</xsl:when>
			<xsl:when test="(($event-month = 3) and ($event-day = 1) and (($event-year mod 4) = 0) or (($event-year mod 400) = 0) and (($event-year mod 100) != 0))">
				<xsl:text>29</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$event-day - 1"/>			
			</xsl:otherwise>
		</xsl:choose>
		<xsl:text>T</xsl:text>
		<xsl:if test="string-length(240000 + $utc-event-time) &lt; 0">
		<xsl:text>0</xsl:text>
		</xsl:if>
		<xsl:value-of select="240000 + $utc-event-time"/>
		<xsl:text>Z</xsl:text>
	</xsl:when>
	<xsl:otherwise>
		<xsl:value-of select="$event-year"/>
		<xsl:value-of select="$event-month"/>
		<xsl:value-of select="$event-day"/>
		<xsl:text>T</xsl:text>
		
		<xsl:choose>
			<xsl:when test="$utc-event-time = 240000">
				<xsl:text>000000</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:if test="string-length($utc-event-time) &lt; 6">
					<xsl:text>0</xsl:text>
				</xsl:if>
				<xsl:if test="string-length($utc-event-time) &lt; 4">
					<xsl:text>0</xsl:text>
				</xsl:if>
				<xsl:if test="string-length($utc-event-time) &lt; 3">
					<xsl:text>0</xsl:text>
				</xsl:if>
				<xsl:if test="string-length($utc-event-time) &lt; 2">
					<xsl:text>0</xsl:text>
				</xsl:if>
				<xsl:if test="string-length($utc-event-time) = 1">
					<xsl:text>0</xsl:text>
				</xsl:if>
				<xsl:value-of select="$utc-event-time"/>
			</xsl:otherwise>
		</xsl:choose>

		
		<xsl:text>Z</xsl:text>
	</xsl:otherwise>
</xsl:choose>
</xsl:template>

<!-- recursive function to get all the RDATE times and check them for UTC -->
<xsl:template name="rdate-comma-utc">
<xsl:param name="text-string"></xsl:param>
<xsl:choose>
	<xsl:when test="substring-before($text-string,',') = true()">
		<xsl:call-template name="utc-time-converter">
			<xsl:with-param name="time-string"><xsl:value-of select="normalize-space(substring-before(substring-before($text-string,','),'/'))" /></xsl:with-param>
		</xsl:call-template>
		<xsl:text>/</xsl:text>
		<xsl:call-template name="utc-time-converter">
			<xsl:with-param name="time-string"><xsl:value-of select="normalize-space(substring-after(substring-before($text-string,','),'/'))" /></xsl:with-param>
		</xsl:call-template>
		<xsl:text>,</xsl:text>
		<xsl:call-template name="rdate-comma-utc">
			<xsl:with-param name="text-string"><xsl:value-of select="substring-after($text-string,',')"/></xsl:with-param>
		</xsl:call-template>
	</xsl:when>
	<xsl:otherwise>
		<xsl:call-template name="utc-time-converter">
			<xsl:with-param name="time-string"><xsl:value-of select="normalize-space(substring-before($text-string,'/'))" /></xsl:with-param>
		</xsl:call-template>
		<xsl:text>/</xsl:text>
		<xsl:call-template name="utc-time-converter">
			<xsl:with-param name="time-string"><xsl:value-of select="normalize-space(substring-after($text-string,'/'))" /></xsl:with-param>
		</xsl:call-template>
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

<!-- don't pass text thru -->
<xsl:template match="text()"></xsl:template>
</xsl:stylesheet>