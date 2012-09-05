<?php

class XmlImport_generateCsv extends ProcessAbstract
{
    public function run($args)
    {
        // Get variables from args array passed into detached process.
        $filepath = $args['filepath'];
        $filename = (isset($args['filename']) && !empty($args['filename']))
                ? $args['filename']
                : pathinfo($filename, PATHINFO_BASENAME);
        $itemsArePublic = $args['public'];
        $itemsAreFeatured = $args['featured'];
        $collectionId = $args['collection_id'];
        $itemTypeId = $args['item_type_id'];
        $tagName = $args['tag_name'];
        $delimiter = $args['delimiter'];
        $stylesheet = (isset($args['stylesheet']) && !empty($args['stylesheet']))
                ? $args['stylesheet']
                : get_option('xml_import_stylesheet');
        $csvfilesdir = (isset($args['destination_dir']) && !empty($args['destination_dir']))
                ? $args['destination_dir']
                : sys_get_temp_dir();

        // Create a DOM document and load the XML data.
        $xml_doc = new DomDocument;
        $xml_doc->load($filepath);

         // Create a DOM document and load the XSL stylesheet.
        $xsl = new DomDocument;
        $xsl->load($stylesheet);

        // Import the XSL styelsheet into the XSLT process.
        $xp = new XsltProcessor();
        $xp->setParameter('', 'node', $tagName);
        $xp->importStylesheet($xsl);

        // Write transformed xml file to the temp csv file.
        try {
            if ($doc = $xp->transformToXML($xml_doc)) {
                $csvFilename = $csvfilesdir . DIRECTORY_SEPARATOR . pathinfo($filename, PATHINFO_FILENAME) . '.csv';
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