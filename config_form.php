<p>
    <?php if ($fullCsvImport) {
        echo __('You are using full Csv Import, so all import formats will be available.');
    }
    else {
        echo __('You are using standard Csv Import, so you will be able to import metadata of items only, not metadata of files.');
    } ?>
</p>

<div class="field">
    <label for="xml_import_xsl_directory">
        <?php echo __('Directory path of xsl files'); ?>
    </label>
    <?php echo get_view()->formText('xml_import_xsl_directory', get_option('xml_import_xsl_directory'), array('size' => 50)); ?>
    <p class="explanation">
        <?php echo __('Directory path of xsl files used to convert xml files to Omeka format.');
        echo ' ' . __('Default directory is "%s".', dirname(__FILE__) . DIRECTORY_SEPARATOR . 'libraries'); ?>
    </p>
</div>
