<?xml version="1.0" encoding="UTF-8"?>
<!--
    Description : Convert an Omeka Xml output (version 4.0/4.1) to "CSV Report"
    format in order to import it automatically into Omeka via Csv Import.

    @copyright Daniel Berthereau, 2012-2015
    @license http://www.apache.org/licenses/LICENSE-2.0.html
    @package XmlImport

    Notes
    - This sheet is compatible with Omeka xml output v5: just change the namespace from
        xmlns:omeka="http://omeka.org/schemas/omeka-xml/v4"
    to
        xmlns:omeka="http://omeka.org/schemas/omeka-xml/v5"
    - This sheet doesn't manage html fields (neither Omeka Xml output).

    TODO
    - Warning: enclosure, delimiter (column, element, tag and file) and end of line are hard
    coded in Xml Import and in the Csv Report format.
-->

<xsl:stylesheet version="1.1"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:omeka="http://omeka.org/schemas/omeka-xml/v4">
    <xsl:output method="text" encoding="UTF-8" />

    <!-- Parameters -->
    <!-- Headers are added by default. -->
    <xsl:param name="headers">true</xsl:param>

    <!-- Default enclosure. -->
    <xsl:param name="enclosure">"</xsl:param>

    <!-- Default delimiter for columns. -->
    <xsl:param name="delimiter">,</xsl:param>

    <!-- Default delimiter for elements. -->
    <xsl:param name="delimiter_element">^^</xsl:param>

    <!-- Default delimiter for tags. -->
    <xsl:param name="delimiter_tag">,</xsl:param>

    <!-- Default delimiter for files. -->
    <xsl:param name="delimiter_file">,</xsl:param>

    <!-- End of line (the Linux one, because it's simpler and smarter). -->
    <xsl:param name="end_of_line"><xsl:text>&#x0A;</xsl:text></xsl:param>

    <!-- Omeka main element sets. -->
    <xsl:param name="omeka_sets_file">omeka_sets.xml</xsl:param>

    <!-- Omeka legacy element sets. -->
    <xsl:param name="omeka_legacy_sets_file">omeka_legacy_sets.xml</xsl:param>

    <!-- User specific element sets. -->
    <xsl:param name="specific_sets_file">specific_sets.xml</xsl:param>

    <!-- Support of Omeka legacy elements. -->
    <xsl:param name="legacy_elements">false</xsl:param>

    <!-- Constantes -->
    <xsl:variable name="line_start">
        <xsl:value-of select="$enclosure" />
    </xsl:variable>
    <xsl:variable name="separator">
        <xsl:value-of select="$enclosure" />
        <xsl:value-of select="$delimiter" />
        <xsl:value-of select="$enclosure" />
    </xsl:variable>
    <xsl:variable name="line_end">
        <xsl:value-of select="$enclosure" />
        <xsl:value-of select="$end_of_line" />
    </xsl:variable>
    <!-- Omeka element sets. -->
    <xsl:variable name="omeka_sets" select="document($omeka_sets_file)" />
    <!-- Omeka legacy element sets. -->
    <xsl:variable name="omeka_legacy_sets" select="document($omeka_legacy_sets_file)" />
    <!-- User specific element sets. -->
    <xsl:variable name="specific_sets" select="document($specific_sets_file)" />

    <!-- Main template -->
    <xsl:template match="/">
        <xsl:if test="$headers = 'true'">
            <xsl:call-template name="headers" />
        </xsl:if>

        <xsl:apply-templates />
    </xsl:template>

    <!-- Template for headers. -->
    <xsl:template name="headers">
        <xsl:value-of select="$line_start" />

        <!-- Specific columns of items. -->
        <xsl:text>itemType</xsl:text>
        <xsl:value-of select="$separator" />
        <xsl:text>collection</xsl:text>
        <xsl:value-of select="$separator" />
        <xsl:text>public</xsl:text>
        <xsl:value-of select="$separator" />
        <xsl:text>featured</xsl:text>
        <xsl:value-of select="$separator" />
        <xsl:text>tags</xsl:text>
        <xsl:value-of select="$separator" />
        <xsl:text>file</xsl:text>

        <!-- Standard metadata headers. -->
        <xsl:for-each select="$omeka_sets/XMLlist/elementSet">
            <xsl:for-each select="element">
                <xsl:value-of select="$separator" />
                <xsl:value-of select="../@setName" />
                <xsl:text>:</xsl:text>
                <xsl:value-of select="." />
            </xsl:for-each>
        </xsl:for-each>
        <!-- Legacy metadata headers. -->
        <xsl:if test="$legacy_elements = 'true'">
            <xsl:for-each select="$omeka_legacy_sets/XMLlist/elementSet">
                <xsl:for-each select="element">
                    <xsl:value-of select="$separator" />
                    <xsl:value-of select="../@setName" />
                    <xsl:text>:</xsl:text>
                    <xsl:value-of select="." />
                </xsl:for-each>
            </xsl:for-each>
        </xsl:if>
        <!-- Specific metadata headers. -->
        <xsl:for-each select="$specific_sets/XMLlist/elementSet">
            <xsl:for-each select="element">
                <xsl:value-of select="$separator" />
                <xsl:value-of select="../@setName" />
                <xsl:text>:</xsl:text>
                <xsl:value-of select="." />
            </xsl:for-each>
        </xsl:for-each>

        <xsl:value-of select="$line_end" />
    </xsl:template>

    <!-- Template for items. -->
    <xsl:template match="omeka:item">
        <xsl:value-of select="$line_start" />

        <xsl:call-template name="base_item" />
        <xsl:call-template name="tags_item" />
        <xsl:call-template name="filenames_item" />

        <!-- Metadata. -->
        <xsl:call-template name="metadata_item">
            <xsl:with-param name="current_record" select="." />
            <xsl:with-param name="sets" select="$omeka_sets" />
        </xsl:call-template>
        <xsl:if test="$legacy_elements = 'true'">
            <xsl:call-template name="metadata_item">
                <xsl:with-param name="current_record" select="." />
                <xsl:with-param name="sets" select="$omeka_legacy_sets" />
            </xsl:call-template>
        </xsl:if>
        <xsl:call-template name="metadata_item">
            <xsl:with-param name="current_record" select="." />
            <xsl:with-param name="sets" select="$specific_sets" />
        </xsl:call-template>

        <xsl:value-of select="$line_end" />
    </xsl:template>

    <!-- Helpers. -->

    <xsl:template name="base_item">
        <!-- No separator because this is the first column. -->
        <!-- Compatibility check to import a file from Omeka 1.5: "Document" is now "Text" in Omeka 2.0. -->
        <xsl:choose>
            <xsl:when test="omeka:itemType/@itemTypeId = '1' and omeka:itemType/omeka:name = 'Document'">
                <xsl:text>Text</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="omeka:itemType/omeka:name" />
            </xsl:otherwise>
        </xsl:choose>
        <xsl:value-of select="$separator" />
        <xsl:value-of select="omeka:collection/omeka:name" />
        <xsl:value-of select="$separator" />
        <xsl:value-of select="@public" />
        <xsl:value-of select="$separator" />
        <xsl:value-of select="@featured" />
    </xsl:template>

    <!-- Helper for list of tags of an item. -->
    <xsl:template name="tags_item">
        <xsl:value-of select="$separator" />
        <xsl:for-each select="omeka:tagContainer/omeka:tag">
            <xsl:value-of select="omeka:name" />
            <xsl:if test="not(position() = last())">
                <xsl:value-of select="$delimiter_tag" />
            </xsl:if>
        </xsl:for-each>
    </xsl:template>

    <!-- Helper for list of files of an item. -->
    <xsl:template name="filenames_item">
        <xsl:value-of select="$separator" />
        <xsl:for-each select="omeka:fileContainer/omeka:file">
            <xsl:value-of select="omeka:src" />
            <xsl:if test="not(position() = last())">
                <xsl:value-of select="$delimiter_file" />
            </xsl:if>
        </xsl:for-each>
    </xsl:template>

    <!-- Helper to get metadata of an item. -->
    <xsl:template name="metadata_item">
        <xsl:param name="current_record" />
        <xsl:param name="sets" />

        <!-- All metadata (only for items). -->
        <xsl:for-each select="$sets/XMLlist/elementSet">
            <xsl:variable name="setName" select="@setName" />
            <xsl:for-each select="element">
                <xsl:variable name="elementName" select="." />
                <xsl:value-of select="$separator" />
                <xsl:choose>
                    <!-- Metadata for items and files (Dublin Core...). -->
                    <xsl:when test="../@recordType = 'All'">
                        <xsl:for-each select="$current_record/omeka:elementSetContainer/omeka:elementSet[omeka:name = $setName]/omeka:elementContainer/omeka:element[omeka:name = $elementName]/omeka:elementTextContainer/omeka:elementText/omeka:text">
                            <xsl:value-of select="." />
                            <xsl:if test="not(position() = last())">
                                <xsl:value-of select="$delimiter_element" />
                            </xsl:if>
                        </xsl:for-each>
                    </xsl:when>
                    <!-- Metadata for items. -->
                    <xsl:when test="../@recordType = 'Item'">
                          <xsl:for-each select="$current_record/omeka:itemType/omeka:elementContainer/omeka:element[omeka:name = $elementName]/omeka:elementTextContainer/omeka:elementText/omeka:text">
                            <xsl:value-of select="." />
                            <xsl:if test="not(position() = last())">
                                <xsl:value-of select="$delimiter_element" />
                            </xsl:if>
                        </xsl:for-each>
                    </xsl:when>
                </xsl:choose>
            </xsl:for-each>
        </xsl:for-each>
    </xsl:template>

    <!-- Ignore everything else. -->
    <xsl:template match="text()" />

</xsl:stylesheet>
