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
Version 0.6
2005-09-08

Copyright 2005 Brian Suda
This work is licensed under the Creative Commons Attribution-ShareAlike License. 
To view a copy of this license, visit 
http://creativecommons.org/licenses/by-sa/1.0/

Major optimization created by Dan Connolly [http://www.w3.org/People/Connolly/] have been rolled into this file.
http://dev.w3.org/cvsweb/2001/palmagent/xhtml2vcard.xsl

NOTES:
Until the hCard spec has been finalised this is a work in progress.
I'm not an XSLT expert, so there are no guarantees to quality of this code!

@@ check for profile in head element
@@ decode only the first instance of a singular property
-->



<xsl:param name="Prodid" select='"-//suda.co.uk//X2V 0.6.18 (BETA)//EN"' />
<xsl:param name="Source" >(Best Practices states this should be the URL the calendar was transformed from)</xsl:param>
<xsl:param name="Anchor" />

<!-- check for profile in head element -->
<xsl:template match="head[contains(concat(' ',normalize-space(@profile),' '),' http://foorbar ')]">
<!-- 
==================== CURRENTLY DISABLED ====================
This will call the vCard template, 
Without the correct profile you cannot assume the class values are intended for the vCard microformat.
-->
<!-- <xsl:call-template name="vcard"/> -->
</xsl:template>

<!-- Each vCard is listed in succession -->
<xsl:template match="*[contains(concat(' ',normalize-space(@class),' '),' vcard ')]">
<!--
	<xsl:param name="vcard-lang">
		<xsl:choose>
			<xsl:when test="@xml:lang != ''"><xsl:value-of select="@xml:lang" /></xsl:when>
			<xsl:when test="@lang != ''"><xsl:value-of select="@lang" /></xsl:when>
		</xsl:choose>
	</xsl:param>
-->	
	<xsl:if test="not($Anchor) or @id = $Anchor">
		<xsl:text>BEGIN:VCARD</xsl:text>
		<xsl:text>&#x0A;PRODID:</xsl:text><xsl:value-of select="$Prodid"/>
		<xsl:text>&#x0A;SOURCE:</xsl:text><xsl:value-of select="$Source"/>
		<xsl:text>&#x0A;NAME: </xsl:text>
		<xsl:call-template name="escapeText">
			<xsl:with-param name="text-string"><xsl:value-of select="normalize-space(//*[name() = 'title'])" /></xsl:with-param>
		</xsl:call-template>
		<xsl:text>&#x0A;VERSION:3.0</xsl:text>

		<!-- @@UID has been removed because this is only locally unique to the page, not globally unique -->
		<!--
		<xsl:text>&#x0A;UID:</xsl:text>
		<xsl:call-template name="escapeText">
			<xsl:with-param name="text-string"><xsl:value-of select="normalize-space(@id)" /></xsl:with-param>
		</xsl:call-template>
		-->
		
		<!--  Implied "N" Optimization -->
		<xsl:variable name="n-elt" select=".//*[contains(concat(' ', normalize-space(@class), ' '),' n ')]" />
		<xsl:choose>
			<xsl:when test="$n-elt">
				<xsl:call-template name="n-prop" />
			</xsl:when>
			<xsl:when test="not($n-elt)">
				<xsl:call-template name="implied-n" />		
			</xsl:when>
		</xsl:choose>

		<xsl:call-template name="textPropLang">
			<xsl:with-param name="label">FN</xsl:with-param>
			<xsl:with-param name="class">fn</xsl:with-param>
		</xsl:call-template>
		<xsl:call-template name="emailProp">
			<xsl:with-param name="label">EMAIL</xsl:with-param>
			<xsl:with-param name="class">email</xsl:with-param>
		</xsl:call-template>
		
		<xsl:call-template name="textPropLang">
			<xsl:with-param name="label">MAILER</xsl:with-param>
			<xsl:with-param name="class">mailer</xsl:with-param>
		</xsl:call-template>

		<xsl:call-template name="textPropLang">
			<xsl:with-param name="label">TITLE</xsl:with-param>
			<xsl:with-param name="class">title</xsl:with-param>
		</xsl:call-template>

		<xsl:call-template name="textPropLang">
			<xsl:with-param name="label">ROLE</xsl:with-param>
			<xsl:with-param name="class">role</xsl:with-param>
		</xsl:call-template>

		<xsl:call-template name="textPropLang">
			<xsl:with-param name="label">SORT-STRING</xsl:with-param>
			<xsl:with-param name="class">sort-string</xsl:with-param>
		</xsl:call-template>

		<xsl:call-template name="textPropLang">
			<xsl:with-param name="label">NOTE</xsl:with-param>
			<xsl:with-param name="class">note</xsl:with-param>
		</xsl:call-template>

		<xsl:call-template name="textPropLang">
			<xsl:with-param name="label">CATEGORIES</xsl:with-param>
			<xsl:with-param name="class">categories</xsl:with-param>
		</xsl:call-template>
		
		<xsl:call-template name="textPropLang">
			<xsl:with-param name="label">NICKNAME</xsl:with-param>
			<xsl:with-param name="class">nickname</xsl:with-param>
		</xsl:call-template>

		<xsl:call-template name="textProp">
			<xsl:with-param name="label">REV</xsl:with-param>
			<xsl:with-param name="class">rev</xsl:with-param>
		</xsl:call-template>
		
		<xsl:call-template name="textProp">
			<xsl:with-param name="label">CLASS</xsl:with-param>
			<xsl:with-param name="class">class</xsl:with-param>
		</xsl:call-template>

		<xsl:call-template name="textProp">
			<xsl:with-param name="label">TZ</xsl:with-param>
      		<xsl:with-param name="class">tz</xsl:with-param>
		</xsl:call-template>
		<!-- @@TYPE=PGP, TYPE=X509, ENCODING=b -->
		<xsl:variable name="key-elt" select=".//*[contains(concat(' ', normalize-space(@class), ' '),' key ')]" />
		<xsl:if test="$key-elt">
				<xsl:call-template name="key-prop"/>
		</xsl:if>

		<!-- LABEL needs work! -->
		<xsl:variable name="label-elt" select=".//*[contains(concat(' ', normalize-space(@class), ' '),' label ')]" />
		<xsl:if test="$label-elt">
				<xsl:call-template name="label-prop"/>
		</xsl:if>

		<xsl:variable name="org-elt" select=".//*[contains(concat(' ', normalize-space(@class), ' '),' org ')]" />
		<xsl:if test="$org-elt">
				<xsl:call-template name="org-prop"/>
		</xsl:if>
		
		<xsl:for-each select=".//*[contains(concat(' ', normalize-space(@class), ' '),' adr ')]">
			<xsl:call-template name="adr-prop" />
		</xsl:for-each>
    
		<xsl:for-each select=".//*[contains(concat(' ', normalize-space(@class), ' '),' tel ')]">
			<xsl:call-template name="tel-prop" />
		</xsl:for-each>

		<!-- Templates that still need work -->
		<!-- due mostly to absolute URLs or BASE64 encoding or UTC datetime conversion -->

<!--
		<xsl:call-template name="textProp">
			<xsl:with-param name="label">GEO</xsl:with-param>
			<xsl:with-param name="class">geo</xsl:with-param>
		</xsl:call-template>
-->
		<!-- <xsl:apply-templates select=".//*[contains(concat(' ',normalize-space(@class),' '),' agent ')]" mode="agent"/> 	-->

		<xsl:apply-templates select=".//*[contains(concat(' ',normalize-space(@class),' '),' url ')]" mode="url"/>

		<xsl:apply-templates select=".//*[contains(concat(' ',normalize-space(@class),' '),' bday ')]" mode="bday"/>


		<xsl:call-template name="blobProp">
			<xsl:with-param name="label">PHOTO</xsl:with-param>
			<xsl:with-param name="class">photo</xsl:with-param>
		</xsl:call-template>

		<xsl:call-template name="blobProp">
			<xsl:with-param name="label">LOGO</xsl:with-param>
			<xsl:with-param name="class">logo</xsl:with-param>
		</xsl:call-template>

		<xsl:call-template name="blobProp">
			<xsl:with-param name="label">SOUND</xsl:with-param>
			<xsl:with-param name="class">sound</xsl:with-param>
		</xsl:call-template>
		<xsl:text>&#x0A;END:VCARD&#x0A;</xsl:text>
	</xsl:if>
</xsl:template>

<!-- ============== working templates ================= -->

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
		<xsl:choose>
			<xsl:when test="substring-before(@src,':') = 'http'">
				<xsl:value-of select="normalize-space(@src)" />
			</xsl:when>
			<xsl:otherwise>
				<!-- convert to absolute url -->
				<xsl:call-template name="make-absolute">
					<xsl:with-param name="relative-string">
						<xsl:value-of select="normalize-space(@src)" />
					</xsl:with-param>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:when>
<!--	
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
-->
	<xsl:otherwise>
		<xsl:call-template name="escapeText">
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





<!-- function to convert relative urls to absolute urls -->
<xsl:template name="make-absolute">
<xsl:param name="relative-string"></xsl:param>

<xsl:choose>
	<xsl:when test="substring($relative-string,1,1) = '/'">
		<xsl:value-of select="substring-before($Source,'/')"/>
		<xsl:text>//</xsl:text>
		<xsl:value-of select="substring-before(substring-after(substring-after($Source,'/'),'/'),'/')"/>
		<xsl:value-of select="$relative-string"/>
	</xsl:when>
	<xsl:when test="substring($Source,string-length($Source)) = '/' and substring($relative-string,1,1) != '/'">
		<xsl:value-of select="$Source"/>
		<xsl:value-of select="$relative-string"/>
	</xsl:when>
	<xsl:when test="substring($Source,string-length($Source)) != '/' and substring($relative-string,1,1) != '/'">
		<xsl:value-of select="substring-before($Source,'/')"/>
		<xsl:text>//</xsl:text>
		<xsl:call-template name="remove-filename">
			<xsl:with-param name="base-url">
				<xsl:value-of select="substring-after(substring-after($Source,'/'),'/')"/>
			</xsl:with-param>
		</xsl:call-template>
		
		<xsl:value-of select="$relative-string"/>
	</xsl:when>

	<xsl:otherwise>
		<xsl:value-of select="$Source"/>
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






<!-- TEXT PROPERTY without LANGUAGE -->
<xsl:template name="textProp">
	<xsl:param name="label" />
	<xsl:param name="class" />
	<xsl:for-each select=".//*[contains(concat(' ', @class, ' '),concat(' ', $class, ' '))]">
    <!-- @@ "the first descendant element with that class should take
         effect, any others being ignored." -->
        <xsl:text>&#x0A;</xsl:text>
		<xsl:value-of select="$label" />
        <xsl:text>:</xsl:text>
		<xsl:choose>
			<xsl:when test='local-name(.) = "ol" or local-name(.) = "ul"'>
				<xsl:for-each select="*">
					<xsl:if test="not(position()=1)">
						<xsl:text>,</xsl:text>
					</xsl:if>
					<xsl:choose>
						<xsl:when test=".//*[contains(concat(' ', normalize-space(@class), ' '),' value ')]">
							<xsl:call-template name="escapeText">
								<xsl:with-param name="text-string" select="normalize-space(.//*[contains(concat(' ', normalize-space(@class), ' '),' value ')])" />
							</xsl:call-template>
						</xsl:when>
						<xsl:otherwise>
							<xsl:call-template name="escapeText">
								<xsl:with-param name="text-string" select="." />
							</xsl:call-template>
						</xsl:otherwise>
					</xsl:choose>		
				</xsl:for-each>
			</xsl:when>
			<xsl:when test='local-name(.) = "abbr" and @title'>
				<xsl:call-template name="escapeText">
					<xsl:with-param name="text-string" select="normalize-space(@title)" />
				</xsl:call-template>
			</xsl:when>			
			<xsl:when test='@alt and local-name(.) = "img"'>
				<xsl:call-template name="escapeText">
					<xsl:with-param name="text-string" select="normalize-space(@alt)" />
				</xsl:call-template>
			</xsl:when>
<!--			
			<xsl:when test='@title'>
				<xsl:call-template name="escapeText">
					<xsl:with-param name="text-string" select="normalize-space(@title)" />
				</xsl:call-template>
			</xsl:when>
-->
			<xsl:when test=".//*[contains(concat(' ', normalize-space(@class), ' '),' value ')]">
				<xsl:for-each select=".//*[contains(concat(' ', normalize-space(@class), ' '),' value ')]">
					<xsl:call-template name="escapeText">
						<xsl:with-param name="text-string" select="normalize-space(.)" />
					</xsl:call-template>
				</xsl:for-each>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="escapeText">
					<xsl:with-param name="text-string" select="normalize-space(.)" />
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:for-each>
</xsl:template>

<!-- blob Property -->
<xsl:template name="blobProp">
	<xsl:param name="label" />
	<xsl:param name="class" />

	<xsl:for-each select=".//*[contains(concat(' ', @class, ' '),concat(' ', $class, ' '))]">
		<xsl:text>&#x0A;</xsl:text>
		<xsl:value-of select="$label" />
	
		<!-- Need to convert these to Absolute URLs -->
		<xsl:choose>
			<xsl:when test="substring-before(@src,':') = 'data'">
					<xsl:text>;ENCODING=b;TYPE=</xsl:text><xsl:value-of select="substring-after(substring-after(substring-before(@src,';'),':'),'/')"/><xsl:text>:</xsl:text><xsl:value-of select="substring-after(@src,',')"/>
			</xsl:when>
			<xsl:when test="@src">
				<xsl:choose>
					<xsl:when test="@src">
						<xsl:text>;VALUE=uri:</xsl:text>
						<xsl:choose>
							<xsl:when test="substring-before(@src,':') = 'http'">
								<xsl:value-of select="normalize-space(@src)" />
							</xsl:when>
							<xsl:otherwise>
								<!-- convert to absolute url -->
								<xsl:call-template name="make-absolute">
									<xsl:with-param name="relative-string">
										<xsl:value-of select="normalize-space(@src)" />
									</xsl:with-param>
								</xsl:call-template>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:when test="@href">
						<xsl:text>;VALUE=uri:</xsl:text>
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
					<xsl:when test="@data">
						<xsl:text>;VALUE=uri:</xsl:text>
						<xsl:call-template name="escapeText">
							<xsl:with-param name="text-string" select="@data" />
						</xsl:call-template>
					</xsl:when>
					<xsl:when test=".//*[contains(concat(' ', normalize-space(@class), ' '),' value ')]">
						<xsl:text>:</xsl:text>
						<xsl:call-template name="escapeText">
							<xsl:with-param name="text-string" select=".//*[contains(concat(' ', normalize-space(@class), ' '),' value ')]" />
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>:</xsl:text>
						<xsl:call-template name="escapeText">
							<xsl:with-param name="text-string" select="." />
						</xsl:call-template>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>:</xsl:text>
				<xsl:value-of select="normalize-space(.)"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:for-each>
</xsl:template>

<!-- KEY Property -->
<xsl:template name="key-prop">
	<xsl:for-each select=".//*[contains(concat(' ', @class, ' '),concat(' ', key, ' '))]">
    <!-- @@ "the first descendant element with that class should take
         effect, any others being ignored." -->
        <xsl:text>&#x0A;KEY:</xsl:text>
		<xsl:variable name="types">
			<xsl:call-template name="find-types">
				<xsl:with-param name="list">pgp x509</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>
		<xsl:if test="normalize-space($types)">
			<xsl:text>;TYPE=</xsl:text>
			<xsl:value-of select="$types"/>
		</xsl:if>
		<xsl:text>;ENCODING=b:</xsl:text>
		<xsl:choose>
			<xsl:when test=".//*[contains(concat(' ', normalize-space(@class), ' '),' value ')]">
				<xsl:call-template name="escapeText">
					<xsl:with-param name="text-string" select="normalize-space(.//*[contains(concat(' ', normalize-space(@class), ' '),' value ')])" />
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="escapeText">
					<xsl:with-param name="text-string" select="normalize-space(.)" />
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:for-each>
</xsl:template>

<!-- LABEL Property -->
<xsl:template name="label-prop">
	<xsl:for-each select=".//*[contains(concat(' ', @class, ' '),concat(' ', label, ' '))]">
    <!-- @@ "the first descendant element with that class should take
         effect, any others being ignored." -->
        <xsl:text>&#x0A;LABEL:</xsl:text>
		<xsl:variable name="types">
			<xsl:call-template name="find-types">
				<xsl:with-param name="list">dom intl postal parcel home work pref</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>
		<xsl:if test="normalize-space($types)">
			<xsl:text>;TYPE=</xsl:text>
			<xsl:value-of select="$types"/>
		</xsl:if>
		<xsl:choose>
			<xsl:when test=".//*[contains(concat(' ', normalize-space(@class), ' '),' value ')]">
				<xsl:call-template name="escapeText">
					<xsl:with-param name="text-string" select="normalize-space(.//*[contains(concat(' ', normalize-space(@class), ' '),' value ')])" />
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="escapeText">
					<xsl:with-param name="text-string" select="normalize-space(.)" />
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:for-each>
</xsl:template>

<!-- ORG Property -->
<xsl:template name="org-prop" >
	<xsl:text>&#x0A;ORG:</xsl:text>
	<xsl:choose>
		<xsl:when test=".//*[contains(concat(' ', @class, ' '), concat(' ', 'organization-name', ' '))]" >
			<xsl:call-template name="sub-prop">
				<xsl:with-param name="class" select='"organization-name"' />
			</xsl:call-template>
			<xsl:for-each select=".//*[contains(concat(' ', @class, ' '), concat(' ', 'organization-unit', ' '))]" >
				<xsl:choose>
					<xsl:when test=".//*[contains(concat(' ', normalize-space(@class), ' '),' value ')]">
						<xsl:call-template name="escapeText">
							<xsl:with-param name="text-string" select="normalize-space(.//*[contains(concat(' ', normalize-space(@class), ' '),' value ')])" />
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
						<xsl:call-template name="escapeText">
							<xsl:with-param name="text-string" select="normalize-space(.)" />
						</xsl:call-template>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:text>;</xsl:text>
			</xsl:for-each>
		</xsl:when>
		<xsl:otherwise>
			<xsl:call-template name="escapeText">
				<xsl:with-param name="text-string" select="normalize-space(.//*[contains(concat(' ', @class, ' '), concat(' ', 'org', ' '))])" />
			</xsl:call-template>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template name="adr-prop" >
	<xsl:text>&#x0A;ADR</xsl:text>
	<xsl:call-template name="lang" />
	<xsl:variable name="types">
		<xsl:call-template name="find-types">
			<xsl:with-param name="list">dom intl postal parcel home work pref</xsl:with-param>
		</xsl:call-template>
	</xsl:variable>
	<xsl:if test="normalize-space($types)">
		<xsl:text>;TYPE=</xsl:text>
		<xsl:value-of select="$types"/>
	</xsl:if>
	<xsl:text>:</xsl:text>
	<xsl:call-template name="sub-prop">
		<xsl:with-param name="class" select='"post-office-box"' />
	</xsl:call-template>
	<xsl:call-template name="sub-prop">
		<xsl:with-param name="class" select='"extended-address"' />
	</xsl:call-template>
	<xsl:call-template name="sub-prop">
		<xsl:with-param name="class" select='"street-address"' />
	</xsl:call-template>
	<xsl:call-template name="sub-prop">
		<xsl:with-param name="class" select='"locality"' />
	</xsl:call-template>
	<xsl:call-template name="sub-prop">
		<xsl:with-param name="class" select='"region"' />
	</xsl:call-template>
	<xsl:call-template name="sub-prop">
		<xsl:with-param name="class" select='"postal-code"' />
	</xsl:call-template>
	<xsl:call-template name="sub-prop">
		<xsl:with-param name="class" select='"country-name"' />
	</xsl:call-template>
</xsl:template>

<!-- TEL Property -->
<xsl:template name="tel-prop">
	<xsl:text>&#x0A;TEL</xsl:text>
	<xsl:variable name="types">
		<xsl:call-template name="find-types">
			<xsl:with-param name="list">home work pref voice fax msg cell pager bbs modem car isdn</xsl:with-param>
		</xsl:call-template>
	</xsl:variable>
	<xsl:if test="normalize-space($types)">
		<xsl:text>;TYPE=</xsl:text>
		<xsl:value-of select="$types"/>
	</xsl:if>
	<xsl:text>:</xsl:text>
	<xsl:choose>
		<!-- @@untested? -->
		<xsl:when test='local-name(.) = "abbr" and @title'>
			<xsl:variable name="v" select="normalize-space(@title)" />
			<xsl:call-template name="escapeText">
				<xsl:with-param name="text-string" select="$v" />
			</xsl:call-template>
		</xsl:when>
		<xsl:when test=".//*[contains(concat(' ', normalize-space(@class), ' '),' value ')]">
			<xsl:for-each select=".//*[contains(concat(' ', normalize-space(@class), ' '),' value ')]">
				<xsl:variable name="v" select="normalize-space(.)" />
				<xsl:call-template name="escapeText">
					<xsl:with-param name="text-string" select="$v" />
				</xsl:call-template>
			</xsl:for-each>
		</xsl:when>		
		<xsl:otherwise>
			<xsl:variable name="v" select="normalize-space(.)" />
			<xsl:call-template name="escapeText">
				<xsl:with-param name="text-string" select="$v" />
			</xsl:call-template>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<!-- N Property -->
<xsl:template name="n-prop" >
	<xsl:text>&#x0A;N</xsl:text>
	<xsl:call-template name="lang" />
	<xsl:text>:</xsl:text>
	<xsl:call-template name="sub-prop">
		<xsl:with-param name="class" select='"family-name"' />
	</xsl:call-template>
	<xsl:call-template name="sub-prop">
		<xsl:with-param name="class" select='"given-name"' />
	</xsl:call-template>
	<xsl:call-template name="sub-prop">
		<xsl:with-param name="class" select='"additional-names"' />
	</xsl:call-template>
	<xsl:call-template name="sub-prop">
		<xsl:with-param name="class" select='"honorific-prefixes"' />
	</xsl:call-template>
	<xsl:call-template name="sub-prop">
		<xsl:with-param name="class" select='"honorific-suffixes"' />
	</xsl:call-template>
</xsl:template>

<!-- IMPLIED N from FN -->
<xsl:template name="implied-n">
	<xsl:for-each select=".//*[contains(concat(' ', @class, ' '),concat(' ','fn', ' '))]">
		<xsl:text>&#x0A;N</xsl:text>
		<xsl:call-template name="lang" />
		<xsl:text>:</xsl:text>
		<xsl:variable name="family-name">
			<xsl:value-of select='substring-after(normalize-space(.), " ")' />
		</xsl:variable>
		<xsl:call-template name="escapeText">
			<xsl:with-param name="text-string" select="$family-name" />
		</xsl:call-template>
		<xsl:text>;</xsl:text>
		
		<xsl:choose>
			<xsl:when test='not(substring-before(normalize-space(.), " "))'>
				<xsl:call-template name="escapeText">
					<xsl:with-param name="text-string" select="normalize-space(.)" />
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="escapeText">
					<xsl:with-param name="text-string" select='substring-before(normalize-space(.), " ")' />
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:text>;</xsl:text>
		<xsl:text>;;;</xsl:text>
	</xsl:for-each>
</xsl:template>

<!-- TEXT PROPERTY with LANGUAGE -->
<xsl:template name="textPropLang">
	<xsl:param name="label" />
	<xsl:param name="class" />

	<xsl:for-each select=".//*[contains(concat(' ', @class, ' '),concat(' ', $class, ' '))]">
    <!-- @@ "the first descendant element with that class should take
         effect, any others being ignored." -->
        <xsl:text>&#x0A;</xsl:text>
		<xsl:value-of select="$label" />
    	<xsl:call-template name="lang" />
        <xsl:text>:</xsl:text>
		<xsl:choose>
			<xsl:when test='local-name(.) = "ol" or local-name(.) = "ul"'>
				<xsl:for-each select="*">
					<xsl:if test="not(position()=1)">
						<xsl:text>,</xsl:text>
					</xsl:if>
					<xsl:choose>
						<xsl:when test=".//*[contains(concat(' ', normalize-space(@class), ' '),' value ')]">
							<xsl:call-template name="escapeText">
								<xsl:with-param name="text-string" select="normalize-space(.//*[contains(concat(' ', normalize-space(@class), ' '),' value ')])" />
							</xsl:call-template>
						</xsl:when>
						<xsl:otherwise>
							<xsl:call-template name="escapeText">
								<xsl:with-param name="text-string" select="." />
							</xsl:call-template>
						</xsl:otherwise>
					</xsl:choose>		
				</xsl:for-each>
			</xsl:when>
			<xsl:when test='local-name(.) = "abbr" and @title'>
				<xsl:call-template name="escapeText">
					<xsl:with-param name="text-string" select="normalize-space(@title)" />
				</xsl:call-template>
			</xsl:when>
			<xsl:when test='@alt and local-name(.) = "src"'>
				<xsl:call-template name="escapeText">
					<xsl:with-param name="text-string" select="normalize-space(@alt)" />
				</xsl:call-template>
			</xsl:when>
<!--			
			<xsl:when test='@longdesc'>
				<xsl:call-template name="escapeText">
					<xsl:with-param name="text-string" select="normalize-space(@longdesc)" />
				</xsl:call-template>
			</xsl:when>
			<xsl:when test='@title'>
				<xsl:call-template name="escapeText">
					<xsl:with-param name="text-string" select="normalize-space(@title)" />
				</xsl:call-template>
			</xsl:when>
-->			
			<xsl:when test=".//*[contains(concat(' ', normalize-space(@class), ' '),' value ')]">
				<xsl:call-template name="escapeText">
					<xsl:with-param name="text-string" select="normalize-space(.//*[contains(concat(' ', normalize-space(@class), ' '),' value ')])" />
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="escapeText">
					<xsl:with-param name="text-string" select="normalize-space(.)" />
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:for-each>
</xsl:template>

<!-- EMAIL PROPERTY -->
<xsl:template name="emailProp">
	<xsl:param name="label" />
	<xsl:param name="class" />
	<xsl:for-each select=".//*[contains(concat(' ', @class, ' '),concat(' ', $class, ' '))]">
		<xsl:variable name="addr">
			<xsl:choose>
				<xsl:when test='@href and starts-with(@href, "mailto:")'>
					<xsl:value-of select='substring-after(@href, ":")' />
				</xsl:when>
				<xsl:when test='not(local-name(.) = "a")'>
					<xsl:choose>
						<xsl:when test=".//*[contains(concat(' ', normalize-space(@class), ' '),' value ')]">
							<xsl:value-of select="normalize-space(.//*[contains(concat(' ', normalize-space(@class), ' '),' value ')])" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="." />
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<!-- Need an otherwise default case? -->
			</xsl:choose>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="normalize-space($addr)">
				<xsl:text>&#x0A;</xsl:text>
				<xsl:value-of select="$label" />
				<xsl:variable name="types">
					<xsl:call-template name="find-types">
						<xsl:with-param name="list">internet x400 pref</xsl:with-param>
					</xsl:call-template>
				</xsl:variable>
				<xsl:if test="normalize-space($types)">
					<xsl:text>;TYPE=</xsl:text>
					<xsl:value-of select="$types"/>
				</xsl:if>
				<xsl:text>:</xsl:text>
				<xsl:call-template name="escapeText">
					<xsl:with-param name="text-string" select='$addr' />
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:message>invalid email href: <xsl:value-of select="@href" /></xsl:message>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:for-each>
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

<!-- get the class value -->
<xsl:template name="class-value">
	<xsl:param name="class" />
		<xsl:choose>
			<xsl:when test=".//*[contains(concat(' ', @class, ' '), concat(' ', $class , ' '))]//*[contains(concat(' ', normalize-space(@class), ' '),' value ')]">
				<xsl:value-of select="normalize-space(.//*[contains(concat(' ', @class, ' '), concat(' ', $class , ' '))]//*[contains(concat(' ', normalize-space(@class), ' '),' value ')])" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select=".//*[contains(concat(' ', @class, ' '), concat(' ', $class , ' '))]" />
			</xsl:otherwise>
		</xsl:choose>
</xsl:template>

<!-- Sub-Property Template for N, ADR, ORG -->
<xsl:template name="sub-prop">
	<xsl:param name="class" />
	<xsl:variable name="v1">
		<xsl:call-template name="class-value">
			<xsl:with-param name="class" select="$class" />
		</xsl:call-template>
	</xsl:variable>
	<xsl:variable name="v" select="normalize-space($v1)" />
	<xsl:call-template name="escapeText">
		<xsl:with-param name="text-string" select="$v" />
	</xsl:call-template>
	<xsl:text>;</xsl:text>
</xsl:template>

<!-- get the class value -->
<xsl:template name="class-attribute-value">
	<xsl:param name="value" />
	<xsl:if test=".//*[contains(concat(' ', @class, ' '), concat(' ', 'type', ' '))]">
		<xsl:choose>
			<xsl:when test="normalize-space(.//*[contains(concat(' ', @class, ' '), concat(' ', 'type', ' '))]) = $value">
				<xsl:value-of select="$value"/>
			</xsl:when>
			<xsl:when test="local-name(.//*[contains(concat(' ', @class, ' '), concat(' ', 'type', ' '))]) = 'abbr'">
				<xsl:if test=".//*[contains(concat(' ', @class, ' '), concat(' ', 'type', ' ')) and @title = $value]">
					<xsl:value-of select="$value"/>
				</xsl:if>
			</xsl:when>
		</xsl:choose>
	</xsl:if>
</xsl:template>

<!-- Recursive function to search for property attributes -->
<xsl:template name="find-types">
  <xsl:param name="list" /> <!-- e.g. "fax modem voice" -->
  <xsl:param name="found" />
  
  <xsl:variable name="first" select='substring-before(concat($list, " "), " ")' />
  <xsl:variable name="rest" select='substring-after($list, " ")' />

	<!-- look for first item in list -->

	<xsl:variable name="v">
		<xsl:call-template name="class-attribute-value">
			<xsl:with-param name="value" select='$first' />
		</xsl:call-template>
	</xsl:variable>

	<xsl:variable name="ff">
		<xsl:choose>
			<xsl:when test='normalize-space($v) and normalize-space($found)'>
				<xsl:value-of select='concat($found, ",", $first)' />
			</xsl:when>
			<xsl:when test='normalize-space($v)'>
				<xsl:value-of select='$first' />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$found" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

	<!-- recur if there are more -->
	<xsl:choose>
		<xsl:when test="$rest">
			<xsl:call-template name="find-types">
				<xsl:with-param name="list" select="$rest" />
				<xsl:with-param name="found" select="$ff" />
			</xsl:call-template>
		</xsl:when>
		<!-- else return what we found -->
		<xsl:otherwise>
			<xsl:value-of select="$ff" />
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

<!-- don't pass text thru -->
<xsl:template match="text()"></xsl:template>
</xsl:stylesheet>