<!--
                                hAtom2Atom.xsl
   An XSLT stylesheet for transforming hAtom documents into Atom documents.

            $Id: hAtom2Atom.xsl 35 2006-03-22 21:10:35Z RobertBachmann $

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

Your XHTML document must have the namespace "http://www.w3.org/1999/xhtml",
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
               xmlns:str="http://exslt.org/strings"
               xmlns:uri ="http://www.w3.org/2000/07/uri43/uri.xsl?template="
               extension-element-prefixes="extension str"
               exclude-result-prefixes="xhtml uri">
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


<!-- Downloaded from http://www.w3.org/2000/07/uri43/uri.xsl -->
<xsl:import href="uri.xsl" />

<xsl:param name="source-uri" />
<xsl:param name="content-type">text/html</xsl:param>

<xsl:output method="xml" indent="yes" encoding="UTF-8" />

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
    <xsl:variable name="feed-base">
      <xsl:apply-templates select="." mode="get-base">
        <xsl:with-param name="fallback" select="/xhtml:html/xhtml:head/xhtml:base[1]/@href" />
      </xsl:apply-templates>
    </xsl:variable>    

    <!--[extension]--> 
      <xsl:apply-templates select="." mode="add-lang-attribute" />
      <xsl:apply-templates select="." mode="add-base-attribute">
        <xsl:with-param name="for-feed" select="true()" />
      </xsl:apply-templates>
    <!--[/extension]--> 
    

    <xsl:variable name="feedLevelElements">
      <xsl:call-template name="feed-level-elements"/>
    </xsl:variable>

    <!-- Extract feed updated -->    
    <!--[extension]-->
      <updated>
        <xsl:choose >
          <!-- Try to use the first element with class="updated" at the feed level -->
          <xsl:when test="extension:node-set($feedLevelElements)/descendant::xhtml:*[contains(concat(' ',normalize-space(@class),' '),' updated ')]">
            <xsl:for-each select="extension:node-set($feedLevelElements)/descendant::xhtml:*[contains(concat(' ',normalize-space(@class),' '),' updated ')][1]">
              <xsl:call-template name="text-value-of" />
            </xsl:for-each>
          </xsl:when>
          <!-- TODO: When there is no element with class="updated" at the feed level 
               We might want to try to use the element from the entry level
               with the greatest (newest) date-time 
          -->
          <xsl:otherwise>
            <!--ERROR: <updated> is required for feed -->
          </xsl:otherwise>
        </xsl:choose>
      </updated>
    <!--[/extension]-->    

    <!-- Extract feed id and link -->
    <!--[extension]-->
      <xsl:choose>
        <!-- If there is an element with class="bookmark" at the feed level use it -->
        <xsl:when test="extension:node-set($feedLevelElements)/descendant::xhtml:a[
            contains(concat(' ',normalize-space(translate(@rel,'BOKMAR','bokmar')),' '),' bookmark ')
            ][1]">
          <xsl:variable name="uri">
            <xsl:call-template name="uri:expand">
              <xsl:with-param name="base">
                <xsl:apply-templates select="extension:node-set($feedLevelElements)/descendant::xhtml:a[
                    contains(concat(' ',normalize-space(translate(@rel,'BOKMAR','bokmar')),' '),' bookmark ')][1]" 
                    mode="get-base">
                   <xsl:with-param name="fallback" select="$feed-base" />
                 </xsl:apply-templates>
               </xsl:with-param>
               <xsl:with-param name="there">
                 <xsl:value-of select="extension:node-set($feedLevelElements)/descendant::xhtml:a[
                   contains(concat(' ',normalize-space(translate(@rel,'BOKMAR','bokmar')),' '),' bookmark ')
                 ][1]/@href" />
               </xsl:with-param>
             </xsl:call-template>
          </xsl:variable>
          <id><xsl:value-of select="$uri" /></id>
          <link rel="alternate" href="{$uri}">
            <xsl:for-each select="extension:node-set($feedLevelElements)/descendant::xhtml:a[
              contains(concat(' ',normalize-space(translate(@rel,'BOKMAR','bokmar')),' '),' bookmark ')][1]">
              <xsl:for-each select="@type|@hreflang|@title|@length">
                <xsl:copy />
              </xsl:for-each>
              <xsl:if test="not(@type)">
                <xsl:attribute name="type"><xsl:value-of select="$content-type" /></xsl:attribute>
              </xsl:if>
            </xsl:for-each>
          </link>
        </xsl:when>
        <!-- If the feed has an ID attribute use it thogether with $source-uri -->
        <xsl:when test="@id">
          <xsl:variable name="uri" select="concat($source-uri,'#',@id)"/>
          <id><xsl:value-of select="$uri"/></id>
          <link rel="alternate" href="{$uri}" type="{$content-type}"/>
        </xsl:when>
        <!-- Use the $source-uri of the feed -->
        <xsl:otherwise>
          <xsl:variable name="uri" select="$source-uri"/>
          <id><xsl:value-of select="$uri"/></id>
          <link rel="alternate" href="{$uri}" type="{$content-type}"/>
        </xsl:otherwise>
      </xsl:choose>
    <!--[/extension]-->
    
    <!-- Extract feed title    -->
    
    <!--[extension]--> 
      <!-- Try to find an element with class="feed-title" -->
      <xsl:variable name="classTitles"
        select="extension:node-set($feedLevelElements)/descendant-or-self::xhtml:*[contains(concat(' ',normalize-space(@class),' '),' feed-title ')]"
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
    
    <!-- Extract feed's tags -->
    <xsl:for-each select="extension:node-set($feedLevelElements)/descendant::xhtml:a[contains(concat(' ',normalize-space(translate(@rel,'TAG','tag')),' '),' tag ')]">
      <xsl:call-template name="create-category" />
    </xsl:for-each>
    
    <xsl:apply-templates select="node()|@*">
      <xsl:with-param name="where">feed</xsl:with-param>
    </xsl:apply-templates>
  </feed>
