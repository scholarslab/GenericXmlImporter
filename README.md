Xml Import (plugin for Omeka)
=============================


[Xml Import] is a plugin for [Omeka] that allows to import data and files and to
update records from one or multiple XML files via a generic or a custom XSLT
sheet. It's usefull to import documents and records from other places or from an
older installation of Omeka.

Process uses [Csv Import], so all imports can be managed in one place.

Currently, to import metadata of extra data of collections, items or files and
to update any records, the [Csv Import Full] fork should be used.


Installation
------------

Install first the plugin [Csv Import] or [Csv Import Full].

Then uncompress files and rename plugin folder "XmlImport".

Then install it like any other Omeka plugin and follow the config instructions.


Examples
--------

Seven examples of xml files are available in the xml_files folder. They are
many because a new one is built for each new feature. The last ones uses all of
them.

Some files may be updated with a second file to get full data. This is just to
have some examples.

1. `test_generic_item.xml`

    A basic list of three books with images of Wikipedia, with non Dublin Core
    tags. To try it, choose options "One xml file", "Item metadata", and the xsl
    sheet `generic_item.xsl`.

2. `test_generic_item_automap.xml`

    The same list with some Dublin Core attributes in order to automap the xml
    tags with the Omeka fields. Parameters are the same than the previous file,
    but you may delete previous import before this one.

3. `test_omeka_xml_output_v5.xml`

    An export of two different items with files and files metadata. To try it,
    use one of the three other sheets: `omeka_xml_output_v4_report.xsl`,
    `omeka_xml_output_v4_item.xsl`, `omeka_xml_output_v5_mixed.xsl` and the
    format "Mixed".

    They allow to import Omeka Xml output files (version 4.0 and 4.1, included
    in Omeka 1.5, and version 5.0, included in Omeka 2.0), that you can get
    when you export your records to this format (simply click on the link at
    the bottom of the admin/items page, or on the link in each item page). The
    last one is recommanded with light or heavy and simple or complex data.
    First sheets don't manage files metadata. Collections should be created
    before import (none in the xml test files). Note that Omeka 1.5 outputs only
    urls of fullsize files, so you may change them before import.

4. `test_mixed.xml`

5. `test_mixed_update.xml`

    A full example of all features of [Csv Import Full] via Xml, and file to
    update the previous one.

    To try them, use format "Mixed" for the first and "Update" for the second,
    check the options "Create collections" and "Contains extra data" and the xsl
    sheet `advanced_mixed.xsl`. If [Geolocation] is installed, it will be used
    to set the location of items.

6. `test_manage_from_mixed.xml`

7. `test_mixed_update.xml`

    These files contain the same data than the two previous ones, but they are
    adapted for the format "Manage". Formats "Mixed" and "Update" are deprecated
    in [Csv Import Full], so this one is recommended. It's simpler and allows
    import, update and remove with the same file and the same sheet. To import
    them, remove previous data and use the sheet `advanced_manage.xsl`.

If your xsl sheet builds a csv file with "Csv Report", "Mixed records" or
"Manage" format, they can be  imported directly without mapping. "Mixed" and
"Manage" formats can be used only with the [Csv Import Full] fork. These formats
are useful to import multiple types of documents (text, image, video...) and
their metadata in one time.

Import of files metadata and update of records are possible only with the
[Csv Import Full] fork.

These xsl sheets can be chained or adapted to any needs and xml formats.

Note about delimiters:
As Xml Import uses Csv Import, delimiters are used. Recommended delimiters are
special characters allowed in xml 1.0: tabulation "\t" for column delimiter,
carriage return "\r"  for element, tag and file delimiters, with the Unix end
of line "\n" (line feed). They can be used with an empty enclosure.
If fields contain paragraphs, another element delimiter should be used,
preferably another Ascii character, like pipe "|".


Warning
-------

Use it at your own risk.

It's always recommended to backup your files and database regularly so you can
roll back if needed.


Troubleshooting
---------------

See online issues on the [plugin issues] page on GitHub.


License
-------

This plugin is published under [Apache licence v2].


Contact
-------

Current maintainers:

* Daniel Berthereau (see [Daniel-KM])
* [Scholars' Lab]

First version of this plugin has been built by [Ethan Gruber] for [Scholars' Lab]
of University of Virginia Library (see [Scholars' Lab Omeka plugins] page).
This plugin has been updated for [École des Ponts ParisTech], [Pop Up Archive]
and [Mines ParisTech].


Copyright
---------

* Copyright Daniel Berthereau, 2012-2015
* Copyright Scholars' Lab, 2010 (GenericXmlImporter v1.0)


[Omeka]: https://omeka.org
[Csv Import]: https://github.com/omeka/plugin-CsvImport
[Csv Import Full]: https://github.com/Daniel-KM/CsvImport
[Geolocation]: http://omeka.org/add-ons/plugins/geolocation
[plugin issues]: https://github.com/Daniel-KM/XmlImport/Issues
[Apache licence v2]: https://www.apache.org/licenses/LICENSE-2.0.html
[Daniel-KM]: https://github.com/Daniel-KM "Daniel Berthereau"
[Ethan Gruber]: mailto:ewg4x@virginia.edu
[Scholars' Lab]: https://github.com/scholarslab
[Scholars' Lab Omeka plugins]: http://www.scholarslab.org/research/omeka-plugins/
[École des Ponts ParisTech]: http://bibliotheque.enpc.fr
[Pop Up Archive]: http://popuparchive.org/
[Mines ParisTech]: http://bib.mines-paristech.fr
