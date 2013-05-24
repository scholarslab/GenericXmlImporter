<?php
/**
 * The form on xml-import/index/index.
 *
 * @package XmlImport
 */
class XmlImport_Form_Main extends Omeka_Form
{
    private $_fileDestinationDir;
    private $_maxFileSize;
    private $_requiredExtensions = 'xml';
    // TODO There is a warning when this is enabled.
    // private $_requiredMimeTypes = 'application/xml,text/xml';

    private $_fullCsvImport = FALSE;

    /**
     * Initialize the form.
     */
    public function init()
    {
        parent::init();

        // Check to add full import options or not.
        $this->_fullCsvImport = (substr(get_plugin_ini('CsvImport', 'version'), -5) == '-full');

        $this->setName('xmlimport')
            ->setAttrib('id', 'xmlimport')
            ->setMethod('post');

        // Radio button for selecting record type.
        $this->addElement('radio', 'xml_import_file_import', array(
            'label' => __('How many files do you want to import?'),
            'multiOptions' => array(
                'file' => __('One xml file'),
                'folder' => __('All xml files in a folder'),
                'recursive' => __('All xml files in a folder (recursive)'),
            ),
            'description' => __('The xsl sheet will create one csv file from this or these xml files and send it to CsvImport.'),
            'required' => true,
            'value' => 'file',
        ));

        // One xml file upload.
        $this->_addFileElement();
        $this->addDisplayGroup(array('xml_import_file'), 'singlefile');

        // Multiple files.
        $xmlFolderElement = new Zend_Form_Element_Text('xml_import_folder');
        $xmlFolderElement
            ->setAttrib('size', '60')
            ->setDescription(__('The server should be able to access to this url or uri.'));
        $this->addElement($xmlFolderElement);
        $this->addDisplayGroup(array('xml_import_folder'), 'multiplefiles');

        // Radio button for selecting record type.
        if ($this->_fullCsvImport) {
            $values = array(
                'Csv Report' => __('Export from Omeka CSV Report'),
                'Item' => __('Item metadata'),
                'File' => __('File metadata'),
            );
            $description = '';
        }
        else {
            $values = array(
                'Csv Report' => __('Export from Omeka CSV Report'),
                'Item' => __('Item metadata'),
            );
            $description = __('Metadata of files cannot be imported, because you are using standard Csv Import.');
        }
        $this->addElement('radio', 'xml_import_format', array(
            'label'=> __('Choose the type of record you want to import (according to the xsl sheet below):'),
            'description'=> $description,
            'multiOptions' => $values,
            'value' => get_option('xml_import_format'),
            'required' => TRUE,
        ));

        // Get item types and load into array.
        $values = get_db()->getTable('ItemType')->findPairsForSelectForm();
        $values = array('' => __('Select item type')) + $values;
        $itemTypeElement = new Zend_Form_Element_Select('xml_import_item_type');
        $itemTypeElement
            ->setLabel(__('Select item type'))
            ->addMultiOptions($values);
        $this->addElement($itemTypeElement);

        // Get collections table and load into array.
        $values = get_db()->getTable('Collection')->findPairsForSelectForm();
        $values = array('' => __('Select collection')) + $values;
        $collectionElement = new Zend_Form_Element_Select('xml_import_collection_id');
        $collectionElement
            ->setLabel(__('Select collection'))
            ->addMultiOptions($values);
        $this->addElement($collectionElement);

        // Items are public?
        $itemsArePublic = new Zend_Form_Element_Checkbox('xml_import_items_are_public');
        $itemsArePublic
            ->setLabel(__('Make all items public?'));
        $this->addElement($itemsArePublic);

        // Items are featured?
        $itemsAreFeatured = new Zend_Form_Element_Checkbox('xml_import_items_are_featured');
        $itemsAreFeatured
            ->setLabel(__('Feature all items?'));
        $this->addElement($itemsAreFeatured);

        // Used to hide some elements when format is set to 'Csv Report'.
        $this->addDisplayGroup(array(
            'xml_import_item_type',
            'xml_import_collection_id',
            'xml_import_items_are_public',
            'xml_import_items_are_featured',
        ), 'format');

        // Elements are html (for automatic import only)?
        $elementsAreHtml = new Zend_Form_Element_Checkbox('xml_import_elements_are_html');
        $elementsAreHtml
            ->setLabel(__('All imported elements are html?'))
            ->setDescription(__('When elements are imported automatically, this checkbox allows to set their default format, raw text or html.'));
        $this->addElement($elementsAreHtml);
        $this->addDisplayGroup(array('xml_import_elements_are_html'), 'formatno');

        // XSLT Stylesheet.
        $stylesheets = $this->_listDirectory(get_option('xml_import_xsl_directory'), 'xsl');
        // Don't return an error if the folder is unavailable, but simply set
        // an empty list.
        if ($stylesheets === false) {
            $stylesheets = array();
        }
        $stylesheet = new Zend_Form_Element_Select('xml_import_stylesheet');
        $stylesheet
            ->setLabel(__('Xsl sheet'))
            ->setDescription(__('The generic xsl sheet is "xml_import_generic_item.xsl". It transforms a flat xml file with multiple records into a csv file with multiple rows to import via "Item" format.'))
            ->setRequired(TRUE)
            ->addMultiOptions($stylesheets)
            ->setValue(get_option('xml_import_stylesheet'));
        $this->addElement($stylesheet);

        // XSLT parameters.
        $stylesheetParametersElement = new Zend_Form_Element_Text('xml_import_stylesheet_parameters');
        $stylesheetParametersElement
            ->setLabel(__('Add specific parameters to use with this xsl sheet'))
            ->setDescription(__('Format: parameter1_name|parameter1_value, parameter2_name|parameter2_value...'))
            ->setValue(get_option('xml_import_stylesheet_parameters'))
            ->setAttrib('size', '60');
        $this->addElement($stylesheetParametersElement);

        $this->applyOmekaStyles();
        $this->setAutoApplyOmekaStyles(false);

        // Submit button.
        $submit = $this->createElement('submit', 'submit', array(
            'label' => __('Upload'),
            'class' => 'submit submit-medium',
        ));
        $submit->setDecorators(array('ViewHelper',
            array('HtmlTag',
                array('tag' => 'div'),
        )));
        $this->addElement($submit);
    }

