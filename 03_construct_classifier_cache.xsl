<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"

                xmlns=""
                version="1.0">

  <xsl:strip-space elements="*"/>
  <xsl:output method="xml" indent="yes"/>

  <xsl:include href="00_head_classifier_filter_and_action_type_var.xsl"/>
  <xsl:include href="00_head_policing_var.xsl"/>
  <xsl:include href="00_head_enhanced_filter_var.xsl"/>

  <!-- default rule -->
  <xsl:template match="*">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>

  <!-- Insert 2nd level enhanced-filter of policy-profile -->
  <xsl:template match="*[
    local-name() = 'ref-by'
    and parent::*[local-name() = 'enhanced-filter']
    and ancestor::*[local-name() = 'enhanced-filters']
    and ancestor::*[local-name() = 'current']
    and ancestor::*[local-name() = 'migration-cache']
    and ancestor::*[local-name() = 'policy-profile']
    and ancestor::*[local-name() = 'qos-policy-profiles' and namespace-uri() = 'urn:bbf:yang:bbf-qos-policies']
  ]">
    <xsl:variable name="cur" select="../../.."/>
    <xsl:variable name="curEnhancedFilterSec" select=".."/>
    <xsl:variable name="curEnhancedFilterName" select="../name"/>
    <xsl:copy>
      <xsl:for-each
              select="$cur/policies/policy/classifiers/classifier/filters/ref-filter[ref = $curEnhancedFilterName and type = $F_EN_FILTER_FLOW_COLOR]">
        <xsl:element name="filter">
          <xsl:variable name="curChildFilterName">
            <xsl:value-of select="normalize-space(child::*[local-name() = 'name'])"/>
          </xsl:variable>
          <xsl:element name="name">
            <xsl:value-of select="$curChildFilterName"/>
          </xsl:element>
          <xsl:variable name="childFilter" select="//*[
            local-name() = 'enhanced-filter' and namespace-uri() ='urn:bbf:yang:bbf-qos-enhanced-filters'
            and parent::*[local-name() = 'filters' and namespace-uri() = 'urn:bbf:yang:bbf-qos-filters']
            and child::*[local-name() = 'name'] = $curChildFilterName
          ]"/>
          <xsl:variable name="colorVar">
            <xsl:call-template name="getEnhancedFilterColor">
              <xsl:with-param name="enhancedFilterName" select="$curChildFilterName"/>
            </xsl:call-template>
          </xsl:variable>
          <xsl:element name="color">
            <xsl:value-of select="$colorVar"/>
          </xsl:element>
        </xsl:element>
      </xsl:for-each>
    </xsl:copy>
  </xsl:template>

  <!-- Insert info on classifier -->
  <xsl:template match="*[
    local-name() = 'classifier'
    and parent::*[local-name() = 'classifiers']
    and ancestor::*[local-name() = 'classifiers']
    and ancestor::*[local-name() = 'policy']
    and ancestor::*[local-name() = 'current']
    and ancestor::*[local-name() = 'policy-profile']
    and ancestor::*[local-name() = 'qos-policy-profiles' and namespace-uri() = 'urn:bbf:yang:bbf-qos-policies']
  ]">
    <xsl:variable name="curClsName">
      <xsl:value-of select="current()/child::*[local-name() = 'name']"/>
    </xsl:variable>

    <xsl:variable name="classifier" select="//*[
    local-name() = 'classifier-entry'
    and parent::*[local-name() = 'classifiers' and namespace-uri() = 'urn:bbf:yang:bbf-qos-classifiers']
    and child::*[local-name() = 'name'] = $curClsName
    ]"/>

    <xsl:variable name="anyframeTypeVar">
      <xsl:call-template name="isAnyFrameFilter">
        <xsl:with-param name="classifierSec" select="$classifier"/>
      </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="filterOperationVar">
      <xsl:call-template name="getFilterOperation">
        <xsl:with-param name="classifierSec" select="$classifier"/>
      </xsl:call-template>
    </xsl:variable>

    <xsl:copy>
      <xsl:apply-templates select="@* | node()"/>

      <xsl:if test="$filterOperationVar and string-length($filterOperationVar) > 0">
        <xsl:element name="filter-operation">
          <xsl:value-of select="$filterOperationVar"/>
        </xsl:element>
      </xsl:if>

      <xsl:if test="$anyframeTypeVar and string-length($anyframeTypeVar) > 0">
        <xsl:element name="any-frame">
          <xsl:value-of select="$anyframeTypeVar"/>
        </xsl:element>
      </xsl:if>

    </xsl:copy>

  </xsl:template>

  <!-- Insert info on classifier actions-->
  <xsl:template match="
      *[
      local-name() = 'actions'
      and parent::*[local-name() = 'classifier']
      and ancestor::*[local-name() = 'classifiers']
      and ancestor::*[local-name() = 'policies']
      and ancestor::*[local-name() = 'current']
      and ancestor::*[local-name() = 'migration-cache']
      and ancestor::*[local-name() = 'policy-profile']
      and ancestor::*[local-name() = 'qos-policy-profiles' and namespace-uri() = 'urn:bbf:yang:bbf-qos-policies']
      ]">

    <xsl:variable name="curClsName">
      <xsl:value-of select="../child::*[local-name() = 'name']"/>
    </xsl:variable>
    <xsl:variable name="classifier" select="//*[
    local-name() = 'classifier-entry'
    and parent::*[local-name() = 'classifiers' and namespace-uri() = 'urn:bbf:yang:bbf-qos-classifiers']
    and child::*[local-name() = 'name'] = $curClsName
    ]"/>

    <xsl:copy>
      <xsl:for-each select="$classifier/child::*[local-name() = 'classifier-action-entry-cfg']">
        <xsl:variable name="actionTypeVariable">
          <xsl:call-template name="getActionType">
            <xsl:with-param name="actionSecParam" select="."/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:element name="action">
          <xsl:element name="type">
            <xsl:value-of select="$actionTypeVariable"/>
          </xsl:element>
          <xsl:if test="$actionTypeVariable = $A_POLICING">
            <xsl:variable name="policingProfileName">
              <xsl:value-of select="child::*[local-name() = 'policing']/child::*[local-name() = 'policing-profile']"/>
            </xsl:variable>
            <xsl:element name="policing-profile">
              <xsl:element name="name">
                <xsl:value-of select="$policingProfileName"/>
              </xsl:element>
              <xsl:element name="type">
                <xsl:call-template name="getPolicingProfileType">
                  <xsl:with-param name="policingProfileName" select="$policingProfileName"/>
                </xsl:call-template>
              </xsl:element>
            </xsl:element>
          </xsl:if>
        </xsl:element>
      </xsl:for-each>
    </xsl:copy>
  </xsl:template>

  <!-- Insert info on classifier filters -->
  <xsl:template match="
      *[
      local-name() = 'filters'
      and parent::*[local-name() = 'classifier']
      and ancestor::*[local-name() = 'classifiers']
      and ancestor::*[local-name() = 'policies']
      and ancestor::*[local-name() = 'current']
      and ancestor::*[local-name() = 'migration-cache']
      and ancestor::*[local-name() = 'policy-profile']
      and ancestor::*[local-name() = 'qos-policy-profiles' and namespace-uri() = 'urn:bbf:yang:bbf-qos-policies']
      ]">
    <xsl:variable name="curClsName">
      <xsl:value-of select="../child::*[local-name() = 'name']"/>
    </xsl:variable>
    <xsl:variable name="classifier" select="//*[
    local-name() = 'classifier-entry'
    and parent::*[local-name() = 'classifiers' and namespace-uri() = 'urn:bbf:yang:bbf-qos-classifiers']
    and child::*[local-name() = 'name'] = $curClsName
    ]"/>
    <xsl:variable name="inlineClassifierTypeVar">
      <xsl:if test="$classifier/child::*[local-name() = 'match-criteria']">
        <xsl:call-template name="getInlineFilterType">
          <xsl:with-param name="matchCriteriaSec"
                          select="$classifier/child::*[local-name() = 'match-criteria']"/>
        </xsl:call-template>
      </xsl:if>
    </xsl:variable>

    <xsl:variable name="enhClassifierTypeVar">
      <xsl:call-template name="getEnhClassifierType">
        <xsl:with-param name="classifierSec" select="$classifier"/>
      </xsl:call-template>
    </xsl:variable>

    <xsl:copy>
      <xsl:apply-templates select="@* | node()"/>

      <xsl:if test="$inlineClassifierTypeVar and string-length($inlineClassifierTypeVar) > 0">
        <xsl:element name="inline-filter-type">
          <xsl:value-of select="$inlineClassifierTypeVar"/>
        </xsl:element>
      </xsl:if>

      <xsl:if test="$enhClassifierTypeVar and string-length($enhClassifierTypeVar) > 0">
        <xsl:element name="enh-filter-type">
          <xsl:value-of select="$enhClassifierTypeVar"/>
        </xsl:element>
      </xsl:if>

      <xsl:if test="string-length($inlineClassifierTypeVar) > 0 or string-length($enhClassifierTypeVar) > 0">
        <xsl:element name="self-filter-types">
          <xsl:choose>
            <xsl:when test="string-length($inlineClassifierTypeVar) > 0 and string-length($enhClassifierTypeVar) > 0">
              <xsl:value-of select="concat($inlineClassifierTypeVar,',',$enhClassifierTypeVar)"/>
            </xsl:when>
            <xsl:when test="boolean($inlineClassifierTypeVar) and string-length($inlineClassifierTypeVar) > 0">
              <xsl:value-of select="$inlineClassifierTypeVar"/>
            </xsl:when>
            <xsl:when test="boolean($enhClassifierTypeVar) and string-length($enhClassifierTypeVar) > 0">
              <xsl:value-of select="$enhClassifierTypeVar"/>
            </xsl:when>
          </xsl:choose>
        </xsl:element>
      </xsl:if>

      <xsl:if test="
        ($inlineClassifierTypeVar = $F_FLOW_COLOR and (not($enhClassifierTypeVar) or $enhClassifierTypeVar = ''))
        or ($enhClassifierTypeVar = $F_FLOW_COLOR and (not($inlineClassifierTypeVar) or $inlineClassifierTypeVar = ''))
      ">
        <xsl:element name="self-filter-flow-color">
          <xsl:if test="$inlineClassifierTypeVar = $F_FLOW_COLOR">
            <xsl:variable name="flowColorVar">
              <xsl:value-of
                      select="$classifier/child::*[local-name() = 'match-criteria']/child::*[local-name() = 'flow-color']"/>
            </xsl:variable>
            <xsl:choose>
              <xsl:when test="$flowColorVar = 'green' or $flowColorVar = 'bbf-qos-plc:green'">
                <xsl:value-of select="$FLOW_COLOR_GREEN"/>
              </xsl:when>
              <xsl:when test="$flowColorVar = 'yellow' or $flowColorVar = 'bbf-qos-plc:yellow'">
                <xsl:value-of select="$FLOW_COLOR_YELLOW"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="$FLOW_COLOR_RED"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:if>
          <xsl:if test="$enhClassifierTypeVar = $F_FLOW_COLOR">
            <xsl:variable name="flowColorVar">
              <xsl:value-of select="$classifier/child::*[local-name() = 'flow-color']"/>
            </xsl:variable>
            <xsl:choose>
              <xsl:when test="$flowColorVar = 'green' or $flowColorVar = 'bbf-qos-plc:green'">
                <xsl:value-of select="$FLOW_COLOR_GREEN"/>
              </xsl:when>
              <xsl:when test="$flowColorVar = 'yellow' or $flowColorVar = 'bbf-qos-plc:yellow'">
                <xsl:value-of select="$FLOW_COLOR_YELLOW"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="$FLOW_COLOR_RED"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:if>
        </xsl:element>
      </xsl:if>
    </xsl:copy>
  </xsl:template>

  <!-- ========================= Infra Function ============================= -->
  <xsl:template name="isAnyFrameFilter">
    <xsl:param name="classifierSec"/>
    <xsl:if test="$classifierSec/child::*[local-name() = 'any-frame']">
      <xsl:value-of select="$F_ANY_FRAME"/>
    </xsl:if>
  </xsl:template>

  <xsl:template name="getFilterOperation">
    <xsl:param name="classifierSec"/>
    <xsl:if test="$classifierSec/child::*[local-name() = 'filter-operation']">
      <xsl:variable name="operationVar">
        <xsl:value-of
                select="normalize-space($classifierSec/child::*[local-name() = 'filter-operation'])"/>
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

  <!-- Function to get classifier action type -->
  <xsl:template name="getActionType">
    <xsl:param name="actionSecParam"/>
    <xsl:variable name="localActionTypeVar">
      <xsl:value-of select="normalize-space($actionSecParam/*[local-name() = 'action-type'])"/>
    </xsl:variable>
    <xsl:choose>
      <xsl:when
              test="$localActionTypeVar = 'pbit-marking' or $localActionTypeVar = 'bbf-qos-cls:pbit-marking'">
        <xsl:value-of select="$A_PBIT_MARKING"/>
      </xsl:when>
      <xsl:when
              test="$localActionTypeVar = 'dei-marking' or $localActionTypeVar = 'bbf-qos-cls:dei-marking'">
        <xsl:value-of select="$A_DEI_MARKING"/>
      </xsl:when>
      <xsl:when
              test="$localActionTypeVar = 'dscp-marking' or $localActionTypeVar = 'bbf-qos-cls:dscp-marking'">
        <xsl:value-of select="$A_DSCP_MARKING"/>
      </xsl:when>
      <xsl:when
              test="$localActionTypeVar = 'scheduling-traffic-class' or $localActionTypeVar = 'bbf-qos-cls:scheduling-traffic-class'">
        <xsl:value-of select="$A_SCHEDULING_TRAFFIC"/>
      </xsl:when>
      <xsl:when
              test="$localActionTypeVar = 'flow-color' or $localActionTypeVar = 'bbf-qos-plc:flow-color'">
        <xsl:value-of select="$A_FLOW_COLOR"/>
      </xsl:when>
      <xsl:when
              test="$localActionTypeVar = 'bac-color' or $localActionTypeVar = 'bbf-qos-plc:bac-color'">
        <xsl:value-of select="$A_BAC_COLOR"/>
      </xsl:when>
      <xsl:when
              test="$localActionTypeVar = 'discard' or $localActionTypeVar = 'bbf-qos-plc:discard'">
        <xsl:value-of select="$A_DISCARD"/>
      </xsl:when>
      <xsl:when
              test="$localActionTypeVar = 'policing' or $localActionTypeVar = 'bbf-qos-plc:policing'">
        <xsl:value-of select="$A_POLICING"/>
      </xsl:when>
      <xsl:when test="$localActionTypeVar = 'pass' or $localActionTypeVar = 'bbf-qos-cls:pass'">
        <xsl:value-of select="$A_PASS"/>
      </xsl:when>
      <xsl:when
              test="$localActionTypeVar = 'rate-limit-frames' or $localActionTypeVar = 'bbf-qos-rc:rate-limit-frames'">
        <xsl:value-of select="$A_RATE_LIMIT"/>
      </xsl:when>
      <xsl:when
              test="$localActionTypeVar = 'policing-traffic-class' or $localActionTypeVar = 'nokia-qos-cls-ext:policing-traffic-class'">
        <xsl:value-of select="$A_PBIT_POLICING_TC"/>
      </xsl:when>
      <xsl:when
              test="$localActionTypeVar = 'count' or $localActionTypeVar = 'nokia-qos-cls-ext:count'">
        <xsl:value-of select="$A_COUNT"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$A_UNKNOWN"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="getInlineFilterType">
    <xsl:param name="matchCriteriaSec"/>
    <xsl:variable name="inlineFilterVar">
      <xsl:if test="$matchCriteriaSec/child::*[local-name() = 'unmetered']">
        <xsl:value-of select="concat($F_UNMETERED ,',')"/>
      </xsl:if>
      <xsl:if test="$matchCriteriaSec/child::*[local-name() = 'flow-color']">
        <xsl:value-of select="concat($F_FLOW_COLOR , ',')"/>
      </xsl:if>
      <xsl:if test="$matchCriteriaSec/child::*[local-name() = 'dscp-range']">
        <xsl:value-of select="concat($F_DSCP_RANGE , ',')"/>
      </xsl:if>
      <xsl:if test="$matchCriteriaSec/child::*[local-name() = 'pbit-marking-list']">
        <xsl:value-of select="concat($F_PBIT_MARKING , ',')"/>
      </xsl:if>
      <xsl:if test="$matchCriteriaSec/child::*[local-name() = 'dei-marking-list']">
        <xsl:value-of select="concat($F_DEI_MARKING , ',')"/>
      </xsl:if>
      <xsl:if test="$matchCriteriaSec/child::*[local-name() = 'untagged']">
        <xsl:value-of select="concat($F_UNTAGGED , ',')"/>
      </xsl:if>
      <xsl:if test="$matchCriteriaSec/descendant::*[local-name() = 'in-pbit-list']">
        <xsl:value-of select="concat($F_IN_PBIT_LIST , ',')"/>
      </xsl:if>
      <xsl:if test="$matchCriteriaSec/descendant::*[local-name() = 'in-dei']">
        <xsl:value-of select="concat($F_IN_DEI , ',')"/>
      </xsl:if>
      <xsl:if test="$matchCriteriaSec/child::*[local-name() = 'protocol']">
        <xsl:choose>
          <xsl:when test="$matchCriteriaSec/child::*[local-name() = 'protocol'] = '0'">
            <xsl:value-of select="concat($F_PROTOCOL_IGMP , ',')"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="concat($F_PROTOCOL_NOT_IGMP , ',')"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:if>
      <xsl:if test="$matchCriteriaSec/child::*[local-name() = 'other-protocol']">
        <xsl:value-of select="concat($F_PROTOCOL_NOT_IGMP , ',')"/>
      </xsl:if>
      <xsl:if test="$matchCriteriaSec/child::*[local-name() = 'any-protocol']">
        <xsl:value-of select="concat($F_ANY_PROTOCOL , ',')"/>
      </xsl:if>
      <xsl:if test="$matchCriteriaSec/child::*[local-name() = 'match-all']">
        <xsl:value-of select="concat($F_MATCH_ALL , ',')"/>
      </xsl:if>
    </xsl:variable>

    <xsl:choose>
      <xsl:when test="string-length($inlineFilterVar) &gt; 0">
        <xsl:value-of select="substring($inlineFilterVar,0,string-length($inlineFilterVar))"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$inlineFilterVar"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="getEnhClassifierType">
    <xsl:param name="classifierSec"/>
    <xsl:variable name="enhClsTypeVar">
      <xsl:if test="$classifierSec/child::*[local-name() = 'flow-color']">
        <xsl:value-of select="concat($F_FLOW_COLOR,',')"/>
      </xsl:if>
      <xsl:if test="$classifierSec/child::*[local-name() = 'source-mac-address']">
        <xsl:value-of select="concat($F_EN_SOURCE_MAC,',')"/>
      </xsl:if>
      <xsl:if test="$classifierSec/child::*[local-name() = 'destination-mac-address']">
        <xsl:value-of select="concat($F_EN_DEST_MAC,',')"/>
      </xsl:if>
      <xsl:if test="$classifierSec/child::*[local-name() = 'ipv4']">
        <xsl:value-of select="concat($F_EN_IPV4,',')"/>
      </xsl:if>
      <xsl:if test="$classifierSec/child::*[local-name() = 'ipv6']">
        <xsl:value-of select="concat($F_EN_IPV6,',')"/>
      </xsl:if>
      <xsl:if test="$classifierSec/child::*[local-name() = 'ethernet-frame-type']">
        <xsl:variable name="local_ethernet_frame_type">
          <xsl:value-of select="normalize-space($classifierSec/child::*[local-name() = 'ethernet-frame-type'])"/>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="$local_ethernet_frame_type = '0'">
            <xsl:value-of select="$F_EN_ETHERNET_FRAME_TYPE_IPV4"/>
          </xsl:when>
          <xsl:when test="$local_ethernet_frame_type = '1'">
            <xsl:value-of select="$F_EN_ETHERNET_FRAME_TYPE_PPPOE"/>
          </xsl:when>
          <xsl:when test="$local_ethernet_frame_type = '2'">
            <xsl:value-of select="$F_EN_ETHERNET_FRAME_TYPE_IPV6"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$F_EN_ETHERNET_FRAME_TYPE_UNKNOWN"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:if>

      <xsl:if test="$classifierSec/child::*[local-name() = 'transport']">
        <xsl:value-of select="concat($F_EN_TRANSPORT,',')"/>
      </xsl:if>
      <xsl:if test="$classifierSec/child::*[local-name() = 'pbit-marking-list']">
        <xsl:value-of select="concat($F_PBIT_MARKING,',')"/>
      </xsl:if>
      <xsl:if test="$classifierSec/child::*[local-name() = 'dei-marking-list']">
        <xsl:value-of select="concat($F_DEI_MARKING,',')"/>
      </xsl:if>
      <xsl:if test="$classifierSec/child::*[local-name() = 'vlans']/child::*[local-name() = 'untagged']">
        <xsl:value-of select="concat($F_UNTAGGED,',')"/>
      </xsl:if>
      <xsl:if test="$classifierSec/child::*[local-name() = 'vlans']/child::*[local-name() = 'tag']/child::*[local-name() = 'in-pbit-list']">
        <xsl:value-of select="concat($F_IN_PBIT_LIST,',')"/>
      </xsl:if>
      <xsl:if test="$classifierSec/child::*[local-name() = 'vlans']/child::*[local-name() = 'tag']/child::*[local-name() = 'in-dei']">
        <xsl:value-of select="concat($F_IN_DEI,',')"/>
      </xsl:if>
      <xsl:if test="$classifierSec/child::*[local-name() = 'ip-common']">
        <xsl:if test="$classifierSec/child::*[local-name() = 'ip-common']/child::*[local-name() = 'dscp-range']">
          <xsl:value-of select="concat($F_DSCP_RANGE,',')"/>
        </xsl:if>
        <xsl:if test="$classifierSec/child::*[local-name() = 'ip-common']/child::*[local-name() = 'dscp']">
          <xsl:value-of select="concat($F_EN_IP_COMMON_DSCP,',')"/>
        </xsl:if>
        <xsl:if test="$classifierSec/child::*[local-name() = 'ip-common']/child::*[local-name() = 'protocol']">
          <xsl:variable name="ipcommon_protocol">
            <xsl:value-of
                    select="normalize-space($classifierSec/child::*[local-name() = 'ip-common']/child::*[local-name() = 'protocol'])"/>
          </xsl:variable>
          <xsl:choose>
            <xsl:when test="$ipcommon_protocol = $PROTOCAL_IGMP_IN_IP_HEAD">
              <xsl:value-of select="concat($F_EN_IP_COMMON_IGMP,',')"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="concat($F_EN_IP_COMMON_NOT_DSCP_DSCPRANGE_IGMP,',')"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:if>
      </xsl:if>
      <xsl:if test="$classifierSec/child::*[local-name() = 'protocol']">
        <xsl:variable name="protocol_var">
          <xsl:value-of select="$classifierSec/child::*[local-name() = 'protocol']"/>
        </xsl:variable>
        <!-- enum igmp mld dhcpv4 dhcpv6 pppoe-discovery icmpv6 nd arp cfm dot1x lacp -->
        <xsl:choose>
          <xsl:when test="$protocol_var = '0'">
            <xsl:value-of select="concat($F_PROTOCOL_IGMP,',')"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="concat($F_PROTOCOL_NOT_IGMP,',')"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:if>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="string-length($enhClsTypeVar) > 0">
        <xsl:value-of select="substring($enhClsTypeVar,0,string-length($enhClsTypeVar))"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$enhClsTypeVar"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="getPolicingProfileType">
    <xsl:param name="policingProfileName"/>
    <xsl:variable name="policingProfile" select="//*[
      local-name() = 'policing-profile'
      and parent::*[local-name() = 'policing-profiles' and namespace-uri() = 'urn:bbf:yang:bbf-qos-policing']
      and child::*[local-name() = 'name'] = $policingProfileName
    ]"/>
    <xsl:choose>
      <xsl:when test="$policingProfile/child::*[local-name() ='two-rate-three-color-marker-mef']">
        <xsl:choose>
          <xsl:when
                  test="$policingProfile/child::*[local-name() ='two-rate-three-color-marker-mef']/child::*[local-name() ='color-mode'] = $color-aware">
            <xsl:value-of select="$POLICING_TYPE_TRTCM_MEF_COLOR_AWARE"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$POLICING_TYPE_TRTCM_MEF_COLOR_BLIND"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="$policingProfile/child::*[local-name() ='two-rate-three-color-marker-with-cos']">
        <xsl:value-of select="$POLICING_TYPE_TRTCM_COS"/>
      </xsl:when>
      <xsl:when test="$policingProfile/child::*[local-name() ='two-rate-three-color-marker-mef-with-cos']">
        <xsl:value-of select="$POLICING_TYPE_TRTCM_MEF_COS"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$POLICING_TYPE_STB"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="getCurClassifierNamesByRefFilter">
    <xsl:param name="refFilterName"/>
    <xsl:param name="curSec"/>
    <xsl:for-each
            select="$curSec/policies/policy/classifiers/classifier[normalize-space(filters/ref-filter/name) = $refFilterName]">
      <xsl:value-of select="normalize-space(current()/name)"/>
    </xsl:for-each>
  </xsl:template>
</xsl:stylesheet>
