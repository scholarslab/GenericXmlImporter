<?xml version="1.0" encoding="UTF-8"?>
<!--
    Description : Convert a generic Xml file to "Manage records" format in order
    to import it automatically into Omeka via Csv Import

    This is the xslt 1.1 downgrade from "advanced.xsl". It requires the
    processor xslt 1 Saxon 6.5.5 or higher. The processor Xalan doesn't work.

    Notes:
    - By default, this sheet uses "Dublin Core:Identifier" as main Identifier.
    If no identifier is found, records should use the attribute "identifierField"
    to be updated.
    - Order of columns is not important for Csv Import.
    - To import values with multiple lines, use html format in Csv Import.
    - This sheet doesn't clean errors in the source.

    @copyright Daniel Berthereau, 2012-2016
    @license http://www.apache.org/licenses/LICENSE-2.0.html
    @package Omeka/Plugins/XmlImport
-->

<xsl:stylesheet version="1.1"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"

    xmlns:omeka="http://omeka.org/schemas/omeka-xml/v5"
    xmlns:dc="http://purl.org/dc/elements/1.1/"
    xmlns:dcterms="http://purl.org/dc/terms/"

    >
    <xsl:output method="text" encoding="UTF-8" />

    <!-- Parameters -->
    <!-- All headers are added by default. -->
    <xsl:param name="headers">true</xsl:param>

    <!-- The base path for the file, if needed. It will be added to all partial
    url or path of files (without a protocol like "https:".). -->
    <xsl:param name="base_file"></xsl:param>

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

    <!-- Identifier field to get the Identifier. -->
    <xsl:param name="identifier_field"><xsl:text>Dublin Core:Identifier</xsl:text></xsl:param>

    <!-- List of Dublin Core terms to simplify the process. -->
    <xsl:param name="dcterms_file">dcterms.xml</xsl:param>

    <!-- Constants -->
    <xsl:variable name="base_url">
        <xsl:value-of select="$base_file" />
        <xsl:if test="$base_file != ''">
            <xsl:if test="substring($base_file, string-length($base_file), 1) != '/'
                and substring($base_file, string-length($base_file), 1) != '\'">
                <xsl:text>/</xsl:text>
            </xsl:if>
        </xsl:if>
    </xsl:variable>
    <xsl:variable name="line_start">
        <xsl:value-of select="$enclosure" />
    </xsl:variable>
    <xsl:variable name="separator">
        <xsl:value-of select="$enclosure" />
        <xsl:choose>
            <xsl:when test="$delimiter != ''">
                <xsl:value-of select="$delimiter" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$delimiter_column" />
            </xsl:otherwise>
        </xsl:choose>
        <xsl:value-of select="$enclosure" />
    </xsl:variable>
    <xsl:variable name="line_end">
        <xsl:value-of select="$enclosure" />
        <xsl:value-of select="$end_of_line" />
    </xsl:variable>

    <!-- List of Dublin Core terms to simplify the process. -->
    <xsl:variable name="dcterms" select="document($dcterms_file)" />

    <!-- Allow to lowercase or uppercase a string (European strings, for xslt 1.0). -->
    <xsl:variable name="uppercase" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZÁÉÍÓÚÀÈÌÒÙÂÊÎÔÛÄËÏÖÜŸÇ'" />
    <xsl:variable name="lowercase" select="'abcdefghijklmnopqrstuvwxyzáéíóúàèìòùâêîôûäëïöüÿç'" />

    <!-- Build the node-set of headers from the xml file. -->
    <!-- This is the list of distinct attribute names of data nodes. -->
    <xsl:variable name="columns">
        <xsl:call-template name="headers" />
    </xsl:variable>

    <!-- Build the identifier field, subfield, and Dublin Core term, if any, to
    simplify next process. -->
    <xsl:variable name="identifierField">
        <xsl:value-of select="normalize-space(substring-before($identifier_field, ':'))" />
    </xsl:variable>
    <xsl:variable name="identifierSubField">
        <xsl:value-of select="normalize-space(substring-after($identifier_field, ':'))" />
    </xsl:variable>
    <xsl:variable name="identifierSubFieldTerm">
        <xsl:if test="$identifierField = 'Dublin Core' and $identifierSubField != ''">
            <xsl:value-of select="$columns/column
                    [@set = $identifierField and @element = $identifierSubField]
                    /@term" />
        </xsl:if>
    </xsl:variable>

    <!-- Template to get a list of headers. -->
    <!-- In the xml schema, this is the list of all distinct attributes names. -->
    <xsl:template name="headers">
        <!-- TODO Find a way to list distinct attributes names directly. -->
        <xsl:variable name="attributes">
            <xsl:call-template name="list_all_attributes" />
        </xsl:variable>
        <!-- Get distinct columns names. -->
        <xsl:for-each select="$attributes/column[not(@name = preceding-sibling::column/@name)]">
            <xsl:copy-of select="." />
        </xsl:for-each>
    </xsl:template>

    <!-- Template for used headers : for each column, check if a data exists, even empty. -->
    <xsl:template name="list_all_attributes">
        <!-- Required column. -->
        <xsl:element name="column">
            <xsl:attribute name="name">Identifier</xsl:attribute>
        </xsl:element>
        <!-- If there are files. -->
        <xsl:if test="//record/record or //record/@file">
            <xsl:element name="column">
                <xsl:attribute name="name">Record Type</xsl:attribute>
            </xsl:element>
            <xsl:element name="column">
                <xsl:attribute name="name">Item</xsl:attribute>
            </xsl:element>
            <!-- In the case where there is no identifier. -->
            <!--
            <xsl:element name="column">
                <xsl:attribute name="name">IdentifierField</xsl:attribute>
            </xsl:element>
            -->
        </xsl:if>
        <!-- Set as column all normal attributes of records. -->
        <xsl:for-each select="//record/@*[
            local-name() = 'action'
            or local-name() = 'identifier'
            or local-name() = 'identifierField'
            or local-name() = 'recordType'
            or local-name() = 'collection'
            or local-name() = 'item'
            or local-name() = 'file'
            or local-name() = 'public'
            or local-name() = 'featured'
            or local-name() = 'itemType'
            ]">
            <!-- Identifier is always added. -->
            <xsl:element name="column">
                <xsl:attribute name="name">
                    <!-- First character as uppercase -->
                    <xsl:choose>
                        <xsl:when test="name() = 'identifierField'">
                            <xsl:text>Identifier Field</xsl:text>
                        </xsl:when>
                        <xsl:when test="name() = 'recordType'">
                            <xsl:text>Record Type</xsl:text>
                        </xsl:when>
                        <xsl:when test="name() = 'itemType'">
                            <xsl:text>Item Type</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:call-template name="capitalizeFirst">
                                <xsl:with-param name="string" select="name()" />
                            </xsl:call-template>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
                <!-- For simpler checks, copy original name as another attribute too. -->
                <xsl:attribute name="attrib">
                    <xsl:value-of select="name()" />
                </xsl:attribute>
            </xsl:element>
        </xsl:for-each>

        <!-- Currently, tags is an exception. -->
        <xsl:if test="//record/tags">
            <xsl:element name="column">
                <xsl:attribute name="name">
                    <xsl:text>Tags</xsl:text>
                </xsl:attribute>
            </xsl:element>
        </xsl:if>

        <!-- Standard Dublin Core metadata used in the file itself, at any level. -->
        <xsl:for-each select="//record/dc:*">
            <xsl:variable name="dcLabel">
                <xsl:call-template name="capitalizeFirst">
                    <xsl:with-param name="string" select="local-name()" />
                </xsl:call-template>
            </xsl:variable>
            <xsl:element name="column">
                <!-- Set the column name. -->
                <xsl:attribute name="name">
                    <xsl:text>Dublin Core</xsl:text>
                    <xsl:text>:</xsl:text>
                    <xsl:value-of select="$dcLabel" />
                </xsl:attribute>
                <!-- For simpler checks, copy term name too. -->
                <xsl:attribute name="set">
                    <xsl:text>Dublin Core</xsl:text>
                </xsl:attribute>
                <xsl:attribute name="element">
                    <xsl:value-of select="$dcLabel" />
                </xsl:attribute>
                <xsl:attribute name="term">
                    <xsl:value-of select="local-name()" />
                </xsl:attribute>
            </xsl:element>
        </xsl:for-each>

        <!-- Qualified Dublin Core metadata used in the file itself, at any level. -->
        <xsl:for-each select="//record/dcterms:*">
            <xsl:variable name="dcLabel">
                <xsl:value-of select="$dcterms/terms
                    /term[@name = local-name(current())]
                    /@label" />
            </xsl:variable>
            <xsl:element name="column">
                <!-- Set the column name. -->
                <xsl:attribute name="name">
                    <xsl:text>Dublin Core</xsl:text>
                    <xsl:text>:</xsl:text>
                    <xsl:value-of select="$dcLabel" />
                </xsl:attribute>
                <!-- For simpler checks, copy term name too. -->
                <xsl:attribute name="set">
                    <xsl:text>Dublin Core</xsl:text>
                </xsl:attribute>
                <xsl:attribute name="element">
                    <xsl:value-of select="$dcLabel" />
                </xsl:attribute>
                <xsl:attribute name="term">
                    <xsl:value-of select="local-name()" />
                </xsl:attribute>
            </xsl:element>
        </xsl:for-each>

        <!-- Elements metadata used in the file itself, at any level. -->
        <xsl:for-each select="//record/elementSet/element">
            <xsl:element name="column">
                <!-- Set the column name. -->
                <xsl:attribute name="name">
                    <xsl:value-of select="../@name" />
                    <xsl:text>:</xsl:text>
                    <xsl:value-of select="@name" />
                </xsl:attribute>
                <!-- For simpler checks, copy original attributes too. -->
                <xsl:attribute name="set">
                    <xsl:value-of select="../@name" />
                </xsl:attribute>
                <xsl:attribute name="element">
                    <xsl:value-of select="@name" />
                </xsl:attribute>
                <xsl:if test="../@name = 'Dublin Core'">
                    <xsl:attribute name="term">
                        <xsl:value-of select="$dcterms/terms
                            /term[@label = current()/@name]
                            /@name" />
                    </xsl:attribute>
                </xsl:if>
            </xsl:element>
        </xsl:for-each>

        <!-- Elements extra metadata used in the file itself, at any level. -->
        <!-- TODO Manage multivalues and add a ":" at the end of the name. -->
        <xsl:for-each select="//record/extra/data">
            <xsl:element name="column">
                <!-- Set the column name. -->
                <xsl:attribute name="name">
                    <xsl:value-of select="@name" />
                </xsl:attribute>
                <!-- For simpler checks. -->
                <xsl:attribute name="extra">
                    <xsl:value-of select="@name" />
                </xsl:attribute>
            </xsl:element>
        </xsl:for-each>
    </xsl:template>

    <!-- Main template for output. -->
    <xsl:template match="/">
        <xsl:if test="$headers = 'true'">
            <xsl:value-of select="$line_start" />
            <xsl:for-each select="$columns/column">
                <xsl:value-of select="@name" />
                <xsl:if test="not(position() = last())">
                    <xsl:value-of select="$separator" />
                </xsl:if>
            </xsl:for-each>
            <xsl:value-of select="$line_end" />
        </xsl:if>

        <xsl:apply-templates select="//record" />
    </xsl:template>

    <xsl:template match="record">
        <xsl:value-of select="$line_start" />

        <xsl:variable name="record" select="." />

        <!-- The record type can be needed twice. -->
        <xsl:variable name="record_type">
            <xsl:call-template name="get_record_type" />
        </xsl:variable>

        <!-- Copy each value of column from each record, if value exists. -->
        <xsl:for-each select="$columns/column">
            <xsl:variable name="column" select="." />

            <!-- Process vary according to columns. -->
            <xsl:choose>
                <!-- Identifier is an exception, because it should exist. -->
                <xsl:when test="@name = 'Identifier'">
                    <xsl:call-template name="get_identifier">
                        <xsl:with-param name="recordNode" select="$record" />
                    </xsl:call-template>
                </xsl:when>
                <!-- RecordType is an exception and should be determined. -->
                <xsl:when test="@name = 'Record Type'">
                    <xsl:value-of select="$record_type" />
                </xsl:when>
                <!-- Action is an exception for files (use item action if any). -->
                <xsl:when test="@name = 'Action'
                        and $record_type = 'File'
                        and (not($record/@action) or $record/@action = '')
                        ">
                    <xsl:value-of select="$record/../@action" />
                </xsl:when>
                <!-- Item is an exception used to manage relations to files. -->
                <xsl:when test="@name = 'Item'">
                    <xsl:if test="$record_type = 'File'
                            and local-name($record/..) = 'record'">
                        <xsl:call-template name="get_identifier">
                            <xsl:with-param name="recordNode" select="$record/parent::node()" />
                        </xsl:call-template>
                    </xsl:if>
                </xsl:when>
                <!-- File is an exception with a specific delimiter. -->
                <xsl:when test="@name = 'File'">
                    <xsl:apply-templates select="$record
                            /@file" />
                </xsl:when>
                <!-- Tags is an exception with a specific delimiter. -->
                <xsl:when test="@name = 'Tags'">
                    <xsl:apply-templates select="$record
                            /tags/data" mode="tags" />
                </xsl:when>
                <!-- Specific columns (attributes of record). -->
                <xsl:when test="@attrib">
                    <xsl:value-of select="$record
                            /@*[local-name() = $column/@attrib]" />
                </xsl:when>
                <!-- Dublin Core elements or Dublin Core tags. -->
                <xsl:when test="@set = 'Dublin Core' and @element">
                    <xsl:apply-templates select="$record
                            /elementSet[@name = $column/@set]
                            /element[@name = $column/@element]
                            /data
                            | $record
                            /dc:*[local-name() = $column/@term]
                            | $record
                            /dcterms:*[local-name() = $column/@term]
                            " />
                </xsl:when>
                <!-- Normal elements. -->
                <xsl:when test="@set and @element">
                    <xsl:apply-templates select="$record
                            /elementSet[@name = $column/@set]
                            /element[@name = $column/@element]
                            /data" />
                </xsl:when>
                <!-- Extra data. -->
                <xsl:when test="@extra">
                    <xsl:apply-templates select="$record
                            /extra
                            /data[@name = $column/@extra]" />
                </xsl:when>
                <!-- Otherwise, not copied. -->
            </xsl:choose>
            <xsl:if test="not(position() = last())">
                <xsl:value-of select="$separator" />
            </xsl:if>
        </xsl:for-each>

        <xsl:value-of select="$line_end" />
    </xsl:template>

    <!-- Determine the record type. -->
    <xsl:template name="get_record_type">
        <xsl:param name="record" select="." />

        <xsl:variable name="recordIdentifierField">
            <xsl:call-template name="stringToLower">
                <xsl:with-param name="string" select="$record/@identifierField" />
            </xsl:call-template>
        </xsl:variable>

        <!-- These checks don't manage all cases, only existing ones. -->
        <xsl:choose>
            <xsl:when test="$record/@recordType">
                <!-- First character as uppercase -->
                <xsl:call-template name="capitalizeFirst">
                    <xsl:with-param name="string" select="$record/@recordType" />
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$record/record/record">
                <xsl:text>Collection</xsl:text>
            </xsl:when>
            <xsl:when test="$record/record
                    or $record/@collection
                    or $record/@itemType
                    ">
                <xsl:text>Item</xsl:text>
            </xsl:when>
            <xsl:when test="$record/@file
                    or $record/parent::record
                    or $recordIdentifierField = 'original filename'
                    or $recordIdentifierField = 'filename'
                    or $recordIdentifierField = 'authentication'
                    or $recordIdentifierField = 'md5'
                    ">
                <xsl:text>File</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>Item</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- Determine the parentidentifier. -->
    <xsl:template name="get_identifier">
        <xsl:param name="recordNode" select="." />

        <xsl:variable name="identify">
            <xsl:choose>
                <xsl:when test="$recordNode/@identifier">
                    <xsl:value-of select="normalize-space($recordNode/@identifier)" />
                </xsl:when>
                <xsl:when test="$identifierField = 'Dublin Core'
                            and $identifierSubField != ''">
                    <xsl:value-of select="
                        normalize-space(
                            (
                                $recordNode
                                /elementSet[@name = $identifierField]
                                /element[@name = $identifierSubField]
                                /data[1]
                                | $recordNode
                                /dc:*[local-name() = $identifierSubFieldTerm][1]
                                | $recordNode
                                /dcterms:*[local-name() = $identifierSubFieldTerm][1]
                            )[1]
                        )" />
                </xsl:when>
                <xsl:when test="$identifierField != ''
                            and $identifierSubField != ''">
                    <xsl:value-of select="
                        normalize-space(
                            $recordNode
                            /elementSet[@name = $identifierField]
                            /element[@name = $identifierSubField]
                            /data[1]
                        )" />
                </xsl:when>
            </xsl:choose>
        </xsl:variable>

        <xsl:choose>
            <xsl:when test="$identify != ''">
                <xsl:value-of select="$identify" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="generate-id($recordNode)" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="@file">
        <xsl:variable name="file" select="normalize-space(.)" />
        <xsl:if test="$base_url != ''
            and substring($file, 1, 7) != 'http://'
            and substring($file, 1, 8) != 'https://'
            and substring($file, 1, 7) != 'file://'
            and substring($file, 1, 1) != '/'
            ">
            <xsl:value-of select="$base_url" />
        </xsl:if>
        <xsl:value-of select="normalize-space(.)" />
        <xsl:if test="not(position() = last())">
            <xsl:value-of select="$delimiter_file" />
        </xsl:if>
    </xsl:template>

    <xsl:template match="data | dc:* | dcterms:*">
        <xsl:value-of select="normalize-space(.)" />
        <xsl:if test="not(position() = last())">
            <xsl:value-of select="$delimiter_element" />
        </xsl:if>
    </xsl:template>

    <xsl:template match="data" mode="tags">
        <xsl:value-of select="normalize-space(.)" />
        <xsl:if test="not(position() = last())">
            <xsl:value-of select="$delimiter_tag" />
        </xsl:if>
    </xsl:template>

    <xsl:template name="capitalizeFirst">
        <xsl:param name="string" select="." />
        <xsl:value-of select="concat(translate(substring($string, 1, 1), $lowercase, $uppercase), substring($string, 2))" />
    </xsl:template>

    <xsl:template name="stringToLower">
        <xsl:param name="string" select="." />
        <xsl:value-of select="translate($string, $uppercase, $lowercase)" />
    </xsl:template>

    <!-- Don't write anything else. -->
    <xsl:template match="text()" />

</xsl:stylesheet>
