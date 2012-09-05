<?php
    head(array('title' => 'Generic XML Import', 'bodyclass' => 'primary', 'content_class' => 'horizontal-nav'));
?>
<h1>Generic XML Import</h1>

<div id="primary">
    <h2>Step 1B: Select Record Element</h2>
    <p>Use the drop down menu below to select the element name the represents the individual Omeka Item.</p>
    <?php echo $form; ?>
</div>

<?php
    foot();
?>
