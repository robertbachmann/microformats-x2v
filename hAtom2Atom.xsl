<!--
                                hAtom2Atom.xsl
   An XSLT stylesheet for transforming hAtom documents into Atom documents.

            $Id: hAtom2Atom.xsl 22 2006-02-06 22:06:43Z RobertBachmann $

                                    LICENSE

Copyright 2005 Luke Arno <http://lukearno.com/>
Copyright 2005-06 Robert Bachmann <http://rbach.priv.at/>
Copyright 2005-06 Benjamin Carlyle <http://soundadvice.id.au/>

This work is licensed under The W3C Open Source License
http://www.w3.org/Consortium/Legal/copyright-software-19980720

                              USAGE INSTRUCTIONS

To use this programme your XSLT engine must support the node-set()
extension function.
If your XSLT engine supports EXSLT it will most likely support node-set().
If you are using Microsoft's XML, .net's System.xml or Oracles XDK
you must change the value of xmlns:extension.
See the comment located bellow <xsl:transform> for instructions.

Your XHTML document must have the namespace "http://w3.org/1999/xhtml",
if it does not or if your input document is written in HTML, filter it
through "tidy -asxhtml" <http://tidy.sourceforge.net/> before
processing it with hAtom2Atom.xsl.

This stylesheet and the hAtom specification are still works in progress. 
Use it at your own risk! 
In all likelihood you will have to play around to get valid output.

                                     NOTES

Code sections which are extensions to the current hAtom draft are enclosed
by "[extension]" and "[/extension]".

                                   SEE ALSO

For the latest version of this stylesheet: 
    <http://rbach.priv.at/hAtom/>
    
Information about hAtom:
    <http://microformats.org/wiki/hatom>
    
Information about Atom:
    <http://www.ietf.org/rfc/rfc4287>

                               ACKNOWLEDGEMENTS

Structure of the multi-valued attribute selection trick taken from
Brian Suda's XHTML-2-iCal: 
    <http://suda.co.uk/projects/X2V/xhtml2vcal.xsl>

This work is based on hAtom2Atom.xsl version 0.0.6 from
    <http://lukearno.com/projects/hAtom/>

-->

<xsl:transform version="1.0"
               xmlns="http://www.w3.org/2005/Atom"
               xmlns:xhtml="http://www.w3.org/1999/xhtml"
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
               xmlns:extension="http://exslt.org/common"
               extension-element-prefixes="extension"
               exclude-result-prefixes="xhtml">
<!-- 
    node-set() for Microsoft's XML, .net's System.xml and Oracle's XDK


    Microsoft users should replace 
        xmlns:extension="http://exslt.org/common"
    with
        xmlns:extension="urn:schemas-microsoft-com:xslt"


    Oracle users should replace
        xmlns:extension="http://exslt.org/common"
    with
        xmlns:extension="http://www.oracle.com/XSL/Transform/java"
-->

<xsl:output method="xml" indent="yes"/>

<xsl:template match="node()|@*">
  <xsl:param name="where"/>
  <!-- By default, do nothing -->
  <xsl:apply-templates select="node()|@*">
    <xsl:with-param name="where" select="$where"/>
  </xsl:apply-templates>
</xsl:template>

