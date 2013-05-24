Xml Import (plugin for Omeka)
=============================


Summary
-------

This plugin for [Omeka] allows to import data and files from one or multiple XML
files via a generic or a custom XSLT sheet.

Process uses [Csv Import], so all imports can be managed in one place.

This release allows import of metadata of files. To use this feature, you need
to install the [Full Csv Import] fork.


Installation
------------

Install the plugin [Csv Import] or [Full Csv Import], then install the
[Xml Import] plugin: uncompress files and rename plugin folder "XmlImport",
then follow the config instructions.


Examples
--------

Two examples of xml files are available in the xml_files folder:

* `test_item.xml`: a basic list of three books with images of Wikipedia, with
non Dublin Core tags.
* `test_automap_item.xml`: the same list with some Dublin Core attributes in
order to automap the xml tags with the Omeka fields.

To try them, you need to choose options "One xml file", "Item metadata", the
type "Text" for the first file and "Hyperlink" for the second and the xsl sheet
`xml_import_generic_for_item.xsl`.

Two other sheets are available:

* `omeka_xml_output_v4.1_item.xsl`
* `omeka_xml_output_v4.1_report.xsl`

They allow to import Omeka Xml output files (version 4.0 and 4.1, included in
Omeka 1.5), that you can get when you export your records to this format (simply
click on the link at the bottom of the admin/items page, or on the link in each
item page).
_Warning_: Currently, these sheets can manage repeatable fields only for tags
and files.

If your xsl sheet builds a csv file with CsvReport format, you can import it
directly without mapping. This format is useful too if you want to import
multiple types of documents (text, image, video...) in one time.

These xsl sheet can be chained or adapted to any needs and xml formats.

Import of files metadata is possible only with the [Full Csv Import] fork.


Warning
-------

Use it at your own risk.

It's always recommended to backup your database so you can roll back if needed.


Troubleshooting
---------------

See online issues on the [Xml Import issues] page on GitHub.


License
-------

This plugin is published under [Apache licence v2].


Contact
-------

Current maintainers:

* Daniel Berthereau (see [Daniel-KM])
* Scholars' Lab (see [Scholars' Lab])

First version of this plugin has been built by [Ethan Gruber] for [Scholars' Lab]
of University of Virginia Library (see [Scholars' Lab Omeka plugins] page).
This plugin has been updated for [École des Ponts ParisTech]) and [Pop Up Archive]).


Copyright
---------

* Copyright Daniel Berthereau, 2012-2013
* Copyright Scholars' Lab, 2010 (GenericXmlImporter v1.0)

[Omeka]: https://omeka.org "Omeka.org"
[Csv Import]: https://github.com/omeka/plugin-CsvImport "Omeka plugin Csv Import"
[Full Csv Import]: https://github.com/Daniel-KM/CsvImport "Full Csv Import"
[Xml Import issues]: https://github.com/Daniel-KM/XmlImport/Issues "GitHub Xml Import"
[Apache licence v2]: https://www.apache.org/licenses/LICENSE-2.0.html
[Daniel-KM]: https://github.com/Daniel-KM "Daniel Berthereau"
[Ethan Gruber]: mailto:ewg4x@virginia.edu
[Scholars' Lab]: https://github.com/scholarslab
[Scholars' Lab Omeka plugins]: http://www.scholarslab.org/research/omeka-plugins/ "Omeka plugins of Scholars' Lab of University of Virginia Library"
[École des Ponts ParisTech]: http://bibliotheque.enpc.fr "École des Ponts ParisTech / ENPC"
[Pop Up Archive]: http://popuparchive.org/
