<?php

/**
 * @version $Id$
 * @copyright Daniel Berthereau for École des Ponts ParisTech, 2012
 * @copyright Scholars' Lab, 2010
 * @license http://www.cecill.info/licences/Licence_CeCILL_V2-en.txt
 * @license http://www.gnu.org/licenses/gpl-3.0.txt
 * @license http://www.apache.org/licenses/LICENSE-2.0.html
 * @package GenericXmlImport
 * @author Daniel Berthereau
 * @author Ethan Gruber: ewg4x at virginia dot edu
 */

/**
 * The GenericXmlImport index controller class.
 *
 * How this works:
 * 1. Select XML file to upload and import options
 * 2. Form accepts and parses XML file, processes it and sends user to next step
 * with a drop down menu with elements that appear to be the document record
 * 3. User selects document record.  Variables passed to CsvImport session, user
 * redirected to CsvImport column mapping
 */

class GenericXmlImporter_UploadController extends Omeka_Controller_Action
{
    public function indexAction()
    {
        $form = $this->importForm();
        $this->view->form = $form;
    }

    //step 1
    public function updateAction($tmpdir = GENXML_IMPORT_TMP_LOCATION)
    {
        $form = $this->importForm();

        if ($_POST) {
            if ($form->isValid($this->_request->getPost())) {
                $uploadedData = $form->getValues();
                if($uploadedData['xmldoc'] != '') {
                    $filename = $uploadedData['xmldoc'];

                    //clean up collection id if no collection is selected
                    if ($uploadedData['genxml_importer_collection_id'] == 'X')
                    {
                        $collectionId = '';
                    }
                    else{
                        $collectionId = $uploadedData['genxml_importer_collection_id'];
                    }

                    //clean up item type
                    if ($uploadedData['genxml_importer_item_type'] == 'X')
                    {
                        $itemTypeId = '';
                    }
                    else{
                        $itemTypeId = $uploadedData['genxml_importer_item_type'];
                    }

                    //Save the file
                    $form->xmldoc->receive();

                    $file = $tmpdir . DIRECTORY_SEPARATOR . $filename;
                    $xml_doc = new DomDocument;
                    $xml_doc->load($file);

                    try {
                        if (simplexml_import_dom($xml_doc)) {
                            //ProcessDispatcher::startProcess('GenericXmlImporter_GenerateCsv', null, $args);
                            //$this->generateCsv($args);
                            $genericXmlImportSession = new Zend_Session_Namespace('GenericXmlImport');
                            $genericXmlImportSession->filename = $filename;
                            $genericXmlImportSession->item_type_id = $itemTypeId;
                            $genericXmlImportSession->collection_id = $collectionId;
                            $genericXmlImportSession->public = $uploadedData['genxml_importer_items_are_public'];
                            $genericXmlImportSession->featured = $uploadedData['genxml_importer_items_are_featured'];
                            $genericXmlImportSession->delimiter = $uploadedData['genxml_importer_delimiter'];
                            $this->redirect->goto('select-element');
                        } else {
                            $this->flashError("Error parsing XML document.");
                        }
                    } catch (Exception $e) {
                        $this->view->error = $e->getMessage();

                    }
                }
                else {
                    $this->flashError('Error receiving file or no file selected--verify that it is an XML document.');
                }
            }
        }
        else {
            $this->flashError('Error receiving file or no file selected--verify that it is an XML document.');
        }
    }

    //step 2
    public function selectElementAction ($tmpdir = GENXML_IMPORT_TMP_LOCATION)
    {
        $db = get_db();

        // Set the memory limit.
        $memoryLimit = get_option('genxml_import_memory_limit');
        ini_set('memory_limit', $memoryLimit);

        $genericXmlImportSession = new Zend_Session_Namespace('GenericXmlImport');
        $view = $this->view;

        $form = $this->elementForm($genericXmlImportSession);
        $this->view->form = $form;
    }

    //step 3, csv file generated
    public function sendAction()
    {
        $genericXmlImportSession = new Zend_Session_Namespace('GenericXmlImport');
        $view = $this->view;

        $form = $this->elementForm($genericXmlImportSession);
        if ($_POST) {
            if ($form->isValid($this->_request->getPost())) {
                $uploadedData = $form->getValues();
                $args = array();
                $args['filename'] = $uploadedData['genxml_importer_filename'];
                $args['tag_name'] = $uploadedData['genxml_importer_tag_name'];
                $args['item_type_id'] = $uploadedData['genxml_importer_item_type'];
                $args['collection_id'] = $uploadedData['genxml_importer_collection_id'];
                $args['public'] = $uploadedData['genxml_importer_items_are_public'];
                $args['featured'] = $uploadedData['genxml_importer_items_are_featured'];
                $args['delimiter'] = $uploadedData['genxml_importer_delimiter'];
                $this->generateCsv($args);
            } else {
                $this->flashError('Error receiving file or no file selected--verify that it is an XML document.');
            }
        }
    }

