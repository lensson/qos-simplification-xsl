<?xml version="1.0" ?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:strip-space elements="*"/>
  <xsl:output method="xml" encoding="UTF-8" indent="yes"/>

  <!-- default rule -->
  <xsl:template match="*">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>

  <!-- dscp-range only support 'any'
    /bbf-qos-cls:classifiers/bbf-qos-cls:classifier-entry/bbf-qos-cls:match-criteria/bbf-qos-cls:dscp-range
  -->
  <xsl:template match="*[
        local-name() = 'dscp-range' and namespace-uri() = 'urn:bbf:yang:bbf-qos-classifiers'
        and current() != 'any'
        and parent::*[name() = 'match-criteria'] and namespace-uri() = 'urn:bbf:yang:bbf-qos-classifiers'
        and ancestor::*[name() = 'classifier-entry'] and namespace-uri() = 'urn:bbf:yang:bbf-qos-classifiers'
        and ancestor::*[name() = 'classifiers'] and namespace-uri() = 'urn:bbf:yang:bbf-qos-classifiers'
    ]">
    <xsl:copy>
      <xsl:value-of select="'any'"/>
    </xsl:copy>
  </xsl:template>

  <!-- protocol only support 'IGMP'
    /bbf-qos-cls:classifiers/bbf-qos-cls:classifier-entry/bbf-qos-cls:match-criteria/bbf-qos-cls:protocol
  -->
  <xsl:template match="*[
        local-name() = 'protocol' and namespace-uri() = 'urn:bbf:yang:bbf-qos-classifiers'
        and current() != 'igmp'
        and parent::*[name() = 'match-criteria'] and namespace-uri() = 'urn:bbf:yang:bbf-qos-classifiers'
        and ancestor::*[name() = 'classifier-entry'] and namespace-uri() = 'urn:bbf:yang:bbf-qos-classifiers'
        and ancestor::*[name() = 'classifiers'] and namespace-uri() = 'urn:bbf:yang:bbf-qos-classifiers'
    ]">
    <xsl:copy>
      <xsl:value-of select="'igmp'"/>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
