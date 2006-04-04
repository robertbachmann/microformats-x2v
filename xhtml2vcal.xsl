<?xml version="1.0"?>
<xsl:stylesheet 
 xmlns:xsl ="http://www.w3.org/1999/XSL/Transform"
 xmlns:uri ="http://www.w3.org/2000/07/uri43/uri.xsl?template="
 version="1.0"
>

<!-- i have saved the file locally to conserve bandwidth, always check for updateds -->
<xsl:import href="uri.xsl" />

<xsl:output
  encoding="UTF-8"
  indent="no"
  media-type="text/calendar"
  method="text"
/>
<!--
brian suda
brian@suda.co.uk
http://suda.co.uk/

XHTML-2-iCal
Version 0.7.3
2006-03-21

Copyright 2005 Brian Suda
This work is relicensed under The W3C Open Source License
http://www.w3.org/Consortium/Legal/copyright-software-19980720


NOTES:
Until the hCal spec has been finalised this is a work in progress.
I'm not an XSLT expert, so there are no guarantees to quality of this code!

-->
<xsl:param name="Prodid">-//suda.co.uk//X2V 0.7.3 (BETA)//EN</xsl:param>
<xsl:param name="x-from-url">(Best Practice: should be URL that this was ripped from)</xsl:param>
<xsl:param name="Anchor" />

<xsl:param name="Debug" select="0"/>

<xsl:variable name="lowalpha" select='"abcdefghijklmnopqrstuvwxyz"'/>
<xsl:variable name="upalpha" select='"ABCDEFGHIJKLMNOPQRSTUVWXYZ"'/>
<xsl:variable name="digit" select='"01234567890"'/>
<xsl:variable name="alpha" select='concat($lowalpha, $upalpha)'/>
<xsl:param name="Encoding" >UTF-8</xsl:param>
<xsl:variable name="nl"><xsl:text>
</xsl:text></xsl:variable>
<xsl:variable name="tb"><xsl:text>	</xsl:text></xsl:variable>


<xsl:template match="/">
	<xsl:text>BEGIN:VCALENDAR</xsl:text>
	<xsl:text>&#x0A;PRODID:</xsl:text><xsl:value-of select="$Prodid"/>
	<xsl:text>&#x0A;X-ORIGINAL-URL:</xsl:text><xsl:value-of select="$x-from-url"/>
	<xsl:text>&#x0A;X-WR-CALNAME:</xsl:text>
	<xsl:call-template name="escapeText">
		<xsl:with-param name="text-string"><xsl:value-of select="normalize-space(//*[name() = 'title'])" /></xsl:with-param>
	</xsl:call-template>
	<xsl:text>&#x0A;VERSION:2.0</xsl:text>
	<xsl:text>&#x0A;METHOD:PUBLISH</xsl:text>	
	<xsl:apply-templates select="//*[contains(concat(' ',normalize-space(@class),' '),' vevent ')]"/>
	<xsl:text>&#x0A;END:VCALENDAR</xsl:text>
</xsl:template>

<!-- Add more templates as they are needed-->
<xsl:template match="*[contains(@class,'vevent')]">
	<xsl:if test="not($Anchor) or @id = $Anchor">
		<xsl:text>&#x0A;BEGIN:VEVENT</xsl:text>
		<!-- check for header="" and extract that data -->
		<xsl:if test="@headers">
			<xsl:call-template name="extract-ids">
				<xsl:with-param name="text-string"><xsl:value-of select="@headers"/></xsl:with-param>
			</xsl:call-template>
		</xsl:if>
		
		<xsl:if test=".//*[ancestor-or-self::*[name() = 'del'] = false()] and .//*[descendant-or-self::*[name() = 'object'] = true() and contains(normalize-space(@data),'#')]">
			<xsl:for-each select=".//*[descendant-or-self::*[name() = 'object'] = true() and contains(normalize-space(@data),'#') and contains(concat(' ',normalize-space(@class),' '),' include ')]">
				<xsl:variable name="header-id"><xsl:value-of select="substring-after(@data,'#')"/></xsl:variable>
				<xsl:for-each select="//*[@id=$header-id]">
					<xsl:call-template name="Properties"/>
				</xsl:for-each>
			</xsl:for-each>
		</xsl:if> 		
	
		<xsl:call-template name="Properties"/>
		<xsl:text>&#x0A;END:VEVENT&#x0A;</xsl:text>
	</xsl:if>
</xsl:template>

