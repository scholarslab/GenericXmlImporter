<?xml version="1.0" encoding="UTF-8"?>
<!--
    Description : Convert a flat xml file to CSV format in order to import it automatically into
    Omeka via CsvImport.

    @copyright Daniel Berthereau, 2012-2013
    @copyright Scholars' Lab, 2010 [GenericXmlImporter v.1.0]
    @license http://www.apache.org/licenses/LICENSE-2.0.html
    @package XmlImport

    Notes
    - This sheet works only if all tags that are present in the first record are present in all
    records, even empty, and always in the same order.
    - Look the example xml_import_test.xml and the xml_import_test_automap.xml.
    - Warning: enclosure, delimiter, delimiter for multi-values and end of line are hard
    coded in Xml Import.

    TODO
    - Improve this xsl to allow a more flexible xml!
-->
<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="1.0">
    <xsl:output method="text" encoding="UTF-8"/>

    <!-- Parameters -->
    <!-- Default tag for each item. -->
    <xsl:param name="node" select="'record'"/>

    <!-- Default enclosure. -->
    <!-- No enclusure is needed when tabulation is used. -->
    <xsl:param name="enclosure"></xsl:param>

    <!-- Default delimiter. -->
    <!-- Tabulation is used by default, because it never appears in current files.
    CsvImport works fine with it, even if it's not allowed. -->
    <xsl:param name="delimiter"><xsl:text>&#x09;</xsl:text></xsl:param>

    <!-- Default delimiter for multivalued fields: control character 13 (Carriage return), the
    only allowed character in xml 1.0, with Tabulation and Line feed. -->
    <xsl:param name="delimiter_multivalues"><xsl:text>&#x0D;</xsl:text></xsl:param>

    <!-- End of line (Linux one because it's simpler and smarter). -->
    <xsl:param name="end_of_line"><xsl:text>&#x0A;</xsl:text></xsl:param>

    <!-- Main template. -->
    <xsl:template match="/">
        <xsl:apply-templates select="descendant::node()[name() = $node]" mode="record"/>
    </xsl:template>

    <xsl:template match="node()" mode="record">
        <!-- Headers for the first node only. -->
        <xsl:if test="position() = 1">
            <xsl:for-each select="child::node()[name()]">
                <xsl:value-of select="$enclosure" />
                <xsl:if test="@set">
                    <xsl:value-of select="@set"/>
                    <xsl:text>:</xsl:text>
                </xsl:if>
                <xsl:value-of select="name()"/>
                <xsl:value-of select="$enclosure" />
                <xsl:if test="not(position() = last())">
                    <xsl:value-of select="$delimiter" />
                </xsl:if>
            </xsl:for-each>
            <xsl:value-of select="$end_of_line" />
        </xsl:if>
        <!-- Lines. -->
        <xsl:for-each select="child::node()[name()]">
            <xsl:value-of select="$enclosure" />
            <xsl:choose>
                <!-- Unique value. -->
                <xsl:when test="count(child::node()[name()]) &lt;= 1">
                    <xsl:value-of select="normalize-space(.)"/>
                </xsl:when>
                <!-- Multiple values. -->
                <xsl:otherwise>
                    <xsl:for-each select="child::node()[name()]">
                        <xsl:value-of select="normalize-space(.)"/>
                        <xsl:if test="not(position() = last())">
                            <xsl:value-of select="$delimiter_multivalues" />
                        </xsl:if>
                    </xsl:for-each>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:value-of select="$enclosure" />
            <xsl:if test="not(position() = last())">
                <xsl:value-of select="$delimiter" />
            </xsl:if>
        </xsl:for-each>
        <xsl:value-of select="$end_of_line" />
    </xsl:template>

    <!-- Don't write anything else. -->
    <xsl:template match="text()" />

</xsl:stylesheet>
