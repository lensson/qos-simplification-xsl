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
                version="1.0">

  <xsl:output method="xml" omit-xml-declaration="yes" indent="yes" encoding="UTF-8"/>
  <xsl:strip-space elements="*"/>

  <xsl:variable name="bbf-qos-enhfilt" select="'bbf-qos-enhfilt'"/>
  <xsl:variable name="bbf-qos-enhfilt-URI" select="'urn:bbf:yang:bbf-qos-enhanced-filters'"/>

  <xsl:template match="*">
    <xsl:variable name="parentName">
      <xsl:value-of select="name(..)"/>
    </xsl:variable>
    <xsl:variable name="curNamespace">
      <xsl:value-of select="namespace-uri(.)"/>
    </xsl:variable>
    <xsl:variable name="parentNamespace">
      <xsl:value-of select="namespace-uri(..)"/>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$curNamespace != $parentNamespace">
        <xsl:choose>
          <xsl:when test="not(child::*) and not(text())">
            <xsl:text disable-output-escaping="yes">&lt;</xsl:text>
            <xsl:value-of select="local-name()"/>
            <xsl:text disable-output-escaping="yes"> xmlns=&quot;</xsl:text>
            <xsl:value-of select="$curNamespace"/>
            <xsl:text disable-output-escaping="yes">&quot;/&gt;</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text disable-output-escaping="yes">&lt;</xsl:text>
            <xsl:value-of select="local-name()"/>
            <xsl:for-each select="attribute::node()">
              <xsl:choose>
                <xsl:when test="current()">
                  <xsl:text disable-output-escaping="yes"> </xsl:text>
                  <xsl:value-of select="local-name()"/>
                  <xsl:text disable-output-escaping="yes">="</xsl:text>
                  <xsl:value-of select="current()"/>
                  <xsl:text disable-output-escaping="yes">" </xsl:text>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:text disable-output-escaping="yes"> </xsl:text>
                  <xsl:value-of select="local-name()"/>
                  <xsl:text disable-output-escaping="yes"> </xsl:text>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:for-each>
            <xsl:text disable-output-escaping="yes"> xmlns=&quot;</xsl:text>
            <xsl:value-of select="$curNamespace"/>
            <xsl:text disable-output-escaping="yes">&quot;&gt;</xsl:text>
            <xsl:apply-templates/>
            <xsl:text disable-output-escaping="yes">&lt;/</xsl:text>
            <xsl:value-of select="local-name()"/>
            <xsl:text disable-output-escaping="yes">&gt;</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:element name="{local-name()}">
          <xsl:copy-of select="@*"/>
          <xsl:apply-templates/>
        </xsl:element>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Remove all wrap , space and namespace prefix in text -->

  <xsl:template match="text()">
    <xsl:variable name="result">
      <xsl:value-of select="normalize-space(.)"/>
    </xsl:variable>
    <xsl:variable name="ptag" select=".."/>
    <xsl:choose>
      <xsl:when test="contains($result,':')">
        <xsl:variable name="prefixCandidate">
          <xsl:value-of select="substring-before($result,':')"/>
        </xsl:variable>
        <xsl:message><xsl:value-of select="$prefixCandidate"/></xsl:message>
        <xsl:variable name="prefixVar">
          <xsl:call-template name="isPrefix">
            <xsl:with-param name="prefixStr" select="$prefixCandidate"/>
            <xsl:with-param name="parentSec" select="$ptag"/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:message>prefixVar : <xsl:value-of select="$prefixVar"/></xsl:message>
        <xsl:choose>
          <xsl:when test="$prefixVar and string-length($prefixVar)>0">
            <xsl:value-of select="substring-after($result,':')"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$result"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$result"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="isPrefix">
    <xsl:param name="parentSec"/>
    <xsl:param name="prefixStr"/>
    <xsl:for-each select="$parentSec/namespace::node()">
      <xsl:choose>
        <xsl:when test="local-name() = 'xml'"/>
        <xsl:when test="local-name() = $prefixStr">
          <xsl:value-of select="$prefixStr"/>
        </xsl:when>
      </xsl:choose>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="getParentDefaultNamespace">
    <xsl:param name="parentNode"/>
    <xsl:choose>
      <xsl:when test="local-name($parentNode) != name($parentNode)">
        <xsl:variable name="prefix">
          <xsl:value-of select="substring-before(name($parentNode),':')"/>
        </xsl:variable>
        <xsl:value-of select="namespace::*[name() = $prefix]"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="namespace::*[not(name())]"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


</xsl:stylesheet>