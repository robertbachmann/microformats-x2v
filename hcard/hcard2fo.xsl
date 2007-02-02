<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet 
	xmlns:xsl  ="http://www.w3.org/1999/XSL/Transform"
	xmlns:fo   ="http://www.w3.org/1999/XSL/Format"
	xmlns:mf   ="http://suda.co.uk/projects/microformats/mf-templates.xsl?template="
	xmlns:xhtml="http://www.w3.org/1999/xhtml" 
	version="1.0"
>

<xsl:include href="../mf-templates.xsl"/>

<xsl:output 
	indent="yes" 
	omit-xml-declaration="yes" 
	method="xml"
/>

<xsl:param name="Source" />

<xsl:template match="/">

<fo:root>
    <fo:layout-master-set>
        <fo:simple-page-master master-name="BusinessCard" page-width="3.370in" page-height="2.125in" >
            <fo:region-body region-name="CardBody" margin="0.1in"/>
        </fo:simple-page-master>
    </fo:layout-master-set>

	<!-- loop through for hCard data -->
	<xsl:for-each select="//*[contains(concat(' ',normalize-space(@class),' '),' vcard ')]">
    	<fo:page-sequence master-reference="BusinessCard">
        	<fo:flow flow-name="CardBody">
				<xsl:for-each select=".//*[contains(concat(' ',normalize-space(@class),' '),' fn ')]">
					<xsl:if test="position() = 1">
						<fo:block font-size="24pt"><xsl:call-template name="mf:extractText"/></fo:block>
					</xsl:if>
				</xsl:for-each>

			<xsl:for-each select=".//*[contains(concat(' ',normalize-space(@class),' '),' url ')]">
					<fo:block font-size="8pt">
						<xsl:call-template name="mf:extractUrl">
							<xsl:with-param name="Source"><xsl:value-of select="$Source"/></xsl:with-param>
						</xsl:call-template>
					</fo:block>
			</xsl:for-each>

			<xsl:for-each select=".//*[ancestor-or-self::*[local-name() = 'del'] = false() and contains(concat(' ', normalize-space(@class), ' '),' email ')]">
				<fo:block font-size="10pt">
					<xsl:call-template name="mf:extractUid">
						<xsl:with-param name="protocol">mailto</xsl:with-param>
						<xsl:with-param name="type-list">internet x400 pref</xsl:with-param>
					</xsl:call-template>
				</fo:block>
			</xsl:for-each>

			<xsl:for-each select=".//*[ancestor-or-self::*[local-name() = 'del'] = false() and contains(concat(' ', normalize-space(@class), ' '),' adr ')]">
					<xsl:call-template name="mf:extractAdr">
						<xsl:with-param name="type-list">dom intl postal parcel home work pref</xsl:with-param>
					</xsl:call-template>
			</xsl:for-each>

			<xsl:for-each select=".//*[ancestor-or-self::*[local-name() = 'del'] = false() and contains(concat(' ', normalize-space(@class), ' '),' tel ')]">
				<fo:block font-size="10pt">
					<xsl:call-template name="mf:extractUid">
						<xsl:with-param name="protocol">tel</xsl:with-param>
						<xsl:with-param name="type-list">home work pref voice fax msg cell pager bbs modem car isdn video pcs</xsl:with-param>
					</xsl:call-template>
				</fo:block>
			</xsl:for-each>

    		</fo:flow>
    	</fo:page-sequence>
	</xsl:for-each>
</fo:root>

</xsl:template>

<xsl:template name="adrCallBack">
	<xsl:param name="type"/>
	<xsl:param name="post-office-box"/>
	<xsl:param name="street-address"/>
	<xsl:param name="extended-address"/>
	<xsl:param name="locality"/>
	<xsl:param name="region"/>
	<xsl:param name="country-name"/>
	<xsl:param name="postal-code"/>

	<xsl:if test="not($post-office-box) = ''">
		<fo:block><xsl:value-of select="$post-office-box"/></fo:block>
	</xsl:if>
	<xsl:if test="not($extended-address) = ''">
    	<fo:block><xsl:value-of select="$extended-address"/></fo:block>
	</xsl:if>
	<xsl:if test="not($street-address) = ''">
		<fo:block><xsl:value-of select="$street-address"/></fo:block>
	</xsl:if>
	<fo:block>
	<xsl:if test="not($locality) = ''">
    	<xsl:value-of select="$locality"/>
	</xsl:if>
	<xsl:if test="not($region) = ''">
    	<xsl:value-of select="$region"/>
	</xsl:if>
	<xsl:if test="not($postal-code) = ''">
    	<xsl:value-of select="$postal-code"/>
	</xsl:if>
	</fo:block>
	<xsl:if test="not($country-name) = ''">
    	<fo:block><xsl:value-of select="$country-name"/></fo:block>
	</xsl:if>
</xsl:template>

<xsl:template name="uidCallBack">
	<xsl:value-of select="$value"/>
</xsl:template>

</xsl:stylesheet>