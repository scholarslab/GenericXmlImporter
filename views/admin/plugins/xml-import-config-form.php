<p>
    <?php if ($full_csv_import):
        echo  __('You are using full Csv Import, so all import formats will be available.');
    else:
        echo __('You are using standard Csv Import, so you will be able to import metadata of items only, not metadata of files.');
    endif; ?>
</p>
<div class="field">
    <div class="two columns alpha">
        <?php echo $this->formLabel('xml_import_xsl_directory', __('Directory path of xsl files')); ?>
    </div>
    <div class="inputs five columns omega">
        <?php echo $this->formText('xml_import_xsl_directory', get_option('xml_import_xsl_directory'), null); ?>
        <p class="explanation">
            <?php echo __('Directory path of xsl files used to convert xml files to Omeka format.');
            echo ' ' . __('Default directory is "%s".', dirname(dirname(dirname(dirname(__FILE__)))) . DIRECTORY_SEPARATOR . 'libraries'); ?>
        </p>
    </div>
</div>
<div class="field">
    <div class="two columns alpha">
        <?php echo $this->formLabel('xml_import_xslt_processor', __('Path to the xslt processor')); ?>
    </div>
    <div class="inputs five columns omega">
        <?php echo get_view()->formText('xml_import_xslt_processor', get_option('xml_import_xslt_processor'), null); ?>
        <p class="explanation">
            <?php echo __('Path to the SaxonB xslt processor, quicker than the php one. Usually, this is "/usr/bin/saxonb-xslt". Let empty to use the php internal xslt processor.'); ?>
        </p>
    </div>
</div>
