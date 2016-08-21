<?php
/**
 * The form on xml-import/index/index.
 *
 * @package XmlImport
 */
class XmlImport_Form_Main extends Omeka_Form
{
    private $_columnDelimiter;
    private $_enclosure;
    private $_elementDelimiter;
    private $_tagDelimiter;
    private $_fileDelimiter;
    private $_fileDestinationDir;
    private $_maxFileSize;

    private $_requiredExtensions = 'xml';
    // TODO There is a warning when this is enabled.
    // private $_requiredMimeTypes = 'application/xml,text/xml';

    /**
     * Initialize the form.
     */
    public function init()
    {
        parent::init();

        $this->_columnDelimiter = CsvImportPlus_RowIterator::getDefaultColumnDelimiter();
        $this->_enclosure = CsvImportPlus_RowIterator::getDefaultEnclosure();
        $this->_elementDelimiter = CsvImportPlus_ColumnMap_Element::getDefaultElementDelimiter();
        $this->_tagDelimiter = CsvImportPlus_ColumnMap_Tag::getDefaultTagDelimiter();
        $this->_fileDelimiter = CsvImportPlus_ColumnMap_File::getDefaultFileDelimiter();

        $allowLocalPaths = Zend_Registry::get('csv_import_plus')->local_folders->allow == '1';

        $this->setName('xmlimport');
        $this->setAttrib('id', 'xmlimport');
        $this->setMethod('post');

        // Radio button for selecting record type.
        $this->addElement('radio', 'file_import', array(
            'label' => __('How many files do you want to import?'),
            'multiOptions' => array(
                'file' => __('One xml file'),
                'folder' => __('All xml files in a folder'),
                'recursive' => __('All xml files in a folder (recursive)'),
            ),
            'description' => __('The xsl sheet will create one csv file from this or these xml files and send it to CsvImportPlus.'),
            'required' => true,
            'value' => 'file',
        ));

        // One xml file upload.
        $this->_addFileElement();

        // Multiple files.
        $this->addElement('text', 'xml_folder', array(
            'description' => __('The server should be able to access to this uri.')
                . ($allowLocalPaths ? '' : ' ' . __('Local paths are forbidden by the administrator.')),
            'required' => false,
            'filters' => array(
                'StringTrim',
            ),
            'validators' => array(
                array(
                    'Callback',
                    true,
                    array(
                        'callback' => array('XmlImport_Form_Validator', 'validateUri'),
                    ),
                    'messages' => array(
                        Zend_Validate_Callback::INVALID_VALUE => __('A url or a path is required to import xml files.'),
                    ),
                ),
            ),
        ));
        // Helper to manage multiple files.
        $this->addElement('text', 'format_filename', array(
            'description' => __('The format of the filenames to search (format: "suffix.extension", for example "refnum.xml"; default: ".xml").')
                . ' ' . __('This is useful especially when folders contains multiple formats of xml files.'),
            'value' => get_option('xml_import_format_filename'),
        ));

        $this->_addColumnDelimiterElement();
        $this->_addEnclosureElement();
        $this->_addElementDelimiterElement();
        $this->_addTagDelimiterElement();
        $this->_addFileDelimiterElement();

        $values = get_table_options('ItemType', __('No default item type'));
        $this->addElement('select', 'item_type_id', array(
            'label' => __('Item type'),
            'multiOptions' => $values,
        ));

        $values = get_table_options('Collection', __('No default collection'));
        $this->addElement('select', 'collection_id', array(
            'label' => __('Collection'),
            'multiOptions' => $values,
        ));

        $this->addElement('checkbox', 'records_are_public', array(
            'label' => __('Make records public'),
            'description' => __('Check to make records (items or collections) public by default.'),
        ));

        $this->addElement('checkbox', 'records_are_featured', array(
            'label' => __('Feature records'),
            'description' => __('Check to make records (items or collections) featured by default.'),
        ));

        $this->addElement('checkbox', 'elements_are_html', array(
            'label' => __('Elements are html'),
            'description' => __('Set default format of all imported elements as html, else raw text.'),
            'value' => get_option('csv_import_plus_html_elements'),
        ));

        $identifierField = get_option('csv_import_plus_identifier_field');
        if (!empty($identifierField) && $identifierField != 'table id' && $identifierField != 'internal id') {
            $currentIdentifierField = $this->_getElementFromIdentifierField($identifierField);
            if ($currentIdentifierField) {
                $identifierField = $currentIdentifierField->id;
            }
        }
        $values = get_table_options('Element', null, array(
            'record_types' => array('All'),
            'sort' => 'alphaBySet',
        ));
        $values = array(
            '' => __('No default identifier field'),
            'table id' => __('Table identifier'),
            'internal id' => __('Internal id'),
            // 'filename' => __('Imported filename (to import files only)'),
            // 'original filename' => __('Original filename (to import files only)'),
        ) + $values;
        $this->addElement('select', 'identifier_field', array(
            'label' => __('Identifier field (required)'),
            'description' => __('The default identifier should be available for all record types that are currently imported in the file.'),
            'multiOptions' => $values,
            'value' => $identifierField,
        ));

        $this->addElement('select', 'action', array(
            'label' => __('Action'),
            'multiOptions' => label_table_options(array(
                CsvImportPlus_ColumnMap_Action::ACTION_UPDATE_ELSE_CREATE
                    => __('Update the record if it exists, else create one'),
                CsvImportPlus_ColumnMap_Action::ACTION_CREATE
                    => __('Create a new record'),
                CsvImportPlus_ColumnMap_Action::ACTION_UPDATE
                    => __('Update values of specific fields'),
                CsvImportPlus_ColumnMap_Action::ACTION_ADD
                    => __('Add values to specific fields'),
                CsvImportPlus_ColumnMap_Action::ACTION_REPLACE
                    => __('Replace values of all fields'),
                CsvImportPlus_ColumnMap_Action::ACTION_DELETE
                    => __('Delete the record'),
                CsvImportPlus_ColumnMap_Action::ACTION_SKIP
                    => __('Skip process of the record'),
            ), __('No default action')),
        ));

       $this->addElement('select', 'contains_extra_data', array(
            'label' => __('Contains extra data'),
            'description' => __('Other columns can be used as values for non standard data.'),
            'multiOptions' =>array(
                'no' => __('No, so unrecognized column names will be noticed'),
                'manual' => __('Perhaps, so the mapping should be done manually'),
                'ignore' => __('Ignore unrecognized column names'),
                'yes' => __("Yes, so column names won't be checked"),
            ),
            'value' => get_option('csv_import_plus_extra_data'),
        ));

        // XSLT Stylesheet.
        $values = $this->_listDirectory(get_option('xml_import_xsl_directory'), 'xsl');
        // Don't return an error if the folder is unavailable, but simply set an
        // empty list.
        if ($values === false) {
            $values = array();
        }
        // Remove the main directory (it will be added later).
        $stylesheets = array();
        foreach ($values as $key => $value) {
            $stylesheets[substr($key, 1 + strlen(get_option('xml_import_xsl_directory')))] = $value;
        }
        $values = $stylesheets;
        $this->addElement('select', 'stylesheet', array(
            'label' => __('Xsl sheet'),
            'description' => __('The generic xsl sheet is "xml_import_generic_item.xsl". It transforms a flat xml file with multiple records into a csv file with multiple rows.'),
            'multiOptions' => $values,
            'required' => true,
            'value' => get_option('xml_import_stylesheet'),
        ));

        $this->addElement('checkbox', 'stylesheet_intermediate', array(
            'label' => __('Intermediate stylesheet'),
            'description' => __('Check if this stylesheet is an intermediate one that converts the xml into the format used for simple documents, that are automatically imported via the stylesheet "advanced".'),
            'value' => get_option('xml_import_stylesheet_intermediate'),
        ));

        $this->addElement('textarea', 'stylesheet_parameters', array(
            'label' => __('Add specific parameters to use with this xsl sheet'),
            'description' => __('Some parameters can be set in the xsl sheets for specific purposes.')
                . ' ' . __('You can specify them here, one by line.'),
            'value' => get_option('xml_import_stylesheet_parameters'),
            'required' => false,
            'rows' => 5,
            'placeholder' => __('parameter_1_name = parameter 1 value'),
            'filters' => array(
                'StringTrim',
            ),
            'validators' => array(
                array(
                    'callback',
                    false,
                    array(
                        'callback' => array('XmlImport_Form_Validator', 'validateExtraParameters'),
                    ),
                    'messages' => array(
                        Zend_Validate_Callback::INVALID_VALUE => __('Each extra parameter, one by line, should have a name separated from the value with a "=".'),
                    ),
                ),
            ),
        ));

        $this->addDisplayGroup(
            array(
                'file_import',
                'xml_file',
                'xml_folder',
                'format_filename',
            ),
            'file_type'
        );

        $this->addDisplayGroup(
            array(
                'column_delimiter_name',
                'column_delimiter',
                'enclosure_name',
                'enclosure',
                'element_delimiter_name',
                'element_delimiter',
                'tag_delimiter_name',
                'tag_delimiter',
                'file_delimiter_name',
                'file_delimiter',
            ),
            'csv_format',
            array(
                'legend' => __('CSV format'),
                'description' => __('Set delimiters and enclosure used in the file.'),
        ));

        $this->addDisplayGroup(
            array(
                'item_type_id',
                'collection_id',
                'records_are_public',
                'records_are_featured',
                'elements_are_html',
            ),
            'default_values',
            array(
                'legend' => __('Default values'),
                'description' => __("Set the default values to use when the column doesn't exist."),
        ));

        $this->addDisplayGroup(
            array(
                'identifier_field',
                'action',
                'contains_extra_data',
            ),
            'import_process',
            array(
                'legend' => __('Process'),
                'description' => __('Set features used to process the file.'),
        ));

        $this->addDisplayGroup(
            array(
                'stylesheet',
                'stylesheet_intermediate',
                'stylesheet_parameters',
            ),
            'xsl_params',
            array(
                'legend' => __('XSL transformation'),
                'description' => __('Set xslt sheet and optional parameters used to process the file.'),
        ));

        // Submit button.
        $submit = $this->createElement('submit', 'submit', array(
            'label' => __('Upload'),
            'class' => 'submit submit-medium',
        ));
        $submit->setDecorators(
            array('ViewHelper',
                array('HtmlTag',
                    array('tag' => 'div',
                        'class' => 'xmlimportupload',
        ))));
        $this->addElement($submit);

        $this->applyOmekaStyles();
        $this->setAutoApplyOmekaStyles(false);
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
            new Zend_Validate_File_Count(array('min' => 0, 'max' => 1)),
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
        $this->addElement('file', 'xml_file', array(
            'validators' => $fileValidators,
            'destination' => $this->_fileDestinationDir,
            'description' => __("Maximum file size is %s.", $size->toString())
        ));
        // TODO Reenable filter and manage name in controller.
        // $this->xml_import_file->addFilter($filter);
    }

