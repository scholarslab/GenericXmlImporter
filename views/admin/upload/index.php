<?php
    head(array('title' => 'XML Import', 'bodyclass' => 'primary', 'content_class' => 'horizontal-nav'));
?>
<h1>XML Import</h1>

<div id="primary">
    <h2>Step 1A: Select File or Folder and Item Settings</h2>
    <p>Select either one XML file <strong>or</strong> a folder with multiple XML files to upload. The stylesheet will create one csv file from this or these XML files.</p>
    <?php echo $form; ?>
</div>

<?php
    foot();
?>