<xsl:template match="/">
  <!--
  See if we can find feed elements within this document.
  Entries that are part of a feed are processed when we
  reach the feed element. If no feeds are found, the
  whole document is a feed.
  entry elements that do not occur within a feed when feed
  elements are present are ignored. (TODO: Check, is this valid?)
  Use modes throughout to determine context. Are we
  * outside a feed (none),
  * inside a feed (feed), or
  * inside an entry (entry)?
  -->
  <xsl:choose>
    <xsl:when test="descendant::xhtml:*[contains(concat(' ',normalize-space(@class),' '),' hfeed ')]">
      <xsl:for-each select="descendant::xhtml:*[contains(concat(' ',normalize-space(@class),' '),' hfeed ')][1]">
        <xsl:apply-templates select="."/>
      </xsl:for-each>
    </xsl:when>
    <xsl:otherwise>
      <xsl:call-template name="feed"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="feed" match="xhtml:*[contains(concat(' ',normalize-space(@class),' '),' hfeed ')]">
  <feed>
    <!--[extension]--> 
      <xsl:apply-templates select="." mode="get-lang" />
      <xsl:apply-templates select="." mode="get-base">
        <xsl:with-param name="for-feed" select="true()" />
      </xsl:apply-templates>
    <!--[/extension]--> 
    
    <!-- TODO: add required id and updated elements -->
    
    <xsl:variable name="feedLevelElements">
      <xsl:call-template name="feed-level-elements"/>
    </xsl:variable>
    
    <!--    Extract feed title    -->
    
    <!--[extension]--> 
      <xsl:variable name="classTitles"
        select="extension:node-set($feedLevelElements)/descendant-or-self::xhtml:*[contains(concat(' ',normalize-space(@class),' '),' title ')]"
        />
      <xsl:variable name="headerTitles"
        select="extension:node-set($feedLevelElements)/descendant-or-self::xhtml:h1|extension:node-set($feedLevelElements)/descendant-or-self::xhtml:h2|extension:node-set($feedLevelElements)/descendant-or-self::xhtml:h3|extension:node-set($feedLevelElements)/descendant-or-self::xhtml:h4|extension:node-set($feedLevelElements)/descendant-or-self::xhtml:h5|extension:node-set($feedLevelElements)/descendant-or-self::xhtml:h6"
        />
    
      <xsl:choose>
        <xsl:when test="$classTitles">
          <xsl:for-each select="$classTitles[1]">
            <title><xsl:call-template name="text-value-of"/></title>
          </xsl:for-each>
        </xsl:when>
        <xsl:when test="$headerTitles">
          <xsl:for-each select="$headerTitles[1]">
            <title><xsl:call-template name="text-value-of"/></title>
          </xsl:for-each>
        </xsl:when>
        <xsl:otherwise>
          <!--ERROR: A feed must have a title -->
          <title/>
        </xsl:otherwise>
      </xsl:choose>
    <!--[/extension]--> 
    
    <xsl:apply-templates select="node()|@*">
      <xsl:with-param name="where">feed</xsl:with-param>
    </xsl:apply-templates>
  </feed>
</xsl:template>

<xsl:template match="xhtml:*[contains(concat(' ',normalize-space(@class),' '),' hentry ')]">
  <xsl:param name="where"/>
  <xsl:if test="$where = 'feed'">
    <entry>
      <!--[extension]-->
        <xsl:apply-templates select="." mode="get-lang">
          <xsl:with-param name="end" select="'hfeed'" />
        </xsl:apply-templates>
        <xsl:apply-templates select="." mode="get-base">
          <xsl:with-param name="end" select="'hfeed'" />
        </xsl:apply-templates>
      <!--[/extension]-->

      <!--  Manually deal with the title attribute -->

      <xsl:variable name="entryLevelElements">
        <xsl:call-template name="entry-level-elements"/>
      </xsl:variable>

      <xsl:variable name="classTitles"
        select="extension:node-set($entryLevelElements)/descendant-or-self::xhtml:*[contains(concat(' ',normalize-space(@class),' '),' headline ')]"
      />

      <xsl:variable name="headerTitles"
        select="extension:node-set($entryLevelElements)/descendant-or-self::xhtml:h1|extension:node-set($entryLevelElements)/descendant-or-self::xhtml:h2|extension:node-set($entryLevelElements)/descendant-or-self::xhtml:h3|extension:node-set($entryLevelElements)/descendant-or-self::xhtml:h4|extension:node-set($entryLevelElements)/descendant-or-self::xhtml:h5|extension:node-set($entryLevelElements)/descendant-or-self::xhtml:h6"
      />

      <xsl:choose>
        <xsl:when test="$classTitles">
          <xsl:for-each select="$classTitles[1]">
            <title><xsl:call-template name="text-value-of"/></title>
          </xsl:for-each>
        </xsl:when>
        <xsl:when test="$headerTitles">
          <xsl:for-each select="$headerTitles[1]">
            <title><xsl:call-template name="text-value-of"/></title>
          </xsl:for-each>
        </xsl:when>
        <xsl:otherwise><title/></xsl:otherwise>
      </xsl:choose>

      <xsl:apply-templates select="node()|@*">
        <xsl:with-param name="where">entry</xsl:with-param>
      </xsl:apply-templates>
    </entry>
  </xsl:if>
</xsl:template>

<xsl:template match="xhtml:a[contains(concat(' ',normalize-space(translate(@rel,'BOKMAR','bokmar')),' '),' bookmark ')]">
  <xsl:param name="where"/>
  <xsl:if test="$where = 'entry'">
    
    <!-- TODO: Make @href absolute -->
    <id><xsl:value-of select="@href"/></id>
    
    <link rel="alternate">
      <!-- X --><xsl:apply-templates select="." mode="get-base">
        <xsl:with-param name="end" select="'hentry'" />
      </xsl:apply-templates>
      <!-- X --><xsl:apply-templates select="." mode="get-lang">
        <xsl:with-param name="end" select="'hentry'" />
      </xsl:apply-templates>
      <xsl:for-each select="@href|@type|@hreflang|@title|@length">
        <xsl:copy/>
      </xsl:for-each>
      <xsl:if test="not(@type)">
        <xsl:attribute name="type">text/html</xsl:attribute>
      </xsl:if>
    </link>
    
  </xsl:if>
