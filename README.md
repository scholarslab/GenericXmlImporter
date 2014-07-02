Xml Import (plugin for Omeka)
=============================


Summary
-------

This plugin for [Omeka] allows to import data and files and to update records
from one or multiple XML files via a generic or a custom XSLT sheet. It's
usefull to import documents and records from other places or from an older
installation of Omeka.

Process uses [Csv Import], so all imports can be managed in one place.

Currently, to import metadata of files and to update records, the
[Csv Import Full] fork should be used.


Installation
------------

Install the plugin [Csv Import] or [Csv Import Full], then install the
[Xml Import] plugin: uncompress files and rename plugin folder "XmlImport",
then follow the config instructions.


Examples
--------

Three examples of xml files are available in the xml_files folder:

* `test_generic_item.xml`: a basic list of three books with images of Wikipedia,
with non Dublin Core tags.
* `test_generic_item_automap.xml`: the same list with some Dublin Core
attributes in order to automap the xml tags with the Omeka fields.
* `test_omeka_xml_output_v5.xml`: an export of two different items with files and
files metadata.

To try the first two, choose options "One xml file", "Item metadata", the type
"Text" for the first file and "Hyperlink" for the second and the xsl sheet
`xml_import_generic_for_item.xsl`.

To try the last, use one of the three other sheets:

* `omeka_xml_output_v4_report.xsl`
* `omeka_xml_output_v4_item.xsl`
* `omeka_xml_output_v5_mixed.xsl`

They allow to import Omeka Xml output files (version 4.0 and 4.1, included in
Omeka 1.5, and version 5.0, included in Omeka 2.0), that you can get when you
export your records to this format (simply click on the link at the bottom of
the admin/items page, or on the link in each item page). The last one is
recommanded with light or heavy and simple or complex data. First sheets don't
manage files metadata. Collections should be created before import (none in the
xml test files). Note that Omeka 1.5 outputs only urls of fullsize files, so you
may change them before import.

If your xsl sheet builds a csv file with "Csv Report" or "Mixed records" format,
you can import it directly without mapping. The second format can be used only
with the [Csv Import Full] fork. These formats are useful too if you want to
import multiple types of documents (text, image, video...) and their metadata in
one time.

Import of files metadata and update of records are possible only with the
[Csv Import Full] fork.

These xsl sheets can be chained or adapted to any needs and xml formats.

Note about delimiters:
As Xml Import uses Csv Import, delimiters are used. Recommended delimiters are
special characters allowed in xml 1.0: tabulation "\t" for column delimiter,
carriage return "\r"  for element, tag and file delimiters, with the Unix end
of line "\n" (line feed).
If fields contain paragraphs, another element delimiter should be used,
preferably another Ascii character, like pipe "|".


Warning
-------

Use it at your own risk.

It's always recommended to backup your files and database so you can roll back
if needed.


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
This plugin has been updated for [École des Ponts ParisTech], [Pop Up Archive]
and [Mines ParisTech].


Copyright
---------

* Copyright Daniel Berthereau, 2012-2014
* Copyright Scholars' Lab, 2010 (GenericXmlImporter v1.0)


[Omeka]: https://omeka.org "Omeka.org"
[Csv Import]: https://github.com/omeka/plugin-CsvImport "Omeka plugin Csv Import"
[Csv Import Full]: https://github.com/Daniel-KM/CsvImport "Csv Import Full"
[Xml Import issues]: https://github.com/Daniel-KM/XmlImport/Issues "GitHub Xml Import"
[Apache licence v2]: https://www.apache.org/licenses/LICENSE-2.0.html
[Daniel-KM]: https://github.com/Daniel-KM "Daniel Berthereau"
[Ethan Gruber]: mailto:ewg4x@virginia.edu
[Scholars' Lab]: https://github.com/scholarslab
[Scholars' Lab Omeka plugins]: http://www.scholarslab.org/research/omeka-plugins/ "Omeka plugins of Scholars' Lab of University of Virginia Library"
[École des Ponts ParisTech]: http://bibliotheque.enpc.fr "École des Ponts ParisTech / ENPC"
[Pop Up Archive]: http://popuparchive.org/
[Mines ParisTech]: http://bib.mines-paristech.fr "Mines ParisTech / ENSMP"
