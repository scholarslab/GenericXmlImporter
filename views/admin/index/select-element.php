<?php
    echo head(array('title' => __('Xml Import')));
?>
<div id="primary">
    <?php echo flash(); ?>
    <h2><?php echo __('Step 1 bis: Select record element'); ?></h2>
    <p><?php echo __('Use the drop down menu below to select the element name that represents the individual Omeka Item.'); ?></p>
    <?php echo $this->form; ?>
</div>
<?php
    echo foot();