</xsl:template>

<xsl:template match="xhtml:*[contains(concat(' ',normalize-space(@class),' '),' updated ')]">
  <updated><xsl:call-template name="text-value-of"/></updated>
</xsl:template>

<xsl:template match="xhtml:*[contains(concat(' ',normalize-space(@class),' '),' published ')]">
  <published><xsl:call-template name="text-value-of"/></published>
</xsl:template>

<!-- FIX: Implement concatenation rules as specified in hAtom -->
<xsl:template match="xhtml:*[contains(concat(' ',normalize-space(@class),' '),' content ')]">
  <xsl:param name="where"/>
  <xsl:if test="$where = 'entry'">
    <content type="xhtml">
      <!--[extension]-->
        <xsl:apply-templates select="." mode="get-lang">
          <xsl:with-param name="end" select="'hentry'" />
        </xsl:apply-templates>
        <xsl:apply-templates select="." mode="get-base">
          <xsl:with-param name="end" select="'hentry'" />
        </xsl:apply-templates>
      <!--[/extension]-->
      <div xmlns="http://www.w3.org/1999/xhtml">
        <xsl:copy-of select="child::*|text()" />
      </div>
    </content>
  </xsl:if>
</xsl:template>

<!-- FIX: Implement concatenation rules as specified in hAtom -->
<!-- FIX: Change class="summary" to class="excerpt" -->
<xsl:template match="xhtml:*[contains(concat(' ',normalize-space(@class),' '),' summary ')]">
  <xsl:param name="where"/>
  <xsl:if test="$where = 'entry'">
    <summary type="xhtml">
      <!--[extension]-->
        <xsl:apply-templates select="." mode="get-lang">
          <xsl:with-param name="end" select="'hentry'" />
        </xsl:apply-templates>
        <xsl:apply-templates select="." mode="get-base">
          <xsl:with-param name="end" select="'hentry'" />
        </xsl:apply-templates>
      <!--[/extension]-->
      <div xmlns="http://www.w3.org/1999/xhtml">
        <xsl:copy-of select="child::*|text()" />
      </div>
    </summary>
  </xsl:if>
</xsl:template>

<!-- 
    Named templates for value extraction
-->

<xsl:template name="value-of">
  <xsl:param name="context" select="."/>
  <xsl:choose>
    <xsl:when test="name($context)='abbr'">
      <xsl:value-of select="normalize-space($context/@title)"/>
    </xsl:when>
    <xsl:when test="$context/xhtml:*[contains(concat(' ',normalize-space(@class),' '),' value ')]">
      <xsl:value-of select="normalize-space($context/xhtml:*[contains(concat(' ',normalize-space(@class),' '),' value ')])"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="normalize-space($context)"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="text-value-of">
  <xsl:param name="context" select="."/>
  <xsl:choose>
    <xsl:when test="name($context) = 'img' and $context/@alt">
      <xsl:value-of select="normalize-space($context/@alt)"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:call-template name="value-of">
        <xsl:with-param name="context" select="$context"/>
      </xsl:call-template>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="uri-value-of">
  <xsl:param name="context" select="."/>
  <xsl:choose>
    <xsl:when test="name($context) = 'a' and $context/@href">
      <xsl:value-of select="normalize-space($context/@href)"/>
    </xsl:when>
    <xsl:when test="name($context) = 'img' and $context/@src">
      <xsl:value-of select="normalize-space($context/@src)"/>
    </xsl:when>
    <xsl:when test="name($context) = 'object' and $context/@data">
      <xsl:value-of select="normalize-space($context/@data)"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:call-template name="value-of">
        <xsl:with-param name="context" select="$context"/>
      </xsl:call-template>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="email-value-of">
  <xsl:param name="context" select="."/>
  <xsl:choose>
    <xsl:when test="name($context) = 'a' and starts-with($context/@href,'mailto:')">
      <xsl:choose>
      <xsl:when test="contains($context/@href,'?')">
        <xsl:value-of select="
          substring-before(substring-after($context/@href,'mailto:'), '?')"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="substring-after($context/@href,'mailto:')"/>
      </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:otherwise>
      <xsl:call-template name="text-value-of">
        <xsl:with-param name="context" select="$context"/>
      </xsl:call-template>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- 
      "Filter" templates for dealing with hAtom's opacity rules
-->

