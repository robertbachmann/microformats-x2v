<?xml version="1.0"?>
<xsl:stylesheet 
 xmlns:xsl ="http://www.w3.org/1999/XSL/Transform" 
 xmlns:uri  ="http://www.w3.org/2000/07/uri43/uri.xsl?template="
 version="1.0"
>

<xsl:import href="http://www.w3.org/2000/07/uri43/uri.xsl" />

<xsl:output
  encoding="UTF-8"
  indent="no"
  media-type="text/x-vcard"
  method="text"
/>

<xsl:param name="prodid" select='"-//connolly.w3.org//palmagent 0.6 (BETA)//EN"' />

<!-- by Dan Connolly; based on... -->

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

@@ check for profile in head element
@@ decode only the first instance of a singular property
-->

<!--Best Practices states this should be
    the URL the calendar was transformed from -->
<xsl:param name="Source" />

<xsl:param name="Anchor" />


<!-- check for profile in head element -->
<xsl:template match="head[contains(concat(' ', normalize-space(@profile), ' '),
		                   ' http://foorbar ')]">
<!-- 
==================== CURRENTLY DISABLED ====================
This will call the vCard template, 
Without the correct profile you cannot assume the class values are intended for the vCard microformat.
-->
<!-- <xsl:apply-templates select="//*[contains(@class,'vcard')]"/> -->
</xsl:template>