<!-- experimental templates -->
<xsl:template name="Properties">
	<xsl:call-template name="textProp">
		<xsl:with-param name="label">CLASS</xsl:with-param>
		<xsl:with-param name="class">class</xsl:with-param>
	</xsl:call-template>

	<xsl:call-template name="textProp">
		<xsl:with-param name="label">UID</xsl:with-param>
		<xsl:with-param name="class">uid</xsl:with-param>
	</xsl:call-template>

	<xsl:call-template name="textPropLang">
		<xsl:with-param name="label">COMMENT</xsl:with-param>
		<xsl:with-param name="class">comment</xsl:with-param>
	</xsl:call-template>

	<xsl:call-template name="textPropLang">
		<xsl:with-param name="label">DESCRIPTION</xsl:with-param>
		<xsl:with-param name="class">description</xsl:with-param>
	</xsl:call-template>

	<xsl:call-template name="textPropLang">
		<xsl:with-param name="label">LOCATION</xsl:with-param>
		<xsl:with-param name="class">location</xsl:with-param>
	</xsl:call-template>

	<xsl:call-template name="textPropLang">
		<xsl:with-param name="label">SUMMARY</xsl:with-param>
		<xsl:with-param name="class">summary</xsl:with-param>
	</xsl:call-template>

	<xsl:call-template name="textPropLang">
		<xsl:with-param name="label">CONTACT</xsl:with-param>
		<xsl:with-param name="class">contact</xsl:with-param>
	</xsl:call-template>

	<xsl:call-template name="textProp">
		<xsl:with-param name="label">SEQUENCE</xsl:with-param>
		<xsl:with-param name="class">sequence</xsl:with-param>
	</xsl:call-template>

	<xsl:call-template name="textProp">
		<xsl:with-param name="label">PRIORITY</xsl:with-param>
		<xsl:with-param name="class">priority</xsl:with-param>
	</xsl:call-template>

	<xsl:call-template name="textProp">
		<xsl:with-param name="label">STATUS</xsl:with-param>
		<xsl:with-param name="class">status</xsl:with-param>
	</xsl:call-template>

	<xsl:call-template name="textProp">
		<xsl:with-param name="label">TRANSP</xsl:with-param>
		<xsl:with-param name="class">transp</xsl:with-param>
	</xsl:call-template>

	<xsl:call-template name="textProp">
		<xsl:with-param name="label">DURATION</xsl:with-param>
		<xsl:with-param name="class">duration</xsl:with-param>
	</xsl:call-template>

	<xsl:call-template name="dateProp">
		<xsl:with-param name="label">DTSTART</xsl:with-param>
		<xsl:with-param name="class">dtstart</xsl:with-param>
	</xsl:call-template>

	<xsl:call-template name="dateProp">
		<xsl:with-param name="label">DTEND</xsl:with-param>
		<xsl:with-param name="class">dtend</xsl:with-param>
	</xsl:call-template>

	<xsl:call-template name="dateProp">
		<xsl:with-param name="label">DTSTAMP</xsl:with-param>
		<xsl:with-param name="class">dtstamp</xsl:with-param>
	</xsl:call-template>

	<xsl:call-template name="dateProp">
		<xsl:with-param name="label">LAST-MODIFIED</xsl:with-param>
		<xsl:with-param name="class">last-modified</xsl:with-param>
	</xsl:call-template>

	<xsl:call-template name="dateProp">
		<xsl:with-param name="label">CREATED</xsl:with-param>
		<xsl:with-param name="class">created</xsl:with-param>
	</xsl:call-template>

	<xsl:call-template name="dateProp">
		<xsl:with-param name="label">RECURRENCE-ID</xsl:with-param>
		<xsl:with-param name="class">recurrence-id</xsl:with-param>
	</xsl:call-template>

	<xsl:call-template name="personProp">
		<xsl:with-param name="label">ATTENDEE</xsl:with-param>
		<xsl:with-param name="class">attendee</xsl:with-param>
	</xsl:call-template>

	<xsl:call-template name="personProp">
		<xsl:with-param name="label">ORGANIZER</xsl:with-param>
		<xsl:with-param name="class">organizer</xsl:with-param>
	</xsl:call-template>
	
	<xsl:call-template name="multiTextPropLang">
		<xsl:with-param name="label">CATEGORIES</xsl:with-param>
		<xsl:with-param name="class">category</xsl:with-param>
	</xsl:call-template>
	

	<!-- These are all unique: custom templates -->
	<xsl:apply-templates select=".//*[contains(concat(' ',normalize-space(@class),' '),' related-to ')]" mode="related-to"/>
	<xsl:apply-templates select=".//*[contains(concat(' ',normalize-space(@class),' '),' attach ')]" mode="attach"/>
	<xsl:apply-templates select=".//*[contains(concat(' ',normalize-space(@class),' '),' url ')]" mode="url"/>
	<xsl:apply-templates select=".//*[contains(concat(' ',normalize-space(@class),' '),' rdate ')]" mode="rdate"/>
	<xsl:apply-templates select=".//*[contains(concat(' ',normalize-space(@class),' '),' exdate ')]" mode="exdate"/>

	<!-- <xsl:apply-templates select=".//*[contains(concat(' ',normalize-space(@class),' '),' geo ')]" mode="geo"/>  -->
	<!-- <xsl:apply-templates select=".//*[contains(concat(' ',normalize-space(@class),' '),' resources ')]" mode="resources"/> -->
	<!-- <xsl:apply-templates select=".//*[contains(concat(' ',normalize-space(@class),' '),' status ')]" mode="status"/> -->
	<!-- <xsl:apply-templates select=".//*[contains(concat(' ',normalize-space(@class),' '),' transp ')]" mode="transp"/> -->

	<!-- UNWRITTEN TEMPLATES -->
	<!--
		
	@@ - all the RRULE stuff!
	
	-->
</xsl:template>

<!-- Date property -->
<xsl:template name="dateProp">
	<xsl:param name="label" />
	<xsl:param name="class" />
	
	<xsl:for-each select="descendant-or-self::*[contains(concat(' ', @class, ' '),concat(' ', $class, ' '))]">
        <xsl:text>&#x0A;</xsl:text>
		<xsl:value-of select="$label" />
		<!-- TZID needs work! -->
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
	</xsl:for-each>
</xsl:template>

<!-- TEXT PROPERTY without LANGUAGE -->
<xsl:template name="textProp">
	<xsl:param name="label" />
	<xsl:param name="class" />
		
	<xsl:for-each select=".//*[ancestor-or-self::*[name() = 'del'] = false() and contains(concat(' ', @class, ' '),concat(' ', $class, ' '))]">
	<xsl:if test="position() = 1">
        <xsl:text>&#x0A;</xsl:text>
		<xsl:value-of select="$label" />
		<xsl:text>;CHARSET=</xsl:text><xsl:value-of select="$Encoding"/>
        <xsl:text>:</xsl:text>
		<xsl:choose>
			<xsl:when test='local-name(.) = "ol" or local-name(.) = "ul"'>
				<xsl:for-each select="*">
					<xsl:if test="not(position()=1)">
						<xsl:text>,</xsl:text>
					</xsl:if>
					<xsl:choose>
						<xsl:when test=".//*[contains(concat(' ', normalize-space(@class), ' '),' value ')]">
							<xsl:for-each select=".//*[contains(concat(' ', normalize-space(@class), ' '),' value ')]">
								<xsl:variable name="textFormatted">
								<xsl:apply-templates select="." mode="unFormatText" />
								</xsl:variable>
								<xsl:value-of select="normalize-space($textFormatted)"/>
							</xsl:for-each>
						</xsl:when>
						<xsl:otherwise>
							<xsl:variable name="textFormatted">
							<xsl:apply-templates select="." mode="unFormatText" />
							</xsl:variable>
							<xsl:value-of select="normalize-space($textFormatted)"/>
						</xsl:otherwise>
					</xsl:choose>		
				</xsl:for-each>
			</xsl:when>
			<xsl:when test='local-name(.) = "abbr" and @title'>
				<xsl:variable name="textFormatted">
				<xsl:apply-templates select="@title" mode="unFormatText" />
				</xsl:variable>
				<xsl:value-of select="normalize-space($textFormatted)"/>
			</xsl:when>			
			<xsl:when test='@alt and local-name(.) = "img"'>
				<xsl:variable name="textFormatted">
				<xsl:apply-templates select="@alt" mode="unFormatText" />
				</xsl:variable>
				<xsl:value-of select="normalize-space($textFormatted)"/>
			</xsl:when>
			<xsl:when test=".//*[contains(concat(' ', normalize-space(@class), ' '),' value ')]">
				<xsl:for-each select=".//*[contains(concat(' ', normalize-space(@class), ' '),' value ')]">
					<xsl:variable name="textFormatted">
					<xsl:apply-templates select="." mode="unFormatText" />
					</xsl:variable>
					<xsl:value-of select="normalize-space($textFormatted)"/>
				</xsl:for-each>
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="textFormatted">
				<xsl:apply-templates select="." mode="unFormatText" />
				</xsl:variable>
				<xsl:value-of select="normalize-space($textFormatted)"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:if>
	</xsl:for-each>
