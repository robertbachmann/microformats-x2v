<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#"
	xmlns:review="http:/www.purl.org/stuff/rev#" 
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" 
	xmlns:mf="http://suda.co.uk/projects/microformats/mf-templates.xsl?template="
	xmlns:xhtml="http://www.w3.org/1999/xhtml" 
	xmlns:dc="http://purl.org/dc/elements/1.1/" 
	xmlns:dcterms="http://purl.org/dc/dcmitype/" 
	xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" 
	xmlns:foaf="http://xmlns.com/foaf/0.1/" 
	xmlns:vcard="http://www.w3.org/2001/vcard-rdf/3.0#"
	version="1.0"
>

<xsl:include href="../mf-templates.xsl"/>

<!--
@todo
* language settings
* base URI
* tags
-->
<xsl:param name="Source" />
<xsl:param name="Anchor" />

<xsl:output 
	indent="yes" 
	omit-xml-declaration="yes" 
	method="xml"
/>

<xsl:template match="/xhtml:html/xhtml:body">
	<rdf:RDF>
	<xsl:element name="Description" namespace="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
		<xsl:attribute name="about" namespace="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
			<xsl:call-template name="mf:baseURL">
				<xsl:with-param name="Source"><xsl:value-of select="$Source"/></xsl:with-param>
			</xsl:call-template>
		</xsl:attribute>
		<xsl:for-each select="//*[contains(concat(' ',normalize-space(@class),' '),' hreview ')]">
			<xsl:if test="
			(descendant::*[contains(concat(' ',normalize-space(@class),' '),' summary ')] or descendant::*[contains(concat(' ',normalize-space(@class),' '),' item ')]/descendant::*[contains(concat(' ',normalize-space(@class),' '),' fn ')])
			and (not($Anchor) or @id = $Anchor)
			">
	  			<review:Review>
					<xsl:call-template name="mf:doIncludes"/>
					<xsl:call-template name="properties"/>
				</review:Review>
			</xsl:if>
  		</xsl:for-each>
	</xsl:element>
	</rdf:RDF>
</xsl:template>		
		
		
		
