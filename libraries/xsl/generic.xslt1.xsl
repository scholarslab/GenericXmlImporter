<?xml version="1.0" encoding="UTF-8"?>
<!--
    Description : Convert a flat xml file to CSV format in order to import it automatically into
    Omeka via CsvImportPlus.

    @copyright Daniel Berthereau, 2012-2015
    @copyright Scholars' Lab, 2010 [GenericXmlImporter v.1.0]
    @license http://www.apache.org/licenses/LICENSE-2.0.html
    @package XmlImport

    Notes
    - Look the example test_item.xml and the test_generic_automap.xml.
    - Warning: enclosure, delimiter (column, element, tag and file) and end of line are hard
    coded in Xml Import.
-->
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:exsl="http://exslt.org/common"

    exclude-result-prefixes="xs exsl"
    >
    <xsl:output method="text" encoding="UTF-8"/>

    <!-- Parameters -->
    <!-- The node used as a record. -->
    <xsl:param name="node" select="''"/>

    <!-- Headers are added by default. -->
    <xsl:param name="headers">true</xsl:param>

    <!-- Default enclosure. -->
    <!-- No enclusure is needed when tabulation is used. -->
    <xsl:param name="enclosure"></xsl:param>

    <!-- Default delimiter for columns. -->
    <!-- Tabulation is used by default, because it never appears in current files.
    Csv Import works fine with it, even if it's not allowed. -->
    <xsl:param name="delimiter"><xsl:text>&#x09;</xsl:text></xsl:param>

    <!-- Default delimiter for elements. -->
    <!-- Control character 13 (Carriage return), the only allowed character in xml 1.0, with
    Tabulation and Line feed. -->
    <xsl:param name="delimiter_element"><xsl:text>&#x0D;</xsl:text></xsl:param>

    <!-- Default delimiter for tags. -->
    <xsl:param name="delimiter_tag"><xsl:text>&#x0D;</xsl:text></xsl:param>

    <!-- Default delimiter for files. -->
    <xsl:param name="delimiter_file"><xsl:text>&#x0D;</xsl:text></xsl:param>

    <!-- End of line (Linux one because it's simpler and smarter). -->
    <xsl:param name="end_of_line"><xsl:text>&#x0A;</xsl:text></xsl:param>

    <!-- Constants -->
    <!-- The name of the node if node if not set. -->
    <xsl:variable name="nodename">
        <xsl:choose>
            <xsl:when test="$node != ''">
                <xsl:value-of select="$node" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="name(/*/*[1])" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>

    <!-- Get the list of all distincts elements from the list of all elements. -->
    <xsl:variable name="all_elements">
        <xsl:for-each select="//*[name() = $nodename]/*">
            <xsl:element name="element">
                <xsl:if test="@set != ''">
                    <xsl:value-of select="@set" />
                    <xsl:text>:</xsl:text>
                </xsl:if>
                <xsl:value-of select="name()" />
            </xsl:element>
        </xsl:for-each>
    </xsl:variable>
    <xsl:variable name="elements">
        <xsl:for-each select="exsl:node-set($all_elements)/element[not(. = preceding-sibling::*)]">
            <xsl:element name="element">
                <xsl:value-of select="." />
            </xsl:element>
        </xsl:for-each>
    </xsl:variable>

    <!-- Main template. -->
    <xsl:template match="/">
        <!-- Headers only if wanted. -->
        <xsl:if test="$headers = 'true'">
            <xsl:call-template name="headers" />
        </xsl:if>

        <xsl:apply-templates select="descendant::node()[name() = $nodename]"/>
    </xsl:template>

    <xsl:template name="headers">
        <xsl:for-each select="exsl:node-set($elements)/element">
            <xsl:value-of select="$enclosure" />
            <xsl:value-of select="."/>
            <xsl:value-of select="$enclosure" />
            <xsl:if test="not(position() = last())">
                <xsl:value-of select="$delimiter" />
            </xsl:if>
        </xsl:for-each>
        <xsl:value-of select="$end_of_line" />
    </xsl:template>

    <xsl:template match="node()">
        <xsl:variable name="record" select="." />

        <xsl:for-each select="exsl:node-set($elements)/element">
            <xsl:value-of select="$enclosure" />

            <xsl:variable name="element" select="." />
            <xsl:for-each select="
                $record/*[(not(contains($element, ':')) and name() = $element)]
                |
                $record/*[(contains($element, ':') and name() = substring-after($element, ':'))]
            ">
                <xsl:choose>
                    <!-- There are sub-values (<tags><tag>alpha</tag><tag>beta</tag></tags>. -->
                    <xsl:when test="*">
                        <xsl:for-each select="*">
                            <xsl:value-of select="normalize-space(.)"/>
                            <xsl:if test="not(position() = last())">
                                <xsl:call-template name="internal_separator" />
                            </xsl:if>
                        </xsl:for-each>
                    </xsl:when>
                    <!-- Simple values (but they can be multiple: <tag>gamma</tag><tag>delta</tag>). -->
                    <xsl:otherwise>
                        <xsl:value-of select="normalize-space(.)"/>
                        <xsl:if test="not(position() = last())">
                            <xsl:call-template name="internal_separator" />
                        </xsl:if>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>

            <xsl:value-of select="$enclosure" />
            <xsl:if test="not(position() = last())">
                <xsl:value-of select="$delimiter" />
            </xsl:if>
        </xsl:for-each>
        <xsl:value-of select="$end_of_line" />
    </xsl:template>

    <xsl:template name="internal_separator">
        <xsl:choose>
            <xsl:when test="name() = 'Tag'">
                <xsl:value-of select="$delimiter_tag" />
            </xsl:when>
            <xsl:when test="name() = 'File'">
                <xsl:value-of select="$delimiter_file" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$delimiter_element" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- Don't write anything else. -->
    <xsl:template match="text()" />

</xsl:stylesheet>
