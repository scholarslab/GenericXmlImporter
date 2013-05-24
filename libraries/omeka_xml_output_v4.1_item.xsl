<?xml version="1.0" encoding="UTF-8"?>
<!--
    Description : Convert an Omeka Xml output (version 4.1) to CSV format in order to import
    it automatically into Omeka via Csv Import.

    @copyright Daniel Berthereau, 2012-2013
    @license http://www.apache.org/licenses/LICENSE-2.0.html
    @package XmlImport

    Notes
    - This sheet is compatible with Omeka Xml output 4.0.
    - This sheet doesn't manage html fields (neither Omeka Xml output).
    - This sheet doesn't manage repetition of fields, except for tags and files.

    TODO
    - Make more generic for all repeated fields.
    - Warning: enclosure, delimiter, delimiter for multi-values and end of line are hard
    coded in Xml Import.
-->

<xsl:stylesheet version="1.1"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:omeka="http://omeka.org/schemas/omeka-xml/v4">
    <xsl:output method="text" encoding="UTF-8"/>

    <!-- Parameters -->
    <!-- Headers are added by default. -->
    <xsl:param name="headers">true</xsl:param>

    <!-- Default enclosure. -->
    <!-- No enclusure is needed when tabulation is used. -->
    <xsl:param name="enclosure"></xsl:param>

    <!-- Default delimiter. -->
    <!-- Tabulation is used by default, because it never appears in current files.
    Csv Import works fine with it, even if it's not allowed. -->
    <xsl:param name="delimiter"><xsl:text>&#x09;</xsl:text></xsl:param>

    <!-- Default delimiter for multivalued fields: control character 13 (Carriage return), the
    only allowed character in xml 1.0, with Tabulation and Line feed. -->
    <xsl:param name="delimiter_multivalues"><xsl:text>&#x0D;</xsl:text></xsl:param>

    <!-- End of line (the Linux one, because it's simpler and smarter). -->
    <xsl:param name="end_of_line"><xsl:text>&#x0A;</xsl:text></xsl:param>

    <!-- Omeka main element sets. -->
    <xsl:param name="omeka_sets_file">omeka_sets.xml</xsl:param>

    <!-- Constantes -->
    <xsl:variable name="line_start">
        <xsl:value-of select="$enclosure"/>
    </xsl:variable>
    <xsl:variable name="separator">
        <xsl:value-of select="$enclosure"/>
        <xsl:value-of select="$delimiter"/>
        <xsl:value-of select="$enclosure"/>
    </xsl:variable>
    <xsl:variable name="line_end">
        <xsl:value-of select="$enclosure"/>
        <xsl:value-of select="$end_of_line"/>
    </xsl:variable>
    <!-- Omeka element sets. -->
    <xsl:variable name="omeka_sets" select="document($omeka_sets_file)"/>

    <!-- Main template -->
    <xsl:template match="/">
        <xsl:if test="$headers = 'true'">
            <xsl:call-template name="headers"/>
        </xsl:if>

        <xsl:apply-templates/>
    </xsl:template>

    <!-- Row for headers. -->
    <xsl:template name="headers">
        <xsl:value-of select="$line_start"/>

        <!-- This value is kept only for information. -->
        <xsl:text>Item identifier</xsl:text>

        <!-- Specific columns of items. -->
        <xsl:value-of select="$separator"/>
        <xsl:text>Tags</xsl:text>
        <xsl:value-of select="$separator"/>
        <xsl:text>Filenames</xsl:text>

        <!-- Standard metadata headers. -->
        <xsl:for-each select="$omeka_sets/XMLlist/elementSet[@recordType != 'File']">
            <xsl:for-each select="element">
                <xsl:value-of select="$separator"/>
                <xsl:value-of select="../@setName"/>
                <xsl:text>:</xsl:text>
                <xsl:value-of select="."/>
            </xsl:for-each>
        </xsl:for-each>

        <xsl:value-of select="$line_end"/>
    </xsl:template>

    <!-- Template for items. -->
    <xsl:template match="omeka:item">
        <xsl:value-of select="$line_start"/>

        <xsl:call-template name="item_base" />
        <xsl:call-template name="item_tags" />
        <xsl:call-template name="item_filenames" />

        <!-- Metadata. -->
        <xsl:call-template name="metadata_item">
            <xsl:with-param name="current_record" select="."/>
            <xsl:with-param name="sets" select="$omeka_sets"/>
        </xsl:call-template>

        <xsl:value-of select="$line_end"/>
    </xsl:template>

    <!-- Helpers. -->

    <xsl:template name="item_base">
        <!-- No separator because this is the first column. -->
        <xsl:value-of select="@itemId"/>
    </xsl:template>

    <!-- Helper for list of tags of an item. -->
    <xsl:template name="item_tags">
        <xsl:value-of select="$separator"/>
        <xsl:variable name="tags">
            <xsl:for-each select="omeka:tagContainer/omeka:tag">
                <xsl:value-of select="omeka:name"/>
                <xsl:value-of select="$delimiter_multivalues"/>
            </xsl:for-each>
        </xsl:variable>
        <xsl:if test="string-length($tags) > 0">
            <xsl:value-of select="substring($tags, 1, string-length($tags) - 1)"/>
        </xsl:if>
    </xsl:template>

    <!-- Helper for list of files of an item. -->
    <xsl:template name="item_filenames">
        <xsl:value-of select="$separator"/>
        <xsl:variable name="filenames">
            <xsl:for-each select="omeka:fileContainer/omeka:file">
                <xsl:value-of select="omeka:src"/>
                <xsl:value-of select="$delimiter_multivalues"/>
            </xsl:for-each>
        </xsl:variable>
        <xsl:if test="string-length($filenames) > 0">
            <xsl:value-of select="substring($filenames, 1, string-length($filenames) - 1)"/>
        </xsl:if>
    </xsl:template>

    <!-- Helper to get metadata of an item. -->
    <xsl:template name="metadata_item">
        <xsl:param name="current_record"/>
        <xsl:param name="sets"/>

        <!-- All metadata (only for items). -->
        <xsl:for-each select="$sets/XMLlist/elementSet[@recordType != 'File']">
            <xsl:variable name="setName" select="@setName"/>
            <xsl:for-each select="element">
                <xsl:variable name="elementName" select="."/>
                <xsl:value-of select="$separator"/>
                <xsl:choose>
                    <!-- Metadata for items and files (Dublin Core...). -->
                    <xsl:when test="../@recordType = 'All'">
                        <xsl:value-of select="$current_record/omeka:elementSetContainer/omeka:elementSet[omeka:name = $setName]/omeka:elementContainer/omeka:element[omeka:name = $elementName]/omeka:elementTextContainer/omeka:elementText/omeka:text"/>
                    </xsl:when>
                    <!-- Metadata for items. -->
                    <xsl:when test="../@recordType = 'Item'">
                          <xsl:value-of select="$current_record/omeka:itemType/omeka:elementContainer/omeka:element[omeka:name = $elementName]/omeka:elementTextContainer/omeka:elementText/omeka:text"/>
                    </xsl:when>
                </xsl:choose>
            </xsl:for-each>
        </xsl:for-each>
    </xsl:template>

    <!-- Ignore everything else. -->
    <xsl:template match="text()" />

</xsl:stylesheet>