<xsl:template name="feed-level-elements">
  <xsl:choose> 
    <xsl:when test="contains(concat(' ',normalize-space(@class),' '),' hentry ')"/>
    <xsl:otherwise>
      <xsl:copy>
        <xsl:for-each select="@*|node()">
          <xsl:call-template name="feed-level-elements"/>
        </xsl:for-each>
      </xsl:copy>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="entry-level-elements">
  <xsl:choose>
    <!-- ignore these elements -->
    <xsl:when test="contains(concat(' ',normalize-space(@class),' '),' content ')"/>
    <xsl:when test="contains(concat(' ',normalize-space(@class),' '),' summary ')"/>
    <xsl:when test="contains(concat(' ',normalize-space(@class),' '),' author ')"/>
    <!--FIX: "contributor" was removed from the hAtom specification -->
    <xsl:when test="contains(concat(' ',normalize-space(@class),' '),' contributor ')"/>
    <xsl:otherwise>
      <xsl:copy>
        <xsl:for-each select="@*|node()">
          <xsl:call-template name="entry-level-elements"/>
        </xsl:for-each>
      </xsl:copy>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="vcard">
  <name>
    <!--[extension]-->
      <!-- FIX: xml:lang not allowed for <name> -->
      <xsl:apply-templates select="descendant-or-self::*[contains(concat(' ',normalize-space(@class),' '),' fn ')]" mode="get-lang">
        <xsl:with-param name="end" select="'hentry'" />
      </xsl:apply-templates>
    <!--[/extension]-->
    <xsl:value-of select="normalize-space(descendant-or-self::*[contains(concat(' ',normalize-space(@class),' '),' fn ')])"/>
  </name>
  <!-- FIX: need to use absolute URI here because xml:base is not allowed for <uri> -->
  <xsl:choose>
    <xsl:when test="descendant-or-self::xhtml:a[contains(concat(' ',normalize-space(@class),' '),' url ')]">
      <uri>
        <!--[extension]-->
          <!-- FIX: xml:base not allowed for <uri> -->
          <xsl:apply-templates select="descendant-or-self::xhtml:a[contains(concat(' ',normalize-space(@class),' '),' url ')]" mode="get-base">
            <xsl:with-param name="end" select="'hentry'" />
          </xsl:apply-templates>
          <xsl:value-of select="descendant-or-self::xhtml:a[contains(concat(' ',normalize-space(@class),' '),' url ')]/@href"/>
        <!--[/extension]-->
      </uri>
    </xsl:when>
    <xsl:when test="descendant-or-self::*[contains(concat(' ',normalize-space(@class),' '),' url ')]">
      <uri>
        <!--[extension]-->
          <!-- FIX: xml:base not allowed for <uri> -->
            <xsl:apply-templates select="descendant-or-self::*[contains(concat(' ',normalize-space(@class),' '),' url ')]" mode="get-base">
              <xsl:with-param name="end" select="'hentry'" />
            </xsl:apply-templates>
         <!--[/extension]-->
         <xsl:value-of select="descendant-or-self::*[contains(concat(' ',normalize-space(@class),' '),' url ')]"/>
      </uri>
    </xsl:when>
  </xsl:choose>
  <xsl:if test="descendant-or-self::*[contains(concat(' ',normalize-space(@class),' '),' email ')]">
    <email>
      <xsl:call-template name="email-value-of">
        <xsl:with-param name="context" select="descendant-or-self::*[contains(concat(' ',normalize-space(@class),' '),' email ')][1]"/>
      </xsl:call-template>
    </email>
  </xsl:if>
</xsl:template>

<xsl:template name="author" match="xhtml:*[contains(concat(' ',normalize-space(@class),' '),' author ')]">
  <xsl:choose>
  <xsl:when test="descendant-or-self::xhtml:*[contains(concat(' ',normalize-space(@class),' '),' vcard ')]">
    <xsl:for-each select="descendant-or-self::xhtml:*[contains(concat(' ',normalize-space(@class),' '),' vcard ')]">
      <author><xsl:call-template name="vcard"/></author>
    </xsl:for-each>
  </xsl:when>
  <xsl:otherwise>
    <author><name><xsl:call-template name="text-value-of"/></name></author>
  </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- FIX: "contributor" was removed from the hAtom specification -->
<xsl:template match="xhtml:*[contains(concat(' ',normalize-space(@class),' '),' contributor ')]">
  <xsl:choose>
  <xsl:when test="descendant-or-self::xhtml:*[contains(concat(' ',normalize-space(@class),' '),' vcard ')]">
    <xsl:for-each select="descendant-or-self::xhtml:*[contains(concat(' ',normalize-space(@class),' '),' vcard ')]">
      <contributor><xsl:call-template name="vcard"/></contributor>
    </xsl:for-each>
  </xsl:when>
  <xsl:otherwise>
    <contributor><name><xsl:call-template name="text-value-of"/></name></contributor>
  </xsl:otherwise>
  </xsl:choose>