    // Generates csv file
    private function generateCsv($args, $stylesheet = GENXML_IMPORT_DOC_EXTRACTOR, $tmpdir = GENXML_IMPORT_TMP_LOCATION)
    {
        //get PHP memory options
        $db = get_db();

        // Set the memory limit.
        $memoryLimit = get_option('genxml_import_memory_limit');
        ini_set('memory_limit', $memoryLimit);

        $xp = new XsltProcessor();

        //Get variables from args array passed into detached process
        $filename = $args['filename'];
        $itemsArePublic = $args['public'];
        $itemsAreFeatured = $args['featured'];
        $collectionId = $args['collection_id'];
        $itemTypeId = $args['item_type_id'];
        $tagName = $args['tag_name'];
        $delimiter = $args['delimiter'];

        //set tag name parameter
        $xp->setParameter( '', 'node', $tagName);

        //set path to xml file in order to load it
        $xml_file = $tmpdir . DIRECTORY_SEPARATOR . $filename;

         // create a DOM document and load the XSL stylesheet
        $xsl = new DomDocument;
        $xsl->load($stylesheet);

        // import the XSL styelsheet into the XSLT process
        $xp->importStylesheet($xsl);

        // create a DOM document and load the XML data
        $xml_doc = new DomDocument;
        $xml_doc->load($xml_file);

        // Write transformed xml file to the temp csv file.
        try {
            if ($doc = $xp->transformToXML($xml_doc)) {
                $csvFilename =  tempnam(sys_get_temp_dir(), 'omeka_xml_import_');
                $documentFile = fopen($csvFilename, 'w');
                fwrite($documentFile, $doc);
                fclose($documentFile);

                // Set up CsvImport validation and column mapping.
                // Get the view.
                $view = $this->view;
                $filePath = $csvFilename;
                $filename =  pathinfo($xml_file, PATHINFO_BASENAME);

                $file = new CsvImport_File($filePath, $delimiter);
                if (!$file->parse()) {
                    $this->flashError('Your file is incorrectly formatted. ' . $file->getErrorString());
                }
                else {
                    // Go directly to the map-columns view of CsvImport plugin.
                    $csvImportSession = new Zend_Session_Namespace('CsvImport');

                    // @see CsvImport_IndexController::indexAction().
                    $csvImportSession->setExpirationHops(2);
                    $csvImportSession->originalFilename = $filename;
                    $csvImportSession->filePath = $filePath;
                    $csvImportSession->columnDelimiter = $delimiter;

                    $csvImportSession->itemTypeId = empty($itemTypeId) ? 0 : $itemTypeId;
                    $csvImportSession->itemsArePublic = ($itemsArePublic == '1');
                    $csvImportSession->itemsAreFeatured = ($itemsAreFeatured == '1');
                    $csvImportSession->collectionId = $collectionId;
                    $csvImportSession->columnNames = $file->getColumnNames();
                    $csvImportSession->columnExamples = $file->getColumnExamples();
                    $csvImportSession->ownerId = $this->getInvokeArg('bootstrap')->currentuser->id;

                    $this->redirect->goto('map-columns', 'index', 'csv-import');
                }
            } else {
                $this->flashError("Could not transform XML file.  Be sure your XML document is valid.");
            }
        } catch (Exception $e) {
            $this->view->error = $e->getMessage();
        }
    }