<xsl:template name="properties">		
	<!-- Review Summary (optional) :: 1 instance -->
	<xsl:choose>
		<xsl:when test="descendant::*[contains(concat(' ',normalize-space(@class),' '),' summary ')][1]">
			<xsl:for-each select="descendant::*[contains(concat(' ',normalize-space(@class),' '),' summary ')][1]">
				<dc:title><xsl:call-template name="mf:extractText" /></dc:title>
			</xsl:for-each>
		</xsl:when>
		<xsl:when test="false() = descendant::*[contains(concat(' ',normalize-space(@class),' '),' summary ')]">
			<xsl:for-each select="descendant::*[contains(concat(' ',normalize-space(@class),' '),' fn ')][1]">
				<dc:title><xsl:call-template name="mf:extractText" /></dc:title>
			</xsl:for-each>
		</xsl:when>
	</xsl:choose>

	<!-- Review Type (optional) :: 1 instance -->
	<xsl:for-each select="descendant::*[contains(concat(' ',normalize-space(@class),' '),' type ')][1]">
	  <!-- product | business | event | person | place | website | url -->
	  <xsl:variable name="reviewType">
	  	<xsl:call-template name="mf:extractText"/>
	  </xsl:variable>
	  <xsl:choose>
	  	<xsl:when test="
	  		$reviewType = 'product' or
	  		$reviewType = 'business' or
	  		$reviewType = 'event' or
	  		$reviewType = 'person' or
	  		$reviewType = 'place' or
	  		$reviewType = 'website' or
	  		$reviewType = 'url'
	  	">
	  		<dc:type><xsl:value-of select="$reviewType"/></dc:type>
	  	</xsl:when>
	  	<!-- implied types -->
	  	<xsl:when test="//*[
	  		 (contains(concat(' ',normalize-space(@class),' '),' item ') and
	  		  contains(concat(' ',normalize-space(@class),' '),' vcard '))
	  		]/descendant::*[contains(concat(' ',normalize-space(@class),' '),' fn ') and contains(concat(' ',normalize-space(@class),' '),' org ')]">
	  		<dc:type>business</dc:type>
	  	</xsl:when>
	  	<xsl:when test="//*[
	  		 (contains(concat(' ',normalize-space(@class),' '),' item ') and
	  		  contains(concat(' ',normalize-space(@class),' '),' vcard '))
	  		]">
	  		<dc:type>person</dc:type>
	  	</xsl:when>
	  	<xsl:when test="//*[
	  		 (contains(concat(' ',normalize-space(@class),' '),' item ') and
	  		  contains(concat(' ',normalize-space(@class),' '),' vevent '))
	  		]">
	  		<dc:type>event</dc:type>
	  	</xsl:when>
	  	<xsl:otherwise>
	  		<!-- default value? -->
	  	</xsl:otherwise>
	  </xsl:choose>
	</xsl:for-each>




  <!-- Item being Reviewed (required) :: 1 instance -->
  <xsl:for-each select="descendant::*[contains(concat(' ',normalize-space(@class),' '),' item ')][1]">

	<xsl:choose>
		<xsl:when test="self::*[contains(concat(' ',normalize-space(@class),' '),' vevent ')]">
			<!-- get vevent data -->
			
			
		</xsl:when>
		<!-- beware of vCards nested in vevents -->
		<xsl:when test="self::*[contains(concat(' ',normalize-space(@class),' '),' vcard ')]">
			<!-- get vCard data -->
			<!-- (optional) :: single instance -->
			<xsl:for-each select="descendant::*[contains(concat(' ',normalize-space(@class),' '),' fn ')][1]">					
				<vcard:FN><xsl:call-template name="mf:extractText"/></vcard:FN>
			</xsl:for-each>
			
			<!-- (optional) :: multiple instances -->
			<xsl:for-each select="descendant::*[contains(concat(' ',normalize-space(@class),' '),' url ')]">					
				<xsl:variable name="url">
					<xsl:call-template name="mf:extractUrl"/>
				</xsl:variable>
				<vcard:URL rdf:resource="{$url}"/>
			</xsl:for-each>
			
			<!-- (optional) :: multiple instances -->
			<xsl:for-each select="descendant::*[contains(concat(' ',normalize-space(@class),' '),' photo ')]">					
				<vcard:PHOTO><xsl:call-template name="mf:extractUrl"/></vcard:PHOTO>
			</xsl:for-each>						

			<!-- (optional) :: multiple instances -->
			<xsl:for-each select="descendant::*[contains(concat(' ',normalize-space(@class),' '),' adr ')]">
				<xsl:call-template name="mf:extractAdr"/>
			</xsl:for-each>

			<!-- (optional) :: single instance -->
			<xsl:for-each select=".//*[ancestor-or-self::*[name() = 'del'] = false() and contains(concat(' ', @class, ' '),concat(' ', 'geo', ' '))][1]">
				<xsl:call-template name="mf:extractGeo"/>
			</xsl:for-each>
			
		</xsl:when>
		<xsl:otherwise>						
			<!-- (optional) :: multiple instances -->
			<xsl:for-each select="descendant::*[contains(concat(' ',normalize-space(@class),' '),' url ')]">					
				<dc:identifier><xsl:call-template name="mf:extractUrl"/></dc:identifier>
			</xsl:for-each>

			<!-- (optional) :: multiple instances -->
			<xsl:for-each select="descendant::*[contains(concat(' ',normalize-space(@class),' '),' photo ')]">					
				<dcterms:Image><xsl:call-template name="mf:extractUrl"/></dcterms:Image>
			</xsl:for-each>
		</xsl:otherwise>
	</xsl:choose>				
  </xsl:for-each>
			
  <!-- Review Date (optional) ISO Timestamp :: 1 instance -->
  <xsl:for-each select="descendant::*[contains(concat(' ',normalize-space(@class),' '),' dtreviewed ')][1]">
	<dc:date><xsl:call-template name="mf:extractDate"/></dc:date>
  </xsl:for-each>

  <!-- Rating and Rating scale (optional) :: 1 instance -->
  <xsl:for-each select="descendant::*[contains(concat(' ',normalize-space(@class),' '),' rating ')][1]">
	<review:rating><xsl:call-template name="mf:extractText"/></review:rating>
	<xsl:for-each select="descendant::*[contains(concat(' ',normalize-space(@class),' '),' best ')][1]">
		<review:maxRating><xsl:call-template name="mf:extractText"/></review:maxRating>
	</xsl:for-each>
  </xsl:for-each>

  <!-- Review Description (optional) :: 1 instance -->
  <xsl:for-each select="descendant::*[contains(concat(' ',normalize-space(@class),' '),' description ')][1]">
	<dc:description><xsl:call-template name="mf:extractText"/></dc:description>
  </xsl:for-each>

  <!-- Review Tags (optional) :: multiple instances -->
  <!-- http://www.holygoat.co.uk/owl/redwood/0.1/tags/tags.n3 -->

  <!-- Review Permalink (optional) :: 1 instance -->
  <xsl:for-each select="descendant::*[
	 (contains(concat(' ',normalize-space(@rel),' '),' bookmark ') and
	  contains(concat(' ',normalize-space(@rel),' '),' self '))
	][1]">
	<dc:identifier><xsl:call-template name="mf:extractUrl"/></dc:identifier>
  </xsl:for-each>

  <!-- Review License (optional) :: multiple instances -->
  <xsl:for-each select="descendant::*[contains(concat(' ',normalize-space(@rel),' '),' license ')][1]">
	<dc:license rdf:resource="{@href}" />
  </xsl:for-each>


  <!-- Reviewer (optional) :: 1 instance -->
  <xsl:for-each select="descendant::*[
	 (contains(concat(' ',normalize-space(@class),' '),' reviewer ') and
	  contains(concat(' ',normalize-space(@class),' '),' vcard '))
	][1]">
	<review:reviewer>
	  <!-- import a hCard2FoaF xslt and call that here -->
	  <foaf:Person>
		<xsl:for-each select="descendant::*[contains(concat(' ',normalize-space(@class),' '),' fn ')][1]">
			<foaf:name><xsl:call-template name="mf:extractText"/></foaf:name>
		</xsl:for-each>

		<xsl:for-each select="descendant::*[contains(concat(' ',normalize-space(@class),' '),' url ')]">
			<!-- need absolute URL -->
			<xsl:variable name="reviewerUrl">
				<xsl:call-template name="mf:extractUrl"/>
			</xsl:variable>
			<foaf:homepage rdf:resource="{$reviewerUrl}"/>
		</xsl:for-each>
	  </foaf:Person>
	</review:reviewer>
  </xsl:for-each>
