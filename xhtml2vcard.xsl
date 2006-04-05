<?xml version="1.0"?>
<xsl:stylesheet 
 xmlns:xsl ="http://www.w3.org/1999/XSL/Transform"
 xmlns:uri ="http://www.w3.org/2000/07/uri43/uri.xsl?template="
 version="1.0"
>

<!-- i have saved the file locally to conserve bandwidth, always check for updateds -->
<xsl:import href="uri.xsl" />

<!--<xsl:strip-space elements="*"/>-->
<xsl:preserve-space elements="pre"/>

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
Version 0.7.10.1
2005-02-27

Copyright 2005 Brian Suda
This work is relicensed under The W3C Open Source License
http://www.w3.org/Consortium/Legal/copyright-software-19980720

Major optimization created by Dan Connolly [http://www.w3.org/People/Connolly/] have been rolled into this file, along with the URI normalizing template [http://www.w3.org/2000/07/uri43/uri.xsl]
http://dev.w3.org/cvsweb/2001/palmagent/xhtml2vcard.xsl

NOTES:
Until the hCard spec has been finalised this is a work in progress.
I'm not an XSLT expert, so there are no guarantees to quality of this code!

@@ check for profile in head element
@@ decode only the first instance of a singular property
-->



<xsl:param name="Prodid" select='"-//suda.co.uk//X2V 0.7.10.1 (BETA)//EN"' />
<xsl:param name="Source" >(Best Practices states this should be the URL the vcard was transformed from)</xsl:param>
<xsl:param name="Encoding" >UTF-8</xsl:param>
<xsl:param name="Anchor" />

<xsl:variable name="nl"><xsl:text>
</xsl:text></xsl:variable>
<xsl:variable name="tb"><xsl:text>	</xsl:text></xsl:variable>

<xsl:variable name="lcase">abcdefghijklmnopqrstuvwxyz</xsl:variable>
<xsl:variable name="ucase">ABCDEFGHIJKLMNOPQRSTUVWXYZ</xsl:variable>

<!-- check for profile in head element -->
<xsl:template match="head[contains(concat(' ',normalize-space(@profile),' '),' http://foobar ')]">
<!-- 
==================== CURRENTLY DISABLED ====================
This will call the vCard template, 
Without the correct profile you cannot assume the class values are intended for the vCard microformat.
-->
<!-- <xsl:call-template name="vcard"/> -->
</xsl:template>

<!-- Each vCard is listed in succession -->
<xsl:template match="*[contains(concat(' ',normalize-space(@class),' '),' vcard ')]">
	<xsl:if test="not($Anchor) or @id = $Anchor">		
		<xsl:text>BEGIN:VCARD</xsl:text>
		<xsl:text>&#x0A;PRODID:</xsl:text><xsl:value-of select="$Prodid"/>
		<xsl:text>&#x0A;SOURCE:</xsl:text><xsl:value-of select="$Source"/>
		<xsl:text>&#x0A;NAME:</xsl:text>
		<xsl:apply-templates select="//*[name() = 'title']" mode="unFormatText" />
		<xsl:text>&#x0A;VERSION:3.0</xsl:text>

		<!-- check for header="" and extract that data -->
		<xsl:if test="@headers">
			<xsl:call-template name="extract-ids">
				<xsl:with-param name="text-string"><xsl:value-of select="@headers"/></xsl:with-param>
			</xsl:call-template>
		</xsl:if>

		<!-- check for object elements with data references to IDs -->
		<xsl:if test=".//*[ancestor-or-self::*[name() = 'del'] = false()] and .//*[descendant-or-self::*[name() = 'object'] = true() and contains(normalize-space(@data),'#')]">
			<xsl:for-each select=".//*[descendant-or-self::*[name() = 'object'] = true() and contains(normalize-space(@data),'#') and contains(concat(' ',normalize-space(@class),' '),' include ')]">
				<xsl:variable name="header-id"><xsl:value-of select="substring-after(@data,'#')"/></xsl:variable>
				<xsl:for-each select="//*[@id=$header-id]">
					<xsl:call-template name="vcardProperties"/>
				</xsl:for-each>
			</xsl:for-each>
		</xsl:if> 

		<xsl:call-template name="vcardProperties"/>

		<xsl:text>&#x0A;END:VCARD&#x0A;&#x0A;</xsl:text>
	</xsl:if>
</xsl:template>

<!-- ============== working templates ================= -->
<xsl:template name="vcardProperties">
	<!--  Implied "N" Optimization -->
	<xsl:variable name="n-elt" select=".//*[ancestor-or-self::*[name() = 'del'] = false() and contains(concat(' ', normalize-space(@class), ' '),' n ')]" />
	<xsl:choose>
		<xsl:when test="$n-elt">
			<xsl:call-template name="n-prop" />
		</xsl:when>
		<xsl:when test="normalize-space(.//*[ancestor-or-self::*[name() = 'del'] = false() and contains(concat(' ',normalize-space(@class),' '),' fn ')]) = normalize-space(.//*[ancestor-or-self::*[name() = 'del'] = false() and contains(concat(' ',normalize-space(@class),' '),' org ')])">
			<xsl:text>&#x0A;N:;;;;;</xsl:text>		
		</xsl:when>
		<xsl:when test="not($n-elt) and not(string-length(normalize-space(.//*[ancestor-or-self::*[name() = 'del'] = false() and contains(concat(' ',normalize-space(@class),' '),' fn ')])) &gt; 1+string-length(translate(normalize-space(.//*[ancestor-or-self::*[name() = 'del'] = false() and contains(concat(' ',normalize-space(@class),' '),' fn ')]),' ','')))">
			<xsl:call-template name="implied-n" />		
		</xsl:when>
		<xsl:otherwise>
			<xsl:text>&#x0A;N:;;;;;</xsl:text>
		</xsl:otherwise>
	</xsl:choose>
	
	<xsl:variable name="org-elt" select=".//*[ancestor-or-self::*[name() = 'del'] = false() and contains(concat(' ', normalize-space(@class), ' '),' org ')]" />
	<xsl:if test="$org-elt">
			<xsl:call-template name="org-prop"/>
	</xsl:if>		
	
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

	<xsl:call-template name="multiTextPropLang">
		<xsl:with-param name="label">CATEGORIES</xsl:with-param>
		<xsl:with-param name="class">category</xsl:with-param>
	</xsl:call-template>
	
	<!-- Check to see if this is not a company -->
	<xsl:choose>
		<xsl:when test="not(normalize-space(.//*[ancestor-or-self::*[name() = 'del'] = false() and contains(concat(' ',normalize-space(@class),' '),' fn ')]) = normalize-space(.//*[ancestor-or-self::*[name() = 'del'] = false() and contains(concat(' ',normalize-space(@class),' '),' org ')]))">
			<!-- check to see it is only one word long -->
			<xsl:choose>
				<xsl:when test="string-length(normalize-space(.//*[ancestor-or-self::*[name() = 'del'] = false() and contains(concat(' ',normalize-space(@class),' '),' fn ')])) = string-length(translate(normalize-space(.//*[ancestor-or-self::*[name() = 'del'] = false() and contains(concat(' ',normalize-space(@class),' '),' fn ')]),' ',''))">
					<xsl:call-template name="multiTextPropLang">
						<xsl:with-param name="label">NICKNAME</xsl:with-param>
						<xsl:with-param name="class">nickname</xsl:with-param>
						<xsl:with-param name="append"><xsl:value-of select="normalize-space(.//*[ancestor-or-self::*[name() = 'del'] = false() and contains(concat(' ',normalize-space(@class),' '),' fn ')])"/></xsl:with-param>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="multiTextPropLang">
						<xsl:with-param name="label">NICKNAME</xsl:with-param>
						<xsl:with-param name="class">nickname</xsl:with-param>
					</xsl:call-template>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:when>
		<xsl:otherwise>
			<xsl:call-template name="multiTextPropLang">
				<xsl:with-param name="label">NICKNAME</xsl:with-param>
				<xsl:with-param name="class">nickname</xsl:with-param>
			</xsl:call-template>
		</xsl:otherwise>
	</xsl:choose>

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
		
	<xsl:for-each select=".//*[ancestor-or-self::*[name() = 'del'] = false() and contains(concat(' ', normalize-space(@class), ' '),' adr ')]">
		<xsl:call-template name="adr-prop" />
	</xsl:for-each>

	<xsl:for-each select=".//*[ancestor-or-self::*[name() = 'del'] = false() and contains(concat(' ', normalize-space(@class), ' '),' tel ')]">
		<xsl:call-template name="tel-prop" />
	</xsl:for-each>

	<xsl:variable name="geo-elt" select=".//*[ancestor-or-self::*[name() = 'del'] = false() and contains(concat(' ', normalize-space(@class), ' '),' geo ')]" />
	<xsl:if test="$geo-elt">
			<xsl:call-template name="geo-prop"/>
	</xsl:if>

	<!-- Templates that still need work -->

	<!-- <xsl:apply-templates select=".//*[ancestor-or-self::*[name() = 'del'] = false() and contains(concat(' ',normalize-space(@class),' '),' agent ')]" mode="agent"/> 	-->

	<xsl:apply-templates select=".//*[ancestor-or-self::*[name() = 'del'] = false() and contains(concat(' ',normalize-space(@class),' '),' url ')]" mode="url"/>

	<xsl:apply-templates select=".//*[ancestor-or-self::*[name() = 'del'] = false() and contains(concat(' ',normalize-space(@class),' '),' bday ')]" mode="bday"/>

	<!-- @@TYPE=PGP, TYPE=X509, ENCODING=b -->
	<xsl:variable name="key-elt" select=".//*[ancestor-or-self::*[name() = 'del'] = false() and contains(concat(' ', normalize-space(@class), ' '),' key ')]" />
	<xsl:if test="$key-elt">
			<xsl:call-template name="key-prop"/>
	</xsl:if>

	<!-- LABEL needs work! -->
	<xsl:variable name="label-elt" select=".//*[ancestor-or-self::*[name() = 'del'] = false() and contains(concat(' ', normalize-space(@class), ' '),' label ')]" />
	<xsl:if test="$label-elt">
			<xsl:call-template name="label-prop"/>
	</xsl:if>

	<!--
	<xsl:text>&#x0A;UID:</xsl:text>
	<xsl:call-template name="escapeText">
		<xsl:with-param name="text-string"><xsl:value-of select="normalize-space(@id)" /></xsl:with-param>
	</xsl:call-template>
	-->


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
				<xsl:call-template name="uri:expand">
					<xsl:with-param name="base">

						<xsl:call-template name="baseURL">
							<xsl:with-param name="Source"><xsl:value-of select="$Source" /></xsl:with-param>
						</xsl:call-template>
						
					</xsl:with-param>
					<xsl:with-param name="there"><xsl:value-of select="@src"/></xsl:with-param>
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
				<xsl:call-template name="uri:expand">
					<xsl:with-param name="base">

						<xsl:call-template name="baseURL">
							<xsl:with-param name="Source"><xsl:value-of select="$Source" /></xsl:with-param>
						</xsl:call-template>
						
					</xsl:with-param>
					<xsl:with-param name="there"><xsl:value-of select="@src"/></xsl:with-param>
				</xsl:call-template>

			</xsl:otherwise>
		</xsl:choose>
	</xsl:when>
	<xsl:otherwise>
		<xsl:variable name="textFormatted">
		<xsl:apply-templates select="." mode="unFormatText" />
		</xsl:variable>
		<xsl:value-of select="normalize-space($textFormatted)"/>
	</xsl:otherwise>
</xsl:choose>
</xsl:template>


<!-- BDAY property -->
<xsl:template match="*[contains(@class,'bday')]" mode="bday">
<xsl:text>
BDAY:</xsl:text>
<xsl:choose>
	<xsl:when test="@title != '' and (local-name(.) = 'abbr' or 'img' = local-name(.))">
		<xsl:variable name="textFormatted">
		<xsl:apply-templates select="@title" mode="unFormatText" />
		</xsl:variable>
		<xsl:value-of select="normalize-space($textFormatted)"/>
	</xsl:when>
	<xsl:otherwise>
		<xsl:variable name="textFormatted">
		<xsl:apply-templates select="." mode="unFormatText" />
		</xsl:variable>
		<xsl:value-of select="normalize-space($textFormatted)"/>
	</xsl:otherwise>
</xsl:choose>
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

<!-- blob Property -->
<xsl:template name="blobProp">
	<xsl:param name="label" />
	<xsl:param name="class" />

	<xsl:for-each select=".//*[ancestor-or-self::*[name() = 'del'] = false() and contains(concat(' ', @class, ' '),concat(' ', $class, ' '))]">
		<xsl:if test="position() = 1">
		<xsl:text>&#x0A;</xsl:text>
		<xsl:value-of select="$label" />
	
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
								<xsl:call-template name="uri:expand">
									<xsl:with-param name="base">

										<xsl:call-template name="baseURL">
											<xsl:with-param name="Source"><xsl:value-of select="$Source" /></xsl:with-param>
										</xsl:call-template>
										
									</xsl:with-param>
									<xsl:with-param name="there"><xsl:value-of select="@src"/></xsl:with-param>
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
								<xsl:call-template name="uri:expand">
									<xsl:with-param name="base">
										<xsl:call-template name="baseURL">
											<xsl:with-param name="Source"><xsl:value-of select="$Source" /></xsl:with-param>
										</xsl:call-template>
									</xsl:with-param>
									<xsl:with-param name="there"><xsl:value-of select="@href"/></xsl:with-param>
								</xsl:call-template>

							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:when test="@data">
						<xsl:text>;VALUE=uri:</xsl:text>
						<xsl:variable name="textFormatted">
						<xsl:apply-templates select="@data" mode="unFormatText" />
						</xsl:variable>
						<xsl:value-of select="normalize-space($textFormatted)"/>
					</xsl:when>
					<xsl:when test=".//*[contains(concat(' ', normalize-space(@class), ' '),' value ')]">
						<xsl:text>:</xsl:text>
						<xsl:for-each select=".//*[contains(concat(' ', normalize-space(@class), ' '),' value ')]">
							<xsl:variable name="textFormatted">
							<xsl:apply-templates select="." mode="unFormatText" />
							</xsl:variable>
							<xsl:value-of select="normalize-space($textFormatted)"/>
						</xsl:for-each>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>:</xsl:text>
						<xsl:variable name="textFormatted">
						<xsl:apply-templates select="." mode="unFormatText" />
						</xsl:variable>
						<xsl:value-of select="normalize-space($textFormatted)"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>:</xsl:text>
				<xsl:variable name="textFormatted">
				<xsl:apply-templates select="." mode="unFormatText" />
				</xsl:variable>
				<xsl:value-of select="normalize-space($textFormatted)"/>
			</xsl:otherwise>
		</xsl:choose>
		</xsl:if>
	</xsl:for-each>
</xsl:template>

<!-- KEY Property -->
<xsl:template name="key-prop">
	<xsl:for-each select=".//*[ancestor-or-self::*[name() = 'del'] = false() and contains(concat(' ', @class, ' '),concat(' ', key, ' '))]">
	<xsl:if test="position() = 1">
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

<!-- LABEL Property -->
<xsl:template name="label-prop">
	<xsl:for-each select=".//*[ancestor-or-self::*[name() = 'del'] = false() and contains(concat(' ', @class, ' '),concat(' ', label, ' '))]">
		<xsl:if test="position() = 1">
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

<!-- ORG Property -->
<xsl:template name="org-prop" >
	<xsl:text>&#x0A;ORG</xsl:text>
	<xsl:text>;CHARSET=</xsl:text><xsl:value-of select="$Encoding"/>
    <xsl:text>:</xsl:text>
	<xsl:choose>
		<xsl:when test=".//*[contains(concat(' ', @class, ' '), concat(' ', 'organization-name', ' '))]" >
			<xsl:call-template name="sub-prop">
				<xsl:with-param name="class" select='"organization-name"' />
			</xsl:call-template>
			<xsl:for-each select=".//*[contains(concat(' ', @class, ' '), concat(' ', 'organization-unit', ' '))]" >
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
				<xsl:text>;</xsl:text>
			</xsl:for-each>
		</xsl:when>
		<xsl:otherwise>
			<!-- value stuff here -->
			<xsl:call-template name="escapeText">
				<xsl:with-param name="text-string" select="normalize-space(.//*[contains(concat(' ', @class, ' '), concat(' ', 'org', ' '))])" />
			</xsl:call-template>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template name="adr-prop" >
	<xsl:text>&#x0A;ADR</xsl:text>
	<xsl:call-template name="lang" />
	<xsl:text>;CHARSET=</xsl:text><xsl:value-of select="$Encoding"/>
	
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
				<xsl:variable name="v" select="." />
				<xsl:variable name="textFormatted">
				<xsl:apply-templates select="$v" mode="unFormatText" />
				</xsl:variable>
				<xsl:value-of select="normalize-space($textFormatted)"/>
			</xsl:for-each>
		</xsl:when>		
		<xsl:otherwise>
			<xsl:variable name="v" select="." />
			<xsl:variable name="textFormatted">
			<xsl:apply-templates select="$v" mode="unFormatText" />
			</xsl:variable>
			<xsl:value-of select="normalize-space($textFormatted)"/>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<!-- N Property -->
<xsl:template name="n-prop" >
	<xsl:text>&#x0A;N</xsl:text>
	<xsl:call-template name="lang" />
	<xsl:text>;CHARSET=</xsl:text><xsl:value-of select="$Encoding"/>
	<xsl:text>:</xsl:text>
	<xsl:call-template name="sub-prop">
		<xsl:with-param name="class" select='"family-name"' />
	</xsl:call-template>
	<xsl:call-template name="sub-prop">
		<xsl:with-param name="class" select='"given-name"' />
	</xsl:call-template>
	<xsl:call-template name="sub-prop">
		<xsl:with-param name="class" select='"additional-name"' />
	</xsl:call-template>
	<xsl:call-template name="sub-prop">
		<xsl:with-param name="class" select='"honorific-prefix"' />
	</xsl:call-template>
	<xsl:call-template name="sub-prop">
		<xsl:with-param name="class" select='"honorific-suffix"' />
	</xsl:call-template>
</xsl:template>

<!-- GEO Property -->
<xsl:template name="geo-prop" >
	<xsl:text>&#x0A;GEO:</xsl:text>
	<xsl:call-template name="sub-prop">
		<xsl:with-param name="class" select='"latitude"' />
	</xsl:call-template>
	<xsl:call-template name="sub-prop">
		<xsl:with-param name="class" select='"longitude"' />
	</xsl:call-template>
</xsl:template>

<!-- IMPLIED N from FN -->
<xsl:template name="implied-n">
	<xsl:for-each select=".//*[ancestor-or-self::*[name() = 'del'] = false() and contains(concat(' ', @class, ' '),concat(' ', 'fn', ' '))]">
		<xsl:if test="position() = 1">
			<xsl:text>&#x0A;N</xsl:text>
			<xsl:call-template name="lang" />
			<xsl:text>;CHARSET=</xsl:text><xsl:value-of select="$Encoding"/>
			<xsl:text>:</xsl:text>
		
			<xsl:choose>
				<xsl:when test="local-name(.) = 'abbr' and @title">
					<xsl:variable name="family-name">
						<xsl:value-of select='substring-after(normalize-space(@title), " ")' />
					</xsl:variable>
					<xsl:call-template name="escapeText">
						<xsl:with-param name="text-string" select="$family-name" />
					</xsl:call-template>
					<xsl:text>;</xsl:text>
					<xsl:choose>
						<xsl:when test='not(substring-before(normalize-space(@title), " "))'>
							<xsl:call-template name="escapeText">
								<xsl:with-param name="text-string" select="normalize-space(@title)" />
							</xsl:call-template>
						</xsl:when>
						<xsl:otherwise>
							<xsl:call-template name="escapeText">
								<xsl:with-param name="text-string" select='substring-before(normalize-space(@title), " ")' />
							</xsl:call-template>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>
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
				</xsl:otherwise>
			</xsl:choose>
			<xsl:text>;</xsl:text>
			<xsl:text>;;;</xsl:text>
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
<xsl:template name="multiTextPropLang">
	<xsl:param name="label" />
	<xsl:param name="class" />
	<xsl:param name="append"/>

	<xsl:choose>
		<xsl:when test=".//*[ancestor-or-self::*[name() = 'del'] = false() and contains(concat(' ', @class, ' '),concat(' ', $class, ' '))]">
			<xsl:text>&#x0A;</xsl:text>
			<xsl:value-of select="$label" />
			<!-- this lang needs to be looked at! -->
			<xsl:call-template name="lang" />
			<xsl:text>;CHARSET=</xsl:text><xsl:value-of select="$Encoding"/>
	    	<xsl:text>:</xsl:text>
			<xsl:if test="$append">
				<xsl:value-of select="$append"/><xsl:text>,</xsl:text>
			</xsl:if>
		</xsl:when>
		<xsl:when test="$append">
			<xsl:text>&#x0A;</xsl:text>
			<xsl:value-of select="$label" />
			<!-- this lang needs to be looked at! -->
			<xsl:call-template name="lang" />
			<xsl:text>;CHARSET=</xsl:text><xsl:value-of select="$Encoding"/>
	    	<xsl:text>:</xsl:text>
			<xsl:value-of select="$append"/>
		</xsl:when>
	</xsl:choose>
	
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
		<xsl:if test="not(position()=last())">
			<xsl:text>,</xsl:text>
		</xsl:if>

	</xsl:for-each>
</xsl:template>

<!-- EMAIL PROPERTY -->
<xsl:template name="emailProp">
	<xsl:param name="label" />
	<xsl:param name="class" />
	<xsl:for-each select=".//*[ancestor-or-self::*[name() = 'del'] = false() and contains(concat(' ', @class, ' '),concat(' ', $class, ' '))]">
		<xsl:variable name="addr">
			<xsl:choose>
				<xsl:when test='@href and starts-with(@href, "mailto:")'>
					<xsl:choose>
						<xsl:when test='string-length(substring-before(substring-after(@href, ":"),"?")) &lt; 1'>
							<xsl:value-of select='substring-after(@href, ":")' />
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select='substring-before(substring-after(@href, ":"),"?")' />
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:when test='not(local-name(.) = "a")'>
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

<!-- Get the base URL for the page if there is one -->
<xsl:template name="baseURL">
	<xsl:param name="Source" />
	
	<xsl:choose>
		<xsl:when test="//*[@xml:base] = true()">
			<xsl:value-of select="//*[@xml:base]/@xml:base" />
		</xsl:when>
	
		<xsl:when test="//*[name() = 'base'] = true()">
			<xsl:value-of select="//*[name() = 'base']/@href" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="$Source" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<!-- get the class value -->
<xsl:template name="class-value">
	<xsl:param name="class" />
		<xsl:choose>
			<xsl:when test=".//*[contains(concat(' ', @class, ' '), concat(' ', $class , ' '))]//*[contains(concat(' ', normalize-space(@class), ' '),' value ')]">
				<xsl:for-each select=".//*[contains(concat(' ', normalize-space(@class), ' '),' value ')]">
					<xsl:variable name="textFormatted">
					<xsl:apply-templates select="." mode="unFormatText" />
					</xsl:variable>
					<xsl:value-of select="normalize-space($textFormatted)"/>
				</xsl:for-each>
			</xsl:when>
			<xsl:when test="$class = 'additional-name' or $class = 'honorific-prefix' or $class = 'honorific-suffix'">
				<xsl:for-each select=".//*[contains(concat(' ', normalize-space(@class), ' '),concat(' ',$class,' '))]">
					<xsl:variable name="textFormatted">
					<xsl:apply-templates select="." mode="unFormatText" />
					</xsl:variable>
					<xsl:value-of select="normalize-space($textFormatted)"/>
					<xsl:if test="not(position()=last())">
						<xsl:text>,</xsl:text>
					</xsl:if>
				</xsl:for-each>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="normalize-space(.//*[contains(concat(' ', @class, ' '), concat(' ', $class , ' '))])" />
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
	<xsl:value-of select="normalize-space($v1)"/>
	<xsl:text>;</xsl:text>
</xsl:template>

<!-- get the class value -->
<xsl:template name="class-attribute-value">
	<xsl:param name="value" />
	<xsl:if test=".//*[contains(concat(' ', @class, ' '), concat(' ', 'type', ' '))]">
		<xsl:choose>
			<xsl:when test="translate(normalize-space(.//*[contains(concat(' ', @class, ' '), concat(' ', 'type', ' '))]),$ucase,$lcase) = $value">
				<xsl:value-of select="normalize-space($value)"/>
			</xsl:when>
			<xsl:when test="local-name(.//*[contains(concat(' ', @class, ' '), concat(' ', 'type', ' '))]) = 'abbr'">
				<xsl:if test=".//*[contains(concat(' ', @class, ' '), concat(' ', 'type', ' ')) and contains(translate(concat(' ', translate(@title,',',' '), ' '),$ucase,$lcase), concat(' ', $value, ' '))]">
					<xsl:value-of select="normalize-space($value)"/>
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

<!-- recursive function to escape text -->
<xsl:template name="escapeText">
	<xsl:param name="text-string"></xsl:param>
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
				<xsl:when test="substring($text-string,1,1) = $nl">
					<xsl:text>\n</xsl:text>
					<xsl:call-template name="escapeText">
						<xsl:with-param name="text-string"><xsl:value-of select="substring($text-string,2)"/></xsl:with-param>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="substring($text-string,1,1)"/>
					<xsl:call-template name="escapeText">
						<xsl:with-param name="text-string"><xsl:value-of select="substring($text-string,2)"/></xsl:with-param>
					</xsl:call-template>
				</xsl:otherwise>				
			</xsl:choose>
		</xsl:when>
		<xsl:otherwise>
			<xsl:choose>
				<xsl:when test="$text-string = '\'">
					<xsl:text>\\</xsl:text>
				</xsl:when>
				<xsl:when test="$text-string = ','">
					<xsl:text>\,</xsl:text>
				</xsl:when>
				<xsl:when test="$text-string = ';'">
					<xsl:text>\;</xsl:text>
				</xsl:when>
				<!-- New Line -->
				<xsl:when test="$text-string = $nl">
					<xsl:text>\n</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$text-string"/>
				</xsl:otherwise>
			</xsl:choose>		
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<!-- don't pass text thru -->
<xsl:template match="text()"></xsl:template>
</xsl:stylesheet>