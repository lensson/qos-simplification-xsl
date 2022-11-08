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

  <xsl:template match="*">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="*[local-name() = 'new']">
    <xsl:copy>
      <xsl:for-each select="node()">
        <xsl:call-template name="nsDoer">
          <xsl:with-param name="curNode" select="current()"/>
        </xsl:call-template>
      </xsl:for-each>
    </xsl:copy>
  </xsl:template>

  <xsl:template name="nsDoer">
    <xsl:param name="curNode"/>
    <xsl:choose>
      <xsl:when test="local-name()">
        <xsl:element name="{local-name()}">
          <xsl:for-each select="node()">
            <xsl:call-template name="nsDoer">
              <xsl:with-param name="curNode" select="current()"/>
            </xsl:call-template>
          </xsl:for-each>
        </xsl:element>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="current()"/>
      </xsl:otherwise>
    </xsl:choose>

  </xsl:template>

  <xsl:template match="comment()">
    <xsl:copy>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
