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
  <xsl:include href="lsr2212_to_lsr2303_qos_simplification_00_head_classifier_type_var.xsl"/>

  <!-- default rule -->
  <xsl:template match="*">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="*[
    local-name() = 'classifier'
    and parent::*[local-name() = 'classifiers']
    and ancestor::*[local-name() = 'classifiers']
    and ancestor::*[local-name() = 'policy']
    and ancestor::*[local-name() = 'current']
    and ancestor::*[local-name() = 'policy-profile']
    and ancestor::*[local-name() = 'qos-policy-profiles' and namespace-uri() = 'urn:bbf:yang:bbf-qos-policies']
  ]">
    <xsl:copy>
      <xsl:apply-templates select="@* | node()"/>
      <xsl:element name="classifier-type">
        <xsl:call-template name="calculateClassifierType">
          <xsl:with-param name="classifierSec" select="current()"/>
        </xsl:call-template>
      </xsl:element>
    </xsl:copy>
  </xsl:template>

  <!-- ==================================== Main Function ================================ -->

  <!-- main indentification process which cursor at classifier -->
  <xsl:template name="calculateClassifierType">
    <xsl:param name="classifierSec"/>

    <xsl:variable name="actionTypesStringVar">
      <xsl:call-template name="mergeActions">
        <xsl:with-param name="classifierSec" select="$classifierSec"/>
      </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="enhancdFilterType">
      <xsl:value-of
              select="$classifierSec/child::*[local-name() = 'filters']/child::*[local-name() = 'ref-filter']/child::*[local-name() = 'type']"/>
    </xsl:variable>

    <xsl:variable name="selfFilterTypes">
      <xsl:value-of
              select="$classifierSec/child::*[local-name() = 'filters']/child::*[local-name() = 'self-filter-types']"/>
    </xsl:variable>

    <xsl:variable name="anyFrame">
      <xsl:value-of select="$classifierSec/*[local-name() = 'any-frame']"/>
    </xsl:variable>

    <xsl:variable name="filterOperation">
      <xsl:value-of select="$classifierSec/*[local-name() = 'filter-operation']"/>
    </xsl:variable>

    <xsl:variable name="isClsTypeFilterMoreThanTwoOfAnyFrameDscpIgmpPbitVar">
      <xsl:call-template name="isClsTypeFilterMoreThanTwoOfAnyFrameDscpIgmpPbit">
        <xsl:with-param name="anyFrameParam" select="$anyFrame"/>
        <xsl:with-param name="selfFilterTypeParam" select="$selfFilterTypes"/>
      </xsl:call-template>
    </xsl:variable>

    <xsl:choose>
      <!-- type rate-limit -->
      <xsl:when test="contains($actionTypesStringVar,$A_RATE_LIMIT)">
        <xsl:value-of select="$CLS_TYPE_MATCHALL_TO_RATE_LIMIT"/>
      </xsl:when>

      <!-- type scheduler-->
      <xsl:when test="contains($actionTypesStringVar, $A_SCHEDULING_TRAFFIC)">
        <xsl:value-of select="$CLS_TYPE_ACTION_WITH_SCHEDULING_TC"/>
      </xsl:when>

      <!-- type action -->
      <!-- inline or enhanced classifer filter type -->
      <xsl:when test="$enhancdFilterType = $F_EN_FILTER_FLOW_COLOR">
        <xsl:value-of select="$CLS_TYPE_EN_FILTER_WITH_FOLOW_COLOR"/>
      </xsl:when>
      <xsl:when test="contains($selfFilterTypes,$F_FLOW_COLOR)">
        <xsl:value-of select="$CLS_TYPE_FILTER_WITH_FLOW_COLOR"/>
      </xsl:when>
      <xsl:when test="contains($actionTypesStringVar,$A_BAC_COLOR)
        and (contains($selfFilterTypes,$F_PBIT_MARKING)
        or contains($selfFilterTypes,$F_IN_PBIT_LIST)
        or contains($selfFilterTypes,$F_DEI_MARKING)
        or contains($selfFilterTypes,$F_IN_DEI))">
        <xsl:value-of select="$CLS_TYPE_ACTION_QUEUE_COLOR"/>
      </xsl:when>

      <!-- type policer -->
      <!-- CLS_TYPE_ANYFRAME_CLS_TO_POLICING -->
      <xsl:when test="$anyFrame = $F_ANY_FRAME and contains($actionTypesStringVar,$A_POLICING)">
        <xsl:value-of select="$CLS_TYPE_ANYFRAME_CLS_TO_POLICING"/>
      </xsl:when>
      <!-- CLS_TYPE_MATCHALL_TO_POLICING -->
      <xsl:when
              test="contains($selfFilterTypes,$F_MATCH_ALL) and contains($actionTypesStringVar,$A_POLICING)">
        <xsl:value-of select="$CLS_TYPE_MATCHALL_TO_POLICING"/>
      </xsl:when>
      <!-- CLS_TYPE_UNMETERED_TO_POLICING -->
      <xsl:when test="contains($selfFilterTypes,$F_UNMETERED) and contains($actionTypesStringVar,$A_POLICING)">
        <xsl:value-of select="$CLS_TYPE_UNMETERED_TO_POLICING"/>
      </xsl:when>

      <!-- type CCL -->
      <!-- CLS_TYPE_ACTION_WITH_POLICING -->
      <xsl:when test="contains($actionTypesStringVar,$A_POLICING)">
        <xsl:value-of select="$CLS_TYPE_ACTION_WITH_POLICING"/>
      </xsl:when>
      <!-- CLS_TYPE_ACTION_WITH_PASS -->
      <xsl:when test="contains($actionTypesStringVar,$A_PASS)">
        <xsl:value-of select="$CLS_TYPE_ACTION_WITH_PASS"/>
      </xsl:when>
      <!-- CLS_TYPE_ACTION_WITH_DISCARD -->
      <xsl:when test="contains($actionTypesStringVar,$A_DISCARD)">
        <xsl:value-of select="$CLS_TYPE_ACTION_WITH_DISCARD"/>
      </xsl:when>
      <!-- CLS_TYPE_ACTION_WITH_PBITMARKING_AND_FLOWCOLOR -->
      <xsl:when
              test="contains($actionTypesStringVar,$A_PBIT_MARKING) and contains($actionTypesStringVar,$A_FLOW_COLOR)">
        <xsl:value-of select="$CLS_TYPE_ACTION_WITH_PBITMARKING_AND_FLOWCOLOR"/>
      </xsl:when>
      <!-- CLS_TYPE_EN_FILTER_WITHOUT_FLOW_COLOR -->
      <xsl:when test="$enhancdFilterType = $F_EN_FILTER_WITHOUT_FLOW_COLOR">
        <xsl:value-of select="$CLS_TYPE_EN_FILTER_WITHOUT_FLOW_COLOR"/>
      </xsl:when>
      <!-- CLS_TYPE_EN_CLS_WITH_MAC_OR_IP_OR_PORT -->
      <xsl:when test="
            contains($selfFilterTypes,$F_EN_SOURCE_MAC) or contains($selfFilterTypes,$F_EN_DEST_MAC)
            or contains($selfFilterTypes,$F_EN_IPV4) or contains($selfFilterTypes,$F_EN_IPV6)
            or contains($selfFilterTypes,$F_EN_IP_COMMON_NOT_DSCP_DSCPRANGE_IGMP) or contains($selfFilterTypes,$F_EN_TRANSPORT)">
        <xsl:value-of select="$CLS_TYPE_EN_CLS_WITH_MAC_OR_IP_OR_PORT"/>
      </xsl:when>
      <!-- CLS_TYPE_FILTER_WITH_PROTOCAL_NOT_IGMP -->
      <xsl:when
              test="contains($selfFilterTypes,$F_PROTOCOL_NOT_IGMP)">
        <xsl:value-of select="$CLS_TYPE_FILTER_WITH_PROTOCAL_NOT_IGMP"/>
      </xsl:when>
      <!-- CLS_TYPE_DEI_MARKING_OR_IN_DEI_TO_PBIT_MARKING -->
      <xsl:when test="
            (contains($selfFilterTypes,$F_DEI_MARKING) or contains($selfFilterTypes,$F_IN_DEI))
            and (contains($actionTypesStringVar,$A_PBIT_MARKING) and not(contains($actionTypesStringVar,$A_DEI_MARKING)))">
        <xsl:value-of select="$CLS_TYPE_DEI_MARKING_OR_IN_DEI_TO_PBIT_MARKING"/>
      </xsl:when>
      <!-- CLS_TYPE_FILTER_MORE_THAN_TWO_TYPE_OF_ANYFRAME_DSCP_IGMP_PBIT -->
      <xsl:when test="$isClsTypeFilterMoreThanTwoOfAnyFrameDscpIgmpPbitVar = 'true'">
        <xsl:value-of select="$CLS_TYPE_FILTER_MORE_THAN_TWO_TYPE_OF_ANYFRAME_DSCP_IGMP_PBIT"/>
      </xsl:when>

      <!-- type pre-color -->
      <!-- CLS_TYPE_ACTION_FLOW_COLOR -->
      <xsl:when test="contains($actionTypesStringVar, $A_FLOW_COLOR)">
        <xsl:value-of select="$CLS_TYPE_ACTION_FLOW_COLOR"/>
      </xsl:when>

      <!-- type marker -->
      <!-- CLS_TYPE_PBIT_TO_PBITMARKING -->
      <xsl:when test="
            (contains($selfFilterTypes,$F_PBIT_MARKING) or contains($selfFilterTypes,$F_IN_PBIT_LIST))
            and contains($actionTypesStringVar,$A_PBIT_MARKING)">
        <xsl:value-of select="$CLS_TYPE_PBIT_TO_PBITMARKING"/>
      </xsl:when>
      <!-- CLS_TYPE_IGMP_TO_PBITMARKING -->
      <xsl:when test="
            (contains($selfFilterTypes,$F_PROTOCOL_IGMP) or contains($selfFilterTypes,$F_EN_IP_COMMON_IGMP))
            and contains($actionTypesStringVar, $A_PBIT_MARKING)">
        <xsl:value-of select="$CLS_TYPE_IGMP_TO_PBITMARKING"/>
      </xsl:when>
      <!-- CLS_TYPE_UNTAGGED_TO_PBITMARKING -->
      <xsl:when test="contains($selfFilterTypes,$F_UNTAGGED) and contains($actionTypesStringVar, $A_PBIT_MARKING)">
        <xsl:value-of select="$CLS_TYPE_UNTAGGED_TO_PBITMARKING"/>
      </xsl:when>
      <!-- CLS_TYPE_DSCP_TO_PBITMARKING -->
      <xsl:when test="
            (contains($selfFilterTypes,$F_DSCP_RANGE) or contains($selfFilterTypes,$F_EN_IP_COMMON_DSCP))
            and contains($actionTypesStringVar, $A_PBIT_MARKING)">
        <xsl:value-of select="$CLS_TYPE_DSCP_TO_PBITMARKING"/>
      </xsl:when>
      <!-- CLS_TYPE_PBIT_TO_POLICING_TC -->
      <xsl:when test="
            (contains($selfFilterTypes,$F_IN_PBIT_LIST) or contains($selfFilterTypes,$F_PBIT_MARKING))
            and contains($actionTypesStringVar, $A_PBIT_POLICING_TC)">
        <xsl:value-of select="$CLS_TYPE_PBIT_TO_POLICING_TC"/>
      </xsl:when>
      <!-- CLS_TYPE_ACTION_COUNT -->
      <xsl:when test="contains($actionTypesStringVar, $A_COUNT)">
        <xsl:value-of select="$CLS_TYPE_ACTION_COUNT"/>
      </xsl:when>

      <xsl:otherwise>
        <xsl:value-of select="$CLS_TYPE_INVALID"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="isClsTypeFilterMoreThanTwoOfAnyFrameDscpIgmpPbit">
    <xsl:param name="selfFilterTypeParam"/>
    <xsl:param name="anyFrameParam"/>

    <xsl:variable name="num1">
      <xsl:if test="$anyFrameParam = $F_ANY_FRAME">
        <xsl:value-of select="1"/>
      </xsl:if>
    </xsl:variable>

    <xsl:variable name="num2">
      <xsl:if test="contains($selfFilterTypeParam,$F_DSCP_RANGE) or contains($selfFilterTypeParam,$F_EN_IP_COMMON_DSCP)">
        <xsl:value-of select="2"/>
      </xsl:if>
    </xsl:variable>

    <xsl:variable name="num3">
      <xsl:if test="contains($selfFilterTypeParam,$F_PROTOCOL_IGMP)">
        <xsl:value-of select="3"/>
      </xsl:if>
    </xsl:variable>

    <xsl:variable name="num4">
      <xsl:if test="contains($selfFilterTypeParam,$F_IN_PBIT_LIST) or contains($selfFilterTypeParam,$F_PBIT_MARKING)">
        <xsl:value-of select="4"/>
      </xsl:if>
    </xsl:variable>

    <xsl:variable name="num">
      <xsl:value-of select="concat(num1,num2,num3,num4)"/>
    </xsl:variable>

    <xsl:choose>
      <xsl:when test="string-length(num) > 1">
        <xsl:value-of select="true"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="false"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
</xsl:stylesheet>
