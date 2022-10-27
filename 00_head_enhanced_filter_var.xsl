<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:strip-space elements="*"/>

  <!-- enum enhanced filter type-->
  <xsl:variable name="F_EN_FILTER_WITHOUT_FLOW_COLOR" select="'F_EN_FILTER_WITHOUT_FLOW_COLOR'"/>
  <xsl:variable name="F_EN_FILTER_FLOW_COLOR" select="'F_EN_FILTER_FLOW_COLOR'"/>

  <!-- flow-color enumeration -->
  <xsl:variable name="FLOW_COLOR_GREEN" select="'green'"/>
  <xsl:variable name="FLOW_COLOR_YELLOW" select="'yellow'"/>
  <xsl:variable name="FLOW_COLOR_RED" select="'red'"/>




  <!-- =========================== Infra function ========================== -->
  <xsl:template name="getEnhancedFilterColor">
    <xsl:param name="enhancedFilterName"/>

    <xsl:variable name="enhancedFilterNameVar">
      <xsl:value-of select="normalize-space($enhancedFilterName)"/>
    </xsl:variable>
    <xsl:variable name="enhancedFilter" select="//*[
      local-name() = 'enhanced-filter' and namespace-uri() = 'urn:bbf:yang:bbf-qos-enhanced-filters'
      and parent::*[local-name() = 'filters' and namespace-uri() = 'urn:bbf:yang:bbf-qos-filters']
      and child::*[local-name() = 'name' and text() = $enhancedFilterNameVar]
    ]"/>
    <xsl:variable name="flowColorSec">
      <xsl:value-of select="$enhancedFilter/child::*[local-name() = 'filter']/child::*[local-name() = 'flow-color']"/>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$flowColorSec = 'green' or $flowColorSec = 'bbf-qos-enhfilt:green'">
        <xsl:value-of select="$FLOW_COLOR_GREEN"/>
      </xsl:when>
      <xsl:when test="$flowColorSec = 'yellow' or $flowColorSec = 'bbf-qos-enhfilt:yellow'">
        <xsl:value-of select="$FLOW_COLOR_YELLOW"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$FLOW_COLOR_RED"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
</xsl:stylesheet>