    /**
     * Add the file element to the form.
     */
    protected function _addFileElement()
    {
        $size = $this->getMaxFileSize();
        $byteSize = clone $this->getMaxFileSize();
        $byteSize->setType(Zend_Measure_Binary::BYTE);

        $fileValidators = array(
            new Zend_Validate_File_Size(array('max' => $byteSize->getValue())),
            new Zend_Validate_File_Count(0, 1),
        );
        if ($this->_requiredExtensions) {
            $fileValidators[] =
                new Omeka_Validate_File_Extension($this->_requiredExtensions);
        }
        if ($this->_requiredMimeTypes) {
            $fileValidators[] =
                new Omeka_Validate_File_MimeType($this->_requiredMimeTypes);
        }

        // Random filename in the temporary directory to prevent race condition.
        $filter = new Zend_Filter_File_Rename($this->_fileDestinationDir
            . '/' . md5(mt_rand() + microtime(true)));
        $this->addElement('file', 'xml_import_file', array(
            'validators' => $fileValidators,
            'destination' => $this->_fileDestinationDir,
            'description' => __("Maximum file size is %s.", $size->toString())
        ));
        // TODO Reenable filter and manage name in controller.
        // $this->xml_import_file->addFilter($filter);
    }

    /**
     * Validate the form post
     */
    public function isValid($post)
    {
        // Too much POST data, return with an error.
        if (empty($post) && (int)$_SERVER['CONTENT_LENGTH'] > 0) {
            $maxSize = $this->getMaxFileSize()->toString();
            $this->xml_import_file->addError(
                __('The file you have uploaded exceeds the maximum post size '
                . 'allowed by the server. Please upload a file smaller '
                . 'than %s.', $maxSize));
            return false;
        }

        return parent::isValid($post);
    }

    /**
     * Set the file destination for the form.
     *
     * @param string $dest The file destination
     */
    public function setFileDestination($dest)
    {
        $this->_fileDestinationDir = $dest;
    }

