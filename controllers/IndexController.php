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
 * The plugin controller for index pages.
 *
 * Technical notes
 * How this works:
 * 1. Select XML file to upload and import options
 * 2. Form accepts and parses XML file, processes it and sends user to next step
 * with a drop down menu with elements that appear to be the document record
 * 3. User selects document record.  Variables passed to CsvImport session, user
 * redirected to CsvImport column mapping
 *
 * @package XmlImport
 */
class XmlImport_IndexController extends Omeka_Controller_Action
{
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
            $this->flashError('Invalid form input. Please see errors below and try again.');
            return;
        }

        $uploadedData = $form->getValues();
        $uploadedData['xmlfolder'] = trim($uploadedData['xmlfolder']);
        $fileList = array();

        // If one file is selected, fill the file list with it.
        if ($uploadedData['xmldoc'] != '') {
            if (!$form->xmldoc->receive()) {
                $this->flashError("Error uploading file. Please try again.");
                return;
            }
            $csvFilename = pathinfo($form->xmldoc->getFileName(), PATHINFO_BASENAME);
            $fileList = array($form->xmldoc->getFileName() => $csvFilename);
        }
        // Else prepare file list from the folder.
        elseif ($uploadedData['xmlfolder'] != '') {
            $fileList = $this->_listRecursiveDirectory($uploadedData['xmlfolder'], 'xml');
            $csvFilename = 'folder "' . $uploadedData['xmlfolder'] . '"';

            // @todo Upload each file? Currently, they are checked only
            // with DirectoryIterator.
        }
        else {
            $this->flashError('Error receiving file or no file selected. Verify that it is an XML document.');
            return;
        }

        if (empty($fileList)) {
            $this->flashError('Error receiving file or no file selected. Verify that it is an XML document.');
            return;
        }

        // Check content of each file via a simplexml parsing and hook.
        foreach ($fileList as $filepath => $filename) {
            $xml_doc = new DomDocument;
            $xml_doc->load($filepath);
            if (simplexml_import_dom($xml_doc)) {
                $result = fire_plugin_hook('xml_import_validate_xml_file', $xml_doc);
                // @todo Check result of the hook.
                if (!isset($xml_doc)) {
                    $this->flashError('Error validating XML document: "' . $filepath . '".');
                    return;
                }
            }
            else {
                $this->flashError('Error parsing XML document: "' . $filepath . '".');
                return;
            }
        }

        // Check delimiter.
        if ($uploadedData['xml_import_delimiter_name'] == 'custom') {
            if ($uploadedData['xml_import_delimiter_name'] == '') {
                $this->flashError('Error parsing XML document: "' . $filepath . '".');
                return;
            }
        }
        else {
            $listDelimiters = $this->_listDelimiters();
            $uploadedData['xml_import_delimiter'] = $listDelimiters[$uploadedData['xml_import_delimiter_name']];
        }

        // Alright, go to next step.
        try {
            // Clean up collection id if no collection is selected.
            $collectionId = ($uploadedData['xml_import_collection_id'] == 'X')
                    ? ''
                    : $uploadedData['xml_import_collection_id'];

            // Clean up item type.
            $itemTypeId = ($uploadedData['xml_import_item_type'] == 'X')
                    ? ''
                    : $uploadedData['xml_import_item_type'];

            $xmlImportSession = new Zend_Session_Namespace('XmlImport');
            $xmlImportSession->file_list = $fileList;
            $xmlImportSession->csv_filename = $csvFilename;
            $xmlImportSession->record_type_id = $uploadedData['xml_import_record_type'];
            $xmlImportSession->item_type_id = $itemTypeId;
            $xmlImportSession->collection_id = $collectionId;
            $xmlImportSession->public = $uploadedData['xml_import_items_are_public'];
            $xmlImportSession->featured = $uploadedData['xml_import_items_are_featured'];
            $xmlImportSession->html_elements = $uploadedData['xml_import_elements_are_html'];
            $xmlImportSession->stylesheet = $uploadedData['xml_import_stylesheet'];
            $xmlImportSession->delimiter = $uploadedData['xml_import_delimiter'];
            $xmlImportSession->stylesheet_parameters = $uploadedData['xml_import_stylesheet_parameters'];

            $this->redirect->goto('select-element');
        } catch (Exception $e) {
            $this->view->error = $e->getMessage();
        }
    }

    /**
     * Displays second form to choose element (step 2).
     */
    public function selectElementAction()
    {
        $xmlImportSession = new Zend_Session_Namespace('XmlImport');
        $view = $this->view;

        $form = $this->_elementForm($xmlImportSession);

        // When tag is not set, display the form to select one.
        if ($form->getValue('xml_import_tag_name') === null) {
            $this->view->form = $form;
        }
        // Else go directly to next step.
        else {
            $uploadedData = $form->getValues();
            $this->_prepareCsvArguments($uploadedData);
        }
    }

    /**
     * Generates csv file (step 3).
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
                $this->flashError('Error receiving file or no file selected. Verify that it is an XML document.');
            }
        }
    }

    /**
     * Helper to prepare array used to generate csv file from a submited form.
     */
    private function _prepareCsvArguments($uploadedData) {
        $args = array();
        $args['file_list'] = unserialize($uploadedData['xml_import_file_list']);
        $args['csv_filename'] = $uploadedData['xml_import_csv_filename'];
        $args['tag_name'] = $uploadedData['xml_import_tag_name'];
        $args['record_type_id'] = $uploadedData['xml_import_record_type'];
        $args['item_type_id'] = $uploadedData['xml_import_item_type'];
        $args['collection_id'] = $uploadedData['xml_import_collection_id'];
        $args['public'] = $uploadedData['xml_import_items_are_public'];
        $args['featured'] = $uploadedData['xml_import_items_are_featured'];
        $args['html_elements'] = $uploadedData['xml_import_elements_are_html'];
        $args['stylesheet'] = $uploadedData['xml_import_stylesheet'];
        $args['delimiter'] = $uploadedData['xml_import_delimiter'];
        $args['stylesheet_parameters'] = $uploadedData['xml_import_stylesheet_parameters'];

        set_option('xml_import_stylesheet', $args['stylesheet']);
        set_option('xml_import_delimiter', $args['delimiter']);
        set_option('xml_import_stylesheet_parameters', $args['stylesheet_parameters']);
        set_option('csv_import_html_elements', $args['html_elements']);

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
        $recordTypeId = $args['record_type_id'];
        $itemTypeId = $args['item_type_id'];
        $collectionId = $args['collection_id'];
        $itemsArePublic = $args['public'];
        $itemsAreFeatured = $args['featured'];
        $elementsAreHtml = $args['html_elements'];
        $tagName = $args['tag_name'];
        $stylesheet = $args['stylesheet'];
        $delimiter = $args['delimiter'];
        $stylesheetParameters = $args['stylesheet_parameters'];

        $csvFilePath = sys_get_temp_dir() . '/' . 'omeka_xml_import_' . date('Ymd-His') . '_' . $this->_sanitizeString($csvFilename) . '.csv';
        $csvFilename = 'Via Xml Import: ' . $csvFilename;

        try {
            // Add items of the custom fields. Allowed types are already checked.
            $parameters = array();
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
            $parameters['node'] = $tagName;
            $parameters['delimiter'] = $delimiter;

            // Flag used to keep or remove headers in the first row.
            $flag_first = TRUE;
            foreach ($fileList as $filepath => $filename) {
                $csvData = $this->_apply_xslt($filepath, $stylesheet, $parameters);

                if ($flag_first) {
                    $flag_first = FALSE;
                }
                else {
                    $csvData = substr($csvData, strpos($csvData, "\n") + 1);
                }

                // @todo Use Zend/Omeka api.
                $result = $this->_append_data_to_file($csvFilePath, $csvData);
                if ($result === FALSE) {
                    // TODO Display error message before return.
                    $this->flashError('Error saving data, because the filepath is not writable ("' . $filepath . '").');
                    $this->redirect->goto('index');
                    return;
                }
            }

            // Get the view.
            $view = $this->view;

            // Set up CsvImport validation and column mapping if needed.
            $file = new CsvImport_File($csvFilePath, $delimiter);
            if (!$file->parse()) {
                // TODO Display error message before return.
                $this->flashError('Your CSV file is incorrectly formatted. ' . $file->getErrorString());
                $this->redirect->goto('index');
                return;
            }
            // Go directly to the correct view of CsvImport plugin.
            else {
                $csvImportSession = new Zend_Session_Namespace('CsvImport');

                // @see CsvImport_IndexController::indexAction().
                $csvImportSession->setExpirationHops(2);
                $csvImportSession->originalFilename = $csvFilename;
                $csvImportSession->filePath = $csvFilePath;
                $csvImportSession->columnDelimiter = $delimiter;

                $csvImportSession->recordTypeId = $recordTypeId;
                $csvImportSession->itemTypeId = empty($itemTypeId) ? 0 : $itemTypeId;
                $csvImportSession->collectionId = $collectionId;
                $csvImportSession->itemsArePublic = ($itemsArePublic == '1');
                $csvImportSession->itemsAreFeatured = ($itemsAreFeatured == '1');
                $csvImportSession->elementsAreHtml = ($elementsAreHtml == '1');
                $csvImportSession->columnNames = $file->getColumnNames();
                $csvImportSession->columnExamples = $file->getColumnExamples();
                // A bug appears in CsvImport when examples contain UTF-8
                // characters like 'ГЧ„чŁ'.
                foreach ($csvImportSession->columnExamples as &$value) {
                    $value = iconv('ISO-8859-15', 'UTF-8', @iconv('UTF-8', 'ISO-8859-15' . '//IGNORE', $value));
                }
                $csvImportSession->ownerId = $this->getInvokeArg('bootstrap')->currentuser->id;

                if ($recordTypeId == 1) {
                    $this->redirect->goto('check-omeka-csv', 'index', 'csv-import');
                }
                else {
                    $this->redirect->goto('map-columns', 'index', 'csv-import');
                }
            }
        } catch (Exception $e) {
            $this->view->error = $e->getMessage();
        }
    }

    /**
     * Helper to prepare main form for step 1.
     */
    private function _getMainForm()
    {
        require_once dirname(__FILE__) . DIRECTORY_SEPARATOR . '..' . DIRECTORY_SEPARATOR . 'forms' . DIRECTORY_SEPARATOR . 'Main.php';
        $form = new XmlImport_Form_Main();
        return $form;
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
        $recordTypeId = $xmlImportSession->record_type_id;
        $itemTypeId = $xmlImportSession->item_type_id;
        $collectionId = $xmlImportSession->collection_id;
        $public = $xmlImportSession->public;
        $featured = $xmlImportSession->featured;
        $htmlElements = $xmlImportSession->html_elements;
        $stylesheet = $xmlImportSession->stylesheet;
        $delimiter = $xmlImportSession->delimiter;
        $stylesheetParameters = $xmlImportSession->stylesheet_parameters;

        // Get first level nodes of first file in order to choose document name.
        // TODO Add the root element name, because some formats use it.
        reset($fileList);
        $doc = new DomDocument;
        $doc->load(key($fileList));
        foreach ($doc->childNodes as $pri) {
            $elementSet = $this->cycleNodes($pri, $elementList = array(), $num = 0);
        }

        require "Zend/Form/Element.php";

        $form = new Omeka_Form();
        $form->setAttrib('id', 'xmlimport');
        $form->setAction('send');
        $form->setMethod('post');

        // Available record elements inside xml file.
        // Automatic import via Omeka CSV Report.
        if ($recordTypeId == 1) {
            $tagNameElement = new Zend_Form_Element_Hidden('xml_import_tag_name');
            $tagNameElement->setValue('item');
        }
        // Only one document.
        elseif (count($elementSet) == 1) {
            reset($elementSet);
            $tagNameElement = new Zend_Form_Element_Hidden('xml_import_tag_name');
            $tagNameElement->setValue(key($elementSet));
        }
        // Multiple possibilities.
        else {
            $tagNameElement = new Zend_Form_Element_Select('xml_import_tag_name');
            $tagNameElement
                ->setLabel('Tag Name')
                ->addMultiOptions($elementSet);
        }
        $form->addElement($tagNameElement);

        $fileListElement = new Zend_Form_Element_Hidden('xml_import_file_list');
        $fileListElement->setValue(serialize($fileList));
        $form->addElement($fileListElement);

        $csvFilenameElement = new Zend_Form_Element_Hidden('xml_import_csv_filename');
        $csvFilenameElement->setValue($csvFilename);
        $form->addElement($csvFilenameElement);

        $recordTypeElement = new Zend_Form_Element_Hidden('xml_import_record_type');
        $recordTypeElement->setValue($recordTypeId);
        $form->addElement($recordTypeElement);

        $itemTypeElement = new Zend_Form_Element_Hidden('xml_import_item_type');
        $itemTypeElement->setValue($itemTypeId);
        $form->addElement($itemTypeElement);

        $collectionIdElement = new Zend_Form_Element_Hidden('xml_import_collection_id');
        $collectionIdElement->setValue($collectionId);
        $form->addElement($collectionIdElement);

        $publicElement = new Zend_Form_Element_Hidden('xml_import_items_are_public');
        $publicElement->setValue($public);
        $form->addElement($publicElement);

        $featuredElement = new Zend_Form_Element_Hidden('xml_import_items_are_featured');
        $featuredElement->setValue($featured);
        $form->addElement($featuredElement);

        $htmlElementsElement = new Zend_Form_Element_Hidden('xml_import_elements_are_html');
        $htmlElementsElement->setValue($htmlElements);
        $form->addElement($htmlElementsElement);

        $stylesheetElement = new Zend_Form_Element_Hidden('xml_import_stylesheet');
        $stylesheetElement->setValue($stylesheet);
        $form->addElement($stylesheetElement);

        $delimiterElement = new Zend_Form_Element_Hidden('xml_import_delimiter');
        $delimiterElement->setValue($delimiter);
        $form->addElement($delimiterElement);

        $stylesheetParametersElement = new Zend_Form_Element_Hidden('xml_import_stylesheet_parameters');
        $stylesheetParametersElement->setValue($stylesheetParameters);
        $form->addElement($stylesheetParametersElement);

        // Submit button.
        $form->addElement('submit','submit');
        $submitElement = $form->getElement('submit');
        $submitElement->setLabel('Next ->');

        return $form;
    }

    /**
     * Iterate through XML file, extracting out element names that seem to meet
     * requirements for Omeka item record.
     */
    public function cycleNodes($pri, $elementList, $num)
    {
        if ($pri->hasChildNodes()) {
            foreach ($pri->childNodes as $sec) {
                if ($sec->hasChildNodes() == FALSE) {
                    $next = $this->cycleNodes($sec, $elementList, $num);
                }
                else{
                    if ($sec->nodeName != '#text' && $sec->nodeName != '#comment') {
                        if ($sec->nodeName != $elementList[$num - 1]) {
                            $elementList[$sec->nodeName] = $sec->nodeName;
                            $num++;
                        }
                    }
                }
            }
        }
        return $elementList;
    }

    /**
     * Iterates recursively through a directory to get all selected filepaths.
     *
     * @param $directory string Directory to check.
     * @param $extension string Extension.
     *
     * @return associative array of filepath => filename.
     */
    private function _listRecursiveDirectory($directory, $extension)
    {
        if (empty($directory)) {
            return array();
        }

        if ($extension == '') {
            $this->flashError('Error selecting extension.');
            return;
        }

        $Directory = new RecursiveDirectoryIterator($directory);
        $Iterator = new RecursiveIteratorIterator($Directory);
        $Regex = new RegexIterator($Iterator, '/^.+\.' . $extension . '$/i', RecursiveRegexIterator::GET_MATCH);
        $filenames = array();
        try {
            foreach($Regex as $name => $object){
                $filenames[$name] = pathinfo($name, PATHINFO_BASENAME);
            }
        } catch (Exception $e) {
            $this->flashError('Error accessing directory "' . $directory . '". Verify that you have rights to access this folder and subfolders.');
            return;
        }

        natcasesort($filenames);
        return $filenames;
    }

    /**
     * Apply a xslt stylesheet on a xml file.
     *
     * @param string $xml_file
     *   Path of xml file.
     * @param string $xsl_file
     *   Path of the xslt file.
     * @param array $parameters
     *   Parameters array.
     *
     * @return string
     *   Transformed data.
     */
    private function _apply_xslt($xml_file, $xsl_file, $parameters = array())
    {
        $DomXml = DomDocument::load($xml_file);
        $DomXsl = DomDocument::load($xsl_file);

        $proc = new XSLTProcessor;
        // Php functions are needed, because php doesn't use XSLT 2.0 and
        // because we need to check existence of a file.
        if (get_plugin_ini('XmlImport', 'xml_import_allow_php_in_xsl') == 'TRUE') {
            $proc->registerPHPFunctions();
        }
        $proc->importStyleSheet($DomXsl);
        $proc->setParameter('', $parameters);

        return $proc->transformToXML($DomXml);
    }

    /**
     * Append and save a string into a file.
     *
     * @param string $filepath
     * @param string $data
     *
     * @return
     *   $filepath if no error, FALSE else.
     */
    private function _append_data_to_file($filepath, $data)
    {
        if (file_put_contents($filepath, $data, FILE_APPEND | LOCK_EX) === FALSE) {
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
        $string = trim(strip_tags($string));
        $string = htmlentities($string, ENT_NOQUOTES, 'utf-8');
        $string = preg_replace('#\&([A-Za-z])(?:uml|circ|tilde|acute|grave|cedil|ring)\;#', '\1', $string);
        $string = preg_replace('#\&([A-Za-z]{2})(?:lig)\;#', '\1', $string);
        $string = preg_replace('#\&[^;]+\;#', '_', $string);
        $string = preg_replace('/[^[:alnum:]\(\)\[\]_\-\.#~@+:]/', '_', $string);
        return preg_replace('/_+/', '_', $string);
    }

    private function _listDelimiters()
    {
        return array(
            'comma'      => ',',
            'semi-colon' => ';',
            'tabulation' => "\t",
            'pipe'       => '|',
            'space'      => ' ',
            'custom'     => 'custom',
        );
    }
}
