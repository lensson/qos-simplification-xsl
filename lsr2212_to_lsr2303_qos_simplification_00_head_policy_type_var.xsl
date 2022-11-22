<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:strip-space elements="*"/>


  <!-- enum PolicyType -->
  <xsl:variable name="POLICY_TYPE_MARKER" select="'POLICY_TYPE_MARKER'"/>
  <xsl:variable name="POLICY_TYPE_COLOR" select="'POLICY_TYPE_COLOR'"/>
  <xsl:variable name="POLICY_TYPE_CCL" select="'POLICY_TYPE_CCL'"/>
  <xsl:variable name="POLICY_TYPE_PORT_POLICER" select="'POLICY_TYPE_PORT_POLICER'"/>
  <xsl:variable name="POLICY_TYPE_ACTION" select="'POLICY_TYPE_ACTION'"/>
  <xsl:variable name="POLICY_TYPE_SCHEDULE" select="'POLICY_TYPE_SCHEDULE'"/>
  <xsl:variable name="POLICY_TYPE_RATE_LIMIT" select="'POLICY_TYPE_RATE_LIMIT'"/>
  <xsl:variable name="POLICY_TYPE_PBIT_POLICING_TC" select="'POLICY_TYPE_PBIT_POLICING_TC'"/>
  <xsl:variable name="POLICY_TYPE_COUNT" select="'POLICY_TYPE_COUNT'"/>
  <xsl:variable name="POLICY_TYPE_INVALID" select="'POLICY_TYPE_INVALID'"/>

  <!-- New Definition -->
  <xsl:variable name="POLICY_TYPE_QUEUE_COLOR" select="'POLICY_TYPE_QUEUE_COLOR'"/>
</xsl:stylesheet>
