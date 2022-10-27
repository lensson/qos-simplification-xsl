<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                exclude-result-prefixes="nokia-qos-cls-ext"
                extension-element-prefixes="nokia-qos-cls-ext"
                xmlns:bbf-qos-pol="urn:bbf:yang:bbf-qos-policies"
                xmlns:bbf-qos-cls="urn:bbf:yang:bbf-qos-classifiers"
                xmlns:bbf-qos-plc="urn:bbf:yang:bbf-qos-policing"
                xmlns:nokia-sdan-qos-policing-extension="http://www.nokia.com/Fixed-Networks/BBA/yang/nokia-sdan-qos-policing-extension"
                xmlns=""
                version="1.0">

  <xsl:strip-space elements="*"/>
  <xsl:output method="xml" omit-xml-declaration="yes" indent="yes"/>

  <xsl:include href="00_head_classifier_filter_and_action_type_var.xsl"/>
  <xsl:include href="00_head_enhanced_filter_var.xsl"/>
  <xsl:include href="00_head_classifier_type_var.xsl"/>
  <xsl:include href="00_head_policy_type_var.xsl"/>
  <xsl:include href="00_head_policing_var.xsl"/>
  <!-- default rule -->

  <xsl:template match="*">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="*[
    local-name() = 'migration-cache'
    and parent::*[local-name() = 'policy-profile']
    and ancestor::*[local-name() = 'qos-policy-profiles' and namespace-uri() = 'urn:bbf:yang:bbf-qos-policies']
  ]">
    <xsl:variable name="profileName">
      <xsl:value-of select="../*[local-name() = 'name']"/>
    </xsl:variable>

    <xsl:variable name="cur" select="child::*[local-name() = 'current']"/>
    <xsl:variable name="enhancedFiltersSec" select="$cur/child::*[local-name() = 'enhanced-filters']"/>

    <!-- PreColor Policy to new policing pre-handling profile -->
    <xsl:variable name="curPreColorPolicySec" select="current/policies/policy[
      normalize-space(policy-type) = $POLICY_TYPE_COLOR
      and boolean(classifiers/classifier/classifier-type = $CLS_TYPE_ACTION_FLOW_COLOR)
    ]"/>
    <xsl:variable name="curPreColorPolicyName">
      <xsl:value-of select="$curPreColorPolicySec/name"/>
    </xsl:variable>
    <xsl:variable name="preColorPolicy" select="//*[
      local-name() = 'policy'
      and child::*[local-name() = 'name' and text() = $curPreColorPolicyName]
      and parent::*[local-name() = 'policies' and namespace-uri() = 'urn:bbf:yang:bbf-qos-policies']
    ]"/>

    <!-- PolicingTC Policy to new policing pre-handling profile -->
    <xsl:variable name="curPolicingTCPolicySec" select="current/policies/policy[
      normalize-space(policy-type) = $POLICY_TYPE_PBIT_POLICING_TC
    ]"/>
    <xsl:variable name="curPolicingTCPolicyName">
      <xsl:value-of select="$curPolicingTCPolicySec/name"/>
    </xsl:variable>
    <xsl:variable name="policingTCPolicy" select="//*[
      local-name() = 'policy'
      and child::*[local-name() = 'name' and text() = $curPolicingTCPolicyName]
      and parent::*[local-name() = 'policies' and namespace-uri() = 'urn:bbf:yang:bbf-qos-policies']
    ]"/>

    <!-- Action Policy to new queue Color policy -->
    <xsl:variable name="curActionPolicyOfQueueColorSec" select="current/policies/policy[
      policy-type = $POLICY_TYPE_ACTION
      and boolean(classifiers/classifier/classifier-type = $CLS_TYPE_ACTION_QUEUE_COLOR)
    ]"/>
    <xsl:variable name="curActionPolicySec" select="current/policies/policy[
      policy-type = $POLICY_TYPE_ACTION
    ]"/>
    <xsl:variable name="curActionPolicyName">
      <xsl:value-of select="$curActionPolicyOfQueueColorSec/name"/>
    </xsl:variable>
    <xsl:variable name="newActionBacColorPolicyName">
      <xsl:value-of select="concat('P_QC_',$curActionPolicyName)"/>
    </xsl:variable>
    <xsl:variable name="actionPolicy" select="//*[
      local-name() = 'policy'
      and child::*[local-name() = 'name' and text() = $curActionPolicyName]
      and parent::*[local-name() = 'policies' and namespace-uri() = 'urn:bbf:yang:bbf-qos-policies']
    ]"/>

    <!-- Schedule Policy to new queue Color policy -->
    <xsl:variable name="curSchedulePolicySec" select="current/policies/policy[
      policy-type = $POLICY_TYPE_SCHEDULE
    ]"/>
    <xsl:variable name="curSchedulePolicyOfQueueColorSec" select="current/policies/policy[
      policy-type = $POLICY_TYPE_SCHEDULE
      and boolean(classifiers/classifier/actions/action = $A_BAC_COLOR)
    ]"/>
    <xsl:variable name="curSchedulePolicyName">
      <xsl:value-of select="$curSchedulePolicySec/name"/>
    </xsl:variable>
    <xsl:variable name="newSchedulePolicyName">
      <xsl:value-of select="concat('P_',$curSchedulePolicyName)"/>
    </xsl:variable>
    <xsl:variable name="newScheduleBacColorPolicyName">
      <xsl:value-of select="concat('P_QC_',$curSchedulePolicyName)"/>
    </xsl:variable>
    <xsl:variable name="schedulePolicySec" select="../child::*[local-name() = 'policy-list'
      and child::*[ local-name() = 'name' and text() = $curSchedulePolicyName ]
    ]"/>
    <xsl:variable name="schedulePolicy" select="//*[
      local-name() = 'policy'
      and child::*[local-name() = 'name' and text() = $curSchedulePolicyName]
      and parent::*[local-name() = 'policies' and namespace-uri() = 'urn:bbf:yang:bbf-qos-policies']
    ]"/>

    <!-- Find port-policer policy in profile -->
    <xsl:variable name="curPortPolicerPolicySec" select="current/policies/policy[
      policy-type = $POLICY_TYPE_PORT_POLICER
    ]"/>

    <xsl:variable name="curPortPolicerPolicyName" select="$curPortPolicerPolicySec/name"/>
    <xsl:variable name="newPortPolicerPolicyName" select="concat('P_',$curPortPolicerPolicyName)"/>
    <xsl:variable name="newPortPolicerPolicyPolicingPorfileName" select="concat('PP_',$curPortPolicerPolicyName)"/>
    <xsl:variable name="portPolicerPolicy" select="//*[
      local-name() = 'policy'
      and child::*[local-name() = 'name' and text() = $curPortPolicerPolicyName]
      and parent::*[local-name() = 'policies' and namespace-uri() = 'urn:bbf:yang:bbf-qos-policies']
    ]"/>

    <!-- Find CCL policy in profile -->
    <xsl:variable name="curCCLPolicySec" select="current/policies/policy[
      policy-type = $POLICY_TYPE_CCL
    ]"/>
    <xsl:variable name="curCCLPolicyName" select="$curCCLPolicySec/name"/>
    <xsl:variable name="newCCLPolicyName" select="concat('P_',$curCCLPolicyName)"/>
    <xsl:variable name="CCLPolicy" select="//*[
      local-name() = 'policy'
      and child::*[local-name() = 'name' and text() = $curCCLPolicyName]
      and parent::*[local-name() = 'policies' and namespace-uri() = 'urn:bbf:yang:bbf-qos-policies']
    ]"/>

    <!-- Find original Marker Policy in profile to new section -->
    <xsl:variable name="curMarkerPolicyName">
      <xsl:value-of select="current/policies/policy[policy-type = $POLICY_TYPE_MARKER]/name"/>
    </xsl:variable>
    <xsl:variable name="markerPolicySec" select="../child::*[local-name() = 'policy-list'
      and child::*[ local-name() = 'name' and text() = $curMarkerPolicyName ]
    ]"/>

    <!-- Find original Queue Count Policy in profile to new section -->
    <xsl:variable name="curQueueCountPolicyName">
      <xsl:value-of select="current/policies/policy[policy-type = $POLICY_TYPE_COUNT]/name"/>
    </xsl:variable>
    <xsl:variable name="countPolicySec" select="../child::*[local-name() = 'policy-list'
      and child::*[ local-name() = 'name' and text() = $curQueueCountPolicyName ]
    ]"/>

    <xsl:copy>
      <xsl:apply-templates select="@* | node()"/>
      <!-- determine whether need to create a new policy-profile -->
      <xsl:if test="$curActionPolicyOfQueueColorSec or $curSchedulePolicyOfQueueColorSec
      or $curPortPolicerPolicySec">
        <xsl:element name="new">
          <xsl:element name="qos-policy-profiles" namespace="urn:bbf:yang:bbf-qos-policies">
            <xsl:element name="policy-profile">
              <xsl:element name="name">
                <xsl:value-of select="$profileName"/>
              </xsl:element>
              <!-- Move marker policy to new policy-profile -->
              <xsl:copy-of select="$markerPolicySec"/>
              <!-- Add CCL policy to policy-profile -->
              <xsl:if test="$curCCLPolicySec">
                <xsl:element name="policy-list">
                  <xsl:element name="name">
                    <xsl:value-of select="$newCCLPolicyName"/>
                  </xsl:element>
                </xsl:element>
              </xsl:if>
              <!-- Add port-policer policy to policy-profile -->
              <xsl:if test="$curPortPolicerPolicySec">
                <xsl:element name="policy-list">
                  <xsl:element name="name">
                    <xsl:value-of select="$newPortPolicerPolicyName"/>
                  </xsl:element>
                </xsl:element>
              </xsl:if>
              <!-- Add scheduler policy to policy-profile -->
              <xsl:if test="$curSchedulePolicyOfQueueColorSec">
                <xsl:element name="policy-list">
                  <xsl:element name="name">
                    <xsl:value-of select="$newSchedulePolicyName"/>
                  </xsl:element>
                </xsl:element>
                <xsl:element name="policy-list">
                  <xsl:element name="name">
                    <xsl:value-of select="$newScheduleBacColorPolicyName"/>
                  </xsl:element>
                </xsl:element>
              </xsl:if>
              <!-- Move schedule policy to new profile if no bac-color in it -->
              <xsl:if test="$curSchedulePolicySec and not($curSchedulePolicyOfQueueColorSec)">
                <xsl:copy-of select="$schedulePolicySec"/>
              </xsl:if>
              <!-- Add queue color policy to policy-profile -->
              <xsl:if test="$curActionPolicyOfQueueColorSec">
                <xsl:element name="policy-list">
                  <xsl:element name="name">
                    <xsl:value-of select="$newActionBacColorPolicyName"/>
                  </xsl:element>
                </xsl:element>
              </xsl:if>
              <!-- Move count policy to new profile -->
              <xsl:copy-of select="$countPolicySec"/>
            </xsl:element>
          </xsl:element>
          <xsl:element name="policies" namespace="urn:bbf:yang:bbf-qos-policies">
            <!-- Create Bac-color policy from action policy -->
            <xsl:if test="$curActionPolicyOfQueueColorSec">
              <xsl:element name="policy">
                <xsl:element name="name">
                  <xsl:value-of select="$newActionBacColorPolicyName"/>
                </xsl:element>
                <xsl:for-each select="$actionPolicy/node()">
                  <xsl:variable name="curClassifierName">
                    <xsl:value-of select="child::*[local-name() = 'name']"/>
                  </xsl:variable>
                  <xsl:if test="
                    local-name() = 'classifiers'
                    and boolean($curActionPolicyOfQueueColorSec/classifiers/classifier[name = $curClassifierName][classifier-type = $CLS_TYPE_ACTION_QUEUE_COLOR])
                  ">

                    <xsl:element name="classifiers" namespace="urn:bbf:yang:bbf-qos-policies">
                      <xsl:element name="name" namespace="urn:bbf:yang:bbf-qos-policies">
                        <xsl:value-of select="concat('C_',$curClassifierName)"/>
                      </xsl:element>
                    </xsl:element>
                  </xsl:if>
                </xsl:for-each>
              </xsl:element>
            </xsl:if>
            <xsl:if test="$curSchedulePolicyOfQueueColorSec">
              <!-- Create new schedule policy from current schedule policy -->
              <xsl:element name="policy">
                <xsl:element name="name">
                  <xsl:value-of select="$newSchedulePolicyName"/>
                </xsl:element>
                <xsl:for-each select="$schedulePolicy/node()">
                  <xsl:variable name="curClassifierName">
                    <xsl:value-of select="child::*[local-name() = 'name']"/>
                  </xsl:variable>
                  <xsl:if test="
                    local-name() = 'classifiers'
                    and boolean($curSchedulePolicySec/classifiers/classifier[name = $curClassifierName]/actions/action != $A_BAC_COLOR)
                  ">
                    <xsl:element name="classifiers" namespace="urn:bbf:yang:bbf-qos-policies">
                      <xsl:element name="name" namespace="urn:bbf:yang:bbf-qos-policies">
                        <xsl:value-of select="concat('C_',$curClassifierName)"/>
                      </xsl:element>
                    </xsl:element>
                  </xsl:if>
                </xsl:for-each>
              </xsl:element>
              <!-- Create new bac-color policy from schedule policy -->
              <xsl:element name="policy">
                <xsl:element name="name">
                  <xsl:value-of select="$newScheduleBacColorPolicyName"/>
                </xsl:element>
                <xsl:for-each select="$schedulePolicy/node()">
                  <xsl:variable name="curClassifierName">
                    <xsl:value-of select="child::*[local-name() = 'name']"/>
                  </xsl:variable>
                  <xsl:if test="
                    local-name() = 'classifiers'
                    and boolean($curSchedulePolicySec/classifiers/classifier[name = $curClassifierName]/actions/action = $A_BAC_COLOR)
                  ">
                    <xsl:element name="classifiers" namespace="urn:bbf:yang:bbf-qos-policies">
                      <xsl:element name="name" namespace="urn:bbf:yang:bbf-qos-policies">
                        <xsl:value-of select="concat('C_QC_',$curClassifierName)"/>
                      </xsl:element>
                    </xsl:element>
                  </xsl:if>
                </xsl:for-each>
              </xsl:element>
            </xsl:if>
            <xsl:if test="$curPortPolicerPolicySec">
              <xsl:element name="policy" namespace="urn:bbf:yang:bbf-qos-policies">
                <xsl:element name="name" namespace="urn:bbf:yang:bbf-qos-policies">
                  <xsl:value-of select="$newPortPolicerPolicyName"/>
                </xsl:element>
                <xsl:for-each select="$portPolicerPolicy/node()">
                  <xsl:variable name="curClassifierName">
                    <xsl:value-of select="child::*[local-name() = 'name']"/>
                  </xsl:variable>
                  <xsl:if test="
                    local-name() = 'classifiers'
                    and boolean($curPortPolicerPolicySec/classifiers/classifier[name = $curClassifierName])
                  ">
                    <xsl:element name="classifiers" namespace="urn:bbf:yang:bbf-qos-policies">
                      <xsl:element name="name" namespace="urn:bbf:yang:bbf-qos-policies">
                        <xsl:value-of select="concat('C_',$curClassifierName)"/>
                      </xsl:element>
                    </xsl:element>
                  </xsl:if>
                </xsl:for-each>
              </xsl:element>
            </xsl:if>
            <xsl:if test="$curCCLPolicySec">
              <xsl:element name="policy">
                <xsl:element name="name">
                  <xsl:value-of select="$newCCLPolicyName"/>
                </xsl:element>
                <xsl:for-each select="$CCLPolicy/node()">
                  <xsl:variable name="curClassifierName">
                    <xsl:value-of select="child::*[local-name() = 'name']"/>
                  </xsl:variable>
                  <xsl:if test="
                    local-name() = 'classifiers'
                    and boolean($curCCLPolicySec/classifiers/classifier[name = $curClassifierName])
                  ">
                    <xsl:element name="classifiers">
                      <xsl:element name="name">
                        <xsl:value-of select="concat('C_',$curClassifierName)"/>
                      </xsl:element>
                    </xsl:element>
                  </xsl:if>
                </xsl:for-each>
              </xsl:element>
            </xsl:if>
          </xsl:element>
          <xsl:element name="classifiers" namespace="urn:bbf:yang:bbf-qos-classifiers">
            <xsl:if test="$curActionPolicyOfQueueColorSec">
              <xsl:for-each
                      select="$curActionPolicyOfQueueColorSec/classifiers/classifier[classifier-type = $CLS_TYPE_ACTION_QUEUE_COLOR]">
                <xsl:variable name="curClassifier" select="//*[
                  local-name() = 'classifier-entry'
                  and parent::*[local-name() = 'classifiers' and namespace-uri() = 'urn:bbf:yang:bbf-qos-classifiers']
                  and child::*[local-name() = 'name' and text() = current()/name]
                ]"/>

                <xsl:element name="classifier-entry">
                  <xsl:element name="name">
                    <xsl:value-of select="concat('C_',$curClassifier/child::*[local-name() = 'name'])"/>
                  </xsl:element>
                  <xsl:for-each select="$curClassifier/node()">
                    <xsl:if test="local-name() != 'name' and local-name() != 'migration-cache'">
                      <xsl:copy-of select="."/>
                    </xsl:if>
                  </xsl:for-each>
                </xsl:element>
              </xsl:for-each>
            </xsl:if>
            <xsl:if test="$curSchedulePolicyOfQueueColorSec">
              <xsl:for-each select="$curSchedulePolicySec/classifiers/classifier">
                <xsl:variable name="hasBacColorAction">
                  <xsl:value-of select="boolean(current()/actions/action = $A_BAC_COLOR)"/>
                </xsl:variable>
                <xsl:variable name="hasNoBacColorAction">
                  <xsl:value-of select="boolean(current()/actions/action != $A_BAC_COLOR)"/>
                </xsl:variable>
                <xsl:variable name="curClassifier" select="//*[
                  local-name() = 'classifier-entry'
                  and parent::*[local-name() = 'classifiers' and namespace-uri() = 'urn:bbf:yang:bbf-qos-classifiers']
                  and child::*[local-name() = 'name' and text() = current()/name]
                ]"/>
                <!-- Create bac-color Classifier -->
                <xsl:if test="$hasBacColorAction">
                  <xsl:element name="classifier-entry">
                    <xsl:element name="name">
                      <xsl:value-of select="concat('C_QC_', $curClassifier/child::*[local-name() = 'name'])"/>
                    </xsl:element>
                    <xsl:for-each select="$curClassifier/node()">
                      <xsl:if test="local-name() != 'name' and local-name() != 'migration-cache'
                        and (local-name() != 'classifier-action-entry-cfg'
                        or (local-name() = 'classifier-action-entry-cfg' and boolean(child::*[local-name() = 'bac-color'])))">
                        <xsl:copy-of select="."/>
                      </xsl:if>
                    </xsl:for-each>
                  </xsl:element>
                </xsl:if>
                <xsl:if test="$hasNoBacColorAction">
                  <xsl:element name="classifier-entry">
                    <xsl:element name="name">
                      <xsl:value-of select="concat('C_',$curClassifier/child::*[local-name() = 'name'])"/>
                    </xsl:element>
                    <xsl:for-each select="$curClassifier/node()">
                      <xsl:if test="local-name() != 'name' and local-name() != 'migration-cache'
                        and (local-name() != 'classifier-action-entry-cfg'
                        or (local-name() = 'classifier-action-entry-cfg' and not(child::*[local-name() = 'bac-color'])))">
                        <xsl:copy-of select="."/>
                      </xsl:if>
                    </xsl:for-each>
                  </xsl:element>
                </xsl:if>
              </xsl:for-each>
            </xsl:if>
            <xsl:if test="$curPortPolicerPolicySec">
              <xsl:for-each select="$curPortPolicerPolicySec/classifiers/classifier">
                <xsl:variable name="classifier" select="//*[
                  local-name() = 'classifier-entry'
                  and parent::*[local-name() = 'classifiers' and namespace-uri() = 'urn:bbf:yang:bbf-qos-classifiers']
                  and child::*[local-name() = 'name' and text() = current()/name]
                ]"/>
                <xsl:element name="classifier-entry" namespace="urn:bbf:yang:bbf-qos-classifiers">
                  <xsl:element name="name" namespace="urn:bbf:yang:bbf-qos-classifiers">
                    <xsl:value-of select="concat('C_',$classifier/child::*[local-name() = 'name'])"/>
                  </xsl:element>
                  <xsl:for-each select="$classifier/node()">
                    <xsl:choose>
                      <xsl:when test="local-name() = 'name'">
                      </xsl:when>
                      <xsl:when test="local-name() = 'match-criteria'">
                        <xsl:if test="child::*[local-name() = 'unmetered']">
                          <xsl:element name="metered-flow" namespace="http://www.nokia.com/Fixed-Networks/BBA/yang/nokia-qos-filters-ext">false</xsl:element>
                        </xsl:if>
                      </xsl:when>
                      <xsl:when test="local-name() = 'classifier-action-entry-cfg'">
                        <xsl:copy>
                          <xsl:choose>
                            <xsl:when test="child::*[local-name() = 'policing']">
                              <xsl:for-each select="node()">
                                <xsl:choose>
                                  <xsl:when test="local-name() = 'policing'">
                                    <xsl:copy>
                                      <xsl:element name="policing-profile">
                                        <xsl:value-of
                                                select="$newPortPolicerPolicyPolicingPorfileName"/>
                                      </xsl:element>
                                    </xsl:copy>
                                  </xsl:when>
                                  <xsl:otherwise>
                                    <xsl:copy-of select="."/>
                                  </xsl:otherwise>
                                </xsl:choose>
                              </xsl:for-each>
                            </xsl:when>
                            <xsl:otherwise>
                              <xsl:copy-of select="."/>
                            </xsl:otherwise>
                          </xsl:choose>
                        </xsl:copy>
                      </xsl:when>
                      <xsl:otherwise>
                        <xsl:copy-of select="."/>
                      </xsl:otherwise>
                    </xsl:choose>
                  </xsl:for-each>
                </xsl:element>
              </xsl:for-each>
            </xsl:if>
            <xsl:if test="$curCCLPolicySec">
              <xsl:for-each select="$curCCLPolicySec/classifiers/classifier">
                <xsl:variable name="curClassifier" select="current()"/>
                <xsl:variable name="classifier" select="//*[
                  local-name() = 'classifier-entry'
                  and parent::*[local-name() = 'classifiers' and namespace-uri() = 'urn:bbf:yang:bbf-qos-classifiers']
                  and child::*[local-name() = 'name' and text() = current()/name]
                ]"/>
                <xsl:variable name="newPolicingProfileName">
                  <xsl:value-of select="concat('PP_', $curClassifier/child::*[local-name() = 'name'])"/>
                </xsl:variable>
                <xsl:element name="classifier-entry">
                  <xsl:element name="name">
                    <xsl:value-of select="concat('C_',$classifier/child::*[local-name() = 'name'])"/>
                  </xsl:element>
                  <xsl:copy-of select="$classifier/child::*[local-name() = 'filter-operation']"/>
                  <xsl:if test="$curClassifier/filters/enh-filter-type">
                    <xsl:element name="enhanced-filter-name" namespace="urn:bbf:yang:bbf-qos-enhanced-filters">
                      <xsl:value-of select="concat('EF_',$curClassifier/name)"/>
                    </xsl:element>
                  </xsl:if>
                  <xsl:for-each select="$classifier/node()">
                    <xsl:choose>
                      <xsl:when test="local-name() = 'any-frame'">
                        <xsl:copy-of select="."/>
                      </xsl:when>
                      <xsl:when test="local-name() = 'classifier-action-entry-cfg'">
                        <xsl:copy>
                          <xsl:for-each select="node()">
                            <xsl:choose>
                              <xsl:when test="local-name() = 'policing'">
                                <xsl:copy>
                                  <xsl:element name="policing-profile">
                                    <xsl:value-of select="$newPolicingProfileName"/>
                                  </xsl:element>
                                </xsl:copy>
                              </xsl:when>
                              <xsl:otherwise>
                                <xsl:copy-of select="."/>
                              </xsl:otherwise>
                            </xsl:choose>
                          </xsl:for-each>
                        </xsl:copy>
                      </xsl:when>
                    </xsl:choose>
                  </xsl:for-each>
                </xsl:element>
              </xsl:for-each>
            </xsl:if>
          </xsl:element>
          <xsl:element name="filters" namespace="urn:bbf:yang:bbf-qos-filters">
            <!-- Find classifiers has inline filter in CCL policy -->
            <xsl:for-each
                    select="$curCCLPolicySec/classifiers/classifier[string-length(normalize-space(filters/enh-filter-type)) > 0]">
              <xsl:variable name="classifier" select="//*[
                local-name() = 'classifier-entry'
                and parent::*[local-name() = 'classifiers' and namespace-uri() = 'urn:bbf:yang:bbf-qos-classifiers']
                and child::*[local-name() = 'name' and text() = current()/name]
              ]"/>
              <xsl:variable name="classifierName">
                <xsl:value-of select="current()/child::*[local-name() = 'name']"/>
              </xsl:variable>
              <xsl:variable name="inlineFilterType">
                <xsl:value-of
                        select="current()/child::*[local-name() = 'filters']/child::*[local-name() = 'inline-filter-type']"/>
              </xsl:variable>
              <xsl:variable name="enhFilterType">
                <xsl:value-of
                        select="current()/child::*[local-name() = 'filters']/child::*[local-name() = 'enh-filter-type']"/>
              </xsl:variable>
              <xsl:element name="enhanced-filter">
                <xsl:element name="name">
                  <xsl:value-of select="concat('EF_',current()/name)"/>
                </xsl:element>
                <xsl:element name="filter-operation" namespace="urn:bbf:yang:bbf-qos-classifiers">match-any-filter
                </xsl:element>
                <xsl:element name="filter">
                  <xsl:element name="name">
                    <xsl:value-of select="concat('F_',$classifierName)"/>
                  </xsl:element>
                  <xsl:choose>
                    <xsl:when test="$enhFilterType = $F_EN_IPV4 and $classifier/child::*[local-name() = 'ipv4']">
                      <xsl:copy-of select="$classifier/child::*[local-name() = 'ipv4']"/>
                    </xsl:when>
                    <xsl:when test="$enhFilterType = $F_EN_IPV6 and $classifier/child::*[local-name() = 'ipv6']">
                      <xsl:copy-of select="$classifier/ipv6"/>
                    </xsl:when>
                    <xsl:when test="$classifier/child::*[local-name() = 'source-mac-address']">
                      <xsl:copy-of select="$classifier/child::*[local-name() = 'source-mac-address']"/>
                    </xsl:when>
                    <xsl:when test="$classifier/child::*[local-name() = 'destination-mac-address']">
                      <xsl:copy-of select="$classifier/child::*[local-name() = 'destination-mac-address']"/>
                    </xsl:when>
                    <xsl:when test="$classifier/child::*[local-name() = 'vlans']">
                      <xsl:copy-of select="$classifier/child::*[local-name() = 'vlans']"/>
                    </xsl:when>
                    <xsl:when test="$classifier/child::*[local-name() = 'ip-common']">
                      <xsl:copy-of select="$classifier/child::*[local-name() = 'ip-common']"/>
                    </xsl:when>
                    <xsl:when test="$classifier/child::*[local-name() = 'transport']">
                      <xsl:copy-of select="$classifier/child::*[local-name() = 'transport']"/>
                    </xsl:when>
                    <xsl:when test="$classifier/child::*[local-name() = 'protocol']">
                      <xsl:copy-of select="$classifier/child::*[local-name() = 'protocol']"/>
                    </xsl:when>
                  </xsl:choose>
                </xsl:element>
              </xsl:element>
            </xsl:for-each>
          </xsl:element>
          <xsl:element name="policing-profiles" namespace="urn:bbf:yang:bbf-qos-policing">
            <!-- Find port policer global policing profile -->
            <xsl:if test="$curPortPolicerPolicySec">

              <!-- There should only 1 classifier in port policer, if others exist, ignore -->
              <xsl:variable name="curPortPolicerClassifier" select="$curPortPolicerPolicySec/classifiers/classifier"/>

              <xsl:variable name="curPolicingProfileName"
                            select="$curPortPolicerClassifier/actions/action/policing-profile/name"/>
              <xsl:variable name="curPolicingProfileType"
                            select="$curPortPolicerClassifier/actions/action/policing-profile/type"/>

              <xsl:variable name="policingProfile" select="//*[
                local-name() = 'policing-profile'
                and child::*[local-name() = 'name' and text() = $curPolicingProfileName]
                and parent::*[local-name() = 'policing-profiles' and namespace-uri() = 'urn:bbf:yang:bbf-qos-policing']
              ]"/>

              <xsl:if test="$policingProfile">
                <xsl:element name="policing-profile">
                  <xsl:element name="name">
                    <xsl:value-of select="$newPortPolicerPolicyPolicingPorfileName"/>
                  </xsl:element>
                  <xsl:for-each select="$policingProfile/node()">
                    <xsl:choose>
                      <xsl:when test="local-name() = 'name' or local-name() = 'migration-cache'">
                      </xsl:when>
                      <xsl:otherwise>
                        <xsl:copy-of select="."/>
                      </xsl:otherwise>
                    </xsl:choose>
                  </xsl:for-each>
                  <xsl:if test="$curPolicingProfileType = $POLICING_TYPE_TRTCM_MEF_COS or $curPolicingProfileType = $POLICING_TYPE_TRTCM_COS or $curPolicingProfileType = $POLICING_TYPE_TRTCM_MEF_COLOR_AWARE">
                    <xsl:element name="policing-pre-handling-profile">
                      <xsl:choose>
                        <xsl:when
                                test="$curPolicingProfileType = $POLICING_TYPE_TRTCM_COS or $curPolicingProfileType = $POLICING_TYPE_TRTCM_MEF_COS">
                          <xsl:value-of select="concat('PPHP_',$curPolicingTCPolicyName)"/>
                        </xsl:when>
                        <xsl:when test="$curPolicingProfileType = $POLICING_TYPE_TRTCM_MEF_COLOR_AWARE">
                          <xsl:value-of select="concat('PPHP_',$curPreColorPolicyName)"/>
                        </xsl:when>
                      </xsl:choose>
                    </xsl:element>
                  </xsl:if>
                  <xsl:if test="$curActionPolicySec and $curActionPolicySec/classifiers/classifier[filters/self-filter-types = $F_FLOW_COLOR and filters/inline-filter-type = $F_FLOW_COLOR and boolean(filters/self-filter-flow-color)]">
                    <xsl:element name="policing-action-profile">
                      <xsl:value-of select="concat('PAP_',$curPortPolicerPolicySec/name)"/>
                    </xsl:element>
                  </xsl:if>
                </xsl:element>
              </xsl:if>
            </xsl:if>

            <!-- Create policing-profile from CCL policy -->
            <xsl:if test="$curCCLPolicySec">
              <xsl:for-each select="$curCCLPolicySec/classifiers/classifier[actions/action/policing-profile]">
                <xsl:variable name="curClassifier" select="current()"/>
                <xsl:variable name="curClassifierName">
                  <xsl:value-of select="current()/child::*[local-name() = 'name']"/>
                </xsl:variable>
                <xsl:variable name="curRefFilterName">
                  <xsl:value-of select="$curClassifier/filters/ref-filter/name"/>
                </xsl:variable>
                <xsl:variable name="curEnhancedFilterSec" select="$enhancedFiltersSec/enhanced-filter[
                  name = $curRefFilterName
                  and child::*[local-name() = 'ref-by']/child::*[local-name() = 'filter']
                ]"/>
                <xsl:variable name="curPolicingProfileName">
                  <xsl:value-of select="current()/actions/action/policing-profile/name"/>
                </xsl:variable>
                <xsl:variable name="curPolicingProfileType">
                  <xsl:value-of select="current()/actions/action/policing-profile/type"/>
                </xsl:variable>
                <xsl:variable name="policingProfile" select="//*[
                  local-name() = 'policing-profile'
                  and child::*[local-name() = 'name' and text() = $curPolicingProfileName]
                  and parent::*[local-name() = 'policing-profiles' and namespace-uri() = 'urn:bbf:yang:bbf-qos-policing']
                ]"/>
                <xsl:variable name="newPolicingProfileName">
                  <xsl:value-of select="concat('PP_', $curClassifierName)"/>
                </xsl:variable>

                <xsl:element name="policing-profile">
                  <xsl:element name="name">
                    <xsl:value-of select="$newPolicingProfileName"/>
                  </xsl:element>
                  <xsl:for-each select="$policingProfile/node()">
                    <xsl:choose>
                      <xsl:when test="local-name() = 'name' or local-name() = 'migration-cache'">
                      </xsl:when>
                      <xsl:otherwise>
                        <xsl:copy-of select="."/>
                      </xsl:otherwise>
                    </xsl:choose>
                  </xsl:for-each>
                  <xsl:choose>
                    <xsl:when
                            test="$curPolicingProfileType = $POLICING_TYPE_TRTCM_COS or $curPolicingProfileType = $POLICING_TYPE_TRTCM_MEF_COS">
                      <xsl:element name="policing-pre-handling-profile"
                                   namespace="http://www.nokia.com/Fixed-Networks/BBA/yang/nokia-sdan-qos-policing-extension">
                        <xsl:value-of select="concat('PPHP_',$curPolicingTCPolicyName)"/>
                      </xsl:element>
                    </xsl:when>
                    <xsl:when test="$curPolicingProfileType = $POLICING_TYPE_TRTCM_MEF_COLOR_AWARE">
                      <xsl:element name="policing-pre-handling-profile"
                                   namespace="http://www.nokia.com/Fixed-Networks/BBA/yang/nokia-sdan-qos-policing-extension">
                        <xsl:value-of select="concat('PPHP_',$curPreColorPolicyName)"/>
                      </xsl:element>
                    </xsl:when>
                  </xsl:choose>
                  <xsl:choose>
                    <!-- The classifier has a root enhanced-filter and matched flow-color children -->
                    <xsl:when test="$curEnhancedFilterSec">
                      <xsl:element name="policing-action-profile"
                                   namespace="http://www.nokia.com/Fixed-Networks/BBA/yang/nokia-sdan-qos-policing-extension">
                        <xsl:value-of select="concat('PAP_',$curRefFilterName)"/>
                      </xsl:element>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:element name="policing-action-profile"
                                   namespace="http://www.nokia.com/Fixed-Networks/BBA/yang/nokia-sdan-qos-policing-extension">
                        <xsl:value-of select="concat('PAP_',$curPortPolicerPolicyName)"/>
                      </xsl:element>
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:element>
              </xsl:for-each>
            </xsl:if>
          </xsl:element>
          <xsl:element name="policing-pre-handling-profiles"
                       namespace="http://www.nokia.com/Fixed-Networks/BBA/yang/nokia-sdan-qos-policing-extension">
            <xsl:if test="$curPreColorPolicySec">
              <xsl:element name="pre-handling-profile">
                <xsl:element name="name">
                  <xsl:value-of select="concat('PPHP_',$curPreColorPolicyName)"/>
                </xsl:element>
                <xsl:for-each select="$curPreColorPolicySec/classifiers/classifier">
                  <xsl:variable name="preColorClassifier" select="//*[
                    local-name() = 'classifier-entry'
                    and child::*[local-name() = 'name' and text() = current()/name]
                    and parent::*[local-name() = 'classifiers' and namespace-uri() = 'urn:bbf:yang:bbf-qos-classifiers']
                  ]"/>
                  <xsl:element name="pre-handling-entry">
                    <xsl:element name="name">
                      <xsl:value-of select="concat('PHE_',$preColorClassifier/child::*[local-name() = 'name'])"/>
                    </xsl:element>
                    <xsl:if test="$preColorClassifier/child::*[local-name() = 'match-criteria']/child::*[local-name() = 'pbit-marking-list']">
                      <xsl:element name="match-params">
                        <xsl:element name="pbit-marking-list">
                          <xsl:element name="index">
                            <xsl:value-of
                                    select="$preColorClassifier/child::*[local-name() = 'match-criteria']/child::*[local-name() = 'pbit-marking-list']/child::*[local-name() = 'index']"/>
                          </xsl:element>
                          <xsl:element name="pbit-value">
                            <xsl:value-of
                                    select="$preColorClassifier/child::*[local-name() = 'match-criteria']/child::*[local-name() = 'pbit-marking-list']/child::*[local-name() = 'pbit-value']"/>
                          </xsl:element>
                        </xsl:element>
                      </xsl:element>
                    </xsl:if>
                    <xsl:element name="flow-color">
                      <xsl:value-of
                              select="$preColorClassifier/child::*[local-name() = 'classifier-action-entry-cfg']/child::*[local-name() = 'flow-color']"/>
                    </xsl:element>
                  </xsl:element>
                </xsl:for-each>
              </xsl:element>
            </xsl:if>
            <xsl:if test="$curPolicingTCPolicySec">
              <xsl:element name="pre-handling-profile">
                <xsl:element name="name">
                  <xsl:value-of select="concat('PPHP_',$curPolicingTCPolicyName)"/>
                </xsl:element>
                <xsl:for-each select="$curPolicingTCPolicySec/classifiers/classifier">
                  <xsl:variable name="policingTCClassifier" select="//*[
                    local-name() = 'classifier-entry'
                    and child::*[local-name() = 'name' and text() = current()/name]
                    and parent::*[local-name() = 'classifiers' and namespace-uri() = 'urn:bbf:yang:bbf-qos-classifiers']
                  ]"/>
                  <xsl:element name="pre-handling-entry">
                    <xsl:element name="name">
                      <xsl:value-of select="concat('PHE_',$policingTCClassifier/child::*[local-name() = 'name'])"/>
                    </xsl:element>
                    <xsl:if test="$policingTCClassifier/child::*[local-name() = 'match-criteria']/child::*[local-name() = 'pbit-marking-list']">
                      <xsl:element name="match-params">
                        <xsl:element name="pbit-marking-list">
                          <xsl:element name="index">
                            <xsl:value-of
                                    select="$policingTCClassifier/child::*[local-name() = 'match-criteria']/child::*[local-name() = 'pbit-marking-list']/child::*[local-name() = 'index']"/>
                          </xsl:element>
                          <xsl:element name="pbit-value">
                            <xsl:value-of
                                    select="$policingTCClassifier/child::*[local-name() = 'match-criteria']/child::*[local-name() = 'pbit-marking-list']/child::*[local-name() = 'pbit-value']"/>
                          </xsl:element>
                        </xsl:element>
                      </xsl:element>
                    </xsl:if>
                    <xsl:element name="policing-traffic-class">
                      <xsl:value-of
                              select="$policingTCClassifier/child::*[local-name() = 'classifier-action-entry-cfg']/child::*[local-name() = 'policing-traffic-class']"/>
                    </xsl:element>
                  </xsl:element>
                </xsl:for-each>
              </xsl:element>
            </xsl:if>
          </xsl:element>
          <xsl:element name="policing-action-profiles"
                       namespace="http://www.nokia.com/Fixed-Networks/BBA/yang/nokia-sdan-qos-policing-extension">

            <!-- Create global port policer policing action profile -->
            <xsl:if test="boolean($curPortPolicerPolicySec) and boolean($curActionPolicySec)">
              <xsl:variable name="curPolicingActionProfileName">
                <xsl:value-of select="concat('PAP_',$curPortPolicerPolicySec/name)"/>
              </xsl:variable>

              <!-- pap for port-policer policy -->
              <xsl:element name="action-profile">
                <xsl:element name="name">
                  <xsl:value-of select="$curPolicingActionProfileName"/>
                </xsl:element>
                <xsl:for-each
                        select="$curActionPolicySec/classifiers/classifier[filters/self-filter-types = $F_FLOW_COLOR and filters/inline-filter-type = $F_FLOW_COLOR and boolean(filters/self-filter-flow-color)]">
                  <xsl:variable name="curActionClassifierName">
                    <xsl:value-of select="name"/>
                  </xsl:variable>
                  <xsl:variable name="color">
                    <xsl:value-of
                            select="current()/child::*[local-name() = 'filters']/child::*[local-name() = 'self-filter-flow-color']"/>
                  </xsl:variable>
                  <xsl:variable name="classifierOfOnlyInlineFolowColor" select="//*[
                    local-name() = 'classifier-entry'
                    and parent::*[local-name() = 'classifiers' and namespace-uri() = 'urn:bbf:yang:bbf-qos-classifiers']
                    and child::*[local-name() = 'name'] = $curActionClassifierName
                  ]"/>
                  <xsl:if test="$classifierOfOnlyInlineFolowColor">
                    <xsl:element name="action">
                      <xsl:element name="flow-color">
                        <xsl:value-of select="$color"/>
                      </xsl:element>
                      <xsl:choose>
                        <xsl:when test="boolean(current()/actions/action/type = $A_PBIT_MARKING)">
                          <xsl:variable name="actionCfg"
                                        select="$classifierOfOnlyInlineFolowColor/child::*[local-name() = 'classifier-action-entry-cfg' and child::*[local-name() = 'action-type' and contains(text(),'pbit-marking')]]"/>
                          <xsl:element name="pbit-marking-list">
                            <xsl:element name="index">
                              <xsl:value-of
                                      select="$actionCfg/child::*[local-name() = 'pbit-marking-cfg']/child::*[local-name() = 'pbit-marking-list']/child::*[local-name() = 'index']"/>
                            </xsl:element>
                            <xsl:element name="pbit-value">
                              <xsl:value-of
                                      select="$actionCfg/child::*[local-name() = 'pbit-marking-cfg']/child::*[local-name() = 'pbit-marking-list']/child::*[local-name() = 'pbit-value']"/>
                            </xsl:element>
                          </xsl:element>
                        </xsl:when>
                        <xsl:when test="boolean(current()/actions/action/type = $A_DEI_MARKING)">
                          <xsl:variable name="actionCfg"
                                        select="$classifierOfOnlyInlineFolowColor/child::*[local-name() = 'classifier-action-entry-cfg' and child::*[local-name() = 'action-type' and contains(text(),'dei-marking')]]"/>
                          <xsl:element name="dei-marking-list">
                            <xsl:element name="index">
                              <xsl:value-of
                                      select="$actionCfg/child::*[local-name() = 'dei-marking-cfg']/child::*[local-name() = 'dei-marking-list']/child::*[local-name() = 'index']"/>
                            </xsl:element>
                            <xsl:element name="dei-value">
                              <xsl:value-of
                                      select="$actionCfg/child::*[local-name() = 'dei-marking-cfg']/child::*[local-name() = 'dei-marking-list']/child::*[local-name() = 'dei-value']"/>
                            </xsl:element>
                          </xsl:element>
                        </xsl:when>
                        <xsl:otherwise>
                          <xsl:element name="discard"/>
                        </xsl:otherwise>
                      </xsl:choose>
                      <xsl:if test="boolean(current()/actions/action/type = $A_BAC_COLOR)">
                        <xsl:variable name="actionCfg"
                                      select="$classifierOfOnlyInlineFolowColor/child::*[local-name() = 'classifier-action-entry-cfg' and child::*[local-name() = 'action-type' and contains(text(),'bac-color')]]"/>
                        <xsl:element name="bac-color">
                          <xsl:value-of select="$actionCfg/child::*[local-name() = 'bac-color']"/>
                        </xsl:element>
                      </xsl:if>
                    </xsl:element>
                  </xsl:if>
                </xsl:for-each>
              </xsl:element>
            </xsl:if>

            <!-- Create CCL rule policing action profile -->
            <xsl:if test="boolean($curCCLPolicySec) and boolean($curActionPolicySec)">

              <xsl:for-each select="$enhancedFiltersSec/enhanced-filter">
                <xsl:variable name="curRootFilter" select="current()"/>
                <xsl:variable name="curRootFilterName">
                  <xsl:value-of select="name"/>
                </xsl:variable>
                <xsl:variable name="hasRefBy" select="boolean($curRootFilter/ref-by/filter)"/>
                <xsl:if test="$hasRefBy = 'true'">
                  <xsl:element name="action-profile">
                    <xsl:element name="name">
                      <xsl:value-of select="concat('PAP_',$curRootFilterName)"/>
                    </xsl:element>
                    <xsl:for-each select="$curRootFilter/ref-by/filter">
                      <xsl:variable name="curChildFilterName">
                        <xsl:value-of select="child::*[local-name() = 'name']"/>
                      </xsl:variable>
                      <xsl:element name="action">
                        <xsl:element name="flow-color">
                          <xsl:value-of select="current()/color"/>
                        </xsl:element>
                        <xsl:variable name="curActionClassifier"
                                      select="$curActionPolicySec/classifiers/classifier[filters/ref-filter/name = $curChildFilterName and filters/ref-filter/ref = $curRootFilterName]"/>
                        <xsl:variable name="curActionClassifierName">
                          <xsl:value-of select="$curActionClassifier/name"/>
                        </xsl:variable>
                        <xsl:variable name="actionClassifier" select="//*[
                          local-name() = 'classifier-entry'
                          and parent::*[local-name() = 'classifiers' and namespace-uri() = 'urn:bbf:yang:bbf-qos-classifiers']
                          and child::*[local-name() = 'name'] = $curActionClassifierName
                        ]"/>
                        <xsl:choose>
                          <xsl:when test="$curActionClassifier/actions/action/type = $A_PBIT_MARKING">
                            <xsl:element name="pbit-marking-list">
                              <xsl:element name="index">
                                <xsl:value-of
                                        select="$actionClassifier/child::*[local-name() = 'classifier-action-entry-cfg']/child::*[local-name() = 'pbit-marking-cfg']/child::*[local-name() = 'pbit-marking-list']/child::*[local-name() = 'index']"/>
                              </xsl:element>
                              <xsl:element name="pbit-value">
                                <xsl:value-of
                                        select="$actionClassifier/child::*[local-name() = 'classifier-action-entry-cfg']/child::*[local-name() = 'pbit-marking-cfg']/child::*[local-name() = 'pbit-marking-list']/child::*[local-name() = 'pbit-value']"/>
                              </xsl:element>
                            </xsl:element>
                          </xsl:when>
                          <xsl:when test="$curActionClassifier/actions/action/type = $A_DEI_MARKING">
                            <xsl:element name="dei-marking-list">
                              <xsl:element name="index">
                                <xsl:value-of
                                        select="$actionClassifier/child::*[local-name() = 'classifier-action-entry-cfg']/child::*[local-name() = 'dei-marking-cfg']/child::*[local-name() = 'dei-marking-list']/child::*[local-name() = 'index']"/>
                              </xsl:element>
                              <xsl:element name="dei-value">
                                <xsl:value-of
                                        select="$actionClassifier/child::*[local-name() = 'classifier-action-entry-cfg']/child::*[local-name() = 'dei-marking-cfg']/child::*[local-name() = 'dei-marking-list']/child::*[local-name() = 'dei-value']"/>
                              </xsl:element>
                            </xsl:element>
                          </xsl:when>
                          <xsl:otherwise>
                            <xsl:element name="discard"/>
                          </xsl:otherwise>
                        </xsl:choose>
                        <xsl:if test="$curActionClassifier/actions/action/type = $A_BAC_COLOR">
                          <xsl:element name="bac-color">
                            <xsl:value-of
                                    select="$actionClassifier/child::*[local-name() = 'classifier-action-entry-cfg']/child::*[local-name() = 'bac-color']"/>
                          </xsl:element>
                        </xsl:if>
                      </xsl:element>
                    </xsl:for-each>
                  </xsl:element>
                </xsl:if>
              </xsl:for-each>

              <!--
              <xsl:for-each select="$enhancedFiltersSec/child::*[local-name() = 'enhanced-filter']">
                <xsl:if test="child::*[local-name() = 'type'] = $F_EN_FILTER_FLOW_COLOR and boolean(ref)">
                  <xsl:variable name="curFilterName">
                    <xsl:value-of select="name"/>
                  </xsl:variable>
                  <xsl:variable name="refFilterName">
                    <xsl:value-of select="ref"/>
                  </xsl:variable>

                  <xsl:variable name="actionClassifierName">
                    <xsl:call-template name="findCurClassifierByPolicyAndRefFilterName">
                      <xsl:with-param name="policySec" select="$curActionPolicySec"/>
                      <xsl:with-param name="refFilterName" select="$curFilterName"/>
                    </xsl:call-template>
                  </xsl:variable>

                  <xsl:variable name="cclClassifierName">
                    <xsl:call-template name="findCurClassifierByPolicyAndRefFilterName">
                      <xsl:with-param name="policySec" select="$curCCLPolicySec"/>
                      <xsl:with-param name="refFilterName" select="$refFilterName"/>
                    </xsl:call-template>
                  </xsl:variable>

                  <xsl:variable name="actionClassifier" select="//*[
                    local-name() = 'classifier-entry'
                    and parent::*[local-name() = 'classifiers' and namespace-uri() = 'urn:bbf:yang:bbf-qos-classifiers']
                    and child::*[local-name() = 'name']  = $actionClassifierName
                  ]"/>
                  <xsl:variable name="cclClassifier" select="//*[
                    local-name() = 'classifier-entry'
                    and parent::*[local-name() = 'classifiers' and namespace-uri() = 'urn:bbf:yang:bbf-qos-classifiers']
                    and child::*[local-name() = 'name'] = $cclClassifierName
                  ]"/>
                </xsl:if>
              </xsl:for-each>
              -->
            </xsl:if>
          </xsl:element>

        </xsl:element>
      </xsl:if>
    </xsl:copy>
  </xsl:template>

  <!-- ====================================== Infra Function ====================================== -->

  <xsl:template name="findCurClassifierByPolicyAndRefFilterName">
    <xsl:param name="policySec"/>
    <xsl:param name="refFilterName"/>

    <xsl:variable name="curClassifierSec" select="
      $policySec/classifiers/classifier[normalize-space(filters/ref-filter/name) = $refFilterName]
    "/>

    <xsl:value-of select="normalize-space($curClassifierSec/name)"/>

  </xsl:template>

  <xsl:template name="findEnhancedFilterFromCCLClassifier">
    <xsl:param name="curCCLClassifier"/>
    <xsl:param name="curEnhancedFiltersSec"/>
    <xsl:variable name="refFilterName" select="$curCCLClassifier/filters/ref-filter/name"/>
    <xsl:if test="$refFilterName">
      <xsl:variable name="curEnhancedFilterSec" select="$curEnhancedFiltersSec/enhanced-filter[name = $refFilterName]"/>
      <xsl:if test="$curEnhancedFilterSec and $curEnhancedFilterSec/ref-by/filter">
        <xsl:value-of select="$curEnhancedFilterSec/name"/>
      </xsl:if>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