</xsl:template>

<xsl:template match="xhtml:*[contains(concat(' ',normalize-space(@class),' '),' hentry ')]">
  <xsl:param name="where"/>
  <xsl:if test="$where = 'feed'">
  <xsl:variable name="entry-base">
    <xsl:apply-templates select="." mode="get-base">
      <xsl:with-param name="fallback" select="/xhtml:html/xhtml:head/xhtml:base[1]/@href" />
    </xsl:apply-templates>
  </xsl:variable>
    <entry>
      <!--[extension]-->
        <xsl:apply-templates select="." mode="add-lang-attribute">
          <xsl:with-param name="end" select="'hfeed'" />
        </xsl:apply-templates>
        <xsl:apply-templates select="." mode="add-base-attribute">
          <xsl:with-param name="end" select="'hfeed'" />
        </xsl:apply-templates>
      <!--[/extension]-->

      <!--  Manually deal with the title attribute -->

      <xsl:variable name="entryLevelElements">
        <xsl:call-template name="entry-level-elements"/>
      </xsl:variable>

      <xsl:variable name="classTitles"
        select="extension:node-set($entryLevelElements)/descendant-or-self::xhtml:*[contains(concat(' ',normalize-space(@class),' '),' entry-title ')]"
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

      <!--  Manually deal with the "id" and the "link" element -->
      <xsl:choose>
        <xsl:when test="extension:node-set($entryLevelElements)/descendant::xhtml:a[contains(concat(' ',normalize-space(translate(@rel,'BOKMAR','bokmar')),' '),' bookmark ')]">
          <!-- Convert to absolute URI -->
          <xsl:variable name="uri">
            <xsl:call-template name="uri:expand">
              <xsl:with-param name="base">
                <xsl:apply-templates select="extension:node-set($entryLevelElements)/descendant::xhtml:a[
                  contains(concat(' ',normalize-space(translate(@rel,'BOKMAR','bokmar')),' '),' bookmark ')][1]" 
                  mode="get-base">
                  <xsl:with-param name="fallback" select="$entry-base" />
                </xsl:apply-templates>
              </xsl:with-param>
              <xsl:with-param name="there">
                <xsl:value-of select="extension:node-set($entryLevelElements)/descendant::xhtml:a[
                  contains(concat(' ',normalize-space(translate(@rel,'BOKMAR','bokmar')),' '),' bookmark ')
                  ][1]/@href" />
              </xsl:with-param>
            </xsl:call-template>
          </xsl:variable>
          <id><xsl:value-of select="$uri" /></id>
          <link rel="alternate" href="{$uri}">
            <xsl:for-each select="extension:node-set($entryLevelElements)/descendant::xhtml:a[
            contains(concat(' ',normalize-space(translate(@rel,'BOKMAR','bokmar')),' '),' bookmark ')][1]
            ">
              <xsl:for-each select="@type|@hreflang|@title|@length">
                <xsl:copy />
              </xsl:for-each>
              <xsl:if test="not(@type)">
                <xsl:attribute name="type"><xsl:value-of select="$content-type" /></xsl:attribute>
              </xsl:if>
            </xsl:for-each>
          </link>
        </xsl:when>
      <!--[extension]-->
        <!-- Try to use the entry's id attribute as ID -->
        <xsl:when test="@id != ''">
          <id>
            <!-- Convert to absolute URI -->
            <xsl:call-template name="uri:expand">
              <xsl:with-param name="base" select="$entry-base" />
              <xsl:with-param name="there" select="concat('#',@id)" />
            </xsl:call-template>
          </id>
        </xsl:when>
        <!-- Try to use the entry's name attribute as ID -->
        <xsl:when test="@name != ''">
          <id>
            <!-- Convert to absolute URI -->
            <xsl:call-template name="uri:expand">
              <xsl:with-param name="base" select="$entry-base" />
              <xsl:with-param name="there" select="concat('#',@name)" />
            </xsl:call-template>
          </id>
        </xsl:when>
      <!--[/extension]-->
        <xsl:otherwise>
          <!--ERROR: <id> is mandatory -->
          <id/>
        </xsl:otherwise>
      </xsl:choose>


      <!--  Manually deal with the "published" element -->
      <xsl:if test="extension:node-set($entryLevelElements)/descendant::xhtml:*[contains(concat(' ',normalize-space(@class),' '),' published ')]">
        <published>
          <!-- 
            Use the value of the 
            first element with class="published" 
            as per hAtom specification 
          -->
          <xsl:for-each select="extension:node-set($entryLevelElements)/descendant::xhtml:*[contains(concat(' ',normalize-space(@class),' '),' published ')][1]">
            <xsl:call-template name="text-value-of" />
          </xsl:for-each>
        </published>
      </xsl:if>

      <!--  Manually deal with the "updated" element -->
      <updated>
        <xsl:choose>
          <xsl:when test="extension:node-set($entryLevelElements)/descendant::xhtml:*[contains(concat(' ',normalize-space(@class),' '),' updated ')]">
            <!-- 
              Use the value of the 
              first element with class="updated" 
              as per hAtom specification 
            -->
            <xsl:for-each select="extension:node-set($entryLevelElements)/descendant::xhtml:*[contains(concat(' ',normalize-space(@class),' '),' updated ')][1]">
              <xsl:call-template name="text-value-of" />
            </xsl:for-each>
          </xsl:when>
          <!-- If no "updated" is present use the value of the first "published" -->
          <xsl:when test="extension:node-set($entryLevelElements)/descendant::xhtml:*[contains(concat(' ',normalize-space(@class),' '),' published ')]">
            <xsl:for-each select="extension:node-set($entryLevelElements)/descendant::xhtml:*[contains(concat(' ',normalize-space(@class),' '),' published ')][1]">
              <xsl:call-template name="text-value-of" />
            </xsl:for-each>
          </xsl:when>
          <xsl:otherwise>
            <!--ERROR: <updated> is mandatory -->
          </xsl:otherwise>
        </xsl:choose>
      </updated>

      <xsl:if test="extension:node-set($entryLevelElements)/descendant::xhtml:*[contains(concat(' ',normalize-space(@class),' '),' entry-summary ')]">
        <summary type="xhtml">
          <!--[extension]-->
            <!-- Only xml:lang and xml:base of the first element with class="summary" will be picked up.
                 This may lead to unexpected results!
            -->
            <xsl:apply-templates select="extension:node-set($entryLevelElements)/descendant::xhtml:*[contains(concat(' ',normalize-space(@class),' '),' entry-summary ')][1]" mode="add-lang-attribute">
              <xsl:with-param name="end" select="'hentry'" />
            </xsl:apply-templates>
            <xsl:apply-templates select="extension:node-set($entryLevelElements)/descendant::xhtml:*[contains(concat(' ',normalize-space(@class),' '),'  ')][1]" mode="add-base-attribute">
              <xsl:with-param name="end" select="'hentry'" />
            </xsl:apply-templates>
          <!--[/extension]-->
          <div xmlns="http://www.w3.org/1999/xhtml">
            <xsl:variable name="entryLevelElements_w_summary">
              <xsl:call-template name="entry-level-elements">
                <xsl:with-param name="deep-copy">entry-summary</xsl:with-param>
              </xsl:call-template>
            </xsl:variable>
            <xsl:for-each select="extension:node-set($entryLevelElements_w_summary)/descendant::xhtml:*[contains(concat(' ',normalize-space(@class),' '),' entry-summary ')]">
              <xsl:variable name="inside-q">
                <xsl:apply-templates mode="is-in-q" select="." />
              </xsl:variable>
              <xsl:if test="$inside-q = 'no'">
                <xsl:copy-of select="child::*|text()" />
              </xsl:if>
            </xsl:for-each>
          </div>
        </summary>
      </xsl:if>

      <xsl:if test="extension:node-set($entryLevelElements)/descendant::xhtml:*[contains(concat(' ',normalize-space(@class),' '),' entry-content ')]">
        <content type="xhtml">
          <!--[extension]-->
            <!-- Only xml:lang and xml:base of the first element with class="content" will be picked up.
                 This may lead to unexpected results!
            -->
            <xsl:apply-templates select="extension:node-set($entryLevelElements)/descendant::xhtml:*[contains(concat(' ',normalize-space(@class),' '),' entry-content ')][1]" mode="add-lang-attribute">
              <xsl:with-param name="end" select="'hentry'" />
            </xsl:apply-templates>
            <xsl:apply-templates select="extension:node-set($entryLevelElements)/descendant::xhtml:*[contains(concat(' ',normalize-space(@class),' '),'  ')][1]" mode="add-base-attribute">
              <xsl:with-param name="end" select="'hentry'" />
            </xsl:apply-templates>
          <!--[/extension]-->
          <div xmlns="http://www.w3.org/1999/xhtml">
            <xsl:variable name="entryLevelElements_w_content">
              <xsl:call-template name="entry-level-elements">
                <xsl:with-param name="deep-copy">entry-content</xsl:with-param>
              </xsl:call-template>
            </xsl:variable>
            <xsl:for-each select="extension:node-set($entryLevelElements_w_content)/descendant::xhtml:*[contains(concat(' ',normalize-space(@class),' '),' entry-content ')]">
              <xsl:variable name="inside-q">
                <xsl:apply-templates mode="is-in-q" select="." />
              </xsl:variable>
              <xsl:if test="$inside-q = 'no'">
                <xsl:copy-of select="child::*|text()" />
              </xsl:if>
            </xsl:for-each>
          </div>
        </content>
      </xsl:if>

      <xsl:choose>
        <xsl:when test="extension:node-set($entryLevelElements)/descendant::xhtml:*[contains(concat(' ',normalize-space(@class),' '),' author ')]">
          <xsl:for-each select="extension:node-set($entryLevelElements)/descendant::xhtml:*[contains(concat(' ',normalize-space(@class),' '),' author ')]">
            <xsl:for-each select="descendant-or-self::xhtml:*[contains(concat(' ',normalize-space(@class),' '),' vcard ')]">
              <author><xsl:call-template name="vcard"/></author>
            </xsl:for-each>
          </xsl:for-each>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates mode="find-author" select="parent::*" />
        </xsl:otherwise>
      </xsl:choose>

      <!-- Extract entry's tags -->
      <xsl:for-each select="extension:node-set($entryLevelElements)/descendant::xhtml:a[contains(concat(' ',normalize-space(translate(@rel,'TAG','tag')),' '),' tag ')]">
        <xsl:call-template name="create-category" />
      </xsl:for-each>

    </entry>
  </xsl:if>
