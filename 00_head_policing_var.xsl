<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:strip-space elements="*"/>


  <!-- enum Policing type -->
  <xsl:variable name="POLICING_TYPE_TRTCM_MEF_COLOR_BLIND" select="'POLICING_TYPE_TRTCM_MEF_COLOR_BLIND'"/>
  <xsl:variable name="POLICING_TYPE_TRTCM_MEF_COLOR_AWARE" select="'POLICING_TYPE_TRTCM_MEF_COLOR_AWARE'"/>

  <xsl:variable name="POLICING_TYPE_TRTCM_COS" select="'POLICING_TYPE_TRTCM_COS'"/>
  <xsl:variable name="POLICING_TYPE_TRTCM_MEF_COS" select="'POLICING_TYPE_TRTCM_MEF_COS'"/>
  <xsl:variable name="POLICING_TYPE_STB" select="'POLICING_TYPE_STB'"/>

  <!-- Color mode -->
  <xsl:variable name="color-blind" select="'color-blind'"/>
  <xsl:variable name="color-aware" select="'color-aware'"/>

</xsl:stylesheet>
