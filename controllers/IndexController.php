<?php
/**
 * The plugin controller for index pages.
 *
 * Technical notes
 * How this works:
 * 1. Select XML file to upload and import options
 * 2. Form accepts and parses XML file, processes it and sends user to next step
 * with a drop down menu with elements that appear to be the document record
 * 3. User selects document record. Variables passed to CsvImport session, user
 * redirected to CsvImport column mapping
 *
 * @copyright Daniel Berthereau, 2012-2013
 * @copyright Scholars' Lab, 2010 [GenericXmlImporter v.1.0]
 * @license http://www.apache.org/licenses/LICENSE-2.0.html
 * @package XmlImport
 */
class XmlImport_IndexController extends Omeka_Controller_AbstractActionController
{
    protected $_pluginConfig = array();

    /**
     * Displays main form (step 1).
     */
    public function indexAction()
    {
        $form = $this->_getMainForm();
        $this->view->form = $form;

        if (!$this->getRequest()->isPost()) {
            return;
        }

        if (!$form->isValid($this->getRequest()->getPost())) {
            $this->_helper->flashMessenger(__('Invalid form input. Please see errors below and try again.'), 'error');
            return;
        }

        $uploadedData = $form->getValues();
        $uploadedData['xml_folder'] = trim($uploadedData['xml_folder']);
        $fileList = array();

        switch ($uploadedData['file_import']) {
            case 'file':
                // If one file is selected, fill the file list with it.
                if ($uploadedData['xml_file'] != '') {
                    if (!$form->xml_file->receive()) {
                        $this->_helper->flashMessenger(__('Error uploading file. Please try again.'), 'error');
                        return;
                    }
                    $csvFilename = pathinfo($form->xml_file->getFileName(), PATHINFO_BASENAME);
                    // Create a file list with one value.
                    $fileList = array($form->xml_file->getFileName() => $csvFilename);
                }
                else {
                    $this->_helper->flashMessenger(__('Error receiving file or no file selected. Verify that it is an XML document.'), 'error');
                    return;
                }
                break;
            case 'folder':
            case 'recursive':
                // Else prepare full files list from the folder.
                if ($uploadedData['xml_folder'] != '') {
                    if ($uploadedData['file_import'] == 'folder') {
                        $fileList = $this->_listRecursiveDirectory($uploadedData['xml_folder'], 'xml', FALSE);
                        $csvFilename = 'folder "' . $uploadedData['xml_folder'] . '"';
                    }
                    else {
                        $fileList = $this->_listRecursiveDirectory($uploadedData['xml_folder'], 'xml', TRUE);
                        $csvFilename = 'recursive folder "' . $uploadedData['xml_folder'] . '"';
                    }
                    // TODO Upload each file? Currently, they are checked only
                    // with DirectoryIterator.
                }
                else {
                    $this->_helper->flashMessenger(__('Error receiving file or no file selected. Verify that it is an XML document.'), 'error');
                    return;
                }
                break;
            default:
                $this->_helper->flashMessenger(__('Error: you need to choose if you import an xml file or a list of xml files in a folder.'), 'error');
                return;
        }

        if ($fileList === false) {
            $this->_helper->flashMessenger(__('Error accessing directory "%s". Verify that you have rights to access this folder and subfolders.', $uploadedData['xml_folder']), 'error');
            return;
        }
        elseif (empty($fileList)) {
            $this->_helper->flashMessenger(__('Error receiving file or no file selected. Verify that file is an XML document or that the selected directory is not empty.'), 'error');
            return;
        }

        // Check content of each file via a simplexml parsing and hook.
        foreach ($fileList as $filepath => $filename) {
            try {
                $xml_doc = $this->_domXmlLoad($filepath);
            } catch (Exception $e) {
                $this->_helper->flashMessenger($e->getMessage(), 'error');
                return;
            }

            // Check if the xml is well formed.
            if (simplexml_import_dom($xml_doc)) {
                // TODO Check result of the hook.
                // $result = fire_plugin_hook('xml_import_validate_xml_file', $xml_doc);
                if (!isset($xml_doc)) {
                    $this->_helper->flashMessenger(__('Error validating XML document: "%s".', $filepath), 'error');
                    return;
                }
            }
            else {
                $this->_helper->flashMessenger(__('Error parsing XML document: "%s".', $filepath), 'error');
                return;
            }
        }

        // Alright, go to next step.
        try {
            $xmlImportSession = new Zend_Session_Namespace('XmlImport');
            $xmlImportSession->file_list = $fileList;
            $xmlImportSession->csv_filename = $csvFilename;
            $xmlImportSession->format = $uploadedData['format'];
            $xmlImportSession->item_type_id = $uploadedData['item_type_id'];
            $xmlImportSession->collection_id = $uploadedData['collection_id'];
            $xmlImportSession->public = $uploadedData['items_are_public'];
            $xmlImportSession->featured = $uploadedData['items_are_featured'];
            $xmlImportSession->html_elements = $uploadedData['elements_are_html'];
            $xmlImportSession->enclosure = $uploadedData['enclosure'];
            $xmlImportSession->stylesheet = $uploadedData['stylesheet'];
            $xmlImportSession->stylesheet_parameters = $uploadedData['stylesheet_parameters'];

            $delimitersList = self::getDelimitersList();
            $columnDelimiterName = $uploadedData['column_delimiter_name'];
            $xmlImportSession->column_delimiter = isset($delimitersList[$columnDelimiterName])
                ? $delimitersList[$columnDelimiterName]
                : $uploadedData['column_delimiter'];
            $elementDelimiterName = $uploadedData['element_delimiter_name'];
            $xmlImportSession->element_delimiter = isset($delimitersList[$elementDelimiterName])
                ? $delimitersList[$elementDelimiterName]
                : $uploadedData['element_delimiter'];
            $tagDelimiterName = $uploadedData['tag_delimiter_name'];
            $xmlImportSession->tag_delimiter = isset($delimitersList[$tagDelimiterName])
                ? $delimitersList[$tagDelimiterName]
                : $uploadedData['tag_delimiter'];
            $fileDelimiterName = $uploadedData['file_delimiter_name'];
            $xmlImportSession->file_delimiter = isset($delimitersList[$fileDelimiterName])
                ? $delimitersList[$fileDelimiterName]
                : $uploadedData['file_delimiter'];

            $this->_helper->redirector->goto('select-element');
        } catch (Exception $e) {
            $this->view->error = $e->getMessage();
        }
    }