</xsl:template>

<!-- TEXT PROPERTY with LANGUAGE -->
<xsl:template name="textPropLang">
	<xsl:param name="label" />
	<xsl:param name="class" />

	<xsl:for-each select=".//*[contains(concat(' ', @class, ' '),concat(' ', $class, ' '))]">

	<xsl:if test="position() = 1">

        <xsl:text>&#x0A;</xsl:text>
		<xsl:value-of select="$label" />
    	<xsl:call-template name="lang" />
		<xsl:text>;CHARSET=</xsl:text><xsl:value-of select="$Encoding"/>
        <xsl:text>:</xsl:text>
		<xsl:choose>
			<xsl:when test='local-name(.) = "ol" or local-name(.) = "ul"'>
				<xsl:for-each select="*">
					<xsl:if test="not(position()=1)">
						<xsl:text>,</xsl:text>
					</xsl:if>
					<xsl:choose>
						<xsl:when test=".//*[contains(concat(' ', normalize-space(@class), ' '),' value ')]">
							<xsl:for-each select=".//*[contains(concat(' ', normalize-space(@class), ' '),' value ')]">
								<xsl:variable name="textFormatted">
								<xsl:apply-templates select="." mode="unFormatText" />
								</xsl:variable>
								<xsl:value-of select="normalize-space($textFormatted)"/>
							</xsl:for-each>
						</xsl:when>
						<xsl:otherwise>
							<xsl:variable name="textFormatted">
							<xsl:apply-templates select="." mode="unFormatText" />
							</xsl:variable>
							<xsl:value-of select="normalize-space($textFormatted)"/>
						</xsl:otherwise>
					</xsl:choose>		
				</xsl:for-each>
			</xsl:when>
			<xsl:when test='local-name(.) = "abbr" and @title'>
				<xsl:variable name="textFormatted">
				<xsl:apply-templates select="@title" mode="unFormatText" />
				</xsl:variable>
				<xsl:value-of select="normalize-space($textFormatted)"/>
			</xsl:when>
			<xsl:when test='@alt and local-name(.) = "src"'>
				<xsl:variable name="textFormatted">
				<xsl:apply-templates select="@alt" mode="unFormatText" />
				</xsl:variable>
				<xsl:value-of select="normalize-space($textFormatted)"/>
			</xsl:when>
			<xsl:when test=".//*[contains(concat(' ', normalize-space(@class), ' '),' value ')]">
				<xsl:for-each select=".//*[contains(concat(' ', normalize-space(@class), ' '),' value ')]">
					<xsl:variable name="textFormatted">
					<xsl:apply-templates select="." mode="unFormatText" />
					</xsl:variable>
					<xsl:value-of select="normalize-space($textFormatted)"/>						
				</xsl:for-each>
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="textFormatted">
				<xsl:apply-templates select="." mode="unFormatText" />
				</xsl:variable>
				<xsl:value-of select="normalize-space($textFormatted)"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:if>
	</xsl:for-each>
</xsl:template>

<!-- Person Property (Attendee / Organizer) -->
<xsl:template name="personProp">
	<xsl:param name="label" />
	<xsl:param name="class" />

	<xsl:for-each select="descendant-or-self::*[contains(concat(' ', @class, ' '),concat(' ', $class, ' '))]">
    <!-- @@ "the first descendant element with that class should take
         effect, any others being ignored." -->
        <xsl:text>&#x0A;</xsl:text>
		<xsl:value-of select="$label" />
    	<xsl:call-template name="lang" />
        <xsl:text>:</xsl:text>
		
		
		<!-- @@ get all the possible parameters -->
		<xsl:text>MAILTO:</xsl:text>
		<xsl:choose>
			<xsl:when test="@href != ''">
				<xsl:call-template name="escapeText">
					<xsl:with-param name="text-string"><xsl:value-of select="normalize-space(substring-after(@href,':'))" /></xsl:with-param>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="@longdesc != ''">
				<xsl:call-template name="escapeText">
					<xsl:with-param name="text-string"><xsl:value-of select="normalize-space(@longdesc)" /></xsl:with-param>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="@alt != ''">
				<xsl:call-template name="escapeText">
					<xsl:with-param name="text-string"><xsl:value-of select="normalize-space(@alt)" /></xsl:with-param>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="@title != ''">
				<xsl:call-template name="escapeText">
					<xsl:with-param name="text-string"><xsl:value-of select="normalize-space(@title)" /></xsl:with-param>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="escapeText">
					<xsl:with-param name="text-string"><xsl:value-of select="normalize-space(.)" /></xsl:with-param>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:for-each>
</xsl:template>


<!-- working templates -->
<xsl:template match="*[contains(@class,'tzid')]" mode="tzid">
<xsl:text>;TZID=</xsl:text>
<xsl:choose>
	<xsl:when test="@longdesc != ''">
		<xsl:call-template name="escapeText">
			<xsl:with-param name="text-string"><xsl:value-of select="normalize-space(@longdesc)" /></xsl:with-param>
		</xsl:call-template>
	</xsl:when>
	<xsl:when test="@alt != ''">
		<xsl:call-template name="escapeText">
			<xsl:with-param name="text-string"><xsl:value-of select="normalize-space(@alt)" /></xsl:with-param>
		</xsl:call-template>
	</xsl:when>
	<xsl:when test="@title != ''">
		<xsl:call-template name="escapeText">
			<xsl:with-param name="text-string"><xsl:value-of select="normalize-space(@title)" /></xsl:with-param>
		</xsl:call-template>
	</xsl:when>
	<xsl:otherwise>
		<xsl:call-template name="escapeText">
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
			<xsl:call-template name="escapeText">
				<xsl:with-param name="text-string"><xsl:value-of select="normalize-space(.)" /></xsl:with-param>
			</xsl:call-template>
		</xsl:for-each>
	</xsl:when>
	<xsl:when test="name()='ul'">
		<xsl:for-each select="*">
			<xsl:if test="not(position()=1)">
				<xsl:text>,</xsl:text>
			</xsl:if>
			<xsl:call-template name="escapeText">
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