</xsl:template>

<!-- 
    Find author outside of "hentry" 
-->
<xsl:template match="*" mode="find-author">
  <xsl:variable name="elements">
    <xsl:call-template name="find-author-filter" />
  </xsl:variable>
  <xsl:choose>
    <xsl:when test="extension:node-set($elements)/descendant::xhtml:address[contains(concat(' ',normalize-space(@class),' '),' author ')]">
	  <xsl:for-each select="extension:node-set($elements)/descendant::xhtml:address[contains(concat(' ',normalize-space(@class),' '),' author ')][1]">
	    <xsl:for-each select="descendant-or-self::xhtml:*[contains(concat(' ',normalize-space(@class),' '),' vcard ')]">
          <author><xsl:call-template name="vcard"/></author>
	    </xsl:for-each>
	   </xsl:for-each>
    </xsl:when>
    <xsl:otherwise>
	  <xsl:apply-templates mode="find-author" select="parent::*" />
    </xsl:otherwise>
  </xsl:choose>  
</xsl:template>

<!-- Filter for find-author template -->
<xsl:template name="find-author-filter">
  <xsl:choose> 
    <xsl:when test="contains(concat(' ',normalize-space(@class),' '),' hentry ')"/>
    <xsl:when test="(local-name() = 'q' or local-name() = 'blockquote')
                and namespace-uri() = 'http://www.w3.org/1999/xhtml' "/>
    <xsl:otherwise>
      <xsl:copy>
        <xsl:for-each select="@*|node()">
          <xsl:call-template name="feed-level-elements"/>
        </xsl:for-each>
      </xsl:copy>
    </xsl:otherwise>
  </xsl:choose>
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
    <xsl:when test="(local-name() = 'q' or local-name() = 'blockquote')
                and namespace-uri() = 'http://www.w3.org/1999/xhtml' "/>
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
  <xsl:param name="deep-copy" />
  <xsl:choose>
    <xsl:when test="$deep-copy != '' and contains(concat(' ',normalize-space(@class),' '), concat(' ',$deep-copy,' '))">
      <xsl:copy-of select="."/>
    </xsl:when>
    <xsl:when test="(local-name() = 'q' or local-name() = 'blockquote')
                    and namespace-uri() = 'http://www.w3.org/1999/xhtml' "/>
    <xsl:otherwise>
      <xsl:copy>
        <xsl:for-each select="@*|node()">
          <xsl:call-template name="entry-level-elements">
            <xsl:with-param name="deep-copy" select="$deep-copy" />
          </xsl:call-template>
        </xsl:for-each>
      </xsl:copy>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="vcard">
  <xsl:variable name="vcard-base">
    <xsl:apply-templates select="." mode="get-base">
      <xsl:with-param name="fallback" select="/xhtml:html/xhtml:head/xhtml:base[1]/@href" />
    </xsl:apply-templates>
  </xsl:variable>    
  <name>
    <xsl:value-of select="normalize-space(descendant-or-self::*[contains(concat(' ',normalize-space(@class),' '),' fn ')])"/>
  </name>
  <xsl:choose>
    <xsl:when test="descendant-or-self::xhtml:a[contains(concat(' ',normalize-space(@class),' '),' url ')]">
      <uri>
        <xsl:call-template name="uri:expand">
          <xsl:with-param name="base">
            <xsl:apply-templates select="descendant-or-self::xhtml:a[
              contains(concat(' ',normalize-space(@class),' '),' url ')]" 
              mode="get-base">
              <xsl:with-param name="fallback" select="$vcard-base" />
            </xsl:apply-templates>
          </xsl:with-param>
          <xsl:with-param name="there">
            <xsl:value-of select="descendant-or-self::xhtml:a[
              contains(concat(' ',normalize-space(@class),' '),' url ')]/@href" />
          </xsl:with-param>
        </xsl:call-template>
      </uri>
    </xsl:when>
    <xsl:when test="descendant-or-self::*[contains(concat(' ',normalize-space(@class),' '),' url ')]">
      <uri>
        <xsl:call-template name="uri:expand">
          <xsl:with-param name="base">
            <xsl:apply-templates select="descendant-or-self::xhtml:*[
              contains(concat(' ',normalize-space(@class),' '),' url ')]" 
              mode="get-base">
              <xsl:with-param name="fallback" select="$vcard-base" />
            </xsl:apply-templates>
          </xsl:with-param>
          <xsl:with-param name="there">
            <xsl:value-of select="descendant-or-self::xhtml:*[
              contains(concat(' ',normalize-space(@class),' '),' url ')]" />
          </xsl:with-param>
        </xsl:call-template>
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

