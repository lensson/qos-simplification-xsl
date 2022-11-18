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

  <!-- Delete unsupported nodes under
    /bbf-qos-cls:classifiers/bbf-qos-cls:classifier-entry
    /bbf-qos-cls:match-criteria/nokia-qos-filt:other-protocol
  -->
  <xsl:template match="*[
        local-name() = 'other-protocol' and namespace-uri() = 'http://www.nokia.com/Fixed-Networks/BBA/yang/nokia-qos-filters-ext'
        and parent::*[name() = 'match-criteria'] and namespace-uri() = 'urn:bbf:yang:bbf-qos-classifiers'
        and ancestor::*[name() = 'classifier-entry'] and namespace-uri() = 'urn:bbf:yang:bbf-qos-classifiers'
        and ancestor::*[name() = 'classifiers'] and namespace-uri() = 'urn:bbf:yang:bbf-qos-classifiers'
    ]">
  </xsl:template>

  <!-- Delete unsupported nodes under
    /bbf-qos-cls:classifiers/bbf-qos-cls:classifier-entry/
    bbf-qos-cls:filter-method/bbf-qos-filt:filter
  -->
  <xsl:template match="*[
        local-name() = 'filter' and namespace-uri() = 'urn:bbf:yang:bbf-qos-filters'
        and parent::*[name() = 'match-criteria'] and namespace-uri() = 'urn:bbf:yang:bbf-qos-classifiers'
        and ancestor::*[name() = 'classifier-entry'] and namespace-uri() = 'urn:bbf:yang:bbf-qos-classifiers'
        and ancestor::*[name() = 'classifiers'] and namespace-uri() = 'urn:bbf:yang:bbf-qos-classifiers'
    ]">
  </xsl:template>

  <!-- Delete unsupported nodes under
    /bbf-qos-cls:classifiers/bbf-qos-cls:classifier-entry
    /bbf-qos-cls:classifier-action-entry-cfg/bbf-qos-cls:dscp-marking-cfg
  -->
  <xsl:template match="*[
        local-name() = 'dscp-marking-cfg' and namespace-uri() = 'urn:bbf:yang:bbf-qos-classifiers'
        and parent::*[name() = 'classifier-action-entry-cfg'] and namespace-uri() = 'urn:bbf:yang:bbf-qos-classifiers'
        and ancestor::*[name() = 'classifier-entry'] and namespace-uri() = 'urn:bbf:yang:bbf-qos-classifiers'
        and ancestor::*[name() = 'classifiers'] and namespace-uri() = 'urn:bbf:yang:bbf-qos-classifiers'
    ]">
  </xsl:template>

  <!-- Delete unsupported nodes under
    /bbf-qos-filt:filters/bbf-qos-filt:filter
  -->
  <xsl:template match="*[
        local-name() = 'filter' and namespace-uri() = 'urn:bbf:yang:bbf-qos-filters'
        and parent::*[name() = 'filters'] and namespace-uri() = 'urn:bbf:yang:bbf-qos-filters'
    ]">
  </xsl:template>

  <!-- Delete unsupported nodes under
    /bbf-qos-plc:policing-profiles/bbf-qos-plc:policing-profile/bbf-qos-plc:hierarchical-policing
  -->
  <xsl:template match="*[
        local-name() = 'hierarchical-policing' and namespace-uri() = 'urn:bbf:yang:bbf-qos-policing'
        and parent::*[name() = 'policing-profile'] and namespace-uri() = 'urn:bbf:yang:bbf-qos-policing'
        and ancestor::*[name() = 'policing-profiles'] and namespace-uri() = 'urn:bbf:yang:bbf-qos-policing'
    ]">
  </xsl:template>

  <!-- Delete unsupported nodes under
    /if:interfaces/if:interface/bbf-qos-tm:tm-root/bbf-qos-tm:queue/bbf-qos-tm:pre-emption
  -->
  <xsl:template match="*[
        local-name() = 'pre-emption' and namespace-uri() = 'urn:bbf:yang:bbf-qos-traffic-mngt'
        and parent::*[name() = 'queue'] and namespace-uri() = 'urn:bbf:yang:bbf-qos-traffic-mngt'
        and ancestor::*[name() = 'tm-root'] and namespace-uri() = 'urn:bbf:yang:bbf-qos-traffic-mngt'
        and ancestor::*[name() = 'interface'] and namespace-uri() = 'urn:ietf:params:xml:ns:yang:ietf-interfaces'
        and ancestor::*[name() = 'interfaces'] and namespace-uri() = 'urn:ietf:params:xml:ns:yang:ietf-interfaces'
    ]">
  </xsl:template>

  <!-- Delete unsupported nodes under
    /if:interfaces/if:interface/bbf-qos-tm:tm-root/bbf-qos-sched:scheduler-node/bbf-qos-sched:queue/bbf-qos-sched:pre-emption
  -->
  <xsl:template match="*[
        local-name() = 'pre-emption' and namespace-uri() = 'urn:bbf:yang:bbf-qos-enhanced-scheduling'
        and parent::*[name() = 'queue'] and namespace-uri() = 'urn:bbf:yang:bbf-qos-enhanced-scheduling'
        and ancestor::*[name() = 'scheduler-node'] and namespace-uri() = 'urn:bbf:yang:bbf-qos-enhanced-scheduling'
        and ancestor::*[name() = 'tm-root'] and namespace-uri() = 'urn:bbf:yang:bbf-qos-traffic-mngt'
        and ancestor::*[name() = 'interface'] and namespace-uri() = 'urn:ietf:params:xml:ns:yang:ietf-interfaces'
        and ancestor::*[name() = 'interfaces'] and namespace-uri() = 'urn:ietf:params:xml:ns:yang:ietf-interfaces'
    ]">
  </xsl:template>

  <!--
    /bbf-qos-filt:filters/bbf-qos-enhfilt:enhanced-filter/bbf-qos-enhfilt:filter
    /bbf-qos-enhfilt:source-mac-address/bbf-qos-enhfilt:any-multicast-mac-address
  -->
  <xsl:template match="*[
        local-name() = 'any-multicast-mac-address' and namespace-uri() = 'urn:bbf:yang:bbf-qos-enhanced-filters'
        and parent::*[name() = 'source-mac-address'] and namespace-uri() = 'urn:bbf:yang:bbf-qos-enhanced-filters'
        and ancestor::*[name() = 'filter'] and namespace-uri() = 'urn:bbf:yang:bbf-qos-enhanced-filters'
        and ancestor::*[name() = 'enhanced-filter'] and namespace-uri() = 'urn:bbf:yang:bbf-qos-enhanced-filters'
        and ancestor::*[name() = 'filters'] and namespace-uri() = 'urn:bbf:yang:bbf-qos-filters'
    ]">
  </xsl:template>

  <!--
    /bbf-qos-filt:filters/bbf-qos-enhfilt:enhanced-filter/bbf-qos-enhfilt:filter
    /bbf-qos-enhfilt:source-mac-address/bbf-qos-enhfilt:unicast-address
  -->
  <xsl:template match="*[
        local-name() = 'unicast-address' and namespace-uri() = 'urn:bbf:yang:bbf-qos-enhanced-filters'
        and parent::*[name() = 'source-mac-address'] and namespace-uri() = 'urn:bbf:yang:bbf-qos-enhanced-filters'
        and ancestor::*[name() = 'filter'] and namespace-uri() = 'urn:bbf:yang:bbf-qos-enhanced-filters'
        and ancestor::*[name() = 'enhanced-filter'] and namespace-uri() = 'urn:bbf:yang:bbf-qos-enhanced-filters'
        and ancestor::*[name() = 'filters'] and namespace-uri() = 'urn:bbf:yang:bbf-qos-filters'
    ]">
  </xsl:template>

  <!--
    /bbf-qos-filt:filters/bbf-qos-enhfilt:enhanced-filter/bbf-qos-enhfilt:filter
    /bbf-qos-enhfilt:destination-mac-address/bbf-qos-enhfilt:any-multicast-mac-address
  -->
  <xsl:template match="*[
        local-name() = 'any-multicast-mac-address' and namespace-uri() = 'urn:bbf:yang:bbf-qos-enhanced-filters'
        and parent::*[name() = 'destination-mac-address'] and namespace-uri() = 'urn:bbf:yang:bbf-qos-enhanced-filters'
        and ancestor::*[name() = 'filter'] and namespace-uri() = 'urn:bbf:yang:bbf-qos-enhanced-filters'
        and ancestor::*[name() = 'enhanced-filter'] and namespace-uri() = 'urn:bbf:yang:bbf-qos-enhanced-filters'
        and ancestor::*[name() = 'filters'] and namespace-uri() = 'urn:bbf:yang:bbf-qos-filters'
    ]">
  </xsl:template>

  <!--
    /bbf-qos-filt:filters/bbf-qos-enhfilt:enhanced-filter/bbf-qos-enhfilt:filter
    /bbf-qos-enhfilt:destination-mac-address/bbf-qos-enhfilt:unicast-address
  -->
  <xsl:template match="*[
        local-name() = 'unicast-address' and namespace-uri() = 'urn:bbf:yang:bbf-qos-enhanced-filters'
        and parent::*[name() = 'destination-mac-address'] and namespace-uri() = 'urn:bbf:yang:bbf-qos-enhanced-filters'
        and ancestor::*[name() = 'filter'] and namespace-uri() = 'urn:bbf:yang:bbf-qos-enhanced-filters'
        and ancestor::*[name() = 'enhanced-filter'] and namespace-uri() = 'urn:bbf:yang:bbf-qos-enhanced-filters'
        and ancestor::*[name() = 'filters'] and namespace-uri() = 'urn:bbf:yang:bbf-qos-filters'
    ]">
  </xsl:template>

</xsl:stylesheet>