<!-- TEXT PROPERTY with LANGUAGE -->
<xsl:template name="multiTextPropLang">
	<xsl:param name="label" />
	<xsl:param name="class" />

	<xsl:if test=".//*[ancestor-or-self::*[name() = 'del'] = false() and contains(concat(' ', @class, ' '),concat(' ', $class, ' '))]">
		<xsl:text>&#x0A;</xsl:text>
		<xsl:value-of select="$label" />
		<!-- this lang needs to be looked at! -->
		<xsl:call-template name="lang" />
		<xsl:text>;CHARSET=</xsl:text><xsl:value-of select="$Encoding"/>
	    <xsl:text>:</xsl:text>
	</xsl:if>
	
	<xsl:for-each select=".//*[ancestor-or-self::*[name() = 'del'] = false() and contains(concat(' ', @class, ' '),concat(' ', $class, ' '))]">
		<xsl:choose>
			<xsl:when test='local-name(.) = "ol" or local-name(.) = "ul"'>
				<xsl:for-each select="*">
					<xsl:if test="not(position()=1)">
						<xsl:text>,</xsl:text>
					</xsl:if>
					<xsl:choose>
						<xsl:when test=".//*[contains(concat(' ', normalize-space(@class), ' '),' value ')]">
							<xsl:for-each select=".//*[contains(concat(' ', normalize-space(@class), ' '),' value ')]">
								<xsl:variable name="textFormatted">
								<xsl:apply-templates select="." mode="unFormatText" />
								</xsl:variable>
								<xsl:value-of select="normalize-space($textFormatted)"/>
							</xsl:for-each>
						</xsl:when>
						<xsl:otherwise>
							<xsl:variable name="textFormatted">
							<xsl:apply-templates select="." mode="unFormatText" />
							</xsl:variable>
							<xsl:value-of select="normalize-space($textFormatted)"/>
						</xsl:otherwise>
					</xsl:choose>		
				</xsl:for-each>
			</xsl:when>
			<xsl:when test='local-name(.) = "abbr" and @title'>
				<xsl:variable name="textFormatted">
				<xsl:apply-templates select="@title" mode="unFormatText" />
				</xsl:variable>
				<xsl:value-of select="normalize-space($textFormatted)"/>
			</xsl:when>
			<xsl:when test='@alt and local-name(.) = "src"'>
				<xsl:variable name="textFormatted">
				<xsl:apply-templates select="@alt" mode="unFormatText" />
				</xsl:variable>
				<xsl:value-of select="normalize-space($textFormatted)"/>
			</xsl:when>
			<xsl:when test=".//*[contains(concat(' ', normalize-space(@class), ' '),' value ')]">
				<xsl:for-each select=".//*[contains(concat(' ', normalize-space(@class), ' '),' value ')]">
					<xsl:variable name="textFormatted">
					<xsl:apply-templates select="." mode="unFormatText" />
					</xsl:variable>
					<xsl:value-of select="normalize-space($textFormatted)"/>
				</xsl:for-each>
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="textFormatted">
				<xsl:apply-templates select="." mode="unFormatText" />
				</xsl:variable>
				<xsl:value-of select="normalize-space($textFormatted)"/>
			</xsl:otherwise>
		</xsl:choose>	
		<xsl:if test="not(position()=last())">
			<xsl:text>,</xsl:text>
		</xsl:if>
	</xsl:for-each>
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
		<xsl:call-template name="escapeText">
			<xsl:with-param name="text-string"><xsl:value-of select="normalize-space(@longdesc)" /></xsl:with-param>
		</xsl:call-template>
	</xsl:when>
	<xsl:when test="@alt != ''">
		<xsl:call-template name="escapeText">
			<xsl:with-param name="text-string"><xsl:value-of select="normalize-space(@alt)" /></xsl:with-param>
		</xsl:call-template>
	</xsl:when>
	<xsl:when test="@title != ''">
		<xsl:call-template name="escapeText">
			<xsl:with-param name="text-string"><xsl:value-of select="normalize-space(@title)" /></xsl:with-param>
		</xsl:call-template>
	</xsl:when>
	<xsl:otherwise>
		<xsl:call-template name="escapeText">
			<xsl:with-param name="text-string"><xsl:value-of select="normalize-space(.)" /></xsl:with-param>
		</xsl:call-template>
	</xsl:otherwise>
</xsl:choose>
</xsl:template>

<!-- URL property -->
<xsl:template match="*[contains(@class,'url')]" mode="url">
<xsl:text>
URL</xsl:text>
<xsl:choose>
	<xsl:when test="@href != ''">
			<xsl:choose>
			<xsl:when test="substring-before(@href,':') = 'http'">
				<xsl:text>:</xsl:text>
				<xsl:value-of select="@href" />
			</xsl:when>
			<xsl:when test="@href != ''">
				<xsl:text>:</xsl:text>
				<!-- convert to absolute url -->
				
				<xsl:call-template name="uri:expand">
					<xsl:with-param name="base"><xsl:value-of select="$x-from-url" /></xsl:with-param>
					<xsl:with-param name="there"><xsl:value-of select="@href"/></xsl:with-param>
				</xsl:call-template>
				
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>:</xsl:text>
				<xsl:value-of select="normalize-space(.)"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:when>
	<xsl:when test="@longdesc != ''">
			<xsl:choose>
			<xsl:when test="substring-before(@longdesc,':') = 'http'">
				<xsl:text>:</xsl:text>
				<xsl:value-of select="@href" />
			</xsl:when>
			<xsl:when test="@longdesc != ''">
				<xsl:text>:</xsl:text>
				<!-- convert to absolute url -->
				<xsl:call-template name="uri:expand">
					<xsl:with-param name="base" ><xsl:value-of select="$x-from-url" /></xsl:with-param>
					<xsl:with-param name="there" ><xsl:value-of select="@longdesc" /></xsl:with-param>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>:</xsl:text>
				<xsl:value-of select="normalize-space(.)"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:when>
	<xsl:when test="@alt != ''">
		<xsl:call-template name="escapeText">
			<xsl:with-param name="text-string"><xsl:value-of select="normalize-space(@alt)" /></xsl:with-param>
		</xsl:call-template>
	</xsl:when>
	<xsl:when test="@title != ''">
		<xsl:call-template name="escapeText">
			<xsl:with-param name="text-string"><xsl:value-of select="normalize-space(@title)" /></xsl:with-param>
		</xsl:call-template>
	</xsl:when>
	<xsl:otherwise>
		<xsl:call-template name="escapeText">
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
			<xsl:when test="@hreftype">
				<xsl:text>;FMTTYPE=</xsl:text><xsl:value-of select="@hreftype"/>
			</xsl:when>
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
				<xsl:text>;VALUE=</xsl:text>
				<!-- convert to absolute url -->
				<xsl:call-template name="uri:expand">
					<xsl:with-param name="base" ><xsl:value-of select="$x-from-url"/></xsl:with-param>
					<xsl:with-param name="there" ><xsl:value-of select="@src"/></xsl:with-param>
				</xsl:call-template>
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

<!-- UID property-->
<xsl:template match="@id" mode="uid">
<xsl:text>
UID:</xsl:text>
<xsl:call-template name="escapeText">
	<xsl:with-param name="text-string"><xsl:value-of select="normalize-space(.)" /></xsl:with-param>
