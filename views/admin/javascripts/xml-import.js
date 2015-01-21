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
        // Exactly the same than CsvImport.
        var fieldsManage = $('div.field').has('#action, #identifier_field, #item_type_id, #collection_id, #records_are_public, #records_are_featured, #elements_are_html, #contains_extra_data, #column_delimiter_name, #column_delimiter, #enclosure_name, #enclosure, #element_delimiter_name, #element_delimiter, #tag_delimiter_name, #tag_delimiter, #file_delimiter_name, #file_delimiter');
        var fieldsManageNo = $('div.field').has('#create_collections, #automap_columns');
        var fieldsReport = $('div.field').has('#elements_are_html');
        var fieldsReportNo = $('div.field').has('#action, #identifier_field, #item_type_id, #collection_id, #create_collections, #records_are_public, #records_are_featured, #contains_extra_data, #automap_columns, #column_delimiter_name, #column_delimiter, #enclosure_name, #enclosure, #element_delimiter_name, #element_delimiter, #tag_delimiter_name, #tag_delimiter, #file_delimiter_name, #file_delimiter');
        var fieldsItem = $('div.field').has('#item_type_id, #collection_id, #create_collections, #records_are_public, #records_are_featured, #automap_columns, #column_delimiter_name, #column_delimiter, #enclosure_name, #enclosure, #element_delimiter_name, #element_delimiter, #tag_delimiter_name, #tag_delimiter, #file_delimiter_name, #file_delimiter');
        var fieldsItemNo = $('div.field').has('#action, #identifier_field, #elements_are_html, #contains_extra_data');
        // Deprecated.
        var fieldsFile = $('div.field').has('#automap_columns, #column_delimiter_name, #column_delimiter, #enclosure_name, #enclosure, #element_delimiter_name, #element_delimiter, #tag_delimiter_name, #tag_delimiter');
        var fieldsFileNo = $('div.field').has('#action, #identifier_field, #item_type_id, #collection_id, #create_collections, #records_are_public, #records_are_featured, #elements_are_html, #contains_extra_data, #file_delimiter_name, #file_delimiter');
        var fieldsMix = $('div.field').has('#item_type_id, #collection_id, #create_collections, #records_are_public, #records_are_featured, #elements_are_html, #contains_extra_data, #column_delimiter_name, #column_delimiter, #enclosure_name, #enclosure, #element_delimiter_name, #element_delimiter, #tag_delimiter_name, #tag_delimiter, #file_delimiter_name, #file_delimiter');
        var fieldsMixNo = $('div.field').has('#action, #identifier_field, #automap_columns');
        var fieldsUpdate = fieldsMix;
        var fieldsUpdateNo = fieldsMixNo;
        var fieldsAll = $('div.field').has('#action, #identifier_field, #item_type_id, #collection_id, #create_collections, #records_are_public, #records_are_featured, #elements_are_html, #contains_extra_data, #automap_columns, #column_delimiter_name, #column_delimiter, #enclosure_name, #enclosure, #element_delimiter_name, #element_delimiter, #tag_delimiter_name, #tag_delimiter, #file_delimiter_name, #file_delimiter');
        // All except the xsl one, always down.
        var fieldSets =  $('#fieldset-file_type, #fieldset-csv_format, #fieldset-default_values, #fieldset-import_features');
        if ($('#format-Manage').is(':checked')) {
            fieldSets.slideDown();
            fieldsManage.slideDown();
            fieldsManageNo.slideUp();
        } else if ($('#format-Report').is(':checked')) {
            $('#fieldset-default_values').slideDown();
            $('#fieldset-csv_format, #fieldset-import_features').slideUp();
            fieldsReport.slideDown();
            fieldsReportNo.slideUp();
        } else if ($('#format-Item').is(':checked')) {
            fieldSets.slideDown();
            fieldsItem.slideDown();
            fieldsItemNo.slideUp();
        } else if ($('#format-File').is(':checked')) {
            $('#fieldset-default_values, #fieldset-import_features').slideUp();
            $('#fieldset-csv_format').slideDown();
            fieldsFile.slideDown();
            fieldsFileNo.slideUp();
        } else if ($('#format-Mix').is(':checked')) {
            fieldSets.slideDown();
            fieldsMix.slideDown();
            fieldsMixNo.slideUp();
        } else if ($('#format-Update').is(':checked')) {
            fieldSets.slideDown();
            fieldsUpdate.slideDown();
            fieldsUpdateNo.slideUp();
        } else {
            fieldSets.slideUp();
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
     * Enable/disable enclosure field.
     */
    Omeka.XmlImport.updateEnclosureField = function () {
        var fieldSelect = $('#enclosure_name');
        var fieldCustom = $('#enclosure');
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
        Omeka.XmlImport.updateEnclosureField();
        Omeka.XmlImport.updateElementDelimiterField();
        Omeka.XmlImport.updateTagDelimiterField();
        Omeka.XmlImport.updateFileDelimiterField();
    };

})(jQuery);