    /**
     * Displays second form to choose element (step 1 bis, used only for the
     * generic sheet when there are more than one base record in the xml).
     */
    public function selectElementAction()
    {
        $xmlImportSession = new Zend_Session_Namespace('XmlImport');
        $view = $this->view;

        $form = $this->_elementForm($xmlImportSession);

        // When tag is not set, display the form to select one.
        if ($form->getValue('tag_name') === null) {
            $this->view->form = $form;
        }
        // Else go directly to next step.
        else {
            $uploadedData = $form->getValues();
            $this->_prepareCsvArguments($uploadedData);
        }
    }

    /**
     * Generates csv file (step 2).
     */
    public function sendAction()
    {
        $xmlImportSession = new Zend_Session_Namespace('XmlImport');

        // Check if user comes directly here.
        if (!isset($xmlImportSession->file_list)) {
            return;
        }

        $view = $this->view;
        $form = $this->_elementForm($xmlImportSession);
        if ($_POST) {
            if ($form->isValid($this->_request->getPost())) {
                $uploadedData = $form->getValues();
                $this->_prepareCsvArguments($uploadedData);
            }
            else {
                $this->_helper->flashMessenger(__('Error receiving file or no file selected. Verify that it is an XML document.'), 'error');
            }
        }
    }

    /**
     * Helper to prepare array used to generate csv file from a submited form.
     */
    private function _prepareCsvArguments($uploadedData)
    {
        $args = array();
        $args['file_list'] = unserialize($uploadedData['file_list']);
        $args['csv_filename'] = $uploadedData['csv_filename'];
        $args['format'] = $uploadedData['format'];
        $args['item_type_id'] = $uploadedData['item_type_id'];
        $args['collection_id'] = $uploadedData['collection_id'];
        $args['public'] = $uploadedData['items_are_public'];
        $args['featured'] = $uploadedData['items_are_featured'];
        $args['html_elements'] = $uploadedData['elements_are_html'];
        $args['tag_name'] = $uploadedData['tag_name'];
        $args['stylesheet'] = $uploadedData['stylesheet'];
        $args['stylesheet_parameters'] = $uploadedData['stylesheet_parameters'];
        $args['column_delimiter'] = $uploadedData['column_delimiter'];
        $args['enclosure'] = $uploadedData['enclosure'];
        $args['element_delimiter'] = $uploadedData['element_delimiter'];
        $args['tag_delimiter'] = $uploadedData['tag_delimiter'];
        $args['file_delimiter'] = $uploadedData['file_delimiter'];

        $this->_generateCsv($args);
    }

