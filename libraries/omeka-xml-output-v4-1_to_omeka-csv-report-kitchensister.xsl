<?xml version="1.0" encoding="UTF-8"?>
<!--
    Document : omeka-xml-output-v4-1_to_omeka-csv-report-kitchensister.xsl
    Created date : 11/11/2012
    Version : 1.0
    Author : Daniel Berthereau for Pop Up Archive (http://popuparchive.org)
    Description : Convert an Omeka Xml output (version 4.1) to CSV format in order to import it in another instance of Omeka with CsvImport.

    Notes
    - This sheet should be used with XmlImport 1.6-files_metadata and CsvImport 1.3.4-fork-1.7.
    - This sheet is compatible with Omeka Xml output 4.0.
    - This sheet doesn't manage html fields (neither Omeka Csv Import).
    - This sheet doesn't manage direct repetition of fields, except tags and files. You need to add specific rules ("^^" is the separator of multivalued fields).
-->

<xsl:stylesheet version="1.1"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:php="http://php.net/xsl"
    xmlns:omeka="http://omeka.org/schemas/omeka-xml/v4">
<xsl:output method="text"
    media-type="text/csv"
    encoding="UTF-8"
    omit-xml-declaration="yes"/>

<!-- Parameters -->
<!-- Default delimiter. -->
<!-- Warning: Tabulation by default, because it never appears in current files, but CsvImport doesn't allow it by default. -->
<xsl:param name="delimiter"><xsl:text>&#x09;</xsl:text></xsl:param>
<!-- Default enclusure. -->
<!-- No enclusure is needed when tabulation is used. -->
<xsl:param name="enclosure"></xsl:param>
<!-- Default delimiter for multivalued fields. -->
<!-- Warning: Currently, CsvImport doesn't allow a specific delimiter for multivalued fields. -->
<xsl:param name="delimiter_multivalues">,</xsl:param>
<!-- CsvImport uses a different delimiter for the Csv Report format (except for tags and files). -->
<xsl:param name="delimiter_multivalues_csvreport">^^</xsl:param>
<!-- Default end of line. -->
<xsl:param name="end_of_line">Linux</xsl:param>
<!-- Headers are added by default. -->
<xsl:param name="headers">true</xsl:param>
<!-- Omeka main element sets. -->
<xsl:param name="omeka_sets_file">empty_sets.xml</xsl:param>
<!-- User specific element sets. -->
<xsl:param name="user_sets_file">user_sets_kitchensisters.xml</xsl:param>
<!-- These sets are used to convert a format to another one. Number of elements should be the number of the main and the user sets.-->
<xsl:param name="convert_sets_file">convert_sets_kitchensisters.xml</xsl:param>
<!-- Use full path (fullpath) or base name (basename) as original name of attached files. -->
<xsl:param name="original_filename">convert</xsl:param>

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
    <xsl:choose>
        <xsl:when test="$end_of_line = 'Linux'">
            <xsl:text>&#x0A;</xsl:text>
        </xsl:when>
        <xsl:when test="$end_of_line = 'Mac'">
            <xsl:text>&#x0D;</xsl:text>
        </xsl:when>
        <xsl:when test="$end_of_line = 'Windows'">
            <xsl:text>&#x0D;&#x0A;</xsl:text>
        </xsl:when>
    </xsl:choose>
</xsl:variable>
<!-- Omeka element sets. -->
<xsl:variable name="omeka_sets" select="document($omeka_sets_file)"/>
<!-- User element sets. -->
<xsl:variable name="user_sets" select="document($user_sets_file)"/>

<!-- Main template -->
<xsl:template match="/">
    <xsl:if test="$headers = 'true'">
        <xsl:value-of select="$line_start"/>
        <xsl:text>recordType</xsl:text>

        <!-- For all items and files. -->
        <xsl:value-of select="$separator"/>
        <xsl:text>itemId</xsl:text>

        <!-- Specific columns of items. -->
        <xsl:value-of select="$separator"/>
        <xsl:text>itemType</xsl:text>
        <xsl:value-of select="$separator"/>
        <xsl:text>collection</xsl:text>
        <xsl:value-of select="$separator"/>
        <xsl:text>public</xsl:text>
        <xsl:value-of select="$separator"/>
        <xsl:text>featured</xsl:text>
        <xsl:value-of select="$separator"/>
        <xsl:text>tags</xsl:text>
        <!-- Note: Files are now imported individually, on separated lines. This field is kept for compatibility purpose. It will be removed in a future release. -->
        <xsl:value-of select="$separator"/>
        <xsl:text>file</xsl:text>

        <!-- Specific columns of files. -->
        <xsl:value-of select="$separator"/>
        <xsl:text>fileId</xsl:text>
        <xsl:value-of select="$separator"/>
        <xsl:text>fileSource</xsl:text>
        <xsl:value-of select="$separator"/>
        <xsl:text>fileOrder</xsl:text>

        <!-- Specific column for Kitchen Sister. -->
        <xsl:value-of select="$separator"/>
        <xsl:text>PBCore:Identifier</xsl:text>
        
        <!-- All metadata headers. -->
        <xsl:call-template name="element_sets"/>

        <xsl:value-of select="$line_end"/>
    </xsl:if>

    <xsl:apply-templates/>
</xsl:template>

<!-- Row for each item. -->
<xsl:template match="omeka:item">
    <xsl:value-of select="$line_start"/>
    <xsl:text>Item</xsl:text>

    <!-- For all items and files. -->
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="@itemId"/>

    <!-- Specific columns of items. -->
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="omeka:itemType/omeka:name"/>
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="omeka:collection/omeka:name"/>
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="@public"/>
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="@featured"/>
    <!-- Specific multivalued columns of items. -->
    <xsl:call-template name="item_tags" />
    <!-- Note: Files are now imported individually, on separated lines, so we don't call item_files any more. This field will be removed in a future release. -->
    <!-- <xsl:call-template name="item_files" /> -->
    <xsl:value-of select="$separator"/>

    <!-- Nothing for columns specific to files. -->
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="$separator"/>

    <!-- Specific column for Kitchen Sister. -->
    <xsl:value-of select="$separator"/>
    <xsl:text>http://kitchensisters.org/archive/items/show/</xsl:text>
    <xsl:value-of select="@itemId"/>
        
    <!-- Metadata of items. -->
    <xsl:call-template name="metadata_item">
        <xsl:with-param name="current_record" select="."/>
        <xsl:with-param name="sets" select="$omeka_sets"/>
    </xsl:call-template>
    <xsl:call-template name="metadata_item">
        <xsl:with-param name="current_record" select="."/>
        <xsl:with-param name="sets" select="$user_sets"/>
    </xsl:call-template>

    <xsl:value-of select="$line_end"/>

    <!-- Apply templates for files. -->
    <xsl:apply-templates/>
</xsl:template>

<!-- Row for each attached file of an item. -->
<xsl:template match="omeka:fileContainer/omeka:file">
    <xsl:value-of select="$line_start"/>
    <xsl:text>File</xsl:text>

    <!-- For all items and files. -->
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="ancestor::omeka:item/@itemId"/>

    <!-- Nothing for columns specific to items. -->
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="$separator"/>
    <!-- Note: This field will be removed in a future release. -->
    <xsl:value-of select="$separator"/>

    <!-- Specific columns of files. -->
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="@fileId"/>
    <xsl:value-of select="$separator"/>
    <xsl:choose>
        <xsl:when test="$original_filename = 'convert'">        
            <xsl:text>http://kitchensisters.org/archive/archive/files/</xsl:text>
            <xsl:variable name="file">
                <xsl:call-template name="basename">
                     <xsl:with-param name="path" select="omeka:src"/>
                 </xsl:call-template>
            </xsl:variable>
            <xsl:value-of select="substring-before($file, '.')"/>
            <xsl:text>.</xsl:text>
            <xsl:variable name="extension">
                <xsl:if test="function-available('php:function')">
                      <!-- TODO To be completed. Currently, we use direct call by a patch in CsvImport. -->
                      <!-- <xsl:value-of select="php:function('item_file', 'id', '', 'array()', @fileId)"/> -->
                </xsl:if>
            </xsl:variable>
            <xsl:value-of select="substring-after($extension, '.')"/>
        </xsl:when>
        <xsl:when test="$original_filename != 'basename'">
            <xsl:value-of select="omeka:src"/>
        </xsl:when>
        <xsl:otherwise>
            <xsl:call-template name="basename">
                 <xsl:with-param name="path" select="omeka:src"/>
             </xsl:call-template>
        </xsl:otherwise>
    </xsl:choose>

    <xsl:value-of select="$separator"/>
    <xsl:value-of select="@order"/>

    <!-- Specific column for Kitchen Sister (item). -->
    <xsl:value-of select="$separator"/>
        
    <!-- Metadata for files. -->
    <xsl:call-template name="metadata_file">
        <xsl:with-param name="current_record" select="."/>
        <xsl:with-param name="sets" select="$omeka_sets"/>
    </xsl:call-template>
    <xsl:call-template name="metadata_file">
        <xsl:with-param name="current_record" select="."/>
        <xsl:with-param name="sets" select="$user_sets"/>
    </xsl:call-template>

    <xsl:value-of select="$line_end"/>
</xsl:template>

<!-- Row for headers. -->
<xsl:template name="element_sets">
    <!-- Check if we convert element sets. -->
    <xsl:choose>
        <xsl:when test="$convert_sets_file = ''">        
            <xsl:for-each select="$omeka_sets/XMLlist/elementSet">
                <xsl:for-each select="element">
                    <xsl:value-of select="$separator"/>
                    <xsl:value-of select="../@setName"/>
                    <xsl:text>:</xsl:text>
                    <xsl:value-of select="."/>
                </xsl:for-each>
            </xsl:for-each>
            <xsl:for-each select="$user_sets/XMLlist/elementSet">
                <xsl:for-each select="element">
                    <xsl:value-of select="$separator"/>
                    <xsl:value-of select="../@setName"/>
                    <xsl:text>:</xsl:text>
                    <xsl:value-of select="."/>
                </xsl:for-each>
            </xsl:for-each>
        </xsl:when>
        <xsl:otherwise>
            <xsl:variable name="convert_sets" select="document($convert_sets_file)"/>
            <xsl:for-each select="$convert_sets/XMLlist/elementSet">
                <xsl:for-each select="element">
                    <xsl:value-of select="$separator"/>
                    <xsl:value-of select="../@setName"/>
                    <xsl:text>:</xsl:text>
                    <xsl:value-of select="."/>
                </xsl:for-each>
            </xsl:for-each>
        </xsl:otherwise>
    </xsl:choose>
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

<!-- Note: Files are now imported individually, on separated lines, so we don't call item_files any more. This template will be removed in a future release. -->
<!-- Helper for list of files of an item. -->
<xsl:template name="item_files">
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

    <xsl:for-each select="$sets/XMLlist/elementSet">
        <xsl:variable name="setName" select="@setName"/>
        <xsl:for-each select="element">
            <xsl:variable name="elementName" select="."/>
            <xsl:value-of select="$separator"/>
            <xsl:choose>
                <!-- Exception: Dublin Core:Notes should be merged with Dublin Core:Format. -->
                <xsl:when test="$setName = 'Dublin Core' and $elementName = 'Notes'">
                    <xsl:value-of select="$current_record/omeka:elementSetContainer/omeka:elementSet[omeka:name = $setName]/omeka:elementContainer/omeka:element[omeka:name = 'Format']/omeka:elementTextContainer/omeka:elementText/omeka:text"/>
                    <xsl:value-of select="$delimiter_multivalues_csvreport"/>
                    <xsl:value-of select="$current_record/omeka:elementSetContainer/omeka:elementSet[omeka:name = $setName]/omeka:elementContainer/omeka:element[omeka:name = $elementName]/omeka:elementTextContainer/omeka:elementText/omeka:text"/>
                </xsl:when>
                <!-- Metadata for items and files (Dublin Core...). -->
                <xsl:when test="../@recordType = 'All'">
                    <xsl:value-of select="$current_record/omeka:elementSetContainer/omeka:elementSet[omeka:name = $setName]/omeka:elementContainer/omeka:element[omeka:name = $elementName]/omeka:elementTextContainer/omeka:elementText/omeka:text"/>
                </xsl:when>
                <!-- Metadata for items. -->
                <xsl:when test="../@recordType = 'Item'">
                      <xsl:value-of select="$current_record/omeka:itemType/omeka:elementContainer/omeka:element[omeka:name = $elementName]/omeka:elementTextContainer/omeka:elementText/omeka:text"/>
                </xsl:when>
                <!-- Metadata for files. -->
                <!-- Skip metadata. -->
            </xsl:choose>
        </xsl:for-each>
    </xsl:for-each>
</xsl:template>

<!-- Helper to get metadata of a file. -->
<xsl:template name="metadata_file">
    <xsl:param name="current_record"/>
    <xsl:param name="sets"/>

    <xsl:for-each select="$sets/XMLlist/elementSet">
        <xsl:variable name="setName" select="@setName"/>
        <xsl:for-each select="element">
            <xsl:variable name="elementName" select="."/>
            <xsl:value-of select="$separator"/>
            <xsl:choose>
                <!-- Metadata for items and files (Dublin Core...) or for files only. -->
                <xsl:when test="../@recordType = 'All' or ../@recordType = 'File'">
                    <xsl:value-of select="$current_record/omeka:elementSetContainer/omeka:elementSet[omeka:name = $setName]/omeka:elementContainer/omeka:element[omeka:name = $elementName]/omeka:elementTextContainer/omeka:elementText/omeka:text"/>
                </xsl:when>
                <!-- Metadata for items. -->
                <!-- Skip metadata. -->
            </xsl:choose>
        </xsl:for-each>
    </xsl:for-each>
</xsl:template>

<!-- Helper to get last part of a string. -->
<xsl:template name="lastpart">
  <xsl:param name="string"/>
  <xsl:param name="character"/>
  <xsl:choose>
     <xsl:when test="contains($string, $character)">
          <xsl:call-template name="lastpart">
               <xsl:with-param name="string" select="substring-after($string, $character)"/>
               <xsl:with-param name="character" select="$character"/>
           </xsl:call-template>
     </xsl:when>
     <xsl:otherwise>
        <xsl:value-of select="$string"/>
     </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- Helper to get base name of a file path. -->
<xsl:template name="basename">
  <xsl:param name="path"/>
  <xsl:choose>
     <xsl:when test="contains($path, '/')">
        <xsl:call-template name="basename">
           <xsl:with-param name="path" select="substring-after($path, '/')"/>
        </xsl:call-template>
     </xsl:when>
     <xsl:when test="contains($path, '\')">
        <xsl:call-template name="basename">
           <xsl:with-param name="path" select="substring-after($path, '\')"/>
        </xsl:call-template>
     </xsl:when>
     <xsl:otherwise>
        <xsl:value-of select="$path"/>
     </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="text()">
    <!-- Ignore tout le reste -->
</xsl:template>

</xsl:stylesheet>