    //main form for step 1
    private function importForm($tmpdir = GENXML_IMPORT_TMP_LOCATION)
    {
        require "Zend/Form/Element.php";

        //Get collections table and load into array
        $collections = array();
        $collections['X'] = 'Select Below';
        $collectionObjects = get_db()->getTable('Collection')->findAll();
        foreach($collectionObjects as $collectionObject) {
            $collections[$collectionObject->id] = $collectionObject->name;
        }

        //Get item types and load into array
        $itemtypes = array();
        $itemtypes['X'] = 'Select Below';
        $itemtypeObjects = get_db()->getTable('ItemType')->findAll();
        foreach($itemtypeObjects as $itemtypeObject) {
            $itemtypes[$itemtypeObject->id] = $itemtypeObject->name;
        }

        $form = new Omeka_Form();
        $form->setAction('update');
        $form->setMethod('post');

        //Dublin Core file upload controls
        $fileUploadElement = new Zend_Form_Element_File('xmldoc');
        $fileUploadElement->setLabel('Select XML file:');
        $fileUploadElement->setDestination($tmpdir);
        $fileUploadElement->addValidator('count', FALSE, 1);
        $fileUploadElement->addValidator('extension', FALSE, 'xml');
        $form->addElement($fileUploadElement);

        //Item Type
        $itemType = new Zend_Form_Element_Select('genxml_importer_item_type');
        $itemType->setLabel('Item Type')
            ->addMultiOptions($itemtypes);
        $form->addElement($itemType);

        //Collection
         $collectionId = new Zend_Form_Element_Select('genxml_importer_collection_id');
         $collectionId->setLabel('Collection')
                ->addMultiOptions($collections);
         $form->addElement($collectionId);

        //Items are Public?
        $itemsArePublic = new Zend_Form_Element_Checkbox('genxml_importer_items_are_public');
        $itemsArePublic->setLabel('Items Are Public?');
        $form->addElement($itemsArePublic);

        //Items are Featured?
        $itemsAreFeatured = new Zend_Form_Element_Checkbox('genxml_importer_items_are_featured');
        $itemsAreFeatured->setLabel('Items Are Featured?');
        $form->addElement($itemsAreFeatured);

        // Delimiter should be the one used the xsl sheet.
        // @see CsvImport_Form_Main::init().
        $delimiter = GENXML_IMPORT_DELIMITER;
        $form->addElement('text', 'genxml_importer_delimiter', array(
            'label' => 'Choose Column Delimiter',
            'description' => "A single character that will be used to separate columns in the file (comma by default)."
                . ' Warning: Note that it must be the same as the one used in the xsl sheet.',
            'value' => $delimiter,
            'required' => TRUE,
            'size' => '1',
            'validators' => array(
                array('validator' => 'NotEmpty',
                      'breakChainOnFailure' => TRUE,
                      'options' => array('messages' => array(
                          Zend_Validate_NotEmpty::IS_EMPTY => "Column delimiter must be one character long.",
                      )),
                ),
                array('validator' => 'StringLength', 'options' => array(
                    'min' => 1,
                    'max' => 1,
                    'messages' => array(
                        Zend_Validate_StringLength::TOO_SHORT => "Column delimiter must be one character long.",
                        Zend_Validate_StringLength::TOO_LONG => "Column delimiter must be one character long.",
                    ),
                )),
            ),
        ));

        //Submit button
        $form->addElement('submit', 'submit');
        $submitElement=$form->getElement('submit');
        $submitElement->setLabel('Upload XML Document');

        return $form;
    }

    //form for step 2, drop down menu created for tag, other options are hidden inputs
    private function elementForm($genericXmlImportSession, $tmpdir = GENXML_IMPORT_TMP_LOCATION)
    {
        $filename = $genericXmlImportSession->filename;
        $itemTypeId = $genericXmlImportSession->item_type_id;
        $collectionId = $genericXmlImportSession->collection_id;
        $public = $genericXmlImportSession->public;
        $featured = $genericXmlImportSession->featured;
        $delimiter = $genericXmlImportSession->delimiter;
        $file = $tmpdir . DIRECTORY_SEPARATOR . $filename;

        $doc = new DomDocument;
        $doc->load($file);
        foreach ($doc->childNodes as $pri) {
            //echo $pri->nodeName;
            $elementSet = $this->cycleNodes($pri, $elementList = array(), $num = 0);
        }

        require "Zend/Form/Element.php";

        $form = new Omeka_Form();
        $form->setAction('send');
        $form->setMethod('post');

        //Available record elements
        $tagName = new Zend_Form_Element_Select('genxml_importer_tag_name');
        $tagName->setLabel('Tag Name')
            ->addMultiOptions($elementSet);
        $form->addElement($tagName);

        $filenameElement = new Zend_Form_Element_Hidden('genxml_importer_filename');
        $filenameElement->setValue($filename);
        $form->addElement($filenameElement);

        $itemTypeElement = new Zend_Form_Element_Hidden('genxml_importer_item_type');
        $itemTypeElement->setValue($itemTypeId);
        $form->addElement($itemTypeElement);

        $collectionIdElement = new Zend_Form_Element_Hidden('genxml_importer_collection_id');
        $collectionIdElement->setValue($collectionId);
        $form->addElement($collectionIdElement);

        $publicElement = new Zend_Form_Element_Hidden('genxml_importer_items_are_public');
        $publicElement->setValue($public);
        $form->addElement($publicElement);

        $featuredElement = new Zend_Form_Element_Hidden('genxml_importer_items_are_featured');
        $featuredElement->setValue($featured);
        $form->addElement($featuredElement);

        $delimiterElement = new Zend_Form_Element_Hidden('genxml_importer_delimiter');
        $delimiterElement->setValue($delimiter);
        $form->addElement($delimiterElement);

        //Submit button
        $form->addElement('submit', 'submit');
        $submitElement=$form->getElement('submit');
        $submitElement->setLabel('Next->');

        return $form;
    }

    // Iterate through XML file, extracting out element names that seem to meet
    // requirements for Omeka item record.
    public function cycleNodes($pri, $elementList, $num)
    {
        if ($pri->hasChildNodes()) {
            foreach ($pri->childNodes as $sec) {
                if ($sec->hasChildNodes() == FALSE) {
                    $next = $this->cycleNodes($sec, $elementList, $num);
                }
                else {
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
}