    /**
     * Helper to generate csv file.
     */
    private function _generateCsv($args)
    {
        // Get variables from args array passed into detached process.
        $fileList = $args['file_list'];
        $csvFilename = $args['csv_filename'];
        $format = $args['format'];
        $itemTypeId = $args['item_type_id'];
        $collectionId = $args['collection_id'];
        $itemsArePublic = $args['public'];
        $itemsAreFeatured = $args['featured'];
        $elementsAreHtml = $args['html_elements'];
        $tagName = $args['tag_name'];
        $stylesheet = $args['stylesheet'];
        $stylesheetParameters = $args['stylesheet_parameters'];
        $columnDelimiter = $args['column_delimiter'];
        $enclosure = $args['enclosure'];
        $elementDelimiter = $args['element_delimiter'];
        $tagDelimiter = $args['tag_delimiter'];
        $fileDelimiter = $args['file_delimiter'];

        // Delimiters for Csv Report are fixed.
        if ($format == 'Report') {
            $columnDelimiter = ',';
            $enclosure = '"';
            $elementDelimiter = CsvImport_ColumnMap_ExportedElement::DEFAULT_ELEMENT_DELIMITER;
            $tagDelimiter = ',';
            $fileDelimiter = ',';
        }
        $endOfLine = "\n";

        // No paramater for this option: fields are always automapped.
        $automapColumns = 1;

        $csvFilePath = sys_get_temp_dir() . '/' . 'omeka_xml_import_' . date('Ymd-His') . '_' . $this->_sanitizeString($csvFilename) . '.csv';
        $csvFilename = 'Via Xml Import: ' . $csvFilename;

        // Prepare parameters for the stylesheet.
        $parameters = array(
            'delimiter' => $columnDelimiter,
            'enclosure' => $enclosure,
            'delimiter_element' => $elementDelimiter,
            'delimiter_tag' => $tagDelimiter,
            'delimiter_file' => $fileDelimiter,
            'end_of_line' => $endOfLine,
            'node' => $tagName,
        );
        // Add custom parameters. Allowed types are already checked.
        $parametersAdded = (trim($stylesheetParameters) == '')
            ? array()
            : array_values(array_map('trim', explode(',', $stylesheetParameters)));
        foreach ($parametersAdded as $value) {
            if (strpos($value, '|') !== FALSE) {
                list($paramName, $paramValue) = explode('|', $value);
                if ($paramName != '') {
                    $parameters[$paramName] = $paramValue;
                }
            }
        }

        try {
            // Flag used to keep or remove headers in the first row.
            $flag_first = TRUE;
            // Convert each xml file to csv with the selected stylesheet and
            // parameters. A result can be empty for a file when there are no
            // metadata to import or if the xml file is not a good one.
            foreach ($fileList as $filepath => $filename) {
                // Let headers only for the first file.
                if ($flag_first) {
                    $flag_first = FALSE;
                }
                // Remove first line for all other files.
                else {
                    $parameters['headers'] = 'false';
                }

                $result = $this->_apply_xslt_and_save($filepath, $stylesheet, '', $parameters);
                if ($result === NULL) {
                    $this->_helper->flashMessenger(__('Error when transforming xml file "%s" with the xsl sheet "%s".', $filepath, $stylesheet), 'error');
                    $this->_helper->redirector->goto('index');
                }
                $output = $result;

                // @todo Use Zend/Omeka api.
                $result = $this->_append_file($csvFilePath, $output);
                if ($result === FALSE) {
                    $this->_helper->flashMessenger(__('Error saving data, because the filepath "%s" is not writable.', $filepath), 'error');
                    $this->_helper->redirector->goto('index');
                }
            }

            // Check final resulted file.
            if (filesize($csvFilePath) == 0) {
                $this->_helper->flashMessenger(__('The conversion of the xml file "%s" to csv via the xslt style sheet "%s" gives an empty file. Check your options and your files.', basename($filepath), basename($stylesheet)), 'error');
                $this->_helper->redirector->goto('index');
            }

            // Get the view.
            $view = $this->view;

            // Set up CsvImport validation and column mapping if needed.
            $file = new CsvImport_File($csvFilePath, $columnDelimiter, $enclosure);
            if (!$file->parse()) {
                $msg = __('Your CSV file is incorrectly formatted.')
                    . ' ' . $file->getErrorString();
                $this->_helper->flashMessenger($msg, 'error');
                $this->_helper->redirector->goto('index');
            }

            // Go directly to the correct view of CsvImport plugin.
            $csvImportSession = new Zend_Session_Namespace('CsvImport');

            // @see CsvImport_IndexController::indexAction().
            $csvImportSession->setExpirationHops(2);
            $csvImportSession->originalFilename = $csvFilename;
            $csvImportSession->filePath = $csvFilePath;
            // Option used with full Csv Import only.
            $csvImportSession->format = $format;
            $csvImportSession->itemTypeId = $itemTypeId;
            $csvImportSession->collectionId = $collectionId;
            $csvImportSession->itemsArePublic = $itemsArePublic;
            $csvImportSession->itemsAreFeatured = $itemsAreFeatured;
            // Option used with full Csv Import only.
            $csvImportSession->elementsAreHtml = $elementsAreHtml;
            // Option used with full Csv Import only.
            $csvImportSession->automapColumns = $automapColumns;
            // Option used with Csv Import standard only.
            $csvImportSession->automapColumnNamesToElements = $automapColumns;
            $csvImportSession->columnDelimiter = $columnDelimiter;
            $csvImportSession->columnNames = $file->getColumnNames();
            $csvImportSession->columnExamples = $file->getColumnExamples();
            // A bug appears in CsvImport when examples contain UTF-8 characters
            // like 'ГЧ„чŁ'.
            foreach ($csvImportSession->columnExamples as &$value) {
                $value = iconv('ISO-8859-15', 'UTF-8', @iconv('UTF-8', 'ISO-8859-15' . '//IGNORE', $value));
            }
            $csvImportSession->enclosure = $enclosure;
            $csvImportSession->elementDelimiter = $elementDelimiter;
            $csvImportSession->tagDelimiter = $tagDelimiter;
            $csvImportSession->fileDelimiter = $fileDelimiter;
            $csvImportSession->ownerId = $this->getInvokeArg('bootstrap')->currentuser->id;

            // All is valid, so we save settings.
            set_option('xml_import_format', $args['format']);
            set_option('csv_import_html_elements', $args['html_elements']);
            set_option('xml_import_stylesheet', $args['stylesheet']);
            set_option('xml_import_stylesheet_parameters', $args['stylesheet_parameters']);
            set_option(CsvImport_RowIterator::COLUMN_DELIMITER_OPTION_NAME, $args['column_delimiter']);
            set_option(CsvImport_RowIterator::ENCLOSURE_OPTION_NAME, $args['enclosure']);
            set_option(CsvImport_ColumnMap_Element::ELEMENT_DELIMITER_OPTION_NAME, $args['element_delimiter']);
            set_option(CsvImport_ColumnMap_Tag::TAG_DELIMITER_OPTION_NAME, $args['tag_delimiter']);
            set_option(CsvImport_ColumnMap_File::FILE_DELIMITER_OPTION_NAME, $args['file_delimiter']);

            switch ($format) {
                case 'Report':
                    $this->_helper->redirector->goto('check-omeka-csv', 'index', 'csv-import');
                case 'Mix':
                    $this->_helper->redirector->goto('check-mix-csv', 'index', 'csv-import');
                case 'Update':
                    $this->_helper->redirector->goto('check-update-csv', 'index', 'csv-import');
                default:
                    $this->_helper->redirector->goto('map-columns', 'index', 'csv-import');
            }
        } catch (Exception $e) {
            $msg = __('Error in your xml file, in your xsl sheet or in your options.')
                . ' ' . __('The xsl sheet should produce a valid csv file with a header and at least one row of metadata.')
                . ' ' . $e->getMessage();
            $this->_helper->flashMessenger($msg, 'error');
            $this->view->error = $msg;
            $this->_helper->redirector->goto('index');
        }
    }

