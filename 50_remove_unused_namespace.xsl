<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="1.0">

  <xsl:strip-space elements="*"/>
  <xsl:output method="xml" omit-xml-declaration="yes" indent="yes"/>

  <!-- default rule -->
  <xsl:template match="*">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>




  <xsl:template match="*" priority="1">

    <xsl:copy>
      <xsl:for-each select=".//namespace::*">
        <!--
        <xsl:message>
          <xsl:value-of select="concat(., '*******', ..)"/>
        </xsl:message>
        -->
        <xsl:if test="(..//*)[namespace-uri()=current() and
                             namespace-uri()!=namespace-uri(current()/..)] or
                     (..|..//*)[starts-with(.,concat(name(current()),':'))]">

          <xsl:copy-of select="."/>
        </xsl:if>
      </xsl:for-each>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

  <!--
  <xsl:template match="*" priority="1">
    <xsl:copy>
      <xsl:variable name="vtheElem" select="."/>

      <xsl:for-each select=".//namespace::*">
        <xsl:message>
          <xsl:value-of select="concat(., '*******', ..)"/>
        </xsl:message>
        <xsl:variable name="vPrefix" select="name()"/>

        <xsl:if test=
                        "$vtheElem/descendant::*
              [(namespace-uri()=current()
             and
              substring-before(name(),':') = $vPrefix)
             or
              @*[substring-before(name(),':') = $vPrefix]
              ]
      ">
          <xsl:copy-of select="."/>
        </xsl:if>
      </xsl:for-each>
      <xsl:apply-templates select="node()|@*"/>
    </xsl:copy>
  </xsl:template>
  -->
</xsl:stylesheet>
