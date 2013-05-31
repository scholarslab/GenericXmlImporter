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
        var fieldsAll = $('div.field').has('#xml_file, #xml_folder');
        if ($('#file_import-file').is(':checked')) {
            fieldsFile.show();
            fieldsFolder.hide();
        } else if ($('#file_import-folder').is(':checked')) {
            fieldsFolder.show();
            fieldsFile.hide();
        } else if ($('#file_import-recursive').is(':checked')) {
            fieldsFolder.show();
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
        var fieldsReportNo = $('div.field').has('#item_type_id, #collection_id, #items_are_public, #items_are_featured, #automap_columns, #column_delimiter_name, #column_delimiter, #element_delimiter_name, #element_delimiter, #tag_delimiter_name, #tag_delimiter, #file_delimiter_name, #file_delimiter');
        var fieldsItem = $('div.field').has('#item_type_id, #collection_id, #items_are_public, #items_are_featured, #automap_columns, #column_delimiter_name, #column_delimiter, #element_delimiter_name, #element_delimiter, #tag_delimiter_name, #tag_delimiter, #file_delimiter_name, #file_delimiter');
        var fieldsItemNo = $('div.field').has('#elements_are_html');
        var fieldsFile = $('div.field').has('#automap_columns, #column_delimiter_name, #column_delimiter, #element_delimiter_name, #element_delimiter, #tag_delimiter_name, #tag_delimiter');
        var fieldsFileNo = $('div.field').has('#item_type_id, #collection_id, #items_are_public, #items_are_featured, #elements_are_html, #file_delimiter_name, #file_delimiter');
        var fieldsMix = $('div.field').has('#item_type_id, #collection_id, #items_are_public, #items_are_featured, #elements_are_html, #column_delimiter_name, #column_delimiter, #element_delimiter_name, #element_delimiter, #tag_delimiter_name, #tag_delimiter, #file_delimiter_name, #file_delimiter');
        var fieldsMixNo = $('div.field').has('#automap_columns');
        var fieldsAll = $('div.field').has('#item_type_id, #collection_id, #items_are_public, #items_are_featured, #elements_are_html, #automap_columns, #column_delimiter_name, #column_delimiter, #element_delimiter_name, #element_delimiter, #tag_delimiter_name, #tag_delimiter, #file_delimiter_name, #file_delimiter');
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
        } else {
            fieldsAll.slideUp();
        };
    };

    /**
     * Enable/disable options after loading.
     */
    Omeka.XmlImport.updateOnLoad = function () {
        Omeka.XmlImport.updateFileOptions();
        Omeka.XmlImport.updateImportOptions();
    };

})(jQuery);
