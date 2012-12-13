<?php
/**
 * The form on xml-import/index/index.
 *
 * @package XmlImport
 */
class XmlImport_Form_Main extends Omeka_Form
{
    public function init()
    {
        parent::init();

        // Get collections table and load into array.
        $collections = array();
        $collections['X'] = 'Select Below';
        $collectionObjects = get_db()->getTable('Collection')->findAll();
        foreach($collectionObjects as $collectionObject) {
            $collections[$collectionObject->id] = $collectionObject->name;
        }

        // Get item types and load into array.
        $itemtypes = array();
        $itemtypes['X'] = 'Select Below';
        $itemtypeObjects = get_db()->getTable('ItemType')->findAll();
        foreach($itemtypeObjects as $itemtypeObject) {
            $itemtypes[$itemtypeObject->id] = $itemtypeObject->name;
        }

        $this->setName('xmlimport')
            ->setAttrib('id', 'xmlimport')
            ->setMethod('post');

        // Radio button for selecting record type.
        $this->addElement('radio', 'xml_import_file_import', array(
            'label' => 'How many files do you want to import?',
            'multiOptions' => array(
                1 => 'One file',
                2 => 'All files in a folder',
            ),
            'description' => 'The stylesheet will create one csv file from this or these XML files.',
            'value' => 1,
        ));

        // One xml file upload.
        $fileUploadElement = new Zend_Form_Element_File('xmldoc');
        $fileUploadElement
            ->setLabel('XML file to upload')
            ->setDescription('Maximum file size is the minimum of ' . ini_get('upload_max_filesize') . ' and ' . ini_get('post_max_size') . '.')
            ->addValidator('Count', FALSE, array('min' => 0, 'max' => 1))
            ->addValidator('Extension', FALSE, 'xml');
        $this->addElement($fileUploadElement);
        $this->addDisplayGroup(array('xmldoc'), 'singlefile');

        // Multiple files.
        $xmlFolderElement = new Zend_Form_Element_Text('xmlfolder');
        $xmlFolderElement
            ->setLabel('Folder of XML files on the server')
            ->setDescription('All XML files in this folder, recursively, will be processed.')
            ->setAttrib('size', '80');
        $this->addElement($xmlFolderElement);
        $this->addDisplayGroup(array('xmlfolder'), 'multiplefiles');

        // Radio button for selecting record type.
        $this->addElement('radio', 'xml_import_record_type', array(
            'label' => 'Which type of record do you want to import ?',
            'multiOptions' => array(
                1 => 'Any',
                2 => 'Item',
                3 => 'File',
            ),
            'value' => 1,
            'required' => TRUE,
        ));

        // Item Type.
        $itemType = new Zend_Form_Element_Select('xml_import_item_type');
        $itemType
            ->setLabel('Item Type')
            ->addMultiOptions($itemtypes);
        $this->addElement($itemType);

        // Collection.
        $collectionId = new Zend_Form_Element_Select('xml_import_collection_id');
        $collectionId
            ->setLabel('Collection')
            ->addMultiOptions($collections);
        $this->addElement($collectionId);

        // Items are public?
        $itemsArePublic = new Zend_Form_Element_Checkbox('xml_import_items_are_public');
        $itemsArePublic
            ->setLabel('Items Are Public?');
        $this->addElement($itemsArePublic);

        // Items are featured?
        $itemsAreFeatured = new Zend_Form_Element_Checkbox('xml_import_items_are_featured');
        $itemsAreFeatured->setLabel('Items Are Featured?');
        $this->addElement($itemsAreFeatured);

        // Used to hide some elements when record type is set to all.
        $this->addDisplayGroup(array(
            'xml_import_item_type',
            'xml_import_collection_id', 
            'xml_import_items_are_public',
            'xml_import_items_are_featured',
        ), 'recordtype'); 

        // Elements are html (for automatic import only)?
        $elementsAreHtml = new Zend_Form_Element_Checkbox('xml_import_elements_are_html');
        $elementsAreHtml
            ->setLabel('All imported elements are html?')
            ->setDescription('When elements are imported automatically, this checkbox allows to set their default format, raw text or html.');
        $this->addElement($elementsAreHtml);
        $this->addDisplayGroup(array('xml_import_elements_are_html'), 'recordtypeno'); 

        // XSLT Stylesheet.
        $stylesheets = $this->_listDirectory(get_option('xml_import_xsl_directory'), 'xsl');
        $stylesheet = new Zend_Form_Element_Select('xml_import_stylesheet');
        $stylesheet
            ->setLabel('Stylesheet')
            ->setDescription('The generic stylesheet is "xml-import-generic.xsl". It transforms a flat xml file with multiple records into a csv file with multiple rows.')
            ->setRequired(TRUE)
            ->addMultiOptions($stylesheets)
            ->setValue(get_option('xml_import_stylesheet'));
        $this->addElement($stylesheet);

        // XSLT parameters.
        $stylesheetParametersElement = new Zend_Form_Element_Text('xml_import_stylesheet_parameters');
        $stylesheetParametersElement
            ->setLabel('Add specific parameters to use with this stylesheet')
            ->setDescription('Format: parameter1_name|parameter1_value, parameter2_name|parameter2_value...')
            ->setValue(get_option('xml_import_stylesheet_parameters'))
            ->setAttrib('size', '80');
        $this->addElement($stylesheetParametersElement);

        // Delimiter should be the one used the xsl sheet.
        // @see CsvImport_Form_Main::init() or CsvImport/models/CsvImport/import.php.
        $delimiter = get_option('xml_import_delimiter');
        if ($delimiter == '') {
            $delimiter = ',';
        }
        $delimiterList = array(
            'comma'      => '« , » (comma)',
            'semi-colon' => '« ; » (semi-colon)',
            'tabulation' => '«   » (tabulation)',
            'pipe'       => '« | » (pipe)',
            'space'      => '«   » (space)',
            'custom'     => 'Custom delimiter',
        );
        $delimiterCurrent = in_array($delimiter, $this->_listDelimiters()) ?
            array_search($delimiter, $this->_listDelimiters()) :
            'custom';
        // Two elements are needed to select the delimiter.
        // First, a list for special types, mainly whitespace and tabulation.
        $delimiterName = new Zend_Form_Element_Select('xml_import_delimiter_name');
        $delimiterName
            ->setLabel('Choose column delimiter')
            ->addMultiOptions($delimiterList)
            ->setRequired(TRUE)
            ->setValue($delimiterCurrent);
        $this->addElement($delimiterName);
        // Second, a field to let user chooses.
        $this->addElement('text', 'xml_import_delimiter', array(
            'description' => "Currently, XmlImport convert your files into a CSV file, that is automatically imported via CsvImport. Choose the character you want to use to separate columns in the imported file." . ' '
            . "If you want a specific one, choose 'Custom' in the drop-down list and fill the text field with a single character.",
            'value' => $delimiter,
            'size' => '1',
            'validators' => array(
                array('validator' => 'StringLength', 'options' => array(
                    'min' => 0,
                    'max' => 1,
                    'messages' => array(
                        Zend_Validate_StringLength::TOO_SHORT => "Column delimiter must be one character long.",
                        Zend_Validate_StringLength::TOO_LONG => "Column delimiter must be one character long.",
                    ),
                )),
            ),
        ));

        // Submit button.
        $this->addElement('submit', 'submit');
        $submitElement = $this->getElement('submit');
        $submitElement->setLabel('Upload');
    }

    /**
     * Iterates through a directory to get all files matching to an extension.
     *
     * @param $directory string Directory to check.
     * @param $extension string Extension.
     *
     * @return associative array of filepath => filename.
     */
    private function _listDirectory($directory, $extension = '')
    {
        if (empty($directory)) {
            return array();
        }
        $filenames = array();
        $paths = new DirectoryIterator($directory);
        foreach ($paths as $file) {
            if (!$file->isDot()
                    && !$file->isDir()
                    && $file->isReadable()
                    && pathinfo($file->getFilename(), PATHINFO_EXTENSION) == $extension
                ) {
                $filenames[$file->getPathname()] = $file->getFilename();
            }
        }

        // Sort the files by filenames.
        natcasesort($filenames);
        return $filenames;
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
