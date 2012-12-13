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
        'config_form',
        'config',
        'define_acl',
        'admin_theme_header',
    );

    protected $_filters = array(
        'admin_navigation_main',
    );

    protected $_options = array(
        'xml_import_xsl_directory' => 'libraries',
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
        $this->_options['xml_import_xsl_directory'] = dirname(__FILE__) . DIRECTORY_SEPARATOR . 'libraries';
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
        $options = $this->_options;
        if (!is_array($options)) {
            return;
        }
        foreach ($options as $name => $value) {
            delete_option($name);
        }
    }

    /**
     * Shows plugin configuration page.
     */
    public function hookConfigForm()
    {
        include_once 'config_form.php';
    }

    /**
     * Processes the configuration form.
     */
    public function hookConfig($post)
    {
        set_option('xml_import_xsl_directory', realpath($post['xml_import_xsl_directory']));
    }

    /**
     * Defines the plugin's access control list.
     *
     * @param object $acl
     */
    public function hookDefineAcl($acl)
    {
        // Only allow super users and admins to import xml files.
        $acl->loadResourceList(array(
            'XmlImport_Index' => array(
                'index',
                'select-element',
                'send',
            ),
        ));
        // Hack to disable CRUD actions.
        $acl->deny(null, 'XmlImport_Index', array('show', 'add', 'edit', 'delete'));
        $acl->deny('admin', 'XmlImport_Index');
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
        if (get_acl()->isAllowed(current_user(), 'XmlImport_Index', 'index')) {
            $tabs['XML Import'] = uri('xml-import');
        }
        return $tabs;
    }
}

/** Installation of the plugin. */
$xmlImportPlugin = new XmlImportPlugin();
$xmlImportPlugin->setUp();
