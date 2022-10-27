<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:bbf-qos-pol="urn:bbf:yang:bbf-qos-policies"
                xmlns:bbf-qos-cls="urn:bbf:yang:bbf-qos-classifiers"
                xmlns:bbf-qos-plc="urn:bbf:yang:bbf-qos-policing"
                xmlns:nokia-sdan-qos-policing-extension="http://www.nokia.com/Fixed-Networks/BBA/yang/nokia-sdan-qos-policing-extension"
                exclude-result-prefixes="bbf-qos-plc"
                xmlns=""
                version="1.0">

  <xsl:strip-space elements="*"/>
  <xsl:output method="xml" indent="yes"/>

  <xsl:include href="00_head_classifier_filter_and_action_type_var.xsl"/>
  <xsl:include href="00_head_classifier_type_var.xsl"/>
  <xsl:include href="00_head_policy_type_var.xsl"/>

  <!-- default rule -->

  <xsl:template match="*">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>

  <!--
  <xsl:template match="comment()">
    <xsl:copy>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
  -->

  <!--
  <xsl:template match="*">
    <xsl:element name="{local-name()}">
      <xsl:for-each select="@*">
        <xsl:attribute name="{local-name()}">
          <xsl:message><xsl:value-of select="local-name()"/></xsl:message>
          <xsl:value-of select="."/>
        </xsl:attribute>
      </xsl:for-each>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>
  -->

  <xsl:template match="*[
    local-name() = 'qos-policy-profiles' and namespace-uri() = 'urn:bbf:yang:bbf-qos-policies'
    and not(parent::*[local-name() = 'new'])
  ]">
    <xsl:variable name="curPolicyProfiles" select="//*[
      parent::*[local-name() = 'new']
      and local-name() = 'qos-policy-profiles'
      and child::*[local-name() = 'policy-profile']
    ]"/>
    <xsl:copy>
      <xsl:apply-templates select="@* | node()"/>
      <xsl:copy-of select="$curPolicyProfiles/node()"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="*[
    local-name() = 'policies' and namespace-uri() = 'urn:bbf:yang:bbf-qos-policies'
    and not(parent::*[local-name() = 'new'])
  ]">
    <xsl:variable name="curPolicies" select="//*[
      parent::*[local-name() = 'new']
      and local-name() = 'policies'
      and child::*[local-name() = 'policy']
    ]"/>
    <xsl:copy>
      <xsl:apply-templates select="@* | node()"/>
      <xsl:copy-of select="$curPolicies/node()"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="*[
    local-name() = 'filters' and namespace-uri() = 'urn:bbf:yang:bbf-qos-filters'
    and not(parent::*[local-name() = 'new'])
  ]">
    <xsl:variable name="newEnhancedFilters" select="//*[
      parent::*[local-name() = 'new']
      and local-name() = 'filters'
      and child::*[local-name() = 'enhanced-filter']
    ]"/>
    <xsl:copy>
      <xsl:apply-templates select="@* | node()"/>
      <xsl:copy-of select="$newEnhancedFilters/node()"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="*[
    local-name() = 'classifiers' and namespace-uri() = 'urn:bbf:yang:bbf-qos-classifiers'
    and not(parent::*[local-name() = 'new'])
  ]">
    <xsl:variable name="curClassifiers" select="//*[
      parent::*[local-name() = 'new']
      and local-name() = 'classifiers'
      and child::*[local-name() = 'classifier-entry']
    ]"/>
    <xsl:copy>
      <xsl:apply-templates select="@* | node()"/>
      <xsl:copy-of select="$curClassifiers/node()"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="*[
    local-name() = 'policing-profiles' and namespace-uri() = 'urn:bbf:yang:bbf-qos-policing'
    and not(parent::*[local-name() = 'new'])
  ]">
    <xsl:variable name="curPolicingProfiles" select="//*[
      local-name() = 'policing-profiles'
      and parent::*[local-name() = 'new']
    ]"/>

    <xsl:variable name="policingActionProfiles" select="//*[
      parent::*[local-name() = 'new']
      and local-name() = 'policing-action-profiles'
      and child::*[local-name() = 'action-profile']
    ]"/>
    <xsl:variable name="policingPrehandlingProfiles" select="//*[
      parent::*[local-name() = 'new']
      and local-name() = 'policing-pre-handling-profiles'
      and child::*[local-name() = 'pre-handling-profile']
    ]"/>

    <xsl:copy>
      <xsl:apply-templates select="@* | node()"/>
      <xsl:copy-of select="$curPolicingProfiles/node()"/>
    </xsl:copy>
    <xsl:copy-of select="$policingPrehandlingProfiles"/>
    <xsl:copy-of select="$policingActionProfiles"/>
  </xsl:template>

  <!--
  <xsl:template match="*[
    local-name() != 'new'
    and child::*[ local-name() = 'policing-profiles' and namespace-uri() = 'urn:bbf:yang:bbf-qos-policing']
  ]">
    <xsl:variable name="policingActionProfiles" select="//*[
      parent::*[local-name() = 'new']
      and local-name() = 'policing-action-profiles'
      and child::*[local-name() = 'policing-action-profile']
    ]"/>
    <xsl:variable name="policingPrehandlingProfiles" select="//*[
      parent::*[local-name() = 'new']
      and local-name() = 'policing-pre-handling-profiles'
      and child::*[local-name() = 'policing-pre-handling-profile']
    ]"/>

    <xsl:copy>
      <xsl:apply-templates select="@* | node()"/>
      <xsl:copy-of select="$policingPrehandlingProfiles"/>
      <xsl:copy-of select="$policingActionProfiles"/>
    </xsl:copy>

  </xsl:template>
  -->
  <!-- rename current policy-profile if have new one -->
  <xsl:template match="*[
    local-name() = 'name'
    and parent::*[local-name() = 'policy-profile']
    and ancestor::*[local-name() = 'qos-policy-profiles' and namespace-uri() = 'urn:bbf:yang:bbf-qos-policies']
    and boolean(../child::*[local-name() = 'migration-cache']/child::*[local-name() = 'new']/child::*[local-name() = 'qos-policy-profiles']/child::*[local-name() = 'policy-profile']/child::*[local-name() = 'name'])
  ]">
    <xsl:copy>
      <xsl:value-of select="concat('DP_', current())"/>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