<!-- Each vCard is listed in succession -->
<xsl:template
    match="*[contains(concat(' ',normalize-space(@class),' '),' vcard ')]">

  <xsl:if test="not($Anchor) or @id = $Anchor">

    <xsl:text>BEGIN:VCARD</xsl:text>
    
    <xsl:text>&#x0A;PRODID:</xsl:text>
    <xsl:value-of select="$prodid" />
    
    <xsl:text>&#x0A;SOURCE: </xsl:text>
    <xsl:value-of select="$Source"/>

    <xsl:text>&#x0A;NAME: </xsl:text>
    <xsl:call-template name="escapeText">
      <xsl:with-param name="text-string"
		      select='normalize-space(//*[name()="title"])' />
    </xsl:call-template>
    
    <xsl:text>&#x0A;VERSION:3.0</xsl:text>
    
    <!--<xsl:apply-templates select="@id" mode="uid"/>-->
    

    <!--  Implied "N" Optimization -->
    <xsl:variable name="n-elt"
		  select=".//*[
      contains(concat(' ', normalize-space(@class), ' '),
               ' n ')]" />

    <xsl:call-template name="textProp">
      <xsl:with-param name="label">FN</xsl:with-param>
      <xsl:with-param name="class">fn</xsl:with-param>
      <xsl:with-param name="implied-n"
		      select="not($n-elt)" />
    </xsl:call-template>

    <xsl:for-each select=".//*[
			  contains(concat(' ', normalize-space(@class), ' '),
			  ' n ')]">
      <xsl:call-template name="n-prop" />
    </xsl:for-each>

    <xsl:call-template name="textProp">
      <xsl:with-param name="label">NICKNAME</xsl:with-param>
      <xsl:with-param name="class">nickname</xsl:with-param>
    </xsl:call-template>

    <xsl:call-template name="blobProp">
      <xsl:with-param name="label">PHOTO</xsl:with-param>
      <xsl:with-param name="class">photo</xsl:with-param>
    </xsl:call-template>

    <xsl:call-template name="textProp">
      <xsl:with-param name="label">BDAY</xsl:with-param>
      <xsl:with-param name="class">bday</xsl:with-param>
    </xsl:call-template>

    <xsl:for-each select=".//*[
			  contains(concat(' ', normalize-space(@class), ' '),
			  ' adr ')]">
      <xsl:call-template name="adr-prop" />
    </xsl:for-each>
    
    <!-- @@ type=dom,home,postal,parcel -->
    <xsl:call-template name="textProp">
      <xsl:with-param name="label">LABEL</xsl:with-param>
      <xsl:with-param name="class">label</xsl:with-param>
    </xsl:call-template>

    <xsl:call-template name="tel-prop"/>

    <xsl:call-template name="emailProp">
      <xsl:with-param name="label">EMAIL</xsl:with-param>
      <xsl:with-param name="class">email</xsl:with-param>
    </xsl:call-template>

    <xsl:call-template name="textProp">
      <xsl:with-param name="label">MAILER</xsl:with-param>
      <xsl:with-param name="class">mailer</xsl:with-param>
    </xsl:call-template>
    
    <xsl:call-template name="textProp">
      <xsl:with-param name="label">TZ</xsl:with-param>
      <xsl:with-param name="class">tz</xsl:with-param>
    </xsl:call-template>
    
    <xsl:call-template name="textProp">
      <!-- hmm... not really a text prop. not tested. -->
      <xsl:with-param name="label">GEO</xsl:with-param>
      <xsl:with-param name="class">geo</xsl:with-param>
    </xsl:call-template>
    
    <xsl:call-template name="textProp">
      <xsl:with-param name="label">TITLE</xsl:with-param>
      <xsl:with-param name="class">title</xsl:with-param>
    </xsl:call-template>
    
    <xsl:call-template name="textProp">
      <xsl:with-param name="label">ROLE</xsl:with-param>
      <xsl:with-param name="class">role</xsl:with-param>
    </xsl:call-template>
    
    <xsl:call-template name="blobProp">
      <xsl:with-param name="label">LOGO</xsl:with-param>
      <xsl:with-param name="class">logo</xsl:with-param>
    </xsl:call-template>

    <!-- @@agent not supported -->

    <!-- @@substructure of ORG not supported -->
    <xsl:call-template name="textProp">
      <xsl:with-param name="label">ORG</xsl:with-param>
      <xsl:with-param name="class">org</xsl:with-param>
    </xsl:call-template>
    
    <xsl:call-template name="textProp">
      <xsl:with-param name="label">CATEGORIES</xsl:with-param>
      <xsl:with-param name="class">categories</xsl:with-param>
    </xsl:call-template>
    
    <xsl:call-template name="textProp">
      <xsl:with-param name="label">NOTE</xsl:with-param>
      <xsl:with-param name="class">note</xsl:with-param>
    </xsl:call-template>
    
    <xsl:call-template name="textProp">
      <xsl:with-param name="label">REV</xsl:with-param>
      <xsl:with-param name="class">rev</xsl:with-param>
    </xsl:call-template>
    
    <xsl:call-template name="textProp">
      <xsl:with-param name="label">SORT-STRING</xsl:with-param>
      <xsl:with-param name="class">sort-string</xsl:with-param>
    </xsl:call-template>
    
    <!-- type=basic not supported. not tested -->
    <xsl:call-template name="blobProp">
      <xsl:with-param name="label">SOUND</xsl:with-param>
      <xsl:with-param name="class">sound</xsl:with-param>
    </xsl:call-template>

    <xsl:call-template name="refProp">
      <xsl:with-param name="label">URL</xsl:with-param>
      <xsl:with-param name="class">url</xsl:with-param>
    </xsl:call-template>

    <xsl:call-template name="textProp">
      <xsl:with-param name="label">CLASS</xsl:with-param>
      <xsl:with-param name="class">class</xsl:with-param>
    </xsl:call-template>

    <!-- @@TYPE=PGP, TYPE=X509, ENCODING=b -->
    <xsl:call-template name="textProp">
      <xsl:with-param name="label">KEY</xsl:with-param>
      <xsl:with-param name="class">key</xsl:with-param>
    </xsl:call-template>

    <xsl:text>&#x0A;END:VCARD&#x0A;</xsl:text>
  </xsl:if>
</xsl:template>