    /**
     * Helper to prepare main form for step 1.
     */
    protected function _getMainForm()
    {
        require_once dirname(__FILE__) . DIRECTORY_SEPARATOR . '..' . DIRECTORY_SEPARATOR . 'forms' . DIRECTORY_SEPARATOR . 'Main.php';
        $csvConfig = $this->_getPluginConfig();
        $form = new XmlImport_Form_Main($csvConfig);
        return $form;
    }

    /**
      * Returns the plugin configuration
      *
      * @return array
      */
    protected function _getPluginConfig()
    {
        if (!$this->_pluginConfig) {
            $config = $this->getInvokeArg('bootstrap')->config->plugins;
            if ($config && isset($config->CsvImport)) {
                $this->_pluginConfig = $config->CsvImport->toArray();
            }
            if (!array_key_exists('fileDestination', $this->_pluginConfig)) {
                $this->_pluginConfig['fileDestination'] =
                    Zend_Registry::get('storage')->getTempDir();
            }
        }
        return $this->_pluginConfig;
    }

    /**
     * Helper to prepare form for step 2.
     *
     * Contains a drop down menu created for tag; other options are hidden
     * inputs.
     */
    private function _elementForm($xmlImportSession)
    {
        $fileList = $xmlImportSession->file_list;
        $csvFilename = $xmlImportSession->csv_filename;
        $format = $xmlImportSession->format;
        $itemTypeId = $xmlImportSession->item_type_id;
        $collectionId = $xmlImportSession->collection_id;
        $public = $xmlImportSession->public;
        $featured = $xmlImportSession->featured;
        $htmlElements = $xmlImportSession->html_elements;
        $stylesheet = $xmlImportSession->stylesheet;
        $stylesheetParameters = $xmlImportSession->stylesheet_parameters;
        $columnDelimiter = $xmlImportSession->column_delimiter;
        $enclosure = $xmlImportSession->enclosure;
        $elementDelimiter = $xmlImportSession->element_delimiter;
        $tagDelimiter = $xmlImportSession->tag_delimiter;
        $fileDelimiter = $xmlImportSession->file_delimiter;

        // Get first level nodes of first file in order to choose document name.
        // TODO Add the root element name, because some formats use it.
        reset($fileList);
        $filepath = key($fileList);
        try {
            $doc = $this->_domXmlLoad($filepath);
        } catch (Exception $e) {
            $this->_helper->flashMessenger($e->getMessage(), 'error');
            return;
        }

        foreach ($doc->childNodes as $primary) {
            $elementSet = $this->cycleNodes($primary, $elementList = array(), $number = 0);
        }

        require "Zend/Form/Element.php";

        $form = new Omeka_Form();
        $form->setAttrib('id', 'xmlimport')
            ->setAction('send')
            ->setMethod('post');

        // Check available record elements inside xml file. This is used only
        // with generic sheets. The tag will not be used in other cases.
        // Automatic import via Omeka CSV Report.
        if ($format == 'Report') {
            $tagNameElement = new Zend_Form_Element_Hidden('tag_name');
            $tagNameElement->setValue('item');
        }
        // Only one first level tag.
        elseif (count($elementSet) == 1) {
            reset($elementSet);
            $tagNameElement = new Zend_Form_Element_Hidden('tag_name');
            $tagNameElement->setValue(key($elementSet));
        }
        // Multiple possibilities but not a generic sheet, so take any tag,
        // because it won't be used.
        elseif (substr(basename($stylesheet), 0, 19) !== 'xml_import_generic_') {
            reset($elementSet);
            $tagNameElement = new Zend_Form_Element_Hidden('tag_name');
            $tagNameElement->setValue(key($elementSet));
        }
        // Multiple possibilities, so the generic xsl can't choose.
        else {
            $tagNameElement = new Zend_Form_Element_Select('tag_name');
            $tagNameElement
                ->setLabel('Tag Name')
                ->addMultiOptions($elementSet);
        }
        $form->addElement($tagNameElement);

        $fileListElement = new Zend_Form_Element_Hidden('file_list');
        $fileListElement->setValue(serialize($fileList));
        $form->addElement($fileListElement);

        $csvFilenameElement = new Zend_Form_Element_Hidden('csv_filename');
        $csvFilenameElement->setValue($csvFilename);
        $form->addElement($csvFilenameElement);

        $formatElement = new Zend_Form_Element_Hidden('format');
        $formatElement->setValue($format);
        $form->addElement($formatElement);

        $itemTypeElement = new Zend_Form_Element_Hidden('item_type_id');
        $itemTypeElement->setValue($itemTypeId);
        $form->addElement($itemTypeElement);

        $collectionIdElement = new Zend_Form_Element_Hidden('collection_id');
        $collectionIdElement->setValue($collectionId);
        $form->addElement($collectionIdElement);

        $publicElement = new Zend_Form_Element_Hidden('items_are_public');
        $publicElement->setValue($public);
        $form->addElement($publicElement);

        $featuredElement = new Zend_Form_Element_Hidden('items_are_featured');
        $featuredElement->setValue($featured);
        $form->addElement($featuredElement);

        $htmlElementsElement = new Zend_Form_Element_Hidden('elements_are_html');
        $htmlElementsElement->setValue($htmlElements);
        $form->addElement($htmlElementsElement);

        $stylesheetElement = new Zend_Form_Element_Hidden('stylesheet');
        $stylesheetElement->setValue($stylesheet);
        $form->addElement($stylesheetElement);

        $stylesheetParametersElement = new Zend_Form_Element_Hidden('stylesheet_parameters');
        $stylesheetParametersElement->setValue($stylesheetParameters);
        $form->addElement($stylesheetParametersElement);

        $columnDelimiterElement = new Zend_Form_Element_Hidden('column_delimiter');
        $columnDelimiterElement->setValue($columnDelimiter);
        $form->addElement($columnDelimiterElement);

        $enclosureElement = new Zend_Form_Element_Hidden('enclosure');
        $enclosureElement->setValue($enclosure);
        $form->addElement($enclosureElement);

        $elementDelimiterElement = new Zend_Form_Element_Hidden('element_delimiter');
        $elementDelimiterElement->setValue($elementDelimiter);
        $form->addElement($elementDelimiterElement);

        $tagDelimiterElement = new Zend_Form_Element_Hidden('tag_delimiter');
        $tagDelimiterElement->setValue($tagDelimiter);
        $form->addElement($tagDelimiterElement);

        $fileDelimiterElement = new Zend_Form_Element_Hidden('file_delimiter');
        $fileDelimiterElement->setValue($fileDelimiter);
        $form->addElement($fileDelimiterElement);

        // Submit button.
        $form->addElement('submit', 'submit');
        $submitElement = $form->getElement('submit');
        $submitElement->setLabel(__('Next'));

        return $form;
    }

