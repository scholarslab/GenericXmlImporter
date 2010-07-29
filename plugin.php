<?php

/**
 * Generic XML import plugin
 *
 * @copyright  Scholars' Lab 2010
 * @license    http://www.apache.org/licenses/LICENSE-2.0.html
 * @version    $Id:$
 * @package GenericXmlImporter
 * @author Ethan Gruber: ewg4x at virginia dot edu
 **/

define('GENXML_IMPORT_DIRECTORY', dirname(__FILE__));
define('GENXML_IMPORT_TMP_LOCATION', GENXML_IMPORT_DIRECTORY . DIRECTORY_SEPARATOR . 'xmldump');
define('GENXML_IMPORT_DOC_EXTRACTOR', GENXML_IMPORT_DIRECTORY . DIRECTORY_SEPARATOR . 'libraries' . DIRECTORY_SEPARATOR . 'genxml-import-documents.xsl');
add_plugin_hook('install', 'genxml_import_install');
add_plugin_hook('uninstall', 'genxml_import_uninstall');
add_plugin_hook('define_acl', 'genxml_import_define_acl');
add_plugin_hook('admin_theme_header', 'genxml_import_admin_header');
add_filter('admin_navigation_main', 'genxml_import_admin_navigation');
add_plugin_hook('config_form', 'genxml_import_config_form');
add_plugin_hook('config', 'genxml_import_config');

function genxml_import_install()
{
	try {
		$xh = new XSLTProcessor; // we check for the ability to use XSLT
	} catch (Exception $e) {
		throw new Zend_Exception("This plugin requires XSLT support");
	}
}

/**
 * Uninstall the plugin.
 * 
 * @return void
 */
function genxml_import_uninstall()
{
    // delete the plugin options
    delete_option('genxml_import_memory_limit'); 
}


/**
 * Add the admin navigation for the plugin.
 * 
 * @return array
 */
function genxml_import_admin_navigation($tabs)
{
    if (get_acl()->checkUserPermission('GenericXmlImporter_Upload', 'upload')) {
        $tabs['GenXML Import'] = uri('generic-xml-importer/upload/');        
    }
    return $tabs;
}

function genxml_import_define_acl($acl)
{
    $acl->loadResourceList(array('GenericXmlImporter_Upload' => array('index', 'status')));
}

function genxml_import_admin_header($request)
{
	if ($request->getModuleName() == 'generic-xml-importer') {
		echo '<link rel="stylesheet" href="' . html_escape(css('generic_xml_importer_main')) . '" />';
		//echo js('generic_xml_import_main');
    }
}

function genxml_import_config_form()
{  
    if (!$memoryLimit = get_option('genxml_import_memory_limit')) {
        $memoryLimit = ini_get('memory_limit');
    }
?>
    <div class="field">
        <label for="genxml_import_memory_limit">Memory Limit</label>
        <?php echo __v()->formText('genxml_import_memory_limit', $memoryLimit, null);?>
        <p class="explanation">Set a high memory limit to avoid memory allocation
        issues during harvesting. Examples include 128M, 1G, and -1. The available
        options are K (for Kilobytes), M (for Megabytes) and G (for Gigabytes).
        Anything else assumes bytes. Set to -1 for an infinite limit. Be advised
        that many web hosts set a maximum memory limit, so this setting may be
        ignored if it exceeds the maximum allowable limit. Check with your web host
        for more information.</p>
    </div>
<?php
}

function genxml_import_config()
{
    set_option('genxml_import_memory_limit', $_POST['genxml_import_memory_limit']);
}