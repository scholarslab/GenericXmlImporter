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
        Omeka.XmlImport.updateColumnDelimiterField();
        Omeka.XmlImport.updateEnclosureField();
        Omeka.XmlImport.updateElementDelimiterField();
        Omeka.XmlImport.updateTagDelimiterField();
        Omeka.XmlImport.updateFileDelimiterField();
    };

})(jQuery);