    /**
     * Return the human readable word for a delimiter if any, or the delimiter.
     *
     * @param string $delimiter The delimiter
     * @return string The human readable word for the delimiter if any, or the
     * delimiter itself.
     */
    protected function _getHumanDelimiterText($delimiter)
    {
        $delimitersList = XmlImport_IndexController::getDelimitersList();

        return in_array($delimiter, $delimitersList)
            ? array_search($delimiter, $delimitersList)
            : $delimiter;
    }

    /**
     * Return the list of standard delimiters for drop-down menu.
     *
     * @return array The list of standard delimiters
     */
    protected function _getDelimitersMenu()
    {
        $delimitersListKeys = array_keys(XmlImport_IndexController::getDelimitersList());
        $values = array_combine($delimitersListKeys, $delimitersListKeys);
        $values['custom'] = 'custom';
        return $values;
    }

    /**
     * Add the column delimiter element to the form.
     */
    protected function _addColumnDelimiterElement()
    {
        $delimiter = $this->_columnDelimiter;
        $humanDelimiterText = $this->_getHumanDelimiterText($delimiter);

        $delimitersList = XmlImport_IndexController::getDelimitersList();
        $delimiterCurrent = in_array($delimiter, $delimitersList)
            ? array_search($delimiter, $delimitersList)
            : 'custom';

        // Two elements are needed to select the delimiter.
        // First, a list for special characters (one character).
        $values = $this->_getDelimitersMenu();
        unset($values['double space']);
        unset($values['empty']);
        $this->addElement('select', 'column_delimiter_name', array(
            'label' => __('Column delimiter'),
            'description'=> __('A single character that will be used to separate columns in the file (the previously used "%s" by default).', $humanDelimiterText),
            'multiOptions' => $values,
            'value' => $delimiterCurrent,
        ));

        // Second, a field to let user chooses a custom delimiter.
        // TODO Autoset according to previous element or display the element only if the column delimiter is "custom".
        $this->addElement('text', 'column_delimiter', array(
            'value' => $delimiter,
            'required' => false,
            'size' => '1',
            'validators' => array(
                // A second check is done in method isValid() with minimum of 1.
                array('validator' => 'StringLength', 'options' => array(
                    'min' => 0,
                    'max' => 1,
                    'messages' => array(
                        Zend_Validate_StringLength::TOO_LONG =>
                            __('Column delimiter must be one character long.'),
                    ),
                )),
            ),
        ));
    }