<!--                      
      Templates for handling rel-tag
-->
<!--[extension]-->
<xsl:template name="create-category">
  <category>
    <xsl:attribute name="term">
      <xsl:call-template name="extract-tag">
        <xsl:with-param name="uri" select="@href"/>
      </xsl:call-template>
    </xsl:attribute>
    <xsl:attribute name="label"><xsl:value-of select="."/></xsl:attribute>
  </category>
</xsl:template>

<!--
  Extract a tag from an URI
-->
<xsl:template name="extract-tag">
  <xsl:param name="uri" />
  
  <xsl:variable name="uri-sans-fragment">
    <xsl:choose>
      <xsl:when test="contains($uri,'#')">
        <xsl:value-of select="substring-before($uri,'#')" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$uri" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="uri-sans-query">
    <xsl:choose>
      <xsl:when test="contains($uri-sans-fragment,'?')">
        <xsl:value-of select="substring-before($uri-sans-fragment,'?')" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$uri-sans-fragment" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="uri-sans-trailing-slashes">
    <xsl:call-template name="strip-trailing-slashes">
      <xsl:with-param name="str" select="$uri-sans-query" />
    </xsl:call-template>
  </xsl:variable>

  <xsl:call-template name="decode-uri">
    <xsl:with-param name="uri">
      <xsl:call-template name="basename">
        <xsl:with-param name="uri" select="$uri-sans-trailing-slashes" />
      </xsl:call-template>
    </xsl:with-param>
  </xsl:call-template>
