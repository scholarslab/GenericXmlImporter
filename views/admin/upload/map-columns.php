<?php 
    head(array('title' => 'Generic XML Import', 'bodyclass' => 'primary', 'content_class' => 'horizontal-nav'));
?>
<h1>Generic XML Import</h1>

<div id="primary">
    <h2>Step 2: Map Columns To Elements, Tags, or Files</h2>
    <?php echo flash(); ?>
    
    <form id="csvimport" method="post" action="">
        <?php echo csv_import_get_column_mappings($csvImportFile, $csvImportItemTypeId); ?>
        <fieldset>
            <?php echo submit(array('name'=>'csv_import_submit', 'class'=>'submit submit-medium'), 'Import XML File'); ?>
        </fieldset>
    </form>
</div>
<?php 
    foot(); 
?>