    /**
     * Iterate recursively through XML file, extracting out element names that
     * seem to meet requirements for Omeka item record.
     */
    public function cycleNodes($primary, $elementList, $number)
    {
        if ($primary->hasChildNodes()) {
            foreach ($primary->childNodes as $secondary) {
                if ($secondary->hasChildNodes() == FALSE) {
                    $next = $this->cycleNodes($secondary, $elementList, $number);
                }
                else{
                    if ($secondary->nodeName != '#text'
                            && $secondary->nodeName != '#comment'
                            && $secondary->nodeName != (isset($elementList[$number - 1]) ? $elementList[$number - 1] : '')
                        ) {
                        $elementList[$secondary->nodeName] = $secondary->nodeName;
                        $number++;
                    }
                }
            }
        }
        return $elementList;
    }

    /**
     * Iterates recursively through a directory to get all selected filepaths.
     *
     * @param string $directory Directory to check.
     * @param string $extension Extension.
     * @param boolean $recursive Recursive or not in subfolder.
     *
     * @return associative array of filepath => filename or false if error.
     */
    private function _listRecursiveDirectory($directory, $extension = '', $recursive = true)
    {
        $filenames = array();

        // Prepare extension.
        if (!empty($extension) && substr($extension, 0, 1) != '.') {
            $extension = '.' . $extension;
        }

        // Get directories and files via http or via file system.
        // Get via http/https.
        if (parse_url($directory, PHP_URL_SCHEME) == 'http' || parse_url($directory, PHP_URL_SCHEME) == 'https') {
            $result = $this->_scandirOverHttp($directory, $extension);
            if (empty($result)) {
                return $filenames;
            }
            $dirs = &$result['dirs'];
            $files = &$result['files'];
        }
        // Get via file system.
        else {
            $dirs = glob($directory . '/*', GLOB_ONLYDIR);
            $files = glob($directory . '/*' . $extension, GLOB_MARK);
            // Remove directories because glob() has no flag to get only files.
            foreach ($files as $key => $file) {
                if (substr($file, -1) == '/') {
                    unset($files[$key]);
                }
            }
        }

        // Recursive call to this function for subdirectories.
        if ($recursive == true) {
            foreach ($dirs as $dir) {
                $subdirectory = $this->_listRecursiveDirectory($dir, $extension);
                if ($subdirectory !== false) {
                    $filenames = array_merge($filenames, $subdirectory);
                }
            }
        }

        // Return filenames in a formatted array.
        foreach ($files as $file) {
            $filenames[$file] = basename($file);
        }

        ksort($filenames);
        return $filenames;
    }