</xsl:call-template>
</xsl:template>

<!-- convert all times to UTC Times -->
<!-- RFC2426 mandates that iCal dates are in UTC without dashes or colons as seperators -->
<xsl:template name="utc-time-converter">
<xsl:param name="time-string"></xsl:param>
<xsl:choose>
	<xsl:when test="substring-before($time-string,'Z') = true()">
		<!-- need to pad with 0000s if needed -->
		<xsl:value-of select="translate(translate(substring-before($time-string,'Z'), ':' ,''), '-' ,'')"/>
		<xsl:if test="string-length(translate(translate(substring-before($time-string,'Z'), ':' ,''), '-' ,''))  &lt; 10">
			<xsl:text>0</xsl:text>
		</xsl:if>
		<xsl:if test="string-length(translate(translate(substring-before($time-string,'Z'), ':' ,''), '-' ,''))  &lt; 11">
			<xsl:text>0</xsl:text>
		</xsl:if>
		<xsl:if test="string-length(translate(translate(substring-before($time-string,'Z'), ':' ,''), '-' ,''))  &lt; 12">
			<xsl:text>0</xsl:text>
		</xsl:if>
		<xsl:if test="string-length(translate(translate(substring-before($time-string,'Z'), ':' ,''), '-' ,''))  &lt; 13">
			<xsl:text>0</xsl:text>
		</xsl:if>
		<xsl:if test="string-length(translate(translate(substring-before($time-string,'Z'), ':' ,''), '-' ,''))  &lt; 14">
			<xsl:text>0</xsl:text>
		</xsl:if>
		<xsl:if test="string-length(translate(translate(substring-before($time-string,'Z'), ':' ,''), '-' ,''))  &lt; 15">
			<xsl:text>0</xsl:text>
		</xsl:if>
		<xsl:text>Z</xsl:text>
	</xsl:when>
	<xsl:when test="substring-before($time-string,'T') = false()">
		<!-- i think we need to pad a timestamp here?  -->
		<xsl:value-of select="translate(translate($time-string, ':' ,''), '-' ,'')"/>
	</xsl:when>
	<xsl:otherwise>
		<xsl:variable name="event-year"> <xsl:value-of select="substring(translate($time-string, '-' ,''),1,4)"/></xsl:variable>
		<xsl:variable name="event-month"><xsl:value-of select="substring(translate($time-string, '-' ,''),5,2)"/></xsl:variable>
		<xsl:variable name="event-day">  <xsl:value-of select="substring(translate($time-string, '-' ,''),7,2)"/></xsl:variable>
		<xsl:variable name="event-date"><xsl:value-of select="substring-before(translate($time-string, '-' ,''),'T')"/></xsl:variable>
		<xsl:choose>
			<xsl:when test="substring-before(substring-after(translate($time-string, ':' ,''),'T'),'+') = true()">
				<xsl:choose>
					<xsl:when test="string-length(substring-before(substring-after(translate($time-string, ':' ,''),'T'),'+')) &lt; 6">
						<xsl:variable name="event-time"><xsl:value-of select="concat(substring-before(substring-after(translate($time-string, ':' ,''),'T'),'+'),'00')"/></xsl:variable>
						<xsl:choose>
							<xsl:when test="string-length(substring-after(substring-after(translate($time-string, ':' ,''),'T'),'+')) &lt; 4">
								<xsl:variable name="event-timezone"><xsl:value-of select="concat(substring-after(substring-after(translate($time-string, ':' ,''),'T'),'+'),'0000')"/></xsl:variable>											<xsl:call-template name="build-utc">
									<xsl:with-param name="event-year"><xsl:value-of select="normalize-space($event-year)" /></xsl:with-param>
									<xsl:with-param name="event-month"><xsl:value-of select="normalize-space($event-month)" /></xsl:with-param>
									<xsl:with-param name="event-day"><xsl:value-of select="normalize-space($event-day)" /></xsl:with-param>
									<xsl:with-param name="utc-event-time"><xsl:value-of select="normalize-space($event-time - $event-timezone)" /></xsl:with-param>
								</xsl:call-template>
							</xsl:when>
							<xsl:when test="string-length(substring-after(substring-after(translate($time-string, ':' ,''),'T'),'+')) &lt; 6">
								<xsl:variable name="event-timezone"><xsl:value-of select="concat(substring-after(substring-after(translate($time-string, ':' ,''),'T'),'+'),'00')"/></xsl:variable>											<xsl:call-template name="build-utc">
									<xsl:with-param name="event-year"><xsl:value-of select="normalize-space($event-year)" /></xsl:with-param>
									<xsl:with-param name="event-month"><xsl:value-of select="normalize-space($event-month)" /></xsl:with-param>
									<xsl:with-param name="event-day"><xsl:value-of select="normalize-space($event-day)" /></xsl:with-param>
									<xsl:with-param name="utc-event-time"><xsl:value-of select="normalize-space($event-time - $event-timezone)" /></xsl:with-param>
								</xsl:call-template>
							</xsl:when>
							<xsl:otherwise>
								<xsl:variable name="event-timezone"><xsl:value-of select="substring-after(substring-after(translate($time-string, ':' ,''),'T'),'+')"/></xsl:variable>
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
						<xsl:variable name="event-time"><xsl:value-of select="substring-before(substring-after(translate($time-string, ':' ,''),'T'),'+')"/></xsl:variable>
						<xsl:choose>
							<xsl:when test="string-length(substring-after(substring-after(translate($time-string, ':' ,''),'T'),'+')) &lt; 4">
								<xsl:variable name="event-timezone"><xsl:value-of select="concat(substring-after(substring-after(translate($time-string, ':' ,''),'T'),'+'),'0000')"/></xsl:variable>
								<xsl:call-template name="build-utc">
									<xsl:with-param name="event-year"><xsl:value-of select="normalize-space($event-year)" /></xsl:with-param>
									<xsl:with-param name="event-month"><xsl:value-of select="normalize-space($event-month)" /></xsl:with-param>
									<xsl:with-param name="event-day"><xsl:value-of select="normalize-space($event-day)" /></xsl:with-param>
									<xsl:with-param name="utc-event-time"><xsl:value-of select="normalize-space($event-time - $event-timezone)" /></xsl:with-param>
								</xsl:call-template>
							</xsl:when>
							<xsl:when test="string-length(substring-after(substring-after(translate($time-string, ':' ,''),'T'),'+')) &lt; 6">
								<xsl:variable name="event-timezone"><xsl:value-of select="concat(substring-after(substring-after(translate($time-string, ':' ,''),'T'),'+'),'00')"/></xsl:variable>
								<xsl:call-template name="build-utc">
									<xsl:with-param name="event-year"><xsl:value-of select="normalize-space($event-year)" /></xsl:with-param>
									<xsl:with-param name="event-month"><xsl:value-of select="normalize-space($event-month)" /></xsl:with-param>
									<xsl:with-param name="event-day"><xsl:value-of select="normalize-space($event-day)" /></xsl:with-param>
									<xsl:with-param name="utc-event-time"><xsl:value-of select="normalize-space($event-time - $event-timezone)" /></xsl:with-param>
								</xsl:call-template>
							</xsl:when>
	
							<xsl:otherwise>
								<xsl:variable name="event-timezone"><xsl:value-of select="substring-after(substring-after(translate($time-string, ':' ,''),'T'),'+')"/></xsl:variable>
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
			</xsl:when>
			<xsl:when test="substring-before(substring-after(translate($time-string, ':' ,''),'T'),'-') = true()">
				<xsl:choose>
					<xsl:when test="string-length(substring-before(substring-after(translate($time-string, ':' ,''),'T'),'-')) &lt; 6">
						<xsl:variable name="event-time"><xsl:value-of select="concat(substring-before(substring-after(translate($time-string, ':' ,''),'T'),'-'),'00')"/></xsl:variable>
						<xsl:choose>
							<xsl:when test="string-length(substring-after(substring-after(translate($time-string, ':' ,''),'T'),'-')) &lt; 4">
								<xsl:variable name="event-timezone"><xsl:value-of select="concat(substring-after(substring-after(translate($time-string, ':' ,''),'T'),'-'),'0000')"/></xsl:variable>
								<xsl:call-template name="build-utc">
									<xsl:with-param name="event-year"><xsl:value-of select="normalize-space($event-year)" /></xsl:with-param>
									<xsl:with-param name="event-month"><xsl:value-of select="normalize-space($event-month)" /></xsl:with-param>
									<xsl:with-param name="event-day"><xsl:value-of select="normalize-space($event-day)" /></xsl:with-param>
									<xsl:with-param name="utc-event-time"><xsl:value-of select="normalize-space($event-time + $event-timezone)" /></xsl:with-param>
								</xsl:call-template>
							</xsl:when>
						
							<xsl:when test="string-length(substring-after(substring-after(translate($time-string, ':' ,''),'T'),'-')) &lt; 6">
								<xsl:variable name="event-timezone"><xsl:value-of select="concat(substring-after(substring-after(translate($time-string, ':' ,''),'T'),'-'),'00')"/></xsl:variable>
								<xsl:call-template name="build-utc">
									<xsl:with-param name="event-year"><xsl:value-of select="normalize-space($event-year)" /></xsl:with-param>
									<xsl:with-param name="event-month"><xsl:value-of select="normalize-space($event-month)" /></xsl:with-param>
									<xsl:with-param name="event-day"><xsl:value-of select="normalize-space($event-day)" /></xsl:with-param>
									<xsl:with-param name="utc-event-time"><xsl:value-of select="normalize-space($event-time + $event-timezone)" /></xsl:with-param>
								</xsl:call-template>
							</xsl:when>
							<xsl:otherwise>
								<xsl:variable name="event-timezone"><xsl:value-of select="substring-after(substring-after(translate($time-string, ':' ,''),'T'),'-')"/></xsl:variable>
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
						<xsl:variable name="event-time"><xsl:value-of select="substring-before(substring-after(translate($time-string, ':' ,''),'T'),'-')"/></xsl:variable>
						<xsl:choose>
							<xsl:when test="string-length(substring-after(substring-after(translate($time-string, ':' ,''),'T'),'-')) &lt; 4">
								<xsl:variable name="event-timezone"><xsl:value-of select="concat(substring-after(substring-after(translate($time-string, ':' ,''),'T'),'-'),'0000')"/></xsl:variable>
								<xsl:call-template name="build-utc">
									<xsl:with-param name="event-year"><xsl:value-of select="normalize-space($event-year)" /></xsl:with-param>
									<xsl:with-param name="event-month"><xsl:value-of select="normalize-space($event-month)" /></xsl:with-param>
									<xsl:with-param name="event-day"><xsl:value-of select="normalize-space($event-day)" /></xsl:with-param>
									<xsl:with-param name="utc-event-time"><xsl:value-of select="normalize-space($event-time + $event-timezone)" /></xsl:with-param>
								</xsl:call-template>
							</xsl:when>
						
							<xsl:when test="string-length(substring-after(substring-after(translate($time-string, ':' ,''),'T'),'-')) &lt; 6">
								<xsl:variable name="event-timezone"><xsl:value-of select="concat(substring-after(substring-after(translate($time-string, ':' ,''),'T'),'-'),'00')"/></xsl:variable>
								<xsl:call-template name="build-utc">
									<xsl:with-param name="event-year"><xsl:value-of select="normalize-space($event-year)" /></xsl:with-param>
									<xsl:with-param name="event-month"><xsl:value-of select="normalize-space($event-month)" /></xsl:with-param>
									<xsl:with-param name="event-day"><xsl:value-of select="normalize-space($event-day)" /></xsl:with-param>
									<xsl:with-param name="utc-event-time"><xsl:value-of select="normalize-space($event-time + $event-timezone)" /></xsl:with-param>
								</xsl:call-template>
							</xsl:when>
							<xsl:otherwise>
								<xsl:variable name="event-timezone"><xsl:value-of select="substring-after(substring-after(translate($time-string, ':' ,''),'T'),'-')"/></xsl:variable>
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
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="normalize-space($event-year)"/>
				<xsl:value-of select="normalize-space($event-month)"/>
				<xsl:value-of select="normalize-space($event-day)"/>
				<xsl:text>T</xsl:text>
				<xsl:if test="string-length(normalize-space(substring-after(translate($time-string, ':' ,''),'T'))) &lt; 6">
					<xsl:text>0</xsl:text>
				</xsl:if>
				<xsl:if test="string-length(normalize-space(substring-after(translate($time-string, ':' ,''),'T'))) &lt; 5">
					<xsl:text>0</xsl:text>
				</xsl:if>
				<xsl:if test="string-length(normalize-space(substring-after(translate($time-string, ':' ,''),'T'))) &lt; 4">
					<xsl:text>0</xsl:text>
				</xsl:if>
				<xsl:if test="string-length(normalize-space(substring-after(translate($time-string, ':' ,''),'T'))) &lt; 3">
					<xsl:text>0</xsl:text>
				</xsl:if>
				<xsl:if test="string-length(normalize-space(substring-after(translate($time-string, ':' ,''),'T'))) &lt; 2">
					<xsl:text>0</xsl:text>
				</xsl:if>
				<xsl:value-of select="normalize-space(substring-after(translate($time-string, ':' ,''),'T'))"/>
			</xsl:otherwise>
		</xsl:choose>
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
	<xsl:when test="$utc-event-time &gt; 235959">
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
			<xsl:when test="(($event-day = 2) or ($event-day = 3) or ($event-day = 4) or ($event-day = 5) or ($event-day = 6) or ($event-day = 7) or ($event-day = 8))">
				<xsl:text>0</xsl:text><xsl:value-of select="$event-day + 1"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$event-day + 1"/>			
			</xsl:otherwise>
		</xsl:choose>

		<xsl:text>T</xsl:text>
				<xsl:if test="string-length($utc-event-time mod 240000) &lt; 6">
					<xsl:text>0</xsl:text>
				</xsl:if>
				<xsl:if test="string-length($utc-event-time mod 240000) &lt; 5">
					<xsl:text>0</xsl:text>
				</xsl:if>
				<xsl:if test="string-length($utc-event-time mod 240000) &lt; 4">
					<xsl:text>0</xsl:text>
				</xsl:if>
				<xsl:if test="string-length($utc-event-time mod 240000) &lt; 3">
					<xsl:text>0</xsl:text>
				</xsl:if>
				<xsl:if test="string-length($utc-event-time mod 240000) &lt; 2">
					<xsl:text>0</xsl:text>
				</xsl:if>
				<!--
				<xsl:if test="string-length($utc-event-time mod 240000) = 1">
					<xsl:text>0</xsl:text>
				</xsl:if>
				-->
