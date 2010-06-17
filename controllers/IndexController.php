<?php

/**
 * @version $Id$
 * @copyright Scholars' Lab, 2010
 * @license    http://www.apache.org/licenses/LICENSE-2.0.html
 * @package GenericXmlImport
 * @author Ethan Gruber ewg4x at virginia dot edu
 */

/**
 * The GenericXmlImport index controller class.
 *
 *How this works:
 *1. Select XML file to upload and import options
 *2. Form accepts and parses XML file, processes it and sends user
 *to next step with a drop down menu with elements that appear to be the document record
 *3. User selects document record.  Variables passed to CsvImport session, user redirected to CsvImport column mapping
 */

class GenericXmlImporter_IndexController extends Omeka_Controller_Action
{
    public function indexAction() 
    {
		$form = $this->importForm();
		$this->view->form = $form;
    }
    
    //step 1
    public function updateAction($tmpdir=GENXML_IMPORT_TMP_LOCATION)
    {    
		$form = $this->importForm();
		
    	if ($_POST) {
    		if ($form->isValid($this->_request->getPost())) {
				$uploadedData = $form->getValues();
				if($uploadedData['xmldoc'] != ''){
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
						if (simplexml_import_dom($xml_doc)){								
							//ProcessDispatcher::startProcess('GenericXmlImporter_GenerateCsv', null, $args);
							//$this->generateCsv($args);
							$genericXmlImportSession = new Zend_Session_Namespace('GenericXmlImport');
							$genericXmlImportSession->filename = $filename;
							$genericXmlImportSession->item_type_id = $itemTypeId;
							$genericXmlImportSession->collection_id = $collectionId;
							$genericXmlImportSession->public = $uploadedData['genxml_importer_items_are_public'];
							$genericXmlImportSession->featured = $uploadedData['genxml_importer_items_are_featured'];
							$this->redirect->goto('select-element');
						} else {
							$this->flashError("Error parsing XML document.");
						}		
					} catch (Exception $e){
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
	public function selectElementAction ($tmpdir=GENXML_IMPORT_TMP_LOCATION){
		$db = get_db();        
        
        // Set the memory limit.
        $memoryLimit = get_option('genxml_import_memory_limit');
        ini_set('memory_limit', $memoryLimit);
	
	 	$genericXmlImportSession = new Zend_Session_Namespace('GenericXmlImport');
        $view = $this->view;        
        
		/*$itemTypeId = $genericXmlImportSession->item_type_id;
		$collectionId = $genericXmlImportSession->collection_id;
		$public = $genericXmlImportSession->public;
		$featured = $genericXmlImportSession->featured;*/
	
		

		$form = $this->elementForm($genericXmlImportSession);
		
		/*$genericXmlImportSession2 = new Zend_Session_Namespace('GenericXmlImport2');
		$genericXmlImportSession2->element_set = $elementSet;
		$itemTypeId = $genericXmlImportSession->item_type_id;
		$collectionId = $genericXmlImportSession->collection_id;
		$public = $genericXmlImportSession->public;
		$featured = $genericXmlImportSession->featured;*/
		
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
					$this->generateCsv($args);
				}
	    		else {
	    		$this->flashError('Error receiving file or no file selected--verify that it is an XML document.');
	    		}
    		}
    }
	
    //generates csv file
	private function generateCsv($args, $stylesheet=GENXML_IMPORT_DOC_EXTRACTOR, $tmpdir=GENXML_IMPORT_TMP_LOCATION, $csvfilesdir=CSV_IMPORT_CSV_FILES_DIRECTORY, $csvImportDirectory = CSV_IMPORT_DIRECTORY){
		
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
		
		//set tag name parameter
		$xp->setParameter( '', 'node', $tagName);		
		
		//set path to xml file in order to load it
		$file = $tmpdir . DIRECTORY_SEPARATOR . $filename;
		$basename = basename($file, '.xml');

		 // create a DOM document and load the XSL stylesheet
		$xsl = new DomDocument;
		$xsl->load($stylesheet);
  
		// import the XSL styelsheet into the XSLT process
		$xp->importStylesheet($xsl);
		
		// create a DOM document and load the XML data
		$xml_doc = new DomDocument;
		$xml_doc->load($file);
		
		// write transformed csv file to the csv file folder in the csvImport directory
		try { 
			if ($doc = $xp->transformToXML($xml_doc)) {			
				$csvFilename = $csvfilesdir . DIRECTORY_SEPARATOR . $basename . '.csv';
				$documentFile = fopen($csvFilename, 'w');
				fwrite($documentFile, $doc);
				fclose($documentFile);
				
				//set up CsvImport validation and column mapping
				// get the session and view
        		$csvImportSession = new Zend_Session_Namespace('CsvImport');
        		$view = $this->view;
				$csvImportFile = new CsvImport_File($basename . '.csv');
				
                $maxRowsToValidate = 2;
                if (!$csvImportFile->isValid($maxRowsToValidate)) {
                    $this->flashError('Your file is incorrectly formatted.  Please select a valid CSV file.');
                } else {                    
                    // save csv file and item type to the session
                    $csvImportSession->csvImportFile = $csvImportFile;                    
                    $csvImportSession->csvImportItemTypeId = empty($itemTypeId) ? 0 : $itemTypeId;
                    $csvImportSession->csvImportItemsArePublic = ($itemsArePublic == '1');
                    $csvImportSession->csvImportItemsAreFeatured = ($itemsAreFeatured == '1');
                    $csvImportSession->csvImportCollectionId = $collectionId;
					//redirect to column mapping page
					$this->_helper->redirector->goto('map-columns', 'index', 'csv-import');
					//$this->redirect->goto('map-columns');
                }
			} else {
				$this->flashError("Could not transform XML file.  Be sure your XML document is valid.");
			}
		} catch (Exception $e){
			$this->view->error = $e->getMessage();
		}
	}
	
	//main form for step 1
	private function importForm($tmpdir=GENXML_IMPORT_TMP_LOCATION)
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
		
    	$form = new Zend_Form();
    	$form->setAction('update');
    	$form->setMethod('post');
    	$form->setAttrib('enctype', 'multipart/form-data');
    	
    	//Dublin Core file upload controls
    	$fileUploadElement = new Zend_Form_Element_File('xmldoc');
    	$fileUploadElement->setLabel('Select XML file:');
    	$fileUploadElement->setDestination($tmpdir);
    	$fileUploadElement->addValidator('count', false, 1); 
    	$fileUploadElement->addValidator('extension', false, 'xml');        	
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
    	  	
    	//Submit button
    	$form->addElement('submit','submit');
    	$submitElement=$form->getElement('submit');
    	$submitElement->setLabel('Upload XML Document');
    	
    	return $form;
	}
	
	//form for step 2, drop down menu created for tag, other options are hidden inputs
	private function elementForm($genericXmlImportSession,$tmpdir=GENXML_IMPORT_TMP_LOCATION){
	
		$filename = $genericXmlImportSession->filename;
		$itemTypeId = $genericXmlImportSession->item_type_id;
		$collectionId = $genericXmlImportSession->collection_id;
		$public = $genericXmlImportSession->public;
		$featured = $genericXmlImportSession->featured;
		
		$file = $tmpdir . DIRECTORY_SEPARATOR . $filename;
	
		$doc = new DomDocument;
		$doc->load($file);
		foreach ($doc->childNodes as $pri){			
				//echo $pri->nodeName;
				$elementSet = $this->cycleNodes($pri, $elementList = array(), $num=0);
		}
		
		require "Zend/Form/Element.php";
		
		$form = new Zend_Form();
    	$form->setAction('send');
    	$form->setMethod('post');
    	$form->setAttrib('enctype', 'multipart/form-data');
    	
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
		
		//Submit button
    	$form->addElement('submit','submit');
    	$submitElement=$form->getElement('submit');
    	$submitElement->setLabel('Next->');
		
		return $form;
	}
	
	//iterate through XML file, extracting out element names that seem to meet requirements for Omeka item record
	public function cycleNodes($pri, $elementList, $num) {
		if ($pri->hasChildNodes()) {
			foreach ($pri->childNodes as $sec){
				if ($sec->hasChildNodes() == false){
					$next = $this->cycleNodes($sec, $elementList);
				}
				else{
					if ($sec->nodeName != '#text' && $sec->nodeName != '#comment'){
						if ($sec->nodeName != $elementList[$num - 1]){
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

