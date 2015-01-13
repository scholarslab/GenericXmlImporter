<?xml version="1.0" encoding="UTF-8"?>
<!--
    Description : Convert a generic Xml file to "Mixed records" format in order
    to import it automatically into Omeka via Csv Import

    Notes:
    - Order of columns is not important for Csv Import.
    - To import values with multiple lines, use html format in Csv Import.

    @copyright Daniel Berthereau, 2012-2015
    @license http://www.apache.org/licenses/LICENSE-2.0.html
    @package Omeka/Plugins/XmlImport

-->

<xsl:stylesheet version="1.1"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:omeka="http://omeka.org/schemas/omeka-xml/v5">
    <xsl:output method="text" encoding="UTF-8"/>

    <!-- Parameters -->
    <!-- All headers are added by default. -->
    <xsl:param name="headers">true</xsl:param>

    <!-- Default enclosure. -->
    <!-- No enclosure is needed when tabulation is used. -->
    <xsl:param name="enclosure"></xsl:param>

    <!-- Default delimiter for columns. -->
    <!-- Tabulation is used by default, because it never appears in current files. -->
    <!-- For compatibility, use "delimiter" if set, else use delimiter_column. -->
    <xsl:param name="delimiter"><xsl:text></xsl:text></xsl:param>
    <xsl:param name="delimiter_column"><xsl:text>&#x09;</xsl:text></xsl:param>

    <!-- Default delimiter for elements. -->
    <!-- Control character 13 (Carriage return), the only allowed character in xml 1.0, with
    Tabulation and Line feed. -->
    <xsl:param name="delimiter_element"><xsl:text>&#x0D;</xsl:text></xsl:param>

    <!-- Default delimiter for tags. -->
    <xsl:param name="delimiter_tag"><xsl:text>&#x0D;</xsl:text></xsl:param>

    <!-- Default delimiter for files. -->
    <xsl:param name="delimiter_file"><xsl:text>&#x0D;</xsl:text></xsl:param>

    <!-- End of line (the Linux one, because it's simpler and smarter). -->
    <xsl:param name="end_of_line"><xsl:text>&#x0A;</xsl:text></xsl:param>

    <!-- Constantes -->
    <xsl:variable name="line_start">
        <xsl:value-of select="$enclosure"/>
    </xsl:variable>
    <xsl:variable name="separator">
        <xsl:value-of select="$enclosure"/>
        <xsl:choose>
            <xsl:when test="$delimiter != ''">
                <xsl:value-of select="$delimiter"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$delimiter_column"/>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:value-of select="$enclosure"/>
    </xsl:variable>
    <xsl:variable name="line_end">
        <xsl:value-of select="$enclosure"/>
        <xsl:value-of select="$end_of_line"/>
    </xsl:variable>

    <!-- Build the node-set of headers from the xml file. -->
    <!-- This is the list of distinct attribute names of data nodes. -->
    <xsl:variable name="columns">
        <xsl:call-template name="headers" />
    </xsl:variable>

    <!-- Template to get a list of headers. -->
    <!-- In the xml schema, this is the list of all distinct attributes names. -->
    <xsl:template name="headers">
        <!-- Specific column for CsvImport that is added when there are sub-records (files)
        that should be linked to the main record (item). -->
        <xsl:if test="//record/record">
            <xsl:element name="column">
                <xsl:attribute name="name">sourceItemId</xsl:attribute>
            </xsl:element>
        </xsl:if>
        <!-- TODO Find a way to list distinct attributes names directly. -->
        <xsl:variable name="attributes">
            <xsl:call-template name="list_all_attributes" />
        </xsl:variable>
        <!-- Get distinct columns names. -->
        <xsl:for-each select="$attributes/column[not(@name = (preceding::*/@name))]">
            <xsl:copy-of select="." />
        </xsl:for-each>
    </xsl:template>

    <!-- Template for used headers : for each column, check if a data exists, even empty. -->
    <xsl:template name="list_all_attributes">
        <!-- Set as column all normal attributes of records. -->
        <xsl:for-each select="//record/@*[
            local-name() = 'updateMode'
            or local-name() = 'updateIdentifier'
            or local-name() = 'recordType'
            or local-name() = 'recordIdentifier'
            or local-name() = 'itemType'
            or local-name() = 'collection'
            or local-name() = 'public'
            or local-name() = 'featured'
            or local-name() = 'fileUrl'
            or local-name() = 'file'
            or local-name() = 'tags'
            ]">
            <xsl:element name="column">
                <xsl:attribute name="name">
                    <xsl:value-of select="name()" />
                </xsl:attribute>
            </xsl:element>
        </xsl:for-each>

        <!-- Specific metadata from the file itself. -->
        <xsl:for-each select="//data">
            <xsl:element name="column">
                <!-- Set the column name. -->
                <xsl:attribute name="name">
                    <xsl:value-of select="@set" />
                    <xsl:if test="@element">
                        <xsl:text>:</xsl:text>
                        <xsl:value-of select="@element" />
                    </xsl:if>
                    <xsl:if test="@subelement">
                        <xsl:text>:</xsl:text>
                        <xsl:value-of select="@subelement" />
                    </xsl:if>
                </xsl:attribute>
                <!-- For simpler checks, copy original attributes too. -->
                <!-- TODO Use a copy all attributes? -->
                <xsl:attribute name="set">
                    <xsl:value-of select="@set" />
                </xsl:attribute>
                <xsl:if test="@element">
                    <xsl:attribute name="element">
                        <xsl:value-of select="@element" />
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="@subelement">
                    <xsl:attribute name="subelement">
                        <xsl:value-of select="@subelement" />
                    </xsl:attribute>
                </xsl:if>
            </xsl:element>
        </xsl:for-each>
    </xsl:template>

    <!-- Main template for output. -->
    <xsl:template match="/">
        <xsl:if test="$headers = 'true'">
            <xsl:value-of select="$line_start"/>
            <xsl:for-each select="$columns/column">
                <xsl:value-of select="@name" />
                <xsl:if test="not(position() = last())">
                    <xsl:value-of select="$separator" />
                </xsl:if>
            </xsl:for-each>
            <xsl:value-of select="$line_end"/>
        </xsl:if>

        <!-- <xsl:apply-templates select="descendant::node()[name() = $node]" mode="record"/> -->
        <xsl:apply-templates select="//record" />
    </xsl:template>

    <xsl:template match="record">
        <xsl:value-of select="$line_start"/>

        <xsl:variable name="record" select="." />

        <!-- Copy each value of column from each record, if value exists. -->
        <xsl:for-each select="$columns/column">
            <xsl:variable name="column" select="." />
            <!-- Process vary according to columns. -->
            <xsl:choose>
                <!-- sourceItemId is an exception (check if there is a sub-record). -->
                <xsl:when test="@name = 'sourceItemId'">
                    <xsl:choose>
                        <!-- A upper-record exists (item), so use the id of the upper record. -->
                        <xsl:when test="$record/parent::record">
                            <xsl:value-of select="generate-id($record/parent::record)" />
                        </xsl:when>
                        <!-- A sub-record exists (file) or not, so use the id of the current record. -->
                        <xsl:otherwise>
                            <xsl:value-of select="generate-id($record)" />
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <!-- Manage specific columns (attributes of record). -->
                <xsl:when test="not(@set)">
                    <xsl:value-of select="$record/@*[local-name() = $column/@name]" />
                </xsl:when>
                <xsl:when test="not(@element)">
                    <xsl:apply-templates select="$record/data
                            [@set = $column/@set]" />
                </xsl:when>
                <xsl:when test="not(@subelement)">
                    <xsl:apply-templates select="$record/data
                            [@set = $column/@set]
                            [@element = $column/@element]" />
                </xsl:when>
                <!-- Specific data for specific plugins, rarely used. -->
                <xsl:otherwise>
                    <xsl:apply-templates select="$record/data
                            [@set = $column/@set]
                            [@element = $column/@element]
                            [@subelement = $column/@subelement]" />
                </xsl:otherwise>
            </xsl:choose>
            <xsl:if test="not(position() = last())">
                <xsl:value-of select="$separator" />
            </xsl:if>
        </xsl:for-each>

        <xsl:value-of select="$line_end"/>
    </xsl:template>

    <xsl:template match="data">
        <xsl:value-of select="normalize-space(.)" />
        <xsl:if test="not(position() = last())">
            <xsl:choose>
                <xsl:when test="@set = 'file'">
                    <xsl:value-of select="$delimiter_file" />
                </xsl:when>
                <xsl:when test="@set = 'tags'">
                    <xsl:value-of select="$delimiter_tag" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$delimiter_element" />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:template>

    <!-- Don't write anything else. -->
    <xsl:template match="text()" />

</xsl:stylesheet>