</xsl:template>

<!-- output Address information -->
<xsl:template name="adrCallBack">
	<xsl:param name="type"/>
	<xsl:param name="post-office-box"/>
	<xsl:param name="street-address"/>
	<xsl:param name="extended-address"/>
	<xsl:param name="locality"/>
	<xsl:param name="region"/>
	<xsl:param name="country-name"/>
	<xsl:param name="postal-code"/>

	<vcard:ADR rdf:parseType="Resource">
		<xsl:if test="$street-address != ''"><vcard:Street><xsl:value-of select="$street-address"/></vcard:Street></xsl:if>
		<xsl:if test="$region != ''"><vcard:Region><xsl:value-of select="$region"/></vcard:Region></xsl:if>
		<xsl:if test="$locality != ''"><vcard:Locality><xsl:value-of select="$locality"/></vcard:Locality></xsl:if>
		<xsl:if test="$extended-address != ''"><vcard:Ext><xsl:value-of select="$extended-address"/></vcard:Ext></xsl:if>
		<xsl:if test="$country-name != ''"><vcard:Country><xsl:value-of select="$country-name"/></vcard:Country></xsl:if>
		<xsl:if test="$postal-code != ''"><vcard:Pcode><xsl:value-of select="$postal-code"/></vcard:Pcode></xsl:if>
	</vcard:ADR>		
</xsl:template>

<!-- output geo data -->
<xsl:template name="geoCallBack">
	<xsl:param name="latitude"/>
	<xsl:param name="longitude"/>
	
	<geo:long><xsl:value-of select="$longitude"/></geo:long>
	<geo:lat><xsl:value-of select="$latitude"/></geo:lat>
</xsl:template>
<!--
<xsl:template name="nCallBack">
	<xsl:param name="family-name"/>
	<xsl:param name="given-name"/>
	<xsl:param name="additional-name"/>
	<xsl:param name="honorific-prefix"/>
	<xsl:param name="honorific-suffix"/>

</xsl:template>

<xsl:template name="orgCallBack">
	<xsl:param name="organization-name"/>
	<xsl:param name="organization-unit"/>
	
</xsl:template>

<xsl:template name="uidCallBack">
	<xsl:param name="type"/>
	<xsl:param name="value"/>
	
</xsl:template>
-->
<!-- don't pass text thru -->
<xsl:template match="text()"></xsl:template>

</xsl:stylesheet>