    /**
     * Scan a directory available only via http (web pages).
     *
     * @param $directory string Directory to check.
     * @param string $extension Extension.
     *
     * @return associative array of directories and filepaths.
     */
    private function _scandirOverHttp($directory, $extension = '')
    {
        $page = file_get_contents($directory);

        if (empty($page)) {
            return false;
        }

        $dirs = array();
        $files = array();

        // Prepare extension.
        if (substr($extension, 0, 1) == '.') {
            $extension = substr($extension, 1);
        }

        // Add a slash to the url in order to append relative filenames easily.
        if (substr($directory, -1) != '/') {
            $directory .= '/';
        }

        // Get parent directory.
        $parent = dirname($directory) . '/';

        // Get the domain if needed.
        $domain = parse_url($directory);
        $user = ($domain['user'] . ':' . $domain['pass'] != ':') ? $domain['user'] . ':' . $domain['pass'] . '@' : '';
        $port = !empty($domain['port']) ? ':' . $domain['port'] : '';
        $domain = $domain['scheme'] . '://' . $user . $domain['host'] . $port;

        // List all links.
        $matches = array();
        preg_match_all("/(a href\=\")([^\?\"]*)(\")/i", $page, $matches);
        // Remove duplicates.
        $matches = array_combine($matches[2], $matches[2]);

        // Check list of urls.
        foreach ($matches as $match) {
            // Add base url to relative ones.
            $urlScheme = parse_url($match, PHP_URL_SCHEME);
            if ($urlScheme != 'http' && $urlScheme != 'https') {
                // Add only domain to absolute url without domain.
                if (substr($match, 0, 1) == '/') {
                    $match = $domain . $match;
                }
                else {
                    $match = $directory . $match;
                }
            }

            // Remove parent and current directory.
            if ($match == $parent
                    || $match == $directory
                    || ($match . '/') == $parent
                    || ($match . '/') == $directory
                ) {
                // Don't add it.
            }
            // Check if this a directory.
            elseif (substr($match, -1) == '/') {
                $dirs[] = $match;
            }
            elseif (empty($extension)) {
                $files[] = $match;
            }
            // Check the extension.
            elseif (preg_match('/^.+\.' . $extension . '$/i', $match)) {
                $files[] = $match;
            }
        }

        return array(
            'dirs' => $dirs,
            'files' => $files,
        );
    }

