<?php
    echo head(array('title' => __('Xml Import')));
?>
<div id="primary">
    <?php echo flash(); ?>
    <?php if (!empty($err)) {
        echo '<p class="error">' . html_escape($err) . '</p>';
    } ?>
    <p><a href="<?php echo url('xml-import'); ?>"><?php echo __('Return to form'); ?></a>.</p>
</div>
<?php
    echo foot();
