<p>
    <?php if ($this->full_csv_import):
        echo  __('You are using full Csv Import, so all import formats will be available.');
    else:
        echo __('You are using standard Csv Import, so you will be able to import metadata of items only, not metadata of files.');
    endif; ?>
</p>
<div class="field">
    <div id="xml_import_xsl_directory_label" class="two columns alpha">
        <label for="xml_import_xsl_directory">
            <?php echo __('Directory path of xsl files'); ?>
        </label>
    </div>
    <div class="inputs five columns omega">
        <?php echo get_view()->formText('xml_import_xsl_directory', get_option('xml_import_xsl_directory'), array('size' => 50)); ?>
        <p class="explanation">
            <?php echo __('Directory path of xsl files used to convert xml files to Omeka format.');
            echo ' ' . __('Default directory is "%s".', dirname(__FILE__) . DIRECTORY_SEPARATOR . 'libraries'); ?>
        </p>
    </div>
</div>