    /**
     * Apply a xslt stylesheet on a xml file.
     *
     * @param string $xml_file
     *   Path of xml file.
     * @param string $xsl_file
     *   Path of the xslt file.
     * @param string $output
     *   Path of the output file. If none, a temp file will be used.
     * @param array $parameters
     *   Parameters array.
     *
     * @return string|null
     *   Path to the output file if ok, null else.
     */
    private function _apply_xslt_and_save($xml_file, $xsl_file, $output = '', $parameters = array())
    {
        if (empty($output)) {
            $output = tempnam(sys_get_temp_dir(), 'xmlimport_');
        }

        switch (basename(get_option('xml_import_xslt_processor'))) {
            case 'saxonb-xslt':
                $command = array(
                    'saxonb-xslt',
                    '-ext:on',
                    '-versionmsg:off',
                    '-s:' . escapeshellarg($xml_file),
                    '-xsl:' . escapeshellarg($xsl_file),
                    '-o:' . escapeshellarg($output),
                );
                foreach ($parameters as $name => $parameter) {
                    $command[] = escapeshellarg($name . '=' . $parameter);
                }
                $command = implode(' ', $command);
                $result = (int)  shell_exec($command . ' 2>&- || echo 1');
                chmod(escapeshellarg($output), 0644);

                return ($result == 1) ? NULL : $output;

            default:
                try {
                    $DomXml = $this->_domXmlLoad($xml_file);
                    $DomXsl = $this->_domXmlLoad($xsl_file);
                } catch (Exception $e) {
                    throw new Exception($e->getMessage());
                }

                $proc = new XSLTProcessor;
                // Php functions are needed, because php doesn't use XSLT 2.0
                // and because we need to check existence of a file.
                if (get_plugin_ini('XmlImport', 'xml_import_allow_php_in_xsl') == 'TRUE') {
                    $proc->registerPHPFunctions();
                }
                $proc->importStyleSheet($DomXsl);
                $proc->setParameter('', $parameters);

                $result = $proc->transformToURI($DomXml, $output);
                chmod(escapeshellarg($output), 0644);

                return ($result === FALSE) ? NULL : $output;
        }
    }

