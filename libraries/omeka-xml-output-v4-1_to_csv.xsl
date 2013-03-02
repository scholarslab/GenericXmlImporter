<?xml version="1.0" encoding="UTF-8"?>
<!--
    Document : omeka-xml-output-v4-1_to_csv.xsl
    Created date : 21/10/2012
    Version : 1.0
    Author : Daniel Berthereau for Pop Up Archive (http://popuparchive.org)
    Description : Convert an Omeka Xml output (version 4.1) to CSV format in order to import it in another instance of Omeka with CsvImport.


    Notes
    - This sheet should be used with XmlImport 1.5-files_metadata and CsvImport 1.3.4-fork.
    - This sheet is compatible with Omeka Xml output 4.0.
    - This sheet doesn't manage html fields (neither Omeka Xml output).
    - This sheet doesn't manage repetition of fields, except tags and files.

    - This sheet can be optimized (do a for-each for each element in a set for headers and values).
-->

<xsl:stylesheet version="1.1"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:omeka="http://omeka.org/schemas/omeka-xml/v4">
<xsl:output method="text"
    media-type="text/csv"
    encoding="UTF-8"
    omit-xml-declaration="yes"/>

<!-- Parameters -->
<!-- Tabulation by default, because it never appears in current files. -->
<!-- Warning: CsvImport doesn't allow it by default. -->
<xsl:param name="delimiter"><xsl:text>&#x09;</xsl:text></xsl:param>
<!-- No enclusure is needed when tabulation is used. -->
<xsl:param name="enclosure"></xsl:param>
<!-- Currently, CsvImport doesn't allow a specific delimiter for multivalued fields. -->
<xsl:param name="delimiter_multivalues">,</xsl:param>
<!-- Headers are added by default. -->
<xsl:param name="headers">true</xsl:param>
<!-- Unix end of line by default. -->
<xsl:param name="end_of_line">Linux</xsl:param>
<!-- Unix end of line by default. -->
<xsl:param name="status">Update</xsl:param>

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
    </xsl:choose>
</xsl:variable>

<!-- Main template -->
<xsl:template match="/">
    <xsl:if test="$headers = 'true'">
        <xsl:value-of select="$line_start"/>
        <!-- Status can be "Update" (if exists, else creates) or "Create" (always create, even existing). -->
        <xsl:text>Omeka import status</xsl:text>
        <xsl:value-of select="$separator"/>
        <xsl:text>Item identifier</xsl:text>
        <xsl:value-of select="$separator"/>
        <xsl:text>Item type</xsl:text>
        <xsl:value-of select="$separator"/>
        <xsl:text>Collection name</xsl:text>
        <xsl:value-of select="$separator"/>
        <xsl:text>Public</xsl:text>
        <xsl:value-of select="$separator"/>
        <xsl:text>Featured</xsl:text>
        <xsl:value-of select="$separator"/>
        <xsl:text>Tags</xsl:text>
        <!-- To add these filenames is needed with current release of XmlImport and CsvImport. -->
        <xsl:value-of select="$separator"/>
        <xsl:text>Filenames</xsl:text>

        <!-- Files metadata. -->
        <xsl:value-of select="$separator"/>
        <xsl:text>File identifier</xsl:text>
        <xsl:value-of select="$separator"/>
        <xsl:text>File order</xsl:text>
        <xsl:value-of select="$separator"/>
        <xsl:text>File source</xsl:text>
        <xsl:value-of select="$separator"/>
        <xsl:text>File authentication</xsl:text>

        <!-- Metadata. -->
        <xsl:call-template name="Dublin_core_set" />
        <xsl:call-template name="Items_sets" />
        <xsl:call-template name="Files_sets" />

        <xsl:value-of select="$line_end"/>
    </xsl:if>

    <xsl:apply-templates/>
</xsl:template>

<!-- Dublin Core -->
<xsl:template name="Dublin_core_set">
    <xsl:value-of select="$separator"/>
    <xsl:text>Contributor</xsl:text>
    <xsl:value-of select="$separator"/>
    <xsl:text>Coverage</xsl:text>
    <xsl:value-of select="$separator"/>
    <xsl:text>Creator</xsl:text>
    <xsl:value-of select="$separator"/>
    <xsl:text>Date</xsl:text>
    <xsl:value-of select="$separator"/>
    <xsl:text>Description</xsl:text>
    <xsl:value-of select="$separator"/>
    <xsl:text>Format</xsl:text>
    <xsl:value-of select="$separator"/>
    <xsl:text>Identifier</xsl:text>
    <xsl:value-of select="$separator"/>
    <xsl:text>Language</xsl:text>
    <xsl:value-of select="$separator"/>
    <xsl:text>Publisher</xsl:text>
    <xsl:value-of select="$separator"/>
    <xsl:text>Relation</xsl:text>
    <xsl:value-of select="$separator"/>
    <xsl:text>Rights</xsl:text>
    <xsl:value-of select="$separator"/>
    <xsl:text>Source</xsl:text>
    <xsl:value-of select="$separator"/>
    <xsl:text>Subject</xsl:text>
    <xsl:value-of select="$separator"/>
    <xsl:text>Title</xsl:text>
    <xsl:value-of select="$separator"/>
    <xsl:text>Type</xsl:text>
</xsl:template>

<xsl:template name="Items_sets">
    <xsl:value-of select="$separator"/>
    <xsl:text>Text</xsl:text>
    <xsl:value-of select="$separator"/>
    <xsl:text>Interviewer</xsl:text>
    <xsl:value-of select="$separator"/>
    <xsl:text>Interviewee</xsl:text>
    <xsl:value-of select="$separator"/>
    <xsl:text>Location</xsl:text>
    <xsl:value-of select="$separator"/>
    <xsl:text>Transcription</xsl:text>
    <xsl:value-of select="$separator"/>
    <xsl:text>Local URL</xsl:text>
    <xsl:value-of select="$separator"/>
    <xsl:text>Original Format</xsl:text>
    <xsl:value-of select="$separator"/>
    <xsl:text>Physical Dimension</xsl:text>
    <xsl:value-of select="$separator"/>
    <xsl:text>Duration</xsl:text>
    <xsl:value-of select="$separator"/>
    <xsl:text>Compression</xsl:text>
    <xsl:value-of select="$separator"/>
    <xsl:text>Producer</xsl:text>
    <xsl:value-of select="$separator"/>
    <xsl:text>Director</xsl:text>
    <xsl:value-of select="$separator"/>
    <xsl:text>Bit Rate/Frequency</xsl:text>
    <xsl:value-of select="$separator"/>
    <xsl:text>Time Summary</xsl:text>
    <xsl:value-of select="$separator"/>
    <xsl:text>Email Body</xsl:text>
    <xsl:value-of select="$separator"/>
    <xsl:text>Subject Line</xsl:text>
    <xsl:value-of select="$separator"/>
    <xsl:text>From</xsl:text>
    <xsl:value-of select="$separator"/>
    <xsl:text>To</xsl:text>
    <xsl:value-of select="$separator"/>
    <xsl:text>CC</xsl:text>
    <xsl:value-of select="$separator"/>
    <xsl:text>BCC</xsl:text>
    <xsl:value-of select="$separator"/>
    <xsl:text>Number of Attachments</xsl:text>
    <xsl:value-of select="$separator"/>
    <xsl:text>Standards</xsl:text>
    <xsl:value-of select="$separator"/>
    <xsl:text>Objectives</xsl:text>
    <xsl:value-of select="$separator"/>
    <xsl:text>Materials</xsl:text>
    <xsl:value-of select="$separator"/>
    <xsl:text>Lesson Plan Text</xsl:text>
    <xsl:value-of select="$separator"/>
    <xsl:text>URL</xsl:text>
    <xsl:value-of select="$separator"/>
    <xsl:text>Event Type</xsl:text>
    <xsl:value-of select="$separator"/>
    <xsl:text>Participants</xsl:text>
    <xsl:value-of select="$separator"/>
    <xsl:text>Birth Date</xsl:text>
    <xsl:value-of select="$separator"/>
    <xsl:text>Birthplace</xsl:text>
    <xsl:value-of select="$separator"/>
    <xsl:text>Death Date</xsl:text>
    <xsl:value-of select="$separator"/>
    <xsl:text>Occupation</xsl:text>
    <xsl:value-of select="$separator"/>
    <xsl:text>Biographical</xsl:text>
    <xsl:value-of select="$separator"/>
    <xsl:text>Bibliography</xsl:text>
</xsl:template>

<xsl:template name="Files_sets">
    <xsl:value-of select="$separator"/>
    <xsl:text>Additional Creator</xsl:text>
    <xsl:value-of select="$separator"/>
    <xsl:text>Transcriber</xsl:text>
    <xsl:value-of select="$separator"/>
    <xsl:text>Producer</xsl:text>
    <xsl:value-of select="$separator"/>
    <xsl:text>Render Device</xsl:text>
    <xsl:value-of select="$separator"/>
    <xsl:text>Render Details</xsl:text>
    <xsl:value-of select="$separator"/>
    <xsl:text>Capture Date</xsl:text>
    <xsl:value-of select="$separator"/>
    <xsl:text>Capture Device</xsl:text>
    <xsl:value-of select="$separator"/>
    <xsl:text>Capture Details</xsl:text>
    <xsl:value-of select="$separator"/>
    <xsl:text>Change History</xsl:text>
    <xsl:value-of select="$separator"/>
    <xsl:text>Watermark</xsl:text>
    <xsl:value-of select="$separator"/>
    <xsl:text>Encryption</xsl:text>
    <xsl:value-of select="$separator"/>
    <xsl:text>Compression</xsl:text>
    <xsl:value-of select="$separator"/>
    <xsl:text>Post Processing</xsl:text>
    <xsl:value-of select="$separator"/>
    <xsl:text>Width</xsl:text>
    <xsl:value-of select="$separator"/>
    <xsl:text>Height</xsl:text>
    <xsl:value-of select="$separator"/>
    <xsl:text>Bit Depth</xsl:text>
    <xsl:value-of select="$separator"/>
    <xsl:text>Channels</xsl:text>
    <xsl:value-of select="$separator"/>
    <xsl:text>Exif String</xsl:text>
    <xsl:value-of select="$separator"/>
    <xsl:text>Exif Array</xsl:text>
    <xsl:value-of select="$separator"/>
    <xsl:text>IPTC String</xsl:text>
    <xsl:value-of select="$separator"/>
    <xsl:text>IPTC Array</xsl:text>
    <xsl:value-of select="$separator"/>
    <xsl:text>Bitrate</xsl:text>
    <xsl:value-of select="$separator"/>
    <xsl:text>Duration</xsl:text>
    <xsl:value-of select="$separator"/>
    <xsl:text>Sample Rate</xsl:text>
    <xsl:value-of select="$separator"/>
    <xsl:text>Codec</xsl:text>
    <xsl:value-of select="$separator"/>
    <xsl:text>Width</xsl:text>
    <xsl:value-of select="$separator"/>
    <xsl:text>Height</xsl:text>
</xsl:template>

<xsl:template name="empty_set">
    <xsl:param name="set"/>
    <xsl:variable name="headers">
        <xsl:choose>
            <xsl:when test="$set = 'Dublin_core_set'">
                <xsl:call-template name="Dublin_core_set" />
            </xsl:when>
            <xsl:when test="$set = 'Items_sets'">
                <xsl:call-template name="Items_sets" />
            </xsl:when>
            <xsl:when test="$set = 'Files_sets'">
                <xsl:call-template name="Files_sets" />
            </xsl:when>
        </xsl:choose>
    </xsl:variable>
    <xsl:value-of select="translate($headers, $headers, $separator)"/>
</xsl:template>

<xsl:template match="omeka:item">
        <xsl:value-of select="$line_start"/>
        <xsl:value-of select="$status"/>

        <xsl:call-template name="item_base" />
        <xsl:call-template name="item_tags" />
        <xsl:call-template name="item_filenames" />

        <!-- Files metadata. -->
        <xsl:value-of select="$separator"/>
        <xsl:value-of select="$separator"/>
        <xsl:value-of select="$separator"/>
        <xsl:value-of select="$separator"/>

        <!-- Metadata. -->
        <xsl:for-each select="omeka:elementSetContainer/omeka:elementSet[omeka:name = 'Dublin Core']/omeka:elementContainer">
            <xsl:call-template name="Dublin_core_set_values" />
        </xsl:for-each>
        <!-- <xsl:for-each select="omeka:itemType/omeka:name = 'Oral History']/omeka:elementContainer"> -->
            <!-- <xsl:call-template name="Items_sets_values" /> -->
        <!-- </xsl:for-each> -->
        <xsl:call-template name="Items_sets_values" />
        <xsl:call-template name="empty_set">
            <xsl:with-param name="set"><xsl:text>Files_sets</xsl:text></xsl:with-param>
        </xsl:call-template>

        <xsl:value-of select="$line_end"/>

        <xsl:for-each select="omeka:fileContainer/omeka:file">
            <xsl:value-of select="$line_start"/>
            <xsl:text>File</xsl:text>

            <xsl:for-each select="../../../omeka:item">
                <xsl:call-template name="item_base" />
            </xsl:for-each>
            <!-- No tags added. -->
            <xsl:value-of select="$separator"/>
            <!-- No filenames added. -->
            <xsl:value-of select="$separator"/>

            <!-- Files metadata. -->
            <xsl:value-of select="$separator"/>
            <xsl:value-of select="@fileId"/>
            <xsl:value-of select="$separator"/>
            <xsl:value-of select="@order"/>
            <xsl:value-of select="$separator"/>
            <xsl:value-of select="omeka:src"/>
            <xsl:value-of select="$separator"/>
            <xsl:value-of select="omeka:authentication"/>

            <!-- Metadata. -->
            <xsl:for-each select="omeka:elementSetContainer/omeka:elementSet[omeka:name = 'Dublin Core']/omeka:elementContainer">
                <xsl:call-template name="Dublin_core_set_values" />
            </xsl:for-each>
            <xsl:call-template name="empty_set">
                <xsl:with-param name="set"><xsl:text>Items_sets</xsl:text></xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name="Files_sets_values" />

            <xsl:value-of select="$line_end"/>
        </xsl:for-each>
</xsl:template>

<xsl:template name="item_base">
        <xsl:value-of select="$separator"/>
        <xsl:value-of select="@itemId"/>
        <xsl:value-of select="$separator"/>
        <xsl:value-of select="omeka:itemType/omeka:name"/>
        <xsl:value-of select="$separator"/>
        <xsl:value-of select="omeka:collection/omeka:name"/>
        <xsl:value-of select="$separator"/>
        <xsl:value-of select="@public"/>
        <xsl:value-of select="$separator"/>
        <xsl:value-of select="@featured"/>
</xsl:template>

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

<!-- Dublin Core values-->
<xsl:template name="Dublin_core_set_values">
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="omeka:element[omeka:name = 'Contributor']/omeka:elementTextContainer/omeka:elementText/omeka:text"/>
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="omeka:element[omeka:name = 'Coverage']/omeka:elementTextContainer/omeka:elementText/omeka:text"/>
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="omeka:element[omeka:name = 'Creator']/omeka:elementTextContainer/omeka:elementText/omeka:text"/>
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="omeka:element[omeka:name = 'Date']/omeka:elementTextContainer/omeka:elementText/omeka:text"/>
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="omeka:element[omeka:name = 'Description']/omeka:elementTextContainer/omeka:elementText/omeka:text"/>
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="omeka:element[omeka:name = 'Format']/omeka:elementTextContainer/omeka:elementText/omeka:text"/>
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="omeka:element[omeka:name = 'Identifier']/omeka:elementTextContainer/omeka:elementText/omeka:text"/>
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="omeka:element[omeka:name = 'Language']/omeka:elementTextContainer/omeka:elementText/omeka:text"/>
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="omeka:element[omeka:name = 'Publisher']/omeka:elementTextContainer/omeka:elementText/omeka:text"/>
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="omeka:element[omeka:name = 'Relation']/omeka:elementTextContainer/omeka:elementText/omeka:text"/>
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="omeka:element[omeka:name = 'Rights']/omeka:elementTextContainer/omeka:elementText/omeka:text"/>
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="omeka:element[omeka:name = 'Source']/omeka:elementTextContainer/omeka:elementText/omeka:text"/>
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="omeka:element[omeka:name = 'Subject']/omeka:elementTextContainer/omeka:elementText/omeka:text"/>
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="omeka:element[omeka:name = 'Title']/omeka:elementTextContainer/omeka:elementText/omeka:text"/>
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="omeka:element[omeka:name = 'Type']/omeka:elementTextContainer/omeka:elementText/omeka:text"/>
</xsl:template>

<xsl:template name="Items_sets_values">
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="omeka:element[omeka:name = 'Text']/omeka:elementTextContainer/omeka:elementText/omeka:text"/>
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="omeka:element[omeka:name = 'Interviewer']/omeka:elementTextContainer/omeka:elementText/omeka:text"/>
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="omeka:element[omeka:name = 'Interviewee']/omeka:elementTextContainer/omeka:elementText/omeka:text"/>
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="omeka:element[omeka:name = 'Location']/omeka:elementTextContainer/omeka:elementText/omeka:text"/>
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="omeka:element[omeka:name = 'Transcription']/omeka:elementTextContainer/omeka:elementText/omeka:text"/>
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="omeka:element[omeka:name = 'Local URL']/omeka:elementTextContainer/omeka:elementText/omeka:text"/>
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="omeka:element[omeka:name = 'Original Format']/omeka:elementTextContainer/omeka:elementText/omeka:text"/>
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="omeka:element[omeka:name = 'Physical Dimension']/omeka:elementTextContainer/omeka:elementText/omeka:text"/>
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="omeka:element[omeka:name = 'Duration']/omeka:elementTextContainer/omeka:elementText/omeka:text"/>
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="omeka:element[omeka:name = 'Compression']/omeka:elementTextContainer/omeka:elementText/omeka:text"/>
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="omeka:element[omeka:name = 'Producer']/omeka:elementTextContainer/omeka:elementText/omeka:text"/>
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="omeka:element[omeka:name = 'Director']/omeka:elementTextContainer/omeka:elementText/omeka:text"/>
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="omeka:element[omeka:name = 'Bit Rate/Frequency']/omeka:elementTextContainer/omeka:elementText/omeka:text"/>
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="omeka:element[omeka:name = 'Time Summary']/omeka:elementTextContainer/omeka:elementText/omeka:text"/>
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="omeka:element[omeka:name = 'Email Body']/omeka:elementTextContainer/omeka:elementText/omeka:text"/>
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="omeka:element[omeka:name = 'Subject Line']/omeka:elementTextContainer/omeka:elementText/omeka:text"/>
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="omeka:element[omeka:name = 'From']/omeka:elementTextContainer/omeka:elementText/omeka:text"/>
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="omeka:element[omeka:name = 'To']/omeka:elementTextContainer/omeka:elementText/omeka:text"/>
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="omeka:element[omeka:name = 'CC']/omeka:elementTextContainer/omeka:elementText/omeka:text"/>
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="omeka:element[omeka:name = 'BCC']/omeka:elementTextContainer/omeka:elementText/omeka:text"/>
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="omeka:element[omeka:name = 'Number of Attachments']/omeka:elementTextContainer/omeka:elementText/omeka:text"/>
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="omeka:element[omeka:name = 'Standards']/omeka:elementTextContainer/omeka:elementText/omeka:text"/>
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="omeka:element[omeka:name = 'Objectives']/omeka:elementTextContainer/omeka:elementText/omeka:text"/>
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="omeka:element[omeka:name = 'Materials']/omeka:elementTextContainer/omeka:elementText/omeka:text"/>
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="omeka:element[omeka:name = 'Lesson Plan Text']/omeka:elementTextContainer/omeka:elementText/omeka:text"/>
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="omeka:element[omeka:name = 'URL']/omeka:elementTextContainer/omeka:elementText/omeka:text"/>
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="omeka:element[omeka:name = 'Event Type']/omeka:elementTextContainer/omeka:elementText/omeka:text"/>
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="omeka:element[omeka:name = 'Participants']/omeka:elementTextContainer/omeka:elementText/omeka:text"/>
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="omeka:element[omeka:name = 'Birth Date']/omeka:elementTextContainer/omeka:elementText/omeka:text"/>
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="omeka:element[omeka:name = 'Birthplace']/omeka:elementTextContainer/omeka:elementText/omeka:text"/>
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="omeka:element[omeka:name = 'Death Date']/omeka:elementTextContainer/omeka:elementText/omeka:text"/>
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="omeka:element[omeka:name = 'Occupation']/omeka:elementTextContainer/omeka:elementText/omeka:text"/>
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="omeka:element[omeka:name = 'Biographical']/omeka:elementTextContainer/omeka:elementText/omeka:text"/>
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="omeka:element[omeka:name = 'Bibliography']/omeka:elementTextContainer/omeka:elementText/omeka:text"/>
</xsl:template>

<xsl:template name="Files_sets_values">
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="omeka:element[omeka:name = 'Additional Creator']/omeka:elementTextContainer/omeka:elementText/omeka:text"/>
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="omeka:element[omeka:name = 'Transcriber']/omeka:elementTextContainer/omeka:elementText/omeka:text"/>
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="omeka:element[omeka:name = 'Producer']/omeka:elementTextContainer/omeka:elementText/omeka:text"/>
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="omeka:element[omeka:name = 'Render Device']/omeka:elementTextContainer/omeka:elementText/omeka:text"/>
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="omeka:element[omeka:name = 'Render Details']/omeka:elementTextContainer/omeka:elementText/omeka:text"/>
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="omeka:element[omeka:name = 'Capture Date']/omeka:elementTextContainer/omeka:elementText/omeka:text"/>
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="omeka:element[omeka:name = 'Capture Device']/omeka:elementTextContainer/omeka:elementText/omeka:text"/>
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="omeka:element[omeka:name = 'Capture Details']/omeka:elementTextContainer/omeka:elementText/omeka:text"/>
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="omeka:element[omeka:name = 'Change History']/omeka:elementTextContainer/omeka:elementText/omeka:text"/>
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="omeka:element[omeka:name = 'Watermark']/omeka:elementTextContainer/omeka:elementText/omeka:text"/>
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="omeka:element[omeka:name = 'Encryption']/omeka:elementTextContainer/omeka:elementText/omeka:text"/>
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="omeka:element[omeka:name = 'Compression']/omeka:elementTextContainer/omeka:elementText/omeka:text"/>
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="omeka:element[omeka:name = 'Post Processing']/omeka:elementTextContainer/omeka:elementText/omeka:text"/>
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="omeka:element[omeka:name = 'Width']/omeka:elementTextContainer/omeka:elementText/omeka:text"/>
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="omeka:element[omeka:name = 'Height']/omeka:elementTextContainer/omeka:elementText/omeka:text"/>
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="omeka:element[omeka:name = 'Bit Depth']/omeka:elementTextContainer/omeka:elementText/omeka:text"/>
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="omeka:element[omeka:name = 'Channels']/omeka:elementTextContainer/omeka:elementText/omeka:text"/>
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="omeka:element[omeka:name = 'Exif String']/omeka:elementTextContainer/omeka:elementText/omeka:text"/>
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="omeka:element[omeka:name = 'Exif Array']/omeka:elementTextContainer/omeka:elementText/omeka:text"/>
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="omeka:element[omeka:name = 'IPTC String']/omeka:elementTextContainer/omeka:elementText/omeka:text"/>
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="omeka:element[omeka:name = 'IPTC Array']/omeka:elementTextContainer/omeka:elementText/omeka:text"/>
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="omeka:element[omeka:name = 'Bitrate']/omeka:elementTextContainer/omeka:elementText/omeka:text"/>
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="omeka:element[omeka:name = 'Duration']/omeka:elementTextContainer/omeka:elementText/omeka:text"/>
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="omeka:element[omeka:name = 'Sample Rate']/omeka:elementTextContainer/omeka:elementText/omeka:text"/>
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="omeka:element[omeka:name = 'Codec']/omeka:elementTextContainer/omeka:elementText/omeka:text"/>
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="omeka:element[omeka:name = 'Width']/omeka:elementTextContainer/omeka:elementText/omeka:text"/>
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="omeka:element[omeka:name = 'Height']/omeka:elementTextContainer/omeka:elementText/omeka:text"/>
</xsl:template>

<xsl:template match="text()">
    <!-- Ignore tout le reste -->
</xsl:template>

</xsl:stylesheet>
