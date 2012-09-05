<?php

class GenericXmlImporter_GenerateCsv extends ProcessAbstract
{
    public function run($args, $stylesheet = GENXML_IMPORT_DOC_EXTRACTOR, $tmpdir = GENXML_IMPORT_TMP_LOCATION, $csvfilesdir = '')
    {
        if ($csvfilesdir == '') {
            $csvfilesdir = sys_get_temp_dir();
        }

        // Get PHP memory options.
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
        $basename = basename($xml_file, '.xml');

         // create a DOM document and load the XSL stylesheet
        $xsl = new DomDocument;
        $xsl->load($stylesheet);

        // import the XSL styelsheet into the XSLT process
        $xp->importStylesheet($xsl);

        // create a DOM document and load the XML data
        $xml_doc = new DomDocument;
        $xml_doc->load($xml_file);

        // write transformed csv file to the csv file folder in the csvImport directory
        try {
            if ($doc = $xp->transformToXML($xml_doc)) {
                $csvFilename = $csvfilesdir . DIRECTORY_SEPARATOR . $basename . '.csv';
                $documentFile = fopen($csvFilename, 'w');
                fwrite($documentFile, $doc);
                fclose($documentFile);

                //$this->_initializeCsvImport($basename, $itemsArePublic, $itemsAreFeatured, $collectionId);
                $this->flashSuccess("Successfully generated CSV File");
            } else {
                $this->flashError("Could not transform XML file.  Be sure your XML document is valid.");
            }
        } catch (Exception $e){
            $this->view->error = $e->getMessage();
        }
    }
}