</xsl:template>

<!--
  Strips trailing slashes from a string
-->
<xsl:template name="strip-trailing-slashes">
  <xsl:param name="str" />
  <xsl:choose>
    <xsl:when test="substring($str,string-length($str)) = '/'">
      <xsl:call-template name="strip-trailing-slashes">
        <xsl:with-param name="str" 
           select="substring($str,1,string-length($str)-1)" />
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$str" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- 
  Basename for URI
-->
<xsl:template name="basename">
  <xsl:param name="uri" />
  <xsl:choose>
    <xsl:when test="contains($uri,'/')">
      <xsl:call-template name="basename">
        <xsl:with-param name="uri"
           select="substring-after($uri,'/')" />
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$uri" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- 
  Decodes an URI 
-->
<xsl:template name="decode-uri">
  <xsl:param name="uri" />
  <xsl:choose>
    <xsl:when test="function-available('str:decode-uri')">
      <xsl:variable name="s">
        <xsl:call-template name="plus_to_space">
          <xsl:with-param name="string" select="$uri" />
        </xsl:call-template>
      </xsl:variable>
      <xsl:value-of select="str:decode-uri($s)" />
    </xsl:when>
    <xsl:when test="system-property('xsl:vendor-url') = 'http://xml.apache.org/xalan-j'">
      <xsl:value-of 
        xmlns:xalan="http://xml.apache.org/xalan/java"
        select="xalan:java.net.URLDecoder.decode($uri,'UTF-8')"
      />
    </xsl:when>
    <xsl:when test="system-property('xsl:vendor-url') = 'http://www.saxonica.com/'">
      <xsl:value-of
        xmlns:saxon="java:java.net.URLDecoder"
        select="saxon:decode($uri,'UTF-8')"
      />
    </xsl:when>   
    <xsl:otherwise>
      <xsl:message terminate="yes">XSLT engine does not support EXSLT's decode-uri().</xsl:message>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!--
  Replace "+" with " " 