<xsl:template name="textProp">
  <xsl:param name="label" />
  <xsl:param name="class" />
  <xsl:param name="implied-n" />

  <xsl:for-each select=".//*[
			contains(concat(' ', @class, ' '),
			concat(' ', $class, ' '))]">

    <!-- @@ "the first descendant element with that class should take
         effect, any others being ignored." -->
    <xsl:text>&#x0A;</xsl:text>
    <xsl:value-of select="$label" />

    <xsl:call-template name="lang" />

    <xsl:text>:</xsl:text>

    <xsl:choose>
      <!-- @@this multiple values stuff doesn't seem to be in the spec
      -->
      <xsl:when test='local-name(.) = "ol" or local-name(.) = "ul"'>
	<xsl:for-each select="*">
	  <xsl:if test="not(position()=1)">
	    <xsl:text>,</xsl:text>
	  </xsl:if>

	  <xsl:call-template name="escapeText">
	    <xsl:with-param name="text-string" select="." />
	  </xsl:call-template>
	</xsl:for-each>
      </xsl:when>

      <xsl:when test='local-name(.) = "abbr" and @title'>
	<xsl:variable name="v"
		      select="normalize-space(@title)" />
	<xsl:call-template name="escapeText">
	  <xsl:with-param name="text-string" select="$v" />
	</xsl:call-template>
      </xsl:when>

      <xsl:otherwise>
	<xsl:variable name="v"
		      select="normalize-space(.)" />
	<xsl:call-template name="escapeText">
	  <xsl:with-param name="text-string" select="$v" />
	</xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>

    <xsl:if test="$implied-n">
      <xsl:call-template name="implied-n" />
    </xsl:if>

  </xsl:for-each>
</xsl:template>


<xsl:template name="tel-prop">
  <xsl:param name="label" />
  <xsl:param name="class" />

  <xsl:for-each select=".//*[
			contains(concat(' ', @class, ' '),
			' tel ')]">

    <!-- @@ "the first descendant element with that class should take
         effect, any others being ignored." -->
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
	<xsl:variable name="v"
		      select="normalize-space(@title)" />
	<xsl:call-template name="escapeText">
	  <xsl:with-param name="text-string" select="$v" />
	</xsl:call-template>
      </xsl:when>

      <xsl:otherwise>
	<xsl:variable name="v"
		      select="normalize-space(.)" />
	<xsl:call-template name="escapeText">
	  <xsl:with-param name="text-string" select="$v" />
	</xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>

  </xsl:for-each>
</xsl:template>


<xsl:template name="implied-n">
  <xsl:text>&#x0A;N</xsl:text>

  <xsl:call-template name="lang" />

  <xsl:text>:</xsl:text>

  <xsl:variable name="family-name">
    <xsl:value-of select='substring-after(normalize-space(.), " ")' />
  </xsl:variable>

  <xsl:variable name="given-name">
    <xsl:value-of select='substring-before(normalize-space(.), " ")' />
  </xsl:variable>

  <xsl:call-template name="escapeText">
    <xsl:with-param name="text-string" select="$family-name" />
  </xsl:call-template>
  <xsl:text>;</xsl:text>

  <xsl:call-template name="escapeText">
    <xsl:with-param name="text-string" select="$given-name" />
  </xsl:call-template>
  <xsl:text>;</xsl:text>

  <xsl:text>;;;</xsl:text>
</xsl:template>


<xsl:template name="lang">
  <xsl:variable name="langElt"
		select='ancestor-or-self::*[@xml:lang or @lang]' />
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
	  <xsl:message>where id lang and xml:lang go?!?!?
	  </xsl:message>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:text>;LANGUAGE=</xsl:text>
    <xsl:value-of select="$lang" />
  </xsl:if>
</xsl:template>


<xsl:template name="sub-prop">
  <xsl:param name="class" />

  <xsl:variable name="v1">
    <xsl:call-template name="class-value">
      <xsl:with-param name="class" select="$class" />
    </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="v"
		select="normalize-space($v1)" />
  <xsl:call-template name="escapeText">
    <xsl:with-param name="text-string" select="$v" />
  </xsl:call-template>
  <xsl:text>;</xsl:text>
</xsl:template>