<!--
		<xsl:if test="string-length($utc-event-time mod 240000) &lt; 6">
		<xsl:text>0</xsl:text>
		</xsl:if>
-->
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
				<xsl:if test="string-length($utc-event-time) &lt; 5">
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

<!-- recursive function to escape text -->
<xsl:template name="escapeText">
	<xsl:param name="text-string"></xsl:param>
	<xsl:variable name="nl">&#x0A;</xsl:variable>
	<xsl:choose>
		<xsl:when test="substring($text-string,2) = true()">
			<xsl:choose>
				<xsl:when test="substring($text-string,1,1) = '\'">
					<xsl:text>\\</xsl:text>
					<xsl:call-template name="escapeText">
						<xsl:with-param name="text-string"><xsl:value-of select="substring($text-string,2)"/></xsl:with-param>
					</xsl:call-template>
				</xsl:when>
				<xsl:when test="substring($text-string,1,1) = ','">
					<xsl:text>\,</xsl:text>
					<xsl:call-template name="escapeText">
						<xsl:with-param name="text-string"><xsl:value-of select="substring($text-string,2)"/></xsl:with-param>
					</xsl:call-template>
				</xsl:when>
				<xsl:when test="substring($text-string,1,1) = ';'">
					<xsl:text>\;</xsl:text>
					<xsl:call-template name="escapeText">
						<xsl:with-param name="text-string"><xsl:value-of select="substring($text-string,2)"/></xsl:with-param>
					</xsl:call-template>
				</xsl:when>
				<!-- New Line -->
				<!--
				<xsl:when test="substring($text-string,1,1) = $nl">
					<xsl:text>\n</xsl:text>
					<xsl:call-template name="escapeText">
						<xsl:with-param name="text-string"><xsl:value-of select="substring($text-string,2)"/></xsl:with-param>
					</xsl:call-template>
				</xsl:when>
				-->
				<xsl:otherwise>
					<xsl:value-of select="substring($text-string,1,1)"/>
					<xsl:call-template name="escapeText">
						<xsl:with-param name="text-string"><xsl:value-of select="substring($text-string,2)"/></xsl:with-param>
					</xsl:call-template>
				</xsl:otherwise>				
			</xsl:choose>
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="$text-string"/>			
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<!-- Get the language for an property -->
<xsl:template name="lang">
	<xsl:variable name="langElt" select='ancestor-or-self::*[@xml:lang or @lang]' />
	<xsl:if test="$langElt">
		<xsl:variable name="lang">
			<xsl:choose>
				<xsl:when test="$langElt[last()]/@xml:lang">
					<xsl:value-of select="normalize-space($langElt[last()]/@xml:lang)" />
				</xsl:when>
				<xsl:when test="$langElt[last()]/@lang">
					<xsl:value-of select="normalize-space($langElt[last()]/@lang)" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:message>where id lang and xml:lang go?!?!?</xsl:message>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:text>;LANGUAGE=</xsl:text>
		<xsl:value-of select="$lang" />
	</xsl:if>
