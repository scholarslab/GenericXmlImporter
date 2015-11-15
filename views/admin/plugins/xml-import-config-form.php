<?php echo flash(); ?>
<fieldset id="fieldset-xml-import"><legend></legend>
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
            <?php echo $this->formText('xml_import_xslt_processor', get_option('xml_import_xslt_processor'), null); ?>
            <p class="explanation">
                <?php echo __('Command of the processor.'); ?>
                <?php echo __('Let empty to use the internal xslt processor of php, if installed.'); ?>
                <?php echo __('This is required by some formats that need to parse a xslt 2 stylesheet.'); ?>
                <?php echo __('See format of the command and examples in the readme.'); ?>
                <?php echo __('Note that the use of an external xslt processor is recommended if the php one returns empty results with the sample xml files.'); ?>
            </p>
        </div>
    </div>
</fieldset>
