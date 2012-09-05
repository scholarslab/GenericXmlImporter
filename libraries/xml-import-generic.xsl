<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="1.0">
    <xsl:output method="text" encoding="UTF-8"/>
    <xsl:param name="node"/>

    <xsl:template match="/">
        <xsl:apply-templates select="descendant::node()[name() = $node]" mode="record"/>
    </xsl:template>

    <xsl:template match="node()" mode="record">
        <xsl:variable name="singlequote">&#x0027;</xsl:variable>

        <xsl:if test="position() = 1">
            <xsl:for-each select="child::node()[name()]">
                <xsl:value-of select="name()"/>
                <xsl:if test="not(position() = last())">
                    <xsl:text>,</xsl:text>
                </xsl:if>
            </xsl:for-each>
            <xsl:text>
            </xsl:text>
        </xsl:if>
        <xsl:for-each select="child::node()[name()]">
            <xsl:text>"</xsl:text>
            <xsl:value-of select="normalize-space(translate(., '&#x0022;', $singlequote))"/>
            <xsl:text>"</xsl:text>
            <xsl:if test="not(position() = last())">
                <xsl:text>,</xsl:text>
            </xsl:if>
        </xsl:for-each>
        <xsl:text>
        </xsl:text>
    </xsl:template>

</xsl:stylesheet>