</xsl:template>

<!-- recursive function to extract headers="id id id" -->
<xsl:template name="extract-ids">
<xsl:param name="text-string"/>
<xsl:choose>
	<xsl:when test="substring-before($text-string,' ') = true()">
		<xsl:call-template name="get-header">
			<xsl:with-param name="header-id"><xsl:value-of select="substring-before($text-string,' ')"/></xsl:with-param>
		</xsl:call-template>
		<xsl:call-template name="extract-ids">
			<xsl:with-param name="text-string"><xsl:value-of select="substring-after($text-string,' ')"/></xsl:with-param>
		</xsl:call-template>
	</xsl:when>
	<xsl:otherwise>
		<xsl:call-template name="get-header">
			<xsl:with-param name="header-id"><xsl:value-of select="$text-string"/></xsl:with-param>
		</xsl:call-template>
	</xsl:otherwise>
</xsl:choose>
</xsl:template>

<xsl:template name="get-header">
	<!-- problem here! need to pass the tag WITH the id, not decendants -->
	<xsl:param name="header-id"/>
	<xsl:for-each select="//*[@id=$header-id]">
		<xsl:call-template name="Properties">
	<!--		<xsl:with-param name="Anchor"><xsl:value-of select="$header-id"/></xsl:with-param> -->
		</xsl:call-template>
	</xsl:for-each>
</xsl:template>

