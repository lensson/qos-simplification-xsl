<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:bbf-qos-filt="urn:bbf:yang:bbf-qos-filters"
                xmlns:bbf-qos-enhfilt="urn:bbf:yang:bbf-qos-enhanced-filters"
                xmlns:bbf-qos-pol="urn:bbf:yang:bbf-qos-policies"
                xmlns:bbf-qos-cls="urn:bbf:yang:bbf-qos-classifiers"
                xmlns:bbf-qos-plc="urn:bbf:yang:bbf-qos-policing"
                xmlns:nokia-qos-filt="http://www.nokia.com/Fixed-Networks/BBA/yang/nokia-qos-filters-ext"
                xmlns:nokia-sdan-qos-policing-extension="http://www.nokia.com/Fixed-Networks/BBA/yang/nokia-sdan-qos-policing-extension"
                xmlns:nokia-qos-cls-ext="http://www.nokia.com/Fixed-Networks/BBA/yang/nokia-sdan-qos-classifier-extension"
                xmlns=""
                version="1.0">

  <xsl:strip-space elements="*"/>
  <xsl:output method="xml" indent="yes"/>

  <xsl:include href="lsr2212_to_lsr2303_qos_simplification_00_head_classifier_filter_and_action_type_var.xsl"/>
  <xsl:include href="lsr2212_to_lsr2303_qos_simplification_00_head_enhanced_filter_var.xsl"/>

  <!-- default rule -->
  <xsl:template match="*">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>

  <!-- Insert 1st level enhanced-filter of policy-profile -->
  <xsl:template match="*[
    local-name() = 'enhanced-filters'
    and parent::*[local-name() = 'current']
    and ancestor::*[local-name() = 'migration-cache']
    and ancestor::*[local-name() = 'policy-profile']
    and ancestor::*[local-name() = 'qos-policy-profiles' and namespace-uri() = 'urn:bbf:yang:bbf-qos-policies']
  ]">
    <xsl:variable name="cur" select=".."/>
    <xsl:copy>
      <xsl:for-each select="//*[
      local-name() = 'enhanced-filter' and namespace-uri() ='urn:bbf:yang:bbf-qos-enhanced-filters'
      and parent::*[local-name() = 'filters' and namespace-uri() = 'urn:bbf:yang:bbf-qos-filters']
      ]">
        <xsl:variable name="enhancedFilter" select="current()"/>
        <xsl:variable name="enhancedFilterName" select="normalize-space($enhancedFilter/child::*[local-name() = 'name'])"/>

        <xsl:variable name="enhancedFilterType">
          <xsl:call-template name="getEnhancedFilterType">
            <xsl:with-param name="enhancedFilterName" select="$enhancedFilterName"/>
          </xsl:call-template>
        </xsl:variable>

        <xsl:variable name="isExist">
          <xsl:value-of select="$cur/policies/policy/classifiers/classifier/filters/ref-filter/name = $enhancedFilterName"/>
        </xsl:variable>
        <xsl:variable name="isRef">
          <xsl:value-of select="$cur/policies/policy/classifiers/classifier/filters/ref-filter/ref = $enhancedFilterName"/>
        </xsl:variable>

        <xsl:if test="$isRef = 'true' or ($isExist and $enhancedFilterType = $F_EN_FILTER_WITHOUT_FLOW_COLOR)">
          <xsl:element name="enhanced-filter">
            <xsl:element name="name">
              <xsl:value-of select="$enhancedFilterName"/>
            </xsl:element>
            <xsl:variable name="filterOperationVar">
              <xsl:call-template name="getFilterOperation">
                <xsl:with-param name="filterSec" select="$enhancedFilter"/>
              </xsl:call-template>
            </xsl:variable>
            <xsl:if test="$filterOperationVar and string-length($filterOperationVar) > 0">
              <xsl:element name="filter-operation">
                <xsl:value-of select="$filterOperationVar"/>
              </xsl:element>
            </xsl:if>
            <xsl:element name="type">
              <xsl:value-of select="$enhancedFilterType"/>
            </xsl:element>
            <xsl:if test="$enhancedFilterType = $F_EN_FILTER_FLOW_COLOR">
              <xsl:element name="color">
                <xsl:call-template name="getEnhancedFilterColor">
                  <xsl:with-param name="enhancedFilterName" select="$enhancedFilterName"/>
                </xsl:call-template>
              </xsl:element>
            </xsl:if>
            <xsl:element name="ref-by"/>
          </xsl:element>
        </xsl:if>
      </xsl:for-each>
    </xsl:copy>
  </xsl:template>


  <!-- =========================== Infra function ========================== -->
  <xsl:template name="getFilterOperation">
    <xsl:param name="filterSec"/>
    <xsl:if test="$filterSec/child::*[local-name() = 'filter-operation']">
      <xsl:variable name="operationVar">
        <xsl:value-of
                select="normalize-space($filterSec/child::*[local-name() = 'filter-operation'])"/>
      </xsl:variable>
      <xsl:choose>
        <xsl:when test="contains($operationVar,'match-all-filter')">
          <xsl:value-of select="$OPER_MATCH_ALL"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$OPER_MATCH_ANY"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
  </xsl:template>

  <xsl:template name="getEnhancedFilterType">
    <xsl:param name="enhancedFilterName"/>
    <xsl:variable name="enhancedFilterNameVar">
      <xsl:value-of select="normalize-space($enhancedFilterName)"/>
    </xsl:variable>
    <xsl:variable name="enhancedFilter" select="//*[
      local-name() = 'enhanced-filter' and namespace-uri() = 'urn:bbf:yang:bbf-qos-enhanced-filters'
      and parent::*[local-name() = 'filters' and namespace-uri() = 'urn:bbf:yang:bbf-qos-filters']
      and child::*[local-name() = 'name' and text() = $enhancedFilterNameVar]
    ]"/>
    <xsl:variable name="flowColorSec"
                  select="$enhancedFilter/child::*[local-name() = 'filter']/child::*[local-name() = 'flow-color']"/>
    <xsl:choose>
      <xsl:when test="boolean($flowColorSec)">
        <xsl:value-of select="$F_EN_FILTER_FLOW_COLOR"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$F_EN_FILTER_WITHOUT_FLOW_COLOR"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="getEnhancedFilterRefFilter">
    <xsl:param name="enhancedFilterName"/>
    <xsl:variable name="enhancedFilter" select="//*[
      local-name() = 'enhanced-filter' and namespace-uri() = 'urn:bbf:yang:bbf-qos-enhanced-filters'
      and parent::*[local-name() = 'filters' and namespace-uri() = 'urn:bbf:yang:bbf-qos-filters']
      and child::*[local-name() = 'name' and text() = $enhancedFilterName]
    ]"/>
    <xsl:variable name="refFilterSec"
                  select="$enhancedFilter/child::*[local-name() = 'filter']/child::*[local-name() = 'enhanced-filter-name']"/>
    <xsl:value-of select="$refFilterSec"/>
  </xsl:template>

  <xsl:template name="getCurClassifierNamesByRefFilter">
    <xsl:param name="refFilterName"/>
    <xsl:param name="curSec"/>
    <xsl:for-each select="$curSec/policies/policy/classifiers/classifier[normalize-space(filters/ref-filter/name) = $refFilterName]">
      <xsl:value-of select="normalize-space(current()/name)"/>
    </xsl:for-each>
  </xsl:template>
</xsl:stylesheet>
