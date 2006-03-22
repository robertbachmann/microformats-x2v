<?xml version="1.0"?>
<xsl:stylesheet 
 xmlns:xsl ="http://www.w3.org/1999/XSL/Transform" 
 version="1.0"
>

<xsl:output
  encoding="UTF-8"
  indent="no"
  media-type="text/x-vcal"
  method="text"
/>

<xsl:template match="/">BEGIN:VCALENDAR
VERSION:1.0
<xsl:if test="//*[contains(@class,'vevent')]">
BEGIN:VEVENT
<!-- checks for an ID--><xsl:if test="@id">
UID:<xsl:value-of select="@id" />
</xsl:if>
<!-- Get summary -->
<xsl:if test="//*[contains(@class,'summary')]">
SUMMARY:<xsl:value-of select="." />
</xsl:if>

</xsl:if>
END:VCALENDAR
</xsl:template>

<xsl:template match="*[contains(@class,'vevent')]">
BEGIN:VEVENT
<!-- checks for an ID--><xsl:if test="@id">
UID:<xsl:value-of select="@id" />
</xsl:if>

<xsl:if test="*[contains(@class,'summary')]">
SUMMARY:<xsl:value-of select="." />
</xsl:if>

<!-- checks for a description --><xsl:if test="*[contains(@class,'description')]">
DESCRIPTION:<xsl:value-of select="." />
</xsl:if>

<!-- checks for a priority --><xsl:if test="*[contains(@class,'priority')]">
PRIORITY:<xsl:value-of select="." />
</xsl:if>

<!-- checks for a percent-complete --><xsl:if test="*[contains(@class,'percent-complete')]">
PERCENT-COMPLETE:<xsl:value-of select="." />
</xsl:if>

<!-- checks for a status --><xsl:if test="*[contains(@class,'status')]">
STATUS:<xsl:value-of select="." />
</xsl:if>

<!-- checks for comments -->
<!-- commas need to be escaped!!! --><xsl:if test="*[contains(@class,'comment')]">
COMMENT:<xsl:value-of select="." />
</xsl:if>


<!-- EXPERIEMENTAL -->

<!-- checks for start date -->
<xsl:if test="//abbr[contains(@class,'dtstart')]">
DTSTART;VALUE=DATE:<xsl:value-of select="@title" /> 
</xsl:if>


<!-- has to more -->
<!-- checks for categories --><xsl:if test="*[contains(@class,'categories')]">
<xsl:apply-templates select="*[contains(@class,'categories')]" />
</xsl:if>

<!-- checks for class --><xsl:if test="*[contains(@class,'class')]">
<xsl:apply-templates select="*[contains(@class,'class')]" />
</xsl:if>


END:VEVENT
</xsl:template>

<!-- attribute values -->
<xsl:template match = "@title" >
<xsl:value-of select = "." />
</xsl:template> 



<!-- Template for Class -->
<xsl:template match="node()[contains(@class,'class')]">
	<xsl:if test="substring-after(@class,' ')">
		<xsl:call-template name="class-vars">
			<xsl:with-param name="values"><xsl:value-of select="@class"/></xsl:with-param>
		</xsl:call-template>
	</xsl:if>
</xsl:template>

<!-- Recursive Values for Class -->
<xsl:template name="class-vars">
	<xsl:param name="values"/>
	<xsl:choose>
		<xsl:when test="substring-after($values,' ')">
			<xsl:call-template name="class-vars">
				<xsl:with-param name="values"><xsl:value-of select="substring-after($values,' ')"/></xsl:with-param>
			</xsl:call-template>
			<xsl:if test="not(substring-before($values,' ')='class')">
				<xsl:text>,</xsl:text><xsl:value-of select="substring-before($values,' ')" />
			</xsl:if>
		</xsl:when>
		<xsl:otherwise>
			CLASS:<xsl:if test="not(substring-before($values,' ')='class')">
				<xsl:value-of select="$values" />
			</xsl:if>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<!-- Template for Categories -->
<xsl:template match="node()[contains(@class,'categories')]">
	<xsl:if test="substring-after(@class,' ')">
		<xsl:call-template name="categories-vars">
			<xsl:with-param name="values"><xsl:value-of select="@class"/></xsl:with-param>
		</xsl:call-template>
	</xsl:if>
</xsl:template>

<!-- Recursive Values for Categories -->
<xsl:template name="categories-vars">
	<xsl:param name="values"/>
	<xsl:choose>
		<xsl:when test="substring-after($values,' ')">
			<xsl:call-template name="categories-vars">
				<xsl:with-param name="values"><xsl:value-of select="substring-after($values,' ')"/></xsl:with-param>
			</xsl:call-template>
			<xsl:if test="not(substring-before($values,' ')='categories')">
				<xsl:text>,</xsl:text><xsl:value-of select="substring-before($values,' ')" />
			</xsl:if>
		</xsl:when>
		<xsl:otherwise>
			CATEGORIES:<xsl:if test="not(substring-before($values,' ')='categories')">
				<xsl:value-of select="$values" />
			</xsl:if>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="*[contains(@class,'vjournal')]">
BEGIN:VJOURNAL
END:VJOURNAL
</xsl:template>

<xsl:template match="*[contains(@class,'vtodo')]">
BEGIN:VTODO

END:VTODO
</xsl:template>


<!-- don't pass text thru -->
<xsl:template match="text()|@*">
</xsl:template>

</xsl:stylesheet>