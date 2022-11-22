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

  <xsl:include href="00_head_classifier_type_var.xsl"/>
  <xsl:include href="00_head_policy_type_var.xsl"/>

  <!-- default rule -->
  <xsl:template match="*">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="*[
    local-name() = 'policy'
    and parent::*[local-name() = 'policies']
    and ancestor::*[local-name() = 'current']
    and ancestor::*[local-name() = 'migration-cache']
    and ancestor::*[local-name() = 'policy-profile']
    and ancestor::*[local-name() = 'qos-policy-profiles' and namespace-uri() = 'urn:bbf:yang:bbf-qos-policies']
  ]">

    <xsl:variable name="firstClassifierTypeVar">
      <xsl:call-template name="getFirstValidClassifierType">
        <xsl:with-param name="curPolicySec" select="current()"/>
      </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="policyTypeVar">
      <xsl:call-template name="clsTypeToPolicyType">
        <xsl:with-param name="clsType" select="$firstClassifierTypeVar"/>
      </xsl:call-template>
    </xsl:variable>

    <xsl:copy>
      <xsl:for-each select="current()/node()">
        <xsl:choose>
          <xsl:when test="local-name() = 'name'">
            <xsl:copy>
              <xsl:apply-templates select="@* | node()"/>
            </xsl:copy>
            <xsl:element name="policy-type">
              <xsl:value-of select="$policyTypeVar"/>
            </xsl:element>
            <xsl:element name="first-classifier-type">
              <xsl:value-of select="$firstClassifierTypeVar"/>
            </xsl:element>
          </xsl:when>
          <xsl:otherwise>
            <xsl:copy>
              <xsl:apply-templates select="@* | node()"/>
            </xsl:copy>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
    </xsl:copy>
  </xsl:template>

  <!-- ================================== Infra functions ================================== -->

  <xsl:template name="getFirstValidClassifierType">
    <xsl:param name="curPolicySec"/>
    <xsl:variable name="firstClsTypeVar">
      <xsl:value-of
              select="$curPolicySec/classifiers/classifier/classifier-type[position() = 1 and not(text() = $CLS_TYPE_INVALID)]"/>
    </xsl:variable>
    <xsl:value-of select="$firstClsTypeVar"/>
  </xsl:template>

  <xsl:template name="clsTypeToPolicyType">
    <xsl:param name="clsType"/>
    <xsl:choose>
      <xsl:when test="$clsType = $CLS_TYPE_MATCHALL_TO_RATE_LIMIT">
        <xsl:value-of select="$POLICY_TYPE_RATE_LIMIT"/>
      </xsl:when>
      <xsl:when test="$clsType = $CLS_TYPE_ACTION_WITH_SCHEDULING_TC">
        <xsl:value-of select="$POLICY_TYPE_SCHEDULE"/>
      </xsl:when>
      <xsl:when test="$clsType = $CLS_TYPE_EN_FILTER_WITH_FOLOW_COLOR or $clsType = $CLS_TYPE_FILTER_WITH_FLOW_COLOR">
        <xsl:value-of select="$POLICY_TYPE_ACTION"/>
      </xsl:when>
      <xsl:when test="$clsType = $CLS_TYPE_UNMETERED_TO_POLICING
      or $clsType = $CLS_TYPE_MATCHALL_TO_POLICING or $clsType = $CLS_TYPE_ANYFRAME_CLS_TO_POLICING">
        <xsl:value-of select="$POLICY_TYPE_PORT_POLICER"/>
      </xsl:when>
      <xsl:when test="$clsType = $CLS_TYPE_ACTION_WITH_POLICING
      or $clsType = $CLS_TYPE_ACTION_WITH_PASS or $clsType = $CLS_TYPE_ACTION_WITH_DISCARD
      or $clsType = $CLS_TYPE_ACTION_WITH_PBITMARKING_AND_FLOWCOLOR or $clsType = $CLS_TYPE_EN_FILTER_WITHOUT_FLOW_COLOR
      or $clsType = $CLS_TYPE_EN_CLS_WITH_MAC_OR_IP_OR_PORT or $clsType = $CLS_TYPE_FILTER_WITH_PROTOCAL_NOT_IGMP
      or $clsType = $CLS_TYPE_DEI_MARKING_OR_IN_DEI_TO_PBIT_MARKING or $clsType = $CLS_TYPE_FILTER_MORE_THAN_TWO_TYPE_OF_ANYFRAME_DSCP_IGMP_PBIT">
        <xsl:value-of select="$POLICY_TYPE_CCL"/>
      </xsl:when>
      <xsl:when test="$clsType = $CLS_TYPE_ACTION_FLOW_COLOR">
        <xsl:value-of select="$POLICY_TYPE_COLOR"/>
      </xsl:when>
      <xsl:when test="$clsType = $CLS_TYPE_PBIT_TO_POLICING_TC">
        <xsl:value-of select="$POLICY_TYPE_PBIT_POLICING_TC"/>
      </xsl:when>
      <xsl:when test="$clsType = $CLS_TYPE_ACTION_COUNT">
        <xsl:value-of select="$POLICY_TYPE_COUNT"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$POLICY_TYPE_MARKER"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
