<?php
    echo head(array('title' => 'Xml Import', 'bodyclass' => 'primary', 'content_class' => 'horizontal-nav'));
?>
<div id="primary">
    <?php echo flash(); ?>
    <h2><?php echo __('Step 1: Select File or Folder and Item Settings'); ?></h2>
    <p><?php echo __('Currently, Xml Import converts your files into a CSV file, that is automatically imported via CsvImport.'); ?></p>
    <?php echo $this->form; ?>
    <script type="text/javascript">
        var radio_file = document.xmlimport.xml_import_file_import;
        var radio_type = document.xmlimport.xml_import_format;

        onload = function() {
            document.getElementById("fieldset-singlefile").style.display = "block";
            document.getElementById("fieldset-multiplefiles").style.display = "none";
            document.getElementById("fieldset-format").style.display = "block";
            document.getElementById("fieldset-formatno").style.display = "none";
        };

        radio_file[0].onclick = function() {
            document.getElementById("fieldset-singlefile").style.display = "block";
            document.getElementById("fieldset-multiplefiles").style.display = "none";
        };
        radio_file[1].onclick = function() {
            document.getElementById("fieldset-singlefile").style.display = "none";
            document.getElementById("fieldset-multiplefiles").style.display = "block";
        };
        radio_file[2].onclick = function() {
            document.getElementById("fieldset-singlefile").style.display = "none";
            document.getElementById("fieldset-multiplefiles").style.display = "block";
        };

        radio_type[0].onclick = function() {
            document.getElementById("fieldset-format").style.display = "none";
            document.getElementById("fieldset-formatno").style.display = "block";
        };
        radio_type[1].onclick = function() {
            document.getElementById("fieldset-format").style.display = "block";
            document.getElementById("fieldset-formatno").style.display = "none";
        };
        radio_type[2].onclick = function() {
            document.getElementById("fieldset-format").style.display = "block";
            document.getElementById("fieldset-formatno").style.display = "none";
        };
    </script>
</div>
<?php
    echo foot();
?>
