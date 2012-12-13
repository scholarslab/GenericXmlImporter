<?php
    head(array('title' => 'XML Import', 'bodyclass' => 'primary', 'content_class' => 'horizontal-nav'));
?>
<h1>XML Import</h1>

<div id="primary">
    <h2>Step 1A: Select File or Folder and Item Settings</h2>
    <?php echo $form; ?>
    <script type="text/javascript">
        var radio_file = document.xmlimport.xml_import_file_import;
        var radio_type = document.xmlimport.xml_import_record_type;
    
        onload = function() {
            document.getElementById("fieldset-singlefile").style.display = "block";
            document.getElementById("fieldset-multiplefiles").style.display = "none";
            document.getElementById("fieldset-recordtype").style.display = "none";
            document.getElementById("fieldset-recordtypeno").style.display = "block";
        };
        
        radio_file[0].onclick = function() {
            document.getElementById("fieldset-singlefile").style.display = "block";
            document.getElementById("fieldset-multiplefiles").style.display = "none";
        };
        radio_file[1].onclick = function() {
            document.getElementById("fieldset-singlefile").style.display = "none";
            document.getElementById("fieldset-multiplefiles").style.display = "block";
        };
        
        radio_type[0].onclick = function() {
            document.getElementById("fieldset-recordtype").style.display = "none";
            document.getElementById("fieldset-recordtypeno").style.display = "block";
        };
        radio_type[1].onclick = function() {
            document.getElementById("fieldset-recordtype").style.display = "block";
            document.getElementById("fieldset-recordtypeno").style.display = "none";
        };
        radio_type[2].onclick = function() {
            document.getElementById("fieldset-recordtype").style.display = "block";
            document.getElementById("fieldset-recordtypeno").style.display = "none";
        };
    </script>
</div>

<?php
    foot();
?>