    /**
     * Add the enclosure element to the form
     */
    protected function _addEnclosureElement()
    {
        $enclosure = $this->_enclosure;
        $enclosuresList = XmlImport_IndexController::getEnclosuresList();
        $enclosureCurrent = in_array($enclosure, $enclosuresList)
            ? array_search($enclosure, $enclosuresList)
            : $enclosure;

        $this->addElement('select', 'enclosure_name', array(
            'label' => __('Enclosure'),
            'description' => __('A zero or single character that will be used to separate columns '
                . 'clearly. It allows to use the column delimiter as a character in a field. By default, '
                . 'the quotation mark « " » is used. Enclosure can be omitted in the csv file.'),
            'multiOptions' => array(
                'double-quote' => __('" (double quote)'),
                'quote' => __(" ' (single quote)"),
                'empty' => __('(empty)'),
                'custom' => __('Custom'),
            ),
            'value' => $enclosureCurrent,
        ));
        $this->addElement('text', 'enclosure', array(
            'value' => $enclosure,
            'required' => false,
            'size' => '1',
            'validators' => array(
                array('validator' => 'StringLength', 'options' => array(
                    'min' => 0,
                    'max' => 1,
                    'messages' => array(
                        Zend_Validate_StringLength::TOO_LONG =>
                            __('Enclosure must be zero or one character long.'),
                    ),
                )),
            ),
        ));
    }