    /**
     * Set the maximum size for an uploaded CSV file.
     *
     * If this is not set in the plugin configuration, defaults to the smaller
     * of 'upload_max_filesize' and 'post_max_size' settings in php.
     *
     * If this is set but it exceeds the aforementioned php setting, the size
     * will be reduced to that lower setting.
     *
     * @param string|null $size The maximum file size
     */
    public function setMaxFileSize($size = null)
    {
        $postMaxSize = $this->_getBinarySize(ini_get('post_max_size'));
        $fileMaxSize = $this->_getBinarySize(ini_get('upload_max_filesize'));

        // Start with the max size as the lower of the two php ini settings.
        $strictMaxSize = $postMaxSize->compare($fileMaxSize) > 0
                        ? $fileMaxSize
                        : $postMaxSize;

        // If the plugin max file size setting is lower, choose it as the strict
        // max size.
        $pluginMaxSizeRaw = trim(get_option(CsvImportPlugin::MEMORY_LIMIT_OPTION_NAME));
        if ($pluginMaxSizeRaw != '') {
            if ($pluginMaxSize = $this->_getBinarySize($pluginMaxSizeRaw)) {
                $strictMaxSize = $strictMaxSize->compare($pluginMaxSize) > 0
                                ? $pluginMaxSize
                                : $strictMaxSize;
            }
        }

        if ($size === null) {
            $maxSize = $this->_maxFileSize;
        } else {
            $maxSize = $this->_getBinarySize($size);
        }

        if ($maxSize === false ||
            $maxSize === null ||
            $maxSize->compare($strictMaxSize) > 0) {
            $maxSize = $strictMaxSize;
        }

        $this->_maxFileSize = $maxSize;
    }

    /**
     * Return the max file size.
     *
     * @return string The max file size
     */
    public function getMaxFileSize()
    {
        if (!$this->_maxFileSize) {
            $this->setMaxFileSize();
        }
        return $this->_maxFileSize;
    }

    /**
     * Return the binary size measure.
     *
     * @return Zend_Measure_Binary The binary size
     */
    protected function _getBinarySize($size)
    {
        if (!preg_match('/(\d+)([KMG]?)/i', $size, $matches)) {
            return false;
        }

        $sizeType = Zend_Measure_Binary::BYTE;

        $sizeTypes = array(
            'K' => Zend_Measure_Binary::KILOBYTE,
            'M' => Zend_Measure_Binary::MEGABYTE,
            'G' => Zend_Measure_Binary::GIGABYTE,
        );

        if (count($matches) == 3 && array_key_exists($matches[2], $sizeTypes)) {
            $sizeType = $sizeTypes[$matches[2]];
        }

        return new Zend_Measure_Binary($matches[1], $sizeType);
    }

    /**
     * Iterates through a directory to get all files matching to an extension.
     *
     * @param $directory string Directory to check.
     * @param $extensions string|array Extension or array of extensions.
     *
     * @return associative array of filepath => filename or false if error.
     */
    private function _listDirectory($directory, $extensions = array())
    {
        return $this->_listRecursiveDirectory($directory, $extensions, false);
    }

    /**
     * Iterates recursively through a directory to get all selected filepaths.
     *
     * @param $directory string Directory to check.
     * @param $extensions string|array Extension or array of extensions.
     *
     * @return associative array of filepath => filename or false if error.
     */
    private function _listRecursiveDirectory($directory, $extensions = array(), $recursive = true)
    {
        if (is_string($extensions)) {
            $extensions = array($extensions);
        }

        $files = @scandir($directory);
        if ($files === false) {
            return false;
        }

        $filenames = array();

        foreach ($files as $file) {
            if ($file != '.' && $file != '..') {
                $path = $directory . DIRECTORY_SEPARATOR . $file;
                if (is_dir($path)) {
                    if ($recursive == true) {
                        $subdirectory = $this->_listRecursiveDirectory($path, $extensions);
                        if ($subdirectory !== false) {
                            $filenames = array_merge($filenames, $subdirectory);
                        }
                    }
                }
                else {
                    foreach ($extensions as $extension) {
                        if (preg_match('/^.+\.' . $extension . '$/i', $file)) {
                            $filenames[$path] = $file;
                            break;
                        }
                    }
                }
            }
        }
        ksort($filenames);
        return $filenames;
    }
}
