if (!Omeka) {
    var Omeka = {};
}

Omeka.XmlImport = {};

(function ($) {

    /**
     * Enable/disable options according to file option.
     */
    Omeka.XmlImport.updateFileOptions = function () {
        var fieldsFile = $('div.field').has('#xml_file');
        var fieldsFolder = $('div.field').has('#xml_folder');
        var fieldsFormat = $('div.field').has('#format_filename');
        var fieldsAll = $('div.field').has('#xml_file, #xml_folder', '#format_filename');
        if ($('#file_import-file').is(':checked')) {
            fieldsFile.show();
            fieldsFolder.hide();
            fieldsFormat.hide();
        } else if ($('#file_import-folder').is(':checked')) {
            fieldsFolder.show();
            fieldsFormat.show();
            fieldsFile.hide();
        } else if ($('#file_import-recursive').is(':checked')) {
            fieldsFolder.show();
            fieldsFormat.show();
            fieldsFile.hide();
        } else {
            fieldsAll.hide();
        };
    };

    /**
     * Enable/disable options according to selected format.
     */
    Omeka.XmlImport.updateImportOptions = function () {
        var fieldsReport = $('#div.field').has('#elements_are_html');
        var fieldsReportNo = $('div.field').has('#item_type_id, #collection_id, #create_collections, #items_are_public, #items_are_featured, #contains_extra_data, #automap_columns, #column_delimiter_name, #column_delimiter, #enclosure, #element_delimiter_name, #element_delimiter, #tag_delimiter_name, #tag_delimiter, #file_delimiter_name, #file_delimiter');
        var fieldsItem = $('div.field').has('#item_type_id, #collection_id, #create_collections, #items_are_public, #items_are_featured, #automap_columns, #column_delimiter_name, #column_delimiter, #enclosure, #element_delimiter_name, #element_delimiter, #tag_delimiter_name, #tag_delimiter, #file_delimiter_name, #file_delimiter');
        var fieldsItemNo = $('div.field').has('#elements_are_html, #contains_extra_data');
        var fieldsFile = $('div.field').has('#automap_columns, #column_delimiter_name, #column_delimiter, #element_delimiter_name, #element_delimiter, #enclosure, #tag_delimiter_name, #tag_delimiter');
        var fieldsFileNo = $('div.field').has('#item_type_id, #collection_id, #create_collections, #items_are_public, #items_are_featured, #elements_are_html, #contains_extra_data, #file_delimiter_name, #file_delimiter');
        var fieldsMix = $('div.field').has('#item_type_id, #collection_id, #create_collections, #items_are_public, #items_are_featured, #elements_are_html, #contains_extra_data, #column_delimiter_name, #column_delimiter, #enclosure, #element_delimiter_name, #element_delimiter, #tag_delimiter_name, #tag_delimiter, #file_delimiter_name, #file_delimiter');
        var fieldsMixNo = $('div.field').has('#automap_columns');
        var fieldsUpdate = $('div.field').has('#create_collections, #elements_are_html, #contains_extra_data, #column_delimiter_name, #column_delimiter, #enclosure, #element_delimiter_name, #element_delimiter, #tag_delimiter_name, #tag_delimiter, #file_delimiter_name, #file_delimiter');
        var fieldsUpdateNo = $('div.field').has('#item_type_id, #collection_id, #items_are_public, #items_are_featured, #automap_columns');
        var fieldsAll = $('div.field').has('#item_type_id, #collection_id, #create_collections, #items_are_public, #items_are_featured, #elements_are_html, #contains_extra_data, #automap_columns, #column_delimiter_name, #column_delimiter, #enclosure, #element_delimiter_name, #element_delimiter, #tag_delimiter_name, #tag_delimiter, #file_delimiter_name, #file_delimiter');
        if ($('#format-Report').is(':checked')) {
            fieldsReport.slideDown();
            fieldsReportNo.slideUp();
        } else if ($('#format-Item').is(':checked')) {
            fieldsItem.slideDown();
            fieldsItemNo.slideUp();
        } else if ($('#format-File').is(':checked')) {
            fieldsFile.slideDown();
            fieldsFileNo.slideUp();
        } else if ($('#format-Mix').is(':checked')) {
            fieldsMix.slideDown();
            fieldsMixNo.slideUp();
        } else if ($('#format-Update').is(':checked')) {
            fieldsUpdate.slideDown();
            fieldsUpdateNo.slideUp();
        } else {
            fieldsAll.slideUp();
        };
    };

    /**
     * Enable/disable column delimiter field.
     */
    Omeka.XmlImport.updateColumnDelimiterField = function () {
        var fieldSelect = $('#column_delimiter_name');
        var fieldCustom = $('#column_delimiter');
        if (fieldSelect.val() == 'custom') {
            fieldCustom.show();
        } else {
            fieldCustom.hide();
        };
    };

    /**
     * Enable/disable element delimiter field.
     */
    Omeka.XmlImport.updateElementDelimiterField = function () {
        var fieldSelect = $('#element_delimiter_name');
        var fieldCustom = $('#element_delimiter');
        if (fieldSelect.val() == 'custom') {
            fieldCustom.show();
        } else {
            fieldCustom.hide();
        };
    };

    /**
     * Enable/disable tag delimiter field.
     */
    Omeka.XmlImport.updateTagDelimiterField = function () {
        var fieldSelect = $('#tag_delimiter_name');
        var fieldCustom = $('#tag_delimiter');
        if (fieldSelect.val() == 'custom') {
            fieldCustom.show();
        } else {
            fieldCustom.hide();
        };
    };

    /**
     * Enable/disable file delimiter field.
     */
    Omeka.XmlImport.updateFileDelimiterField = function () {
        var fieldSelect = $('#file_delimiter_name');
        var fieldCustom = $('#file_delimiter');
        if (fieldSelect.val() == 'custom') {
            fieldCustom.show();
        } else {
            fieldCustom.hide();
        };
    };

    /**
     * Enable/disable options after loading.
     */
    Omeka.XmlImport.updateOnLoad = function () {
        Omeka.XmlImport.updateFileOptions();
        Omeka.XmlImport.updateImportOptions();
        Omeka.XmlImport.updateColumnDelimiterField();
        Omeka.XmlImport.updateElementDelimiterField();
        Omeka.XmlImport.updateTagDelimiterField();
        Omeka.XmlImport.updateFileDelimiterField();
    };

})(jQuery);
