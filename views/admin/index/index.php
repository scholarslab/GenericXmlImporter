<?php
    echo head(array('title' => 'Xml Import', 'bodyclass' => 'primary', 'content_class' => 'horizontal-nav'));
?>
<div id="primary">
    <?php echo flash(); ?>
    <h2><?php echo __('Step 1: Select file or folder and metadata settings'); ?></h2>
    <p><?php echo __('Currently, Xml Import converts your files into a csv file that is automatically imported via CSV Import.'); ?></p>
    <?php echo $this->form; ?>
</div>
<script type="text/javascript">
//<![CDATA[
jQuery(document).ready(function () {
    jQuery('#file_import-file').click(Omeka.XmlImport.updateFileOptions);
    jQuery('#file_import-folder').click(Omeka.XmlImport.updateFileOptions);
    jQuery('#file_import-recursive').click(Omeka.XmlImport.updateFileOptions);
    jQuery('#format-Report').click(Omeka.XmlImport.updateImportOptions);
    jQuery('#format-Item').click(Omeka.XmlImport.updateImportOptions);
    jQuery('#format-File').click(Omeka.XmlImport.updateImportOptions);
    jQuery('#format-Mix').click(Omeka.XmlImport.updateImportOptions);
    Omeka.XmlImport.updateOnLoad(); // Need this to reset invalid forms.
});
//]]>
</script>
<?php
    echo foot();
?>
