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

  <xsl:include href="00_head_classifier_filter_and_action_type_var.xsl"/>
  <xsl:include href="00_head_enhanced_filter_var.xsl"/>
  <!-- default rule -->
  <xsl:template match="*">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="*[
    local-name() = 'policy-profile'
    and parent::*[local-name() = 'qos-policy-profiles' and namespace-uri() = 'urn:bbf:yang:bbf-qos-policies']
  ]">
    <xsl:copy>
      <xsl:element name="migration-cache">
        <xsl:element name="current">
          <xsl:element name="name">
            <xsl:value-of select="child::*[local-name() = 'name']"/>
          </xsl:element>

          <xsl:element name="enhanced-filters"/>

          <xsl:element name="policies">
            <xsl:for-each select="child::*[local-name() = 'policy-list']">
              <xsl:element name="policy">
                <xsl:variable name="curPolicyName">
                  <xsl:value-of select="child::*[local-name() = 'name']"/>
                </xsl:variable>

                <xsl:element name="name">
                  <xsl:value-of select="$curPolicyName"/>
                </xsl:element>

                <xsl:element name="enhanced-filters"/>

                <xsl:variable name="curPolicy" select="//*[
                  local-name() = 'policy'
                  and parent::*[local-name() = 'policies' and namespace-uri() = 'urn:bbf:yang:bbf-qos-policies']
                  and child::*[local-name() = 'name'] = $curPolicyName
                ]"/>
                <xsl:element name="classifiers">
                  <xsl:for-each select="$curPolicy/child::*[local-name() = 'classifiers']">
                    <xsl:element name="classifier">
                      <xsl:variable name="curClsName">
                        <xsl:value-of select="child::*[local-name() = 'name']"/>
                      </xsl:variable>
                      <xsl:element name="name">
                        <xsl:value-of select="$curClsName"/>
                      </xsl:element>

                      <xsl:variable name="classifier" select="//*[
                        local-name() = 'classifier-entry'
                        and parent::*[local-name() = 'classifiers' and namespace-uri() = 'urn:bbf:yang:bbf-qos-classifiers']
                        and child::*[local-name() = 'name'] = $curClsName
                      ]"/>
                      <xsl:element name="filters">
                        <xsl:if test="$classifier/child::*[local-name() = 'enhanced-filter-name' and namespace-uri() = 'urn:bbf:yang:bbf-qos-enhanced-filters']">
                          <xsl:element name="ref-filter">
                            <xsl:variable name="refFilterName">
                              <xsl:value-of select="normalize-space($classifier/child::*[local-name() = 'enhanced-filter-name'])"/>
                            </xsl:variable>
                            <xsl:element name="name">
                              <xsl:value-of select="$refFilterName"/>
                            </xsl:element>
                            <xsl:variable name="enhancedFilter" select="//*[
                              local-name() = 'enhanced-filter' and namespace-uri() = 'urn:bbf:yang:bbf-qos-enhanced-filters'
                              and parent::*[local-name() = 'filters' and namespace-uri() = 'urn:bbf:yang:bbf-qos-filters']
                              and child::*[local-name() = 'name'] = $refFilterName
                            ]"/>
                            <xsl:element name="type">
                              <xsl:call-template name="getEnhancedFilterType">
                                <xsl:with-param name="enhancedFilterName" select="$refFilterName"/>
                              </xsl:call-template>
                            </xsl:element>
                            <xsl:variable name="ref" select="$enhancedFilter/child::*[local-name() = 'filter']/child::*[local-name() = 'enhanced-filter-name']"/>
                            <xsl:if test="boolean($ref)">
                              <xsl:element name="ref">
                                <xsl:value-of select="$ref"/>
                              </xsl:element>
                            </xsl:if>
                          </xsl:element>
                        </xsl:if>
                      </xsl:element>
                      <xsl:element name="actions"/>
                    </xsl:element>
                  </xsl:for-each>
                </xsl:element>
              </xsl:element>
            </xsl:for-each>
          </xsl:element>
        </xsl:element>
      </xsl:element>
      <xsl:apply-templates select="@* | node()"/>
    </xsl:copy>
  </xsl:template>

  <!-- =========================== Infra function ========================== -->
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
</xsl:stylesheet>
