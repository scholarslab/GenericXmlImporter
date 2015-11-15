<?php
/**
 * Xml Import
 *
 * Allows to import one or multiple XML files via generic or custom XSLT sheet.
 * Process ends with CsvImport, so all imports can be managed in one place.
 *
 * @copyright Daniel Berthereau, 2012-2013
 * @copyright Scholars' Lab, 2010 [GenericXmlImporter v.1.0]
 * @license http://www.apache.org/licenses/LICENSE-2.0.html
 */

/**
 * The Xml Import plugin.
 * @package Omeka\Plugins\XmlImport
 */
class XmlImportPlugin extends Omeka_Plugin_AbstractPlugin
{
    /**
     * @var array Hooks for the plugin.
     */
    protected $_hooks = array(
        'install',
        'upgrade',
        'uninstall',
        'config_form',
        'config',
        'define_acl',
        'admin_head',
    );

    /**
     * @var array Filters for the plugin.
     */
    protected $_filters = array(
        'admin_navigation_main',
    );

    /**
     * @var array Options and their default values.
     */
    protected $_options = array(
        'xml_import_xsl_directory' => 'libraries',
        'xml_import_xslt_processor' => '',
        'xml_import_format' => 'Item',
        'xml_import_stylesheet' => 'generic_item.xsl',
        'xml_import_stylesheet_parameters' => '',
        'xml_import_format_filename' => '.xml',
    );

    /**
     * Installs the plugin.
     */
    public function hookInstall()
    {
        // Default stylesheet.
        $this->_options['xml_import_xsl_directory'] = dirname(__FILE__) . DIRECTORY_SEPARATOR . 'libraries';
        $this->_options['xml_import_stylesheet'] = XmlImportPlugin::isFullCsvImport() ? 'generic_mixed.xsl' :  'generic_item.xsl';

        // Checks the ability to use XSLT.
        try {
            $xslt = new XSLTProcessor;
        } catch (Exception $e) {
            throw new Zend_Exception(__('This plugin requires XSLT support.'));
        }

        $this->_installOptions();
    }

    /**
     * Upgrades the plugin.
     */
    public function hookUpgrade($args)
    {
        $oldVersion = $args['old_version'];
        $newVersion = $args['new_version'];

        if (version_compare($oldVersion, '2.8', '<')) {
            delete_option('xml_import_delimiter');
            set_option('xml_import_format', $this->_options['xml_import_format']);
        }

        if (version_compare($oldVersion, '2.13', '<')) {
            set_option('xml_import_stylesheet', substr(get_option('xml_import_stylesheet'), 1 + strlen(get_option('xml_import_xsl_directory'))));
        }
    }

    /**
     * Uninstalls the plugin.
     */
    public function hookUninstall()
    {
        $this->_uninstallOptions();
    }

    /**
     * Shows plugin configuration page.
     */
    public function hookConfigForm($args)
    {
        $view = get_view();
        echo $view->partial(
            'plugins/xml-import-config-form.php',
            array(
                'full_csv_import' => $this->isFullCsvImport(),
            )
        );
    }

    /**
     * Processes the configuration form.
     *
     * @return void
     */
    public function hookConfig($args)
    {
        $post = $args['post'];
        foreach ($this->_options as $optionKey => $optionValue) {
            if ($optionKey == 'xml_import_xsl_directory') {
                $post[$optionKey] = empty($post[$optionKey])
                    ? dirname(__FILE__) . DIRECTORY_SEPARATOR . 'libraries'
                    : realpath($post[$optionKey]);
            }
            if (isset($post[$optionKey])) {
                set_option($optionKey, $post[$optionKey]);
            }
        }
    }

    /**
     * Defines the plugin's access control list.
     *
     * @param object $args
     */
    public function hookDefineAcl($args)
    {
        $acl = $args['acl'];
        $resource = 'XmlImport_Index';

        // TODO This is currently needed for tests for an undetermined reason.
        if (!$acl->has($resource)) {
            $acl->addResource($resource);
        }
        // Hack to disable CRUD actions.
        $acl->deny(null, $resource, array('show', 'add', 'edit', 'delete'));
        $acl->deny(null, $resource);

        $roles = $acl->getRoles();

        // Check that all the roles exist, in case a plugin-added role has
        // been removed (e.g. GuestUser).
        $allowRoles = unserialize(get_option('csv_import_allow_roles')) ?: array();
        $allowRoles = array_intersect($roles, $allowRoles);

        if ($allowRoles) {
            $acl->allow($allowRoles, $resource);
        }

        $denyRoles = array_diff($roles, $allowRoles);
        if ($denyRoles) {
            $acl->deny($denyRoles, $resource);
        }
    }

   /**
    * Configures admin theme header.
    *
    * @param array $args
    */
    public function hookAdminHead($args)
    {
        $request = Zend_Controller_Front::getInstance()->getRequest();
        if ($request->getModuleName() == 'xml-import') {
            queue_css_file('xml-import');
            queue_js_file('xml-import');
        }
    }

    /**
     * Adds the plugin link to the admin main navigation.
     *
     * @param array Navigation array.
     * @return array Filtered navigation array.
     */
    public function filterAdminNavigationMain($nav)
    {
        $nav[] = array(
            'label' => __('Xml Import'),
            'uri' => url('xml-import'),
            'resource' => 'XmlImport_Index',
            'privilege' => 'index',
        );
        return $nav;
    }

    /**
     * Determine if the CsvImport Full is installed.
     *
     * Some import options are unailable if CsvImport Full is not installed.
     *
     * @return boolean
     */
    static public function isFullCsvImport()
    {
        return (substr(get_plugin_ini('CsvImport', 'version'), -5) == '-full');
    }
}