    /**
     * Load a xml or xslt file into a Dom document via file system or http.
     *
     * @param string $filepath Path of xml file on file system or via http.
     *
     * @return DomDocument or throw error message.
     */
    private function _DomXmlLoad($filepath)
    {
        $domDocument = new DomDocument;

        // Default import via file system.
        if (parse_url($filepath, PHP_URL_SCHEME) != 'http' && parse_url($filepath, PHP_URL_SCHEME) != 'https') {
            $domDocument->load($filepath);
        }

        // If xml file is over http, need to get it locally to process xslt.
        else {
            $xmlContent = file_get_contents($filepath);
            if ($xmlContent === false) {
                $message = __('Enable to load "%s". Verify that you have rights to access this folder and subfolders.', $filepath);
                throw new Exception($message);
            }
            elseif (empty($xmlContent)) {
                $message = __('The file "%s" is empty. Process is aborted.', $filepath);
                throw new Exception($message);
            }
            $domDocument->loadXML($xmlContent);
        }

        return $domDocument;
    }

    /**
     * Append and save a string into a file.
     *
     * @param string $filepath
     * @param string $filepath_to_append
     *
     * @return string|boolean
     *   $filepath if no error, FALSE else.
     */
    private function _append_file($filepath, $filepath_to_append)
    {
        // Size of file to append is never bigger than some MB, so cat is not
        // used.
        if (file_put_contents($filepath, file_get_contents($filepath_to_append), FILE_APPEND | LOCK_EX) === FALSE) {
            return FALSE;
        }
        chmod($filepath, 0644);
        return $filepath;
    }

    /**
     * Returns a sanitized and unaccentued string for folder or file path.
     *
     * @param string $string The string to sanitize.
     *
     * @return string The sanitized string to use as a folder or a file name.
     */
    private function _sanitizeString($string)
    {
        return  substr($this->_convertNameToAscii($string), -200);
    }

    /**
     * Returns a sanitized string for folder or file path.
     *
     * The string should be a simple name, not a full path or url, because "/",
     * "\" and ":" are removed (so a path should be sanitized by part).
     *
     * @param string $string The string to sanitize.
     *
     * @return string The sanitized string.
     */
    private function _sanitizeName($string)
    {
        $string = strip_tags($string);
        $string = trim($string, ' /\\?<>:*%|"\'`&;');
        $string = preg_replace('/[\(\{]/', '[', $string);
        $string = preg_replace('/[\)\}]/', ']', $string);
        $string = preg_replace('/[[:cntrl:]\/\\\?<>:\*\%\|\"\'`\&\;#+\^\$\s]/', ' ', $string);
        return substr(preg_replace('/\s+/', ' ', $string), -250);
    }

    /**
     * Returns a sanitized and unaccentued string for folder or file name.
     *
     * @param string $string The string to convert to ascii.
     *
     * @return string The converted string to use as a folder or a file name.
     */
    private function _convertNameToAscii($string)
    {
        $string = $this->_sanitizeName($string);
        $string = htmlentities($string, ENT_NOQUOTES, 'utf-8');
        $string = preg_replace('#\&([A-Za-z])(?:acute|cedil|circ|grave|lig|orn|ring|slash|th|tilde|uml)\;#', '\1', $string);
        $string = preg_replace('#\&([A-Za-z]{2})(?:lig)\;#', '\1', $string);
        $string = preg_replace('#\&[^;]+\;#', '_', $string);
        $string = preg_replace('/[^[:alnum:]\[\]_\-\.#~@+:]/', '_', $string);
        return substr(preg_replace('/_+/', '_', $string), -250);
    }

    /**
     * Return the list of standard delimiters.
     *
     * @return array The list of standard delimiters.
     */
    public static function getDelimitersList()
    {
        return array(
            'comma'        => ',',
            'semi-colon'   => ';',
            'pipe'         => '|',
            'tabulation'   => "\t",
            'carriage return' => "\r",
            'space'        => ' ',
            'double space' => '  ',
            'empty'        => '',
        );
    }
}