<xsl:template name="find-types">
  <xsl:param name="list" /> <!-- e.g. "fax modem voice" -->
  <xsl:param name="found" />

  <xsl:variable name="first"
		select='substring-before(concat($list, " "), " ")' />
  <xsl:variable name="rest"
		select='substring-after($list, " ")' />

  <!-- look for first item in list -->
  <xsl:variable name="v">
    <xsl:call-template name="class-value">
      <xsl:with-param name="class" select='$first' />
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

<xsl:template name="class-value">
  <xsl:param name="class" />

  <xsl:value-of	select="descendant-or-self::*[
			contains(concat(' ', @class, ' '),
			concat(' ', $class, ' '))]" />
</xsl:template>


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


<xsl:template name="refProp">
  <xsl:param name="label" />
  <xsl:param name="class" />

  <xsl:for-each select=".//*[
			contains(concat(' ', @class, ' '),
			concat(' ', $class, ' '))]">
    <xsl:text>&#x0A;</xsl:text>
    <xsl:value-of select="$label" />

    <xsl:choose>
      <xsl:when test="@href">
	<xsl:text>:</xsl:text>
	<xsl:call-template name="escapeText">
	  <xsl:with-param name="text-string">
	    <xsl:call-template name="uri:expand">
	      <!-- @@ look for xml:base attr and/or <base> elt -->
	      <xsl:with-param name="base" select="$Source" />
	      <xsl:with-param name="there" select="@href" />
	    </xsl:call-template>
	  </xsl:with-param>
	</xsl:call-template>
      </xsl:when>

      <xsl:otherwise>
	<xsl:text>:</xsl:text>
	<xsl:call-template name="escapeText">
	  <xsl:with-param name="text-string" select="." />
	</xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:for-each>
</xsl:template>


<xsl:template name="blobProp">
  <xsl:param name="label" />
  <xsl:param name="class" />

  <xsl:for-each select=".//*[
			contains(concat(' ', @class, ' '),
			concat(' ', $class, ' '))]">
    <xsl:text>&#x0A;</xsl:text>
    <xsl:value-of select="$label" />

    <xsl:choose>
      <xsl:when test="@src">
	<xsl:text>;VALUE=uri:</xsl:text>
	<xsl:call-template name="escapeText">
	  <xsl:with-param name="text-string" select="@src" />
	</xsl:call-template>
      </xsl:when>

      <!-- hmm... href? -->

      <xsl:otherwise>
	<xsl:text>:</xsl:text>
	<xsl:call-template name="escapeText">
	  <xsl:with-param name="text-string" select="." />
	</xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:for-each>
</xsl:template>


<xsl:template name="emailProp">
  <xsl:param name="label" />
  <xsl:param name="class" />

  <xsl:for-each select=".//*[
			contains(concat(' ', @class, ' '),
			concat(' ', $class, ' '))]">
    <xsl:variable name="addr">
      <xsl:choose>
	<xsl:when test='@href and starts-with(@href, "mailto:")'>
	  <xsl:value-of select='substring-after(@href, ":")' />
	</xsl:when>

	<xsl:when test='@href'>
	  <xsl:value-of select='""' />
	</xsl:when>

	<xsl:otherwise>
	  <xsl:value-of select='.' />
	</xsl:otherwise>
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
	  <xsl:with-param name="text-string"
			  select='$addr' />
	</xsl:call-template>
      </xsl:when>

      <xsl:otherwise>
	<xsl:message>invalid email href: <xsl:value-of select="@href" />
	</xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:for-each>
</xsl:template>


<xsl:template name="escapeText">
  <xsl:param name="text-string"></xsl:param>
  <xsl:choose>
    <xsl:when test="substring-before($text-string,',') = true()">
      <xsl:value-of select="substring-before($text-string,',')"/>
      <xsl:text>\,</xsl:text>
      <xsl:call-template name="escapeText">
	<xsl:with-param name="text-string">
	  <xsl:value-of select="substring-after($text-string,',')"/>
	</xsl:with-param>
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$text-string"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>


<!-- don't pass text thru -->
<xsl:template match="text()" />
</xsl:stylesheet>
