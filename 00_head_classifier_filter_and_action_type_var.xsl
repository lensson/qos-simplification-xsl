<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:strip-space elements="*"/>

  <!-- Filter Type enumeration -->
  <!-- Inline filter enumeration -->
  <xsl:variable name="F_MATCH_ALL" select="'F_MATCH_ALL'"/>
  <xsl:variable name="F_ANY_PROTOCOL" select="'F_ANY_PROTOCOL'"/>
  <xsl:variable name="F_PRECEDENC_RANGE" select="'F_PRECEDENC_RANGE'"/>
  <xsl:variable name="F_UNMETERED" select="'F_UNMETERED'"/>
  <!-- inline and enhanced-classifier in common -->
  <xsl:variable name="F_UNTAGGED" select="'F_UNTAGGED'"/>
  <xsl:variable name="F_FLOW_COLOR" select="'F_FLOW_COLOR'"/>
  <xsl:variable name="F_DSCP_RANGE" select="'F_DSCP_RANGE'"/>
  <xsl:variable name="F_DSCP_ANY" select="'F_DSCP_ANY'"/>
  <xsl:variable name="F_PROTOCOL_IGMP" select="'F_PROTOCOL_IGMP'"/>
  <xsl:variable name="F_PROTOCOL_NOT_IGMP" select="'F_PROTOCOL_NOT_IGMP'"/>
  <xsl:variable name="F_IN_PBIT_LIST" select="'F_IN_PBIT_LIST'"/>
  <xsl:variable name="F_IN_DEI" select="'F_IN_DEI'"/>
  <xsl:variable name="F_PBIT_MARKING" select="'F_PBIT_MARKING'"/>
  <xsl:variable name="F_DEI_MARKING" select="'F_DEI_MARKING'"/>
  <!-- any frame filter enumeration -->
  <xsl:variable name="F_ANY_FRAME" select="'F_ANY_FRAME'"/>


  <!-- enhanced classifier enumeration -->
  <xsl:variable name="F_EN_SOURCE_MAC" select="'F_EN_SOURCE_MAC'"/>
  <xsl:variable name="F_EN_DEST_MAC" select="'F_EN_DEST_MAC'"/>
  <xsl:variable name="F_EN_ETHERNET_FRAME_TYPE" select="'F_EN_ETHERNET_FRAME_TYPE'"/>
  <xsl:variable name="F_EN_ETHERNET_FRAME_TYPE_IPV4" select="'F_EN_ETHERNET_FRAME_TYPE_IPV4'"/>
  <xsl:variable name="F_EN_ETHERNET_FRAME_TYPE_IPV6" select="'F_EN_ETHERNET_FRAME_TYPE_IPV6'"/>
  <xsl:variable name="F_EN_ETHERNET_FRAME_TYPE_PPPOE" select="'F_EN_ETHERNET_FRAME_TYPE_PPPOE'"/>
  <xsl:variable name="F_EN_ETHERNET_FRAME_TYPE_UNKNOWN" select="'F_EN_ETHERNET_FRAME_TYPE_UNKNOWN'"/>
  <xsl:variable name="F_EN_IPV4" select="'F_EN_IPV4'"/>
  <xsl:variable name="F_EN_IPV6" select="'F_EN_IPV6'"/>
  <xsl:variable name="F_EN_IP_COMMON_DSCP" select="'F_EN_IP_COMMON_DSCP'"/>
  <xsl:variable name="F_EN_IP_COMMON_IGMP" select="'F_EN_IP_COMMON_IGMP'"/>
  <xsl:variable name="F_EN_IP_COMMON_NOT_DSCP_DSCPRANGE_IGMP"
                select="'F_EN_IP_COMMON_NOT_DSCP_DSCPRANGE_IGMP'"/>
  <xsl:variable name="F_EN_TRANSPORT" select="'F_EN_TRANSPORT'"/>
  <xsl:variable name="F_PROTOCOL_ARP" select="'F_PROTOCOL_ARP'"/>
  <xsl:variable name="F_UNKNOWN" select="'F_UNKNOWN'"/>

  <!-- Classifier Action Type enumeration -->
  <xsl:variable name="A_PBIT_MARKING" select="'A_PBIT_MARKING'"/>
  <xsl:variable name="A_DEI_MARKING" select="'A_DEI_MARKING'"/>
  <xsl:variable name="A_DSCP_MARKING" select="'A_DSCP_MARKING'"/>
  <xsl:variable name="A_SCHEDULING_TRAFFIC" select="'A_SCHEDULING_TRAFFIC'"/>
  <xsl:variable name="A_FLOW_COLOR" select="'A_FLOW_COLOR'"/>
  <xsl:variable name="A_BAC_COLOR" select="'A_BAC_COLOR'"/>
  <xsl:variable name="A_DISCARD" select="'A_DISCARD'"/>
  <xsl:variable name="A_POLICING" select="'A_POLICING'"/>
  <xsl:variable name="A_PASS" select="'A_PASS'"/>
  <xsl:variable name="A_RATE_LIMIT" select="'A_RATE_LIMIT'"/>
  <xsl:variable name="A_PBIT_POLICING_TC" select="'A_PBIT_POLICING_TC'"/>
  <xsl:variable name="A_COUNT" select="'A_COUNT'"/>
  <xsl:variable name="A_UNKNOWN" select="'A_UNKNOWN'"/>

  <!-- filter-operation enumeration -->
  <xsl:variable name="OPER_MATCH_ANY" select="'OPER_MATCH_ANY'"/>
  <xsl:variable name="OPER_MATCH_ALL" select="'OPER_MATCH_ALL'"/>
  <xsl:variable name="OPER_UNKNOWN" select="'OPER_UNKNOWN'"/>
  <!-- ip common protocol value enumeration -->
  <xsl:variable name="PROTOCAL_IGMP_IN_IP_HEAD" select="'2'"/>

  <!-- ================================== Infra functions ================================== -->

  <xsl:template name="splitStringToItems">
    <xsl:param name="list" />
    <xsl:param name="delimiter" select="','"  />
    <xsl:variable name="_delimiter">
      <xsl:choose>
        <xsl:when test="string-length($delimiter)=0">,</xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$delimiter"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="newlist">
      <xsl:choose>
        <xsl:when test="contains($list, $_delimiter)">
          <xsl:value-of select="normalize-space($list)" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="concat(normalize-space($list), $_delimiter)"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="first" select="substring-before($newlist, $_delimiter)" />
    <xsl:variable name="remaining" select="substring-after($newlist, $_delimiter)" />
    <item>
      <xsl:value-of select="$first" />
    </item>
    <xsl:if test="$remaining">
      <xsl:call-template name="splitStringToItems">
        <xsl:with-param name="list" select="$remaining" />
        <xsl:with-param name="delimiter" select="$_delimiter" />
      </xsl:call-template>
    </xsl:if>
  </xsl:template>


  <xsl:template name="mergeActions">
    <xsl:param name="classifierSec"/>
    <xsl:for-each select="$classifierSec/child::*[local-name() = 'actions']/child::*[local-name() = 'action']/child::*[local-name() = 'type']">
      <xsl:choose>
        <xsl:when test="position() = 1">
          <xsl:value-of select="current()"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="','"/>
          <xsl:value-of select="current()"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:template>

</xsl:stylesheet>