    /**
     * Add the element delimiter element to the form.
     */
    protected function _addElementDelimiterElement()
    {
        $delimiter = $this->_elementDelimiter;
        $humanDelimiterText = $this->_getHumanDelimiterText($delimiter);

        $delimitersList = XmlImport_IndexController::getDelimitersList();
        $delimiterCurrent = in_array($delimiter, $delimitersList)
            ? array_search($delimiter, $delimitersList)
            : 'custom';

        // Two elements are needed to select the delimiter.
        // First, a list for special characters.
        $values = $this->_getDelimitersMenu();
        $this->addElement('select', 'element_delimiter_name', array(
            'label' => __('Element delimiter'),
            'description' => __('This delimiter will be used to separate metadata elements within a cell (the previously used "%s" by default).', $humanDelimiterText) . '<br />'
                . __('If the delimiter is empty, then the whole text will be used.') . '<br />'
                . ' ' . __('To use more than one character is allowed.'),
            'multiOptions' => $values,
            'value' => $delimiterCurrent,
            'required' => false,
        ));
        // Second, a field to let user chooses a custom delimiter.
        // TODO Autoset according to previous element or display and check the element only if the file delimiter is "custom".
        $this->addElement('text', 'element_delimiter', array(
            'value' => $delimiter,
            'required' => false,
            'size' => '40',
        ));
    }

    /**
     * Add the tag delimiter element to the form.
     */
    protected function _addTagDelimiterElement()
    {
        $delimiter = $this->_tagDelimiter;
        $humanDelimiterText = $this->_getHumanDelimiterText($delimiter);

        $delimitersList = XmlImport_IndexController::getDelimitersList();
        $delimiterCurrent = in_array($delimiter, $delimitersList)
            ? array_search($delimiter, $delimitersList)
            : 'custom';

        // Two elements are needed to select the delimiter.
        // First, a list for special characters.
        $values = $this->_getDelimitersMenu();
        $this->addElement('select', 'tag_delimiter_name', array(
            'label' => __('Tag delimiter'),
            'description' => __('This delimiter will be used to separate tags within a cell (the previously used "%s" by default).', $humanDelimiterText) . '<br />'
                . __('If the delimiter is empty, then the whole text will be used.') . '<br />'
                . ' ' . __('To use more than one character is allowed.'),
            'multiOptions' => $values,
            'value' => $delimiterCurrent,
            'required' => false,
        ));
        // Second, a field to let user chooses a custom delimiter.
        // TODO Autoset according to previous element or display and check the element only if the tag delimiter is "custom".
        $this->addElement('text', 'tag_delimiter', array(
            'value' => $delimiter,
            'required' => false,
            'size' => '40',
        ));
    }