-->
<xsl:template name="plus_to_space">
  <xsl:param name="string" />
  <xsl:choose>
    <xsl:when test="contains($string,'+')">
      <xsl:variable name="new_string" select="
        concat(
          substring-before($string,'+'),
          ' ',
          substring-after($string,'+')
        )
        "/>
      <xsl:call-template name="plus_to_space">
        <xsl:with-param name="string" select="$new_string" />
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise><xsl:value-of select="$string" /></xsl:otherwise>
  </xsl:choose>
</xsl:template>


<!-- 
  Walk the tree upwards to find
  a suitable xml:lang.
  TODO: If no one was found and $for-feed is true try to
  use the $source-lang stylesheet parameter.
-->
<xsl:template match="xhtml:*" mode="add-lang-attribute">
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
        <xsl:apply-templates mode="add-lang-attribute" select="parent::*">
          <xsl:with-param name="end" select="$end" />
        </xsl:apply-templates>
      </xsl:if>
    </xsl:when>
    <xsl:otherwise>
      <xsl:apply-templates mode="add-lang-attribute" select="parent::*">
        <xsl:with-param name="end" select="$end" />
      </xsl:apply-templates>    
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- 
  Walk the tree upwards to find
  a suitable xml:base.
  If none is found and $for-feed = true()
  try to use HTML's <base>. (If no HTML <base> is present try to use
  use the $source-uri stylesheet parameter.)