</xsl:template>


<!--                      
      Templates for handling rel-tag
-->
<!--[extension]-->
<xsl:template match="xhtml:a[contains(concat(' ',normalize-space(translate(@rel,'TAG','tag')),' '),' tag ')]">
  <category>
    <xsl:attribute name="term">
      <xsl:call-template name="extract-tag">
        <xsl:with-param name="in" select="@href"/>
      </xsl:call-template>
    </xsl:attribute>
    <xsl:attribute name="label"><xsl:value-of select="."/></xsl:attribute>
  </category>
</xsl:template>

<xsl:template name="extract-tag">
  <xsl:param name="in"/>
  <xsl:param name="out"/>
  <xsl:choose>
    <xsl:when test="string-length($in) = 0">
      <xsl:value-of select="$out"/>
    </xsl:when>
    <xsl:when test="substring($in,1,1) = '/'">
      <xsl:call-template name="extract-tag">
        <xsl:with-param name="in" select="substring($in,2)"/>
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
      <xsl:call-template name="extract-tag">
        <xsl:with-param name="in" select="substring($in,2)"/>
        <xsl:with-param name="out" select="concat($out,substring($in,1,1))"/>
      </xsl:call-template>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>
<!--[/extension]-->


<!-- 
  Walk the tree upwards to find
  a suitable xml:lang.
  TODO: If no one was found and $for-feed is true try to
  use the $source-lang stylesheet parameter.
-->
<xsl:template match="xhtml:*" mode="get-lang">
  <xsl:param name="end" />
  <xsl:choose>
    <xsl:when test="@xml:lang">
      <xsl:attribute name="xml:lang"><xsl:value-of select="@xml:lang" /></xsl:attribute>
    </xsl:when> 
    <xsl:when test="@lang">
      <xsl:attribute name="xml:lang"><xsl:value-of select="@lang" /></xsl:attribute>
    </xsl:when>
    <xsl:when test="not($end='')">
      <xsl:if test="not(contains(concat(' ',normalize-space(@class),' '), concat(' ',$end,' ')))">
        <xsl:apply-templates mode="get-lang" select="parent::*">
          <xsl:with-param name="end" select="$end" />
        </xsl:apply-templates>
      </xsl:if>
    </xsl:when>
    <xsl:otherwise>
      <xsl:apply-templates mode="get-lang" select="parent::*">
        <xsl:with-param name="end" select="$end" />
      </xsl:apply-templates>    
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- 
  Walk the tree upwards to find
  a suitable xml:base.
  If none is found and $for-feed = true()
  try to use HTML's <base>.
  TODO: If no HTML <base> is present try to use
  use the $source-base stylesheet parameter.
-->
<xsl:template match="xhtml:*" mode="get-base">
  <xsl:param name="for-feed" />
  <xsl:param name="end" />
  <xsl:choose>
    <xsl:when test="@xml:base">
      <xsl:attribute name="xml:base"><xsl:value-of select="@xml:base" /></xsl:attribute>
    </xsl:when> 
    <!-- 
      Are we trying to find the xml:base for <feed>
      and are we already at the root element?
    -->
    <xsl:when test="local-name(.)='html' and $for-feed">
      <!-- Try to use HTML's <base> -->
      <xsl:choose>
        <xsl:when test="/xhtml:html/xhtml:head/xhtml:base[@href]">
          <xsl:attribute name="xml:base">
            <xsl:value-of select="/xhtml:html/xhtml:head/xhtml:base/@href" />
          </xsl:attribute>
        </xsl:when>    
        <xsl:otherwise>
          <!-- TODO: Use $source-uri param -->
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:when test="not($end='')">
      <xsl:if test="not(contains(concat(' ',normalize-space(@class),' '), concat(' ',$end,' ')))">
        <xsl:apply-templates mode="get-base" select="parent::*">
          <xsl:with-param name="end" select="$end" />
          <xsl:with-param name="for-feed" select="$for-feed" />
        </xsl:apply-templates>
      </xsl:if>
    </xsl:when>
    <xsl:otherwise>
      <xsl:apply-templates mode="get-base" select="parent::*">
        <xsl:with-param name="end" select="$end" />
        <xsl:with-param name="for-feed" select="$for-feed" />
      </xsl:apply-templates>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

</xsl:transform>