<!-- recursive function to give plain text some equivalent HTML formatting -->
<xsl:template match="*" mode="unFormatText">
	<xsl:for-each select="node()">
		<xsl:choose>

			<xsl:when test="name() = 'p'">
				<xsl:apply-templates select="." mode="unFormatText"/>
				<xsl:text>\n\n</xsl:text>
			</xsl:when>
			<xsl:when test="name() = 'del'"></xsl:when>
			
			<xsl:when test="name() = 'div'">
				<xsl:apply-templates select="." mode="unFormatText"/>
				<xsl:text>\n</xsl:text>
			</xsl:when>
			<xsl:when test="name() = 'dl' or name() = 'dt' or name() = 'dd'">
				<xsl:apply-templates select="." mode="unFormatText"/>
				<xsl:text>\n</xsl:text>
			</xsl:when>
			<xsl:when test="name() = 'q'">
				<xsl:text>“</xsl:text>
				<xsl:apply-templates select="." mode="unFormatText"/>
				<xsl:text>”</xsl:text>
				<xsl:text>\n</xsl:text>
			</xsl:when>
			<xsl:when test="name() = 'sup'">
				<xsl:text>[</xsl:text>
				<xsl:apply-templates select="." mode="unFormatText"/>
				<xsl:text>]</xsl:text>
			</xsl:when>
			<xsl:when test="name() = 'sub'">
				<xsl:text>(</xsl:text>
				<xsl:apply-templates select="." mode="unFormatText"/>
				<xsl:text>)</xsl:text>
			</xsl:when>
			<xsl:when test="name() = 'ul' or name() = 'ol'">
				<xsl:apply-templates select="." mode="unFormatText"/>
				<xsl:text>\n</xsl:text>
			</xsl:when>
			<xsl:when test="name() = 'li'">
				<xsl:choose>
					<xsl:when test="name(..) = 'ol'">
						<xsl:number format="1. " />
						<xsl:apply-templates select="." mode="unFormatText"/>
						<xsl:text>\n</xsl:text>
					</xsl:when> 
					<xsl:otherwise> 
						<xsl:text>* </xsl:text>
						<xsl:apply-templates select="." mode="unFormatText"/>
						<xsl:text>\n</xsl:text>
					</xsl:otherwise> 
				</xsl:choose>
			</xsl:when>
			<xsl:when test="name() = 'pre'">
				<xsl:call-template name="escapeText">
					<xsl:with-param name="text-string">
						<xsl:value-of select="."/>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="name() = 'br'">
				<xsl:text>\n</xsl:text>
			</xsl:when>
			<xsl:when test="name() = 'h1' or name() = 'h2' or name() = 'h3' or name() = 'h4' or name() = 'h5' or name() = 'h6'">
				<xsl:apply-templates select="." mode="unFormatText"/>				
				<xsl:text>\n</xsl:text>
			</xsl:when>
			<xsl:when test="descendant::*">
				<xsl:apply-templates select="." mode="unFormatText"/>
			</xsl:when>
			<xsl:when test="text()">
				<xsl:call-template name="normalize-spacing">
					<xsl:with-param name="text-string">
						<xsl:call-template name="escapeText">
							<xsl:with-param name="text-string">
								<xsl:value-of select="."/>
							</xsl:with-param>
						</xsl:call-template>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>				
				<xsl:choose>
					<!--
					<xsl:when test="normalize-space(.) = '' and not(contains(.,' '))"><xsl:text>^</xsl:text></xsl:when>-->
					<xsl:when test="contains(.,' ') and normalize-space(.) = ''">
						
						<xsl:text> </xsl:text>
					</xsl:when>
					<xsl:when test="substring(.,1,1) = $tb or substring(.,1,1) = ' '">
						<xsl:text> </xsl:text>
						<xsl:choose>
							<xsl:when test="substring(.,string-length(.),1) = $tb or substring(.,string-length(.),1) = ' '">
								<xsl:value-of select="normalize-space(.)"/>
								<xsl:text> </xsl:text>	
							</xsl:when>	
							<xsl:otherwise>
								<xsl:value-of select="normalize-space(.)"/>
							</xsl:otherwise>						
						</xsl:choose>
					</xsl:when>
					<xsl:when test="substring(.,string-length(.),1) = $tb or substring(.,string-length(.),1) = ' '">
						<xsl:value-of select="normalize-space(.)"/>
						<xsl:text> </xsl:text>
					</xsl:when>
					<xsl:otherwise>
						
						<!--
						<xsl:call-template name="normalize-spacing">
							<xsl:with-param name="text-string">
						-->
								<xsl:call-template name="escapeText">
									<xsl:with-param name="text-string">
										<xsl:value-of select="translate(translate(.,$tb,' '),$nl,' ')"/>
									</xsl:with-param>
								</xsl:call-template>
						<!--
							</xsl:with-param>
						</xsl:call-template>
					-->
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:for-each>

</xsl:template>

<!-- recursive function to normalize-spacing in text -->
<xsl:template name="normalize-spacing">
	<xsl:param name="text-string"></xsl:param>
	<xsl:param name="colapse-spacing">1</xsl:param>
	<xsl:choose>
		<xsl:when test="substring($text-string,2) = true()">
			<xsl:choose>
				<xsl:when test="$colapse-spacing = '1'">
					<xsl:choose>
						<xsl:when test="substring($text-string,1,1) = ' ' or substring($text-string,1,1) = '$tb' or substring($text-string,1,1) = '$cr' or substring($text-string,1,1) = '$nl'">
							<xsl:text> </xsl:text>
							<xsl:call-template name="normalize-spacing">
								<xsl:with-param name="text-string"><xsl:value-of select="substring($text-string,2)"/></xsl:with-param>
								<xsl:with-param name="colapse-spacing">1</xsl:with-param>
							</xsl:call-template>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="normalize-space(substring($text-string,1,1))"/>
							<xsl:call-template name="normalize-spacing">
								<xsl:with-param name="text-string"><xsl:value-of select="substring($text-string,2)"/></xsl:with-param>
								<xsl:with-param name="colapse-spacing">0</xsl:with-param>
							</xsl:call-template>							
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>
					<xsl:choose>
						<xsl:when test="substring($text-string,1,1) = ' ' or substring($text-string,1,1) = '$tb' or substring($text-string,1,1) = '$cr' or substring($text-string,1,1) = '$nl'">
							<xsl:text> </xsl:text>
							<xsl:call-template name="normalize-spacing">
								<xsl:with-param name="text-string"><xsl:value-of select="substring($text-string,2)"/></xsl:with-param>
								<xsl:with-param name="colapse-spacing">1</xsl:with-param>
							</xsl:call-template>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="normalize-space(substring($text-string,1,1))"/>
							<xsl:call-template name="normalize-spacing">
								<xsl:with-param name="text-string"><xsl:value-of select="substring($text-string,2)"/></xsl:with-param>
								<xsl:with-param name="colapse-spacing">0</xsl:with-param>
							</xsl:call-template>							
						</xsl:otherwise>
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:when>		
			
		<xsl:otherwise>
			<xsl:choose>
				<xsl:when test="$colapse-spacing = '1'">
					<xsl:value-of select="normalize-space($text-string)"/>			
				</xsl:when>
				<xsl:when test="substring($text-string,1,1) = ' '">
					<xsl:text> </xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="normalize-space($text-string)"/>			
				</xsl:otherwise>
			</xsl:choose>
		</xsl:otherwise>		
	</xsl:choose>

</xsl:template>

<!-- don't pass text thru -->
<xsl:template match="text()"></xsl:template>
</xsl:stylesheet>