-->
<xsl:template match="xhtml:*" mode="add-base-attribute">
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
    <xsl:when test="(local-name()='html' and namespace-uri() = 'http://www.w3.org/1999/xhtml')and $for-feed">
      <!-- Try to use HTML's <base> -->
      <xsl:choose>
        <xsl:when test="/xhtml:html/xhtml:head/xhtml:base[@href]">
          <xsl:attribute name="xml:base">
            <xsl:value-of select="/xhtml:html/xhtml:head/xhtml:base/@href" />
          </xsl:attribute>
        </xsl:when>    
        <xsl:otherwise>
          <xsl:attribute name="xml:base">
            <xsl:value-of select="$source-uri" />
          </xsl:attribute>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:when test="not($end='')">
      <xsl:if test="not(contains(concat(' ',normalize-space(@class),' '), concat(' ',$end,' ')))">
        <xsl:apply-templates mode="add-base-attribute" select="parent::*">
          <xsl:with-param name="end" select="$end" />
          <xsl:with-param name="for-feed" select="$for-feed" />
        </xsl:apply-templates>
      </xsl:if>
    </xsl:when>
    <xsl:otherwise>
      <xsl:apply-templates mode="add-base-attribute" select="parent::*">
        <xsl:with-param name="end" select="$end" />
        <xsl:with-param name="for-feed" select="$for-feed" />
      </xsl:apply-templates>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>


<!-- 
  Get the xml:base for the current element 
  If no xml:base is present use the value of $fallback.
  If $fallback = "" then use the value of $source-uri
-->
<xsl:template match="*" mode="get-base">
  <xsl:param name="fallback" />

  <xsl:choose>
    <xsl:when test="@xml:base">
      <xsl:value-of select="@xml:base" />
    </xsl:when> 
    <!-- 
      Are we trying to find the xml:base for <feed>
      and are we already at the root element?
    -->
    <xsl:when test="not(parent::*)">
      <xsl:choose>
        <xsl:when test="$fallback != ''"><xsl:value-of select="$fallback" /></xsl:when>
        <xsl:otherwise><xsl:value-of select="$source-uri" /></xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:otherwise>
      <xsl:apply-templates mode="get-base" select="parent::*">
        <xsl:with-param name="fallback" select="$fallback" />
      </xsl:apply-templates>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- 
  Determine if the element is inside a quotation element.
-->
<xsl:template match="*" mode="is-in-q">
  <xsl:choose>
    <xsl:when test="(local-name() = 'q' or local-name() = 'blockquote')
                    and namespace-uri() = 'http://www.w3.org/1999/xhtml' ">
      <xsl:value-of select="'yes'" />
    </xsl:when>
    <xsl:when test="parent::*">
      <xsl:apply-templates mode="is-in-q" select="parent::*" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="'no'" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

</xsl:transform>

