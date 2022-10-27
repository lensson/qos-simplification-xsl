<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:strip-space elements="*"/>

  <!-- Classifier Type -->
  <!-- type 1 -->
  <xsl:variable name="CLS_TYPE_IGMP_TO_PBITMARKING" select="'CLS_TYPE_IGMP_TO_PBITMARKING'"/>
  <xsl:variable name="CLS_TYPE_UNTAGGED_TO_PBITMARKING" select="'CLS_TYPE_UNTAGGED_TO_PBITMARKING'"/>
  <xsl:variable name="CLS_TYPE_PBIT_TO_PBITMARKING" select="'CLS_TYPE_PBIT_TO_PBITMARKING'"/>
  <xsl:variable name="CLS_TYPE_DSCP_TO_PBITMARKING" select="'CLS_TYPE_DSCP_TO_PBITMARKING'"/>
  <!-- type 2 -->
  <xsl:variable name="CLS_TYPE_ACTION_FLOW_COLOR" select="'CLS_TYPE_ACTION_FLOW_COLOR'"/>
  <!-- type 3 -->
  <xsl:variable name="CLS_TYPE_PBIT_TO_POLICING_TC" select="'CLS_TYPE_PBIT_TO_POLICING_TC'"/>
  <!-- type 4 -->
  <xsl:variable name="CLS_TYPE_ACTION_WITH_POLICING" select="'CLS_TYPE_ACTION_WITH_POLICING'"/>
  <xsl:variable name="CLS_TYPE_ACTION_WITH_PASS" select="'CLS_TYPE_ACTION_WITH_PASS'"/>
  <xsl:variable name="CLS_TYPE_ACTION_WITH_DISCARD" select="'CLS_TYPE_ACTION_WITH_DISCARD'"/>
  <xsl:variable name="CLS_TYPE_ACTION_WITH_PBITMARKING_AND_FLOWCOLOR"
                select="'CLS_TYPE_ACTION_WITH_PBITMARKING_AND_FLOWCOLOR'"/>
  <xsl:variable name="CLS_TYPE_EN_FILTER_WITHOUT_FLOW_COLOR"
                select="'CLS_TYPE_EN_FILTER_WITHOUT_FLOW_COLOR'"/>
  <xsl:variable name="CLS_TYPE_EN_CLS_WITH_MAC_OR_IP_OR_PORT"
                select="'CLS_TYPE_EN_CLS_WITH_MAC_OR_IP_OR_PORT'"/>
  <xsl:variable name="CLS_TYPE_FILTER_WITH_PROTOCAL_NOT_IGMP"
                select="'CLS_TYPE_FILTER_WITH_PROTOCAL_NOT_IGMP'"/>
  <xsl:variable name="CLS_TYPE_DEI_MARKING_OR_IN_DEI_TO_PBIT_MARKING"
                select="'CLS_TYPE_DEI_MARKING_OR_IN_DEI_TO_PBIT_MARKING'"/>
  <xsl:variable name="CLS_TYPE_FILTER_MORE_THAN_TWO_TYPE_OF_ANYFRAME_DSCP_IGMP_PBIT"
                select="'CLS_TYPE_FILTER_MORE_THAN_TWO_TYPE_OF_ANYFRAME_DSCP_IGMP_PBIT'"/>
  <!-- type 5 -->
  <xsl:variable name="CLS_TYPE_UNMETERED_TO_POLICING" select="'CLS_TYPE_UNMETERED_TO_POLICING'"/>
  <xsl:variable name="CLS_TYPE_MATCHALL_TO_POLICING" select="'CLS_TYPE_MATCHALL_TO_POLICING'"/>
  <xsl:variable name="CLS_TYPE_ANYFRAME_CLS_TO_POLICING"
                select="'CLS_TYPE_ANYFRAME_CLS_TO_POLICING'"/>
  <!-- type 6 -->
  <xsl:variable name="CLS_TYPE_EN_FILTER_WITH_FOLOW_COLOR"
                select="'CLS_TYPE_EN_FILTER_WITH_FOLOW_COLOR'"/>
  <xsl:variable name="CLS_TYPE_FILTER_WITH_FLOW_COLOR" select="'CLS_TYPE_FILTER_WITH_FLOW_COLOR'"/>
  <!-- type 7 -->
  <xsl:variable name="CLS_TYPE_ACTION_COUNT" select="'CLS_TYPE_ACTION_COUNT'"/>
  <!-- type 8 -->
  <xsl:variable name="CLS_TYPE_ACTION_WITH_SCHEDULING_TC"
                select="'CLS_TYPE_ACTION_WITH_SCHEDULING_TC'"/>
  <!-- type 9 -->
  <xsl:variable name="CLS_TYPE_MATCHALL_TO_RATE_LIMIT" select="'CLS_TYPE_MATCHALL_TO_RATE_LIMIT'"/>
  <!-- type 10 -->
  <xsl:variable name="CLS_TYPE_ACTION_QUEUE_COLOR" select="'CLS_TYPE_ACTION_QUEUE_COLOR'"/>
  <!-- unknown type -->
  <xsl:variable name="CLS_TYPE_INVALID" select="'CLS_TYPE_INVALID'"/>

</xsl:stylesheet>
