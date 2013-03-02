
Xml Import (plugin for Omeka) [files_metadata branch]
=============================


Summary
-------

This plugin allows to import data and files from one or multiple XML files via
a generic or a custom XSLT sheet.

Process uses CsvImport, so all imports can be managed in one place.

This release is a branch of the original plugin that allows import of metadata
of files. It requires a fork of CsvImport (see [CsvImport fork][1]).

For more information on Omeka, see [Omeka][2].


Installation
------------

Install CsvImport ([original][3] or [fork][1], depending on the version of
XmlImport you use).

Uncompress files and rename plugin folder "XmlImport".

Then install it like any other Omeka plugin and follow the config instructions.


Warning
-------

Use it at your own risk.

It's always recommended to backup your database so you can roll back if needed.


Troubleshooting
---------------

See online issues on [GitHub][4].


License
-------

This plugin is published under [Apache licence v2][5].


Contact
-------

Current maintainers:

* Daniel Berthereau (see [Daniel-KM][6])
* Scholars' Lab (see [Scholars' Lab][7])

First version of this plugin has been built by [Scholars' Lab of University of Virginia Library][8].
This plugin has been updated for [ENPC / École des Ponts ParisTech][9]) and [Pop Up Archive][10]).


Copyright
---------

* Copyright Daniel Berthereau, 2012-2013
* Copyright Scholars' Lab, 2010 [GenericXmlImporter v1.0]


[1]: https://github.com/Daniel-KM/CsvImport "CsvImport fork"
[2]: https://omeka.org "Omeka.org"
[3]: https://github.com/omeka/plugin-CsvImport "Omeka plugin CsvImport"
[4]: https://github.com/Daniel-KM/XmlImport/Issues "GitHub XmlImport"
[5]: https://www.apache.org/licenses/LICENSE-2.0.html "Apache licence v2"
[6]: https://github.com/Daniel-KM "Daniel Berthereau"
[7]: https://github.com/scholarslab "Scholars' Lab"
[8]: http://www.scholarslab.org/research/omeka-plugins/ "Scholars' Lab of University of Virginia Library"
[9]: http://bibliotheque.enpc.fr "École des Ponts ParisTech"
[10]: http://popuparchive.org/ "Pop Up Archive"