    /**
     * Add the file delimiter element to the form.
     */
    protected function _addFileDelimiterElement()
    {
        $delimiter = $this->_fileDelimiter;
        $humanDelimiterText = $this->_getHumanDelimiterText($delimiter);

        $delimitersList = XmlImport_IndexController::getDelimitersList();
        $delimiterCurrent = in_array($delimiter, $delimitersList)
            ? array_search($delimiter, $delimitersList)
            : 'custom';

        // Two elements are needed to select the delimiter.
        // First, a list for special characters.
        $values = $this->_getDelimitersMenu();
        $this->addElement('select', 'file_delimiter_name', array(
            'label' => __('File delimiter'),
            'description' => __('This delimiter will be used to separate file paths or URLs within a cell (the previously used "%s" by default).', $humanDelimiterText) . '<br />'
                . __('If the delimiter is empty, then the whole text will be used as the file path or URL.') . '<br />'
                . ' ' . __('To use more than one character is allowed.'),
            'multiOptions' => $values,
            'value' => $delimiterCurrent,
            'required' => false,
        ));
        // Second, a field to let user chooses a custom delimiter.
        // TODO Autoset according to previous element or display and check the element only if the file delimiter is "custom".
        $this->addElement('text', 'file_delimiter', array(
            'value' => $delimiter,
            'required' => false,
            'size' => '40',
        ));
    }

    /**
     * Validate the form post.
     */
    public function isValid($post)
    {
        $isValid = true;
        // Too much POST data, return with an error.
        if (empty($post) && (int)$_SERVER['CONTENT_LENGTH'] > 0) {
            $maxSize = $this->getMaxFileSize()->toString();
            $this->xml_import_file->addError(
                __('The file you have uploaded exceeds the maximum post size '
                . 'allowed by the server. Please upload a file smaller '
                . 'than %s.', $maxSize));
            return false;
        }

        // Check custom delimiters.
        if ($post['column_delimiter_name'] == 'custom') {
            if (strlen($post['column_delimiter']) != 1) {
                $this->column_delimiter->addError(
                    __('The custom delimiter you choose cannot be whitespace and must be one character long.'));
                $isValid = false;
            }
        }

        if (!$isValid) {
            return false;
        }

        return parent::isValid($post);
    }

    /**
     * Set the column delimiter for the form.
     *
     * @param string $delimiter The column delimiter
     */
    public function setColumnDelimiter($delimiter)
    {
        $this->_columnDelimiter = $delimiter;
    }

    /**
     * Set the enclosure for the form.
     *
     * @param string $enclosure The enclosure
     */
    public function setEnclosure($enclosure)
    {
        $this->_enclosure = $enclosure;
    }

    /**
     * Set the element delimiter for the form.
     *
     * @param string $delimiter The element delimiter
     */
    public function setElementDelimiter($delimiter)
    {
        $this->_elementDelimiter = $delimiter;
    }

    /**
     * Set the tag delimiter for the form.
     *
     * @param string $delimiter The tag delimiter
     */
    public function setTagDelimiter($delimiter)
    {
        $this->_tagDelimiter = $delimiter;
    }

    /**
     * Set the file delimiter for the form.
     *
     * @param string $delimiter The file delimiter
     */
    public function setFileDelimiter($delimiter)
    {
        $this->_fileDelimiter = $delimiter;
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
        $pluginMaxSizeRaw = trim(get_option(CsvImportPlusPlugin::MEMORY_LIMIT_OPTION_NAME));
        if ($pluginMaxSizeRaw != '') {
            $pluginMaxSize = $this->_getBinarySize($pluginMaxSizeRaw);
            if ($pluginMaxSize) {
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

        if ($maxSize === false
                || $maxSize === null
                || $maxSize->compare($strictMaxSize) > 0
            ) {
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

    /**
     * Return the element from an identifier.
     *
     * @return Element|boolean
     */
    private function _getElementFromIdentifierField($identifierField)
    {
        if (strlen($identifierField) > 0) {
            $parts = explode(
                    CsvImportPlus_ColumnMap_MixElement::DEFAULT_COLUMN_NAME_DELIMITER,
                    $identifierField);
            if (count($parts) == 2) {
                $elementSetName = trim($parts[0]);
                $elementName = trim($parts[1]);
                $element = get_db()->getTable('Element')
                    ->findByElementSetNameAndElementName($elementSetName, $elementName);
                if ($element) {
                    return $element;
                }
            }
        }
    }
}
