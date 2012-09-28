<?php
/**
 * @version $Id$
 * @copyright Daniel Berthereau for École des Ponts ParisTech, 2012
 * @copyright Scholars' Lab, 2010 [GenericXmlImporter v.1.0]
 * @license http://www.apache.org/licenses/LICENSE-2.0.html
 * @package XmlImport
 * @author Daniel Berthereau
 * @author Ethan Gruber: ewg4x at virginia dot edu
 */

/**
 * Allows to import one or multiple XML files via generic or custom XSLT sheet.
 *
 * Process ends with CsvImport, so all imports can be managed in one place.
 *
 * @see README.md
 */

/**
 * Contains code used to integrate the plugin into Omeka.
 *
 * @package XmlImport
 */
class XmlImportPlugin extends Omeka_Plugin_Abstract
    {
    protected $_hooks = array(
        'install',
        'uninstall',
        'define_acl',
        'admin_theme_header',
    );

    protected $_filters = array(
        'admin_navigation_main',
    );

    protected $_options = array(
        'xml_import_path_main' => '',
        'xml_import_path_images' => '',
        'xml_import_path_subfolder' => '',
        'xml_import_stylesheet' => 'xml-import-generic.xsl',
        'xml_import_delimiter' => ',',
        'xml_import_stylesheet_parameters' => '',
    );

    /**
     * Installs the plugin.
     */
    public function hookInstall()
    {
        // Default stylesheet.
        $this->_options['xml_import_stylesheet'] = dirname(__FILE__) . DIRECTORY_SEPARATOR . 'libraries' . DIRECTORY_SEPARATOR . 'xml-import-generic.xsl';

        // Checks the ability to use XSLT.
        try {
            $xslt = new XSLTProcessor;
        } catch (Exception $e) {
            throw new Zend_Exception('This plugin requires XSLT support.');
        }

        self::_installOptions();
    }

    /**
     * Uninstalls the plugin.
     */
    public function hookUninstall()
    {
        self::_uninstallOptions();
    }

    /**
     * Defines the plugin's access control list.
     *
     * @param object $acl
     */
    public function hookDefineAcl($acl)
    {
        $acl->loadResourceList(array('XmlImport_Upload' => array('index', 'status')));
    }

    public function hookAdminThemeHeader($request)
    {
        if ($request->getModuleName() == 'xml-import') {
            queue_css('xml_import_main');
            queue_js('xml_import_main');
        }
    }

    /**
     * Adds a tab to the admin navigation.
     *
     * @param array $tabs
     * @return array
     */
    public static function filterAdminNavigationMain($tabs)
    {
        if (get_acl()->isAllowed(current_user(), 'XmlImport_Upload', 'upload')) {
            $tabs['XML Import'] = uri('xml-import/upload/');
        }
        return $tabs;
    }
}

/** Installation of the plugin. */
$xmlImportPlugin = new XmlImportPlugin();
$xmlImportPlugin->setUp();
