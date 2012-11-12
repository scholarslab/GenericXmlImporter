<?xml version="1.0" encoding="UTF-8"?>
<!--
    Document : omeka-xml-output-v4-1_to_omeka-csv-report-bibnumponts.xsl
    Created date : 11/11/2012
    Version : 1.0
    Auteur : Daniel Berthereau pour l'École des Ponts (http://bibliotheque.enpc.fr)
    Description : Convertit un fichier refNum en Dublin Core au format Omeka CSV Report.

    Notes
    - This sheet should be used with XmlImport 1.6-files_metadata and CsvImport 1.3.4-fork-1.7.
    - This sheet is compatible with Omeka Xml output 4.0.
    - This sheet doesn't manage html fields (neither Omeka Csv Import).
    - This sheet doesn't manage direct repetition of fields, except tags and files. You need to add specific rules ("^^" is the separator of multivalued fields).
    
    Notes de contenu
    Cette feuille XSLT respecte au plus près le format refNum de la Bibliothèque nationale de France ((http://bibnum.bnf.fr/refNum/). Toutefois, elle presente certaines particularités pour trois raisons.
    * Les fichiers fournis par les prestataires ne contiennent pas tous les champs du format refNum et certains sont mal transcrits.
    * Le système et les besoins pour la bibliothèque numérique de l'École des Ponts sont également spécifiques.
    * Le principe de numérisation de l'École des Ponts est d'une image unique par objet, même de grand format. Aucun test n'a été fait au cas où un objet à plusieurs images.
    * Certains codes refNum sont convertis afin d'être directement utilisables par Omeka, sachant que les fichiers refNum initiaux peuvent toujours être utilisés pour d'autres traitements.
    * La feuille importe également les fichiers associés éventuels d'OCR Alto et le convertit en texte brut, sans saut de ligne.
    Le plugin XmlImport permet de gérer ces spécificités, notamment par le biais des paramètres.
    
    Remarques
    - Tous les champs sont inclus, sauf référence et historique. Certains champs sont inclus pour information et ne sont en fait pas importés dans Omeka.
    - Certains sont répétitifs selon refNum, mais ne le sont jamais en pratique en raison des spécifications demandées lors de la numérisation (structure/commentaire...).
    - Le champ "tomaison" (type / valeur) est unifié en un seul champ en raison des limitations d'Omeka.
    - Le champ Genre est modifié : "Monographie" devient "Monographie imprimée", etc.
    - Le mot "Pages : " est ajouté au champ nombre de pages puisqu'il sera associé à dc:format.
    - Pour la Structure, seuls les noms des fichiers sont récupérés ; les autres métadonnées sont mises à jour lors de l'import.
    - Les objets associés, notamment les fichiers Alto, ne sont pas pris encore en charge par cette feuille.
    - Pour les fichiers, l'Url complète est du type http://mondomaine.com/mon_serveur/Cours/ENPC02_COU_4_19539_1893/ENPC02_COU_4_19539_1893_0001.jpg.
    - L'utilisation du plugin Archive Repertory permet de conserver le vrai nom des fichiers :
        - Sans plugin, l'Url des fichier sera http://mondomaine.com/archive/files/hash_qoehvvbcnlojcxwjytzb.jpg.
        - Avec plugin, elle sera http://mondomaine.com/archive/files/Cours/ENPC02_COU_4_19539_1893/ENPC02_COU_4_19539_1893_0001.jpg.
    - Compte tenu du contenu des fichiers refNum des prestataires, certains noms de fichiers doivent être modifiés. En pratique, seuls les liens incomplets vers les fichiers sont renommés (cf. infra).
-->

<xsl:stylesheet version="1.1"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:php="http://php.net/xsl"
    xmlns:omeka="http://omeka.org/schemas/omeka-xml/v4"
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:refNum="http://bibnum.bnf.fr/ns/refNum"
    xmlns:alto="http://bibnum.bnf.fr/ns/alto_prod">
<xsl:output method="text"
    media-type="text/csv"
    encoding="UTF-8"
    omit-xml-declaration="yes"/>

<!-- Parameters -->
<!-- Default delimiter. -->
<!-- Warning: Tabulation by default, because it never appears in current files, but CsvImport doesn't allow it by default. -->
<xsl:param name="delimiter"><xsl:text>&#x09;</xsl:text></xsl:param>
<!-- Default enclusure. -->
<!-- No enclusure is needed when tabulation is used. -->
<xsl:param name="enclosure"></xsl:param>
<!-- Default delimiter for multivalued fields. -->
<!-- Warning: Currently, CsvImport doesn't allow a specific delimiter for multivalued fields. -->
<xsl:param name="delimiter_multivalues">,</xsl:param>
<!-- CsvImport uses a different delimiter for the Csv Report format (except for tags and files). -->
<xsl:param name="delimiter_multivalues_csvreport">^^</xsl:param>
<!-- Default end of line. -->
<xsl:param name="end_of_line">Linux</xsl:param>
<!-- Headers are added by default. -->
<xsl:param name="headers">true</xsl:param>
<!-- Omeka main element sets. -->
<xsl:param name="omeka_sets_file">omeka_sets_bibnumponts.xml</xsl:param>
<!-- User specific element sets. -->
<xsl:param name="user_sets_file">user_sets_bibnumponts.xml</xsl:param>
<!-- Use full path (fullpath) or base name (basename) as original name of attached files. -->
<!-- Utilisation du module Archive Repertory qui reprend aussi le basename. -->
<xsl:param name="original_filename">fullpath</xsl:param>

<!-- Default choices. --> 
<xsl:param name="item_type">Document</xsl:param>
<xsl:param name="collection"></xsl:param>
<xsl:param name="public">1</xsl:param>
<xsl:param name="featured">1</xsl:param>

<!-- CsvImport ne prend pas directement en compte les fichiers locaux : il faut donc utiliser un lien ou un montage sur le serveur. -->
<!-- <xsl:param name="chemin_source">http://127.0.0.1/images</xsl:param> -->
<!-- <xsl:param name="chemin_source">http://127.0.0.1/_gandi/images_originales/Phares</xsl:param> -->
<xsl:param name="chemin_source">http://127.0.0.1/_gandi/images_originales/Patrimoine/Phares</xsl:param>
<!-- Utilisation de la fonction de renommage -->
<xsl:param name="renommage_fichier">true</xsl:param>
<!-- Préfixe à ajouter pour identifier le document -->
<xsl:param name="préfixe_identifiant">document:</xsl:param>
<!-- Copyright du document papier. -->
<xsl:param name="copyright">Domaine public (original papier)</xsl:param>
<!-- Copyright pour les images numériques. -->
<xsl:param name="copyright_2">École Nationale des Ponts et Chaussées (image numérisée)</xsl:param>
<!-- Chemin source pour le renvoi vers la notice du catalogue. -->
<xsl:param name="chemin_source_catalogue">http://bibliotheque.enpc.fr/document/</xsl:param>

<!-- Constantes -->
<xsl:variable name="line_start">
    <xsl:value-of select="$enclosure"/>
</xsl:variable>
<xsl:variable name="separator">
    <xsl:value-of select="$enclosure"/>
    <xsl:value-of select="$delimiter"/>
    <xsl:value-of select="$enclosure"/>
</xsl:variable>
<xsl:variable name="line_end">
    <xsl:value-of select="$enclosure"/>
    <xsl:choose>
        <xsl:when test="$end_of_line = 'Linux'">
            <xsl:text>&#x0A;</xsl:text>
        </xsl:when>
        <xsl:when test="$end_of_line = 'Mac'">
            <xsl:text>&#x0D;</xsl:text>
        </xsl:when>
        <xsl:when test="$end_of_line = 'Windows'">
            <xsl:text>&#x0D;&#x0A;</xsl:text>
        </xsl:when>
    </xsl:choose>
</xsl:variable>
<!-- Omeka element sets. -->
<xsl:variable name="omeka_sets" select="document($omeka_sets_file)"/>
<!-- User element sets. -->
<xsl:variable name="user_sets" select="document($user_sets_file)"/>

<!-- Permet la mise en minuscule du type de fichier (xslt 1.0) -->
<xsl:variable name="majuscule" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'" />
<xsl:variable name="minuscule" select="'abcdefghijklmnopqrstuvwxyz'" />
<!-- Liste des codes utilisés dans refNum. -->
<xsl:variable name="refNum_codes" select="document('refNum_codes.xml')"/>

<!-- Main template -->
<xsl:template match="/refNum:refNum">
    <xsl:if test="$headers = 'true'">
        <xsl:value-of select="$line_start"/>
        <xsl:text>recordType</xsl:text>

        <!-- For all items and files. -->
        <xsl:value-of select="$separator"/>
        <xsl:text>itemId</xsl:text>

        <!-- Specific columns of items. -->
        <xsl:value-of select="$separator"/>
        <xsl:text>itemType</xsl:text>
        <xsl:value-of select="$separator"/>
        <xsl:text>collection</xsl:text>
        <xsl:value-of select="$separator"/>
        <xsl:text>public</xsl:text>
        <xsl:value-of select="$separator"/>
        <xsl:text>featured</xsl:text>
        <xsl:value-of select="$separator"/>
        <xsl:text>tags</xsl:text>
        <!-- Note: Files are now imported individually, on separated lines. This field is kept for compatibility purpose. It will be removed in a future release. -->
        <xsl:value-of select="$separator"/>
        <xsl:text>file</xsl:text>

        <!-- Specific columns of files. -->
        <xsl:value-of select="$separator"/>
        <xsl:text>fileId</xsl:text>
        <xsl:value-of select="$separator"/>
        <xsl:text>fileSource</xsl:text>
        <xsl:value-of select="$separator"/>
        <xsl:text>fileOrder</xsl:text>

        <!-- All metadata headers. -->
        <xsl:call-template name="element_sets"/>

        <xsl:value-of select="$line_end"/>
    </xsl:if>

    <xsl:apply-templates/>
</xsl:template>

<!-- Row for each item. -->
<xsl:template match="/refNum:refNum/refNum:document">
    <xsl:value-of select="$line_start"/>
    <xsl:text>Item</xsl:text>

    <!-- For all items and files. -->
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="@identifiant"/>

    <!-- Specific columns of items. -->
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="$item_type"/>
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="$collection"/>
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="$public"/>
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="$featured"/>
    <!-- Specific multivalued columns of items. -->
    <xsl:value-of select="$separator"/>
    <!-- Note: Files are now imported individually, on separated lines, so we don't call item_files any more. This field will be removed in a future release. -->
    <!-- <xsl:call-template name="item_files" /> -->
    <xsl:value-of select="$separator"/>

    <!-- Nothing for columns specific to files. -->
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="$separator"/>

    <!-- Metadata of items. -->
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="$préfixe_identifiant"/>
    <xsl:value-of select="@identifiant"/>

    <xsl:value-of select="$separator"/>
    <xsl:choose>
        <xsl:when test="refNum:bibliographie/refNum:genre = 'MONOGRAPHIE'">
            <xsl:text>Monographie imprimée</xsl:text>
        </xsl:when>
        <xsl:when test="refNum:bibliographie/refNum:genre = 'PERIODIQUE'">
            <xsl:text>Publication en série imprimée</xsl:text>
        </xsl:when>
        <xsl:when test="refNum:bibliographie/refNum:genre = 'LOT'">
            <xsl:text></xsl:text>
        </xsl:when>
        <xsl:otherwise>
            <xsl:value-of select="refNum:bibliographie/refNum:genre"/>
        </xsl:otherwise>
    </xsl:choose>
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="normalize-space(refNum:bibliographie/refNum:titre)"/>
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="refNum:bibliographie/refNum:auteur"/>
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="normalize-space(refNum:bibliographie/refNum:description)"/>
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="refNum:bibliographie/refNum:editeur"/>
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="refNum:bibliographie/refNum:dateEdition"/>
    
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="$copyright"/>
    <xsl:value-of select="$delimiter_multivalues_csvreport"/>
    <xsl:value-of select="$copyright_2"/>

    <!-- Tomaison variant entre 0 et 3 dans refNum , une colonne multivaluée est utilisée. -->
    <xsl:value-of select="$separator"/>
    <xsl:variable name="format_refnum">
        <xsl:if test="refNum:bibliographie/refNum:tomaison[1]">
            <xsl:value-of select="refNum:bibliographie/refNum:tomaison[1]/refNum:type"/>
            <xsl:text> : </xsl:text>
            <xsl:value-of select="refNum:bibliographie/refNum:tomaison[1]/refNum:valeur"/>
            <xsl:value-of select="$delimiter_multivalues_csvreport"/>
        </xsl:if>
        <xsl:if test="refNum:bibliographie/refNum:tomaison[2]">
            <xsl:value-of select="refNum:bibliographie/refNum:tomaison[2]/refNum:type"/>
            <xsl:text> : </xsl:text>
            <xsl:value-of select="refNum:bibliographie/refNum:tomaison[2]/refNum:valeur"/>
            <xsl:value-of select="$delimiter_multivalues_csvreport"/>
        </xsl:if>
        <xsl:if test="refNum:bibliographie/refNum:tomaison[3]">
            <xsl:value-of select="refNum:bibliographie/refNum:tomaison[3]/refNum:type"/>
            <xsl:text> : </xsl:text>
            <xsl:value-of select="refNum:bibliographie/refNum:tomaison[3]/refNum:valeur"/>
            <xsl:value-of select="$delimiter_multivalues_csvreport"/>
        </xsl:if>
        <xsl:if test="refNum:bibliographie/refNum:nombrePages != ''">
            <!-- Le mot Pages est ajouté, car cela serait incompréhensible dans dc:format. -->
            <xsl:text>Pages : </xsl:text>
            <xsl:value-of select="refNum:bibliographie/refNum:nombrePages"/>
            <xsl:value-of select="$delimiter_multivalues_csvreport"/>
        </xsl:if>
        <xsl:if test="refNum:production/refNum:nombreImages != ''">
            <!-- Le mot Images est ajouté, car cela serait incompréhensible dans dc:format. -->
            <xsl:text>Images : </xsl:text>
            <xsl:value-of select="refNum:production/refNum:nombreImages"/>
            <xsl:value-of select="$delimiter_multivalues_csvreport"/>
        </xsl:if>
    </xsl:variable>
    <xsl:if test="$format_refnum != ''">
        <xsl:value-of select="substring($format_refnum, 1, string-length($format_refnum) - string-length($delimiter_multivalues_csvreport))"/>
    </xsl:if>

    <!-- Source et relation ne sont actuellement pas remplies, car les url sur Cadic ne sont pas propres. Elle est mise à jour par OAI-PMH. -->
    <xsl:value-of select="$separator"/>
    <!-- <xsl:value-of select="@identifiant"/> -->
    <xsl:value-of select="$separator"/>
    <!-- <xsl:value-of select="$chemin_source_catalogue"/> -->
    <!-- <xsl:value-of select="@identifiant"/> -->
        
    <!-- Non utilisé dans les fichiers de numérisation de l'ENPC. -->
    <!--
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="refNum:bibliographie/refNum:reference"/>
    -->
    
    <xsl:value-of select="$separator"/>
    <!-- Ce champ n'est pas rempli correctement dans les fichiers refNum d'un prestataire (un espace et/ou un saut de ligne en trop). -->
    <xsl:value-of select="normalize-space(refNum:production/refNum:dateNumerisation)"/>
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="refNum:production/refNum:nombreVueObjets"/>
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="refNum:production/refNum:identifiantSupport"/>
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="refNum:production/refNum:objetAssocie"/>
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="refNum:production/refNum:objetAssocie/@date"/>

    <!-- Non utilisé dans les fichiers de numérisation de l'ENPC. -->
    <!--
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="refNum:production/refNum:historique"/>
    -->
    
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="refNum:structure/refNum:commentaire/@type"/>
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="refNum:structure/refNum:commentaire/@date"/>
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="normalize-space(refNum:structure/refNum:commentaire)"/>

	<!-- Éléments pour les fichiers. -->
	<!-- Éléments du standard "Omeka Image File". -->
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="$separator"/>

	<!-- Éléments du standard refNum. -->
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="$separator"/>

    <xsl:value-of select="$line_end"/>

    <!-- Apply templates for files. -->
    <xsl:apply-templates/>
</xsl:template>

<!-- Row for each attached file of an item. -->
<xsl:template match="/refNum:refNum/refNum:document/refNum:structure/refNum:vueObjet">
    <xsl:variable name = "urlImage">
        <xsl:call-template name="url_image" />
    </xsl:variable>

    <xsl:variable name="nomPage">
        <xsl:call-template name="nom_page"/>
    </xsl:variable>

    <xsl:variable name = "identifiantImage">
        <xsl:call-template name="nom_image" />
    </xsl:variable>

    <!-- Détermine l'url du fichier alto associé, s'il existe, même si l'existence du fichier n'est pas indiqué dans le refNum. -->
    <xsl:variable name="url_fichier_alto">
        <xsl:call-template name="retourne_url_fichier_alto"/>
    </xsl:variable>

    <xsl:value-of select="$line_start"/>
    <xsl:text>File</xsl:text>

    <!-- For all items and files. -->
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="ancestor::refNum:document/@identifiant"/>

    <!-- Nothing for columns specific to items. -->
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="$separator"/>
    <!-- Note: This field will be removed in a future release. -->
    <xsl:value-of select="$separator"/>

    <!-- Specific columns of files. -->
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="refNum:image/@nomImage"/>
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="$urlImage"/>
    <!-- Les documents contiennent une seule image par objet. -->
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="@ordre"/>

    <!-- Metadata for all. -->
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="$identifiantImage"/>
    <xsl:value-of select="$separator"/>

    <xsl:value-of select="$separator"/>
    <xsl:value-of select="concat(translate(substring($nomPage, 1, 1), $minuscule, $majuscule), substring($nomPage, 2))"/>
    <xsl:text> (document </xsl:text>
    <xsl:value-of select="../../@identifiant"/>
    <xsl:text>, image </xsl:text>
    <xsl:value-of select="@ordre"/>
    <xsl:text>)</xsl:text>
    
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="$separator"/>
    
    <!-- Metadata for items. -->
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="$separator"/>
    
    <!-- Metadata for files. -->
    <!-- Metadata for Omeka Image File. -->
    <!-- Automatically created during import. -->
    
    <!-- Métadonnées refNum. -->
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="ancestor::refNum:document/@identifiant"/>
    
    <xsl:value-of select="$separator"/>
    <xsl:variable name="typePage" select="@typePage"/>
    <xsl:value-of select="$refNum_codes/XMLlist/typePage/entry[@code = $typePage]"/>
        
    <xsl:value-of select="$separator"/>
    <xsl:variable name="typePagination" select="@typePagination"/>
    <xsl:value-of select="$refNum_codes/XMLlist/typePagination/entry[@code = $typePagination]"/>

    <xsl:value-of select="$separator"/>
    <xsl:if test="@typePagination != 'N'">
        <xsl:value-of select="@numeroPage"/>
    </xsl:if>

    <xsl:value-of select="$separator"/>
    <xsl:value-of select="$nomPage"/>
        
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="@ordre"/>
      
    <xsl:value-of select="$separator"/>
    <xsl:variable name="supportOrigine" select="refNum:image/@supportOrigine"/>
    <xsl:value-of select="$refNum_codes/XMLlist/supportOrigine/entry[@code = $supportOrigine]"/>
    
    <xsl:value-of select="$separator"/>
    <!-- Ce champ n'est pas rempli correctement dans les fichiers refNum d'un prestataire (un espace et/ou un saut de ligne en trop). -->
    <xsl:value-of select="normalize-space(../../refNum:production/refNum:dateNumerisation)"/>

    <!-- Gestion d'un seul objet associé. -->
    <xsl:value-of select="$separator"/>
    <!-- Ce champ n'est pas rempli par l'un des prestataires. Il faut donc s'appuyer sur l'adresse du fichier associé. -->
    <!-- <xsl:value-of select="../../refNum:production/refNum:objetAssocie"/> -->
    <!-- Actuellement, seuls des fichiers Alto sont associés pour certains documents. -->
    <xsl:choose>
        <xsl:when test="boolean(document($url_fichier_alto))">
            <xsl:text>ALTO</xsl:text>
        </xsl:when>
    </xsl:choose>

    <xsl:value-of select="$separator"/>
    <!-- Récupération intégrale du fichier associé. -->
    <xsl:if test="boolean(document($url_fichier_alto))">
        <!-- TODO (actuellement, seul le texte brut est extrait, cf. champ ci-dessous). -->
        <!-- Charge le fichier alto et le copie intégralement. -->
        <!-- Supprime les sauts de ligne du fichier alto pour pouvoir le charger en CSV (sans problème compte tenu des données disponibles dans un fichier Alto).-->
    </xsl:if>
        
   <!-- Statistiques OCR -->
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="substring-after(document($url_fichier_alto)/alto:alto/alto:Description/alto:OCRProcessing[last()]/alto:ocrProcessingStep/alto:processingStepDescription[1], 'OCR_TOTAL_NC=')"/>
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="substring-after(document($url_fichier_alto)/alto:alto/alto:Description/alto:OCRProcessing[last()]/alto:ocrProcessingStep/alto:processingStepDescription[2], 'OCR_TOTAL_NC_DICO=')"/>
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="substring-after(document($url_fichier_alto)/alto:alto/alto:Description/alto:OCRProcessing[last()]/alto:ocrProcessingStep/alto:processingStepDescription[3], 'OCR_TAUX_NC=')"/>
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="substring-after(document($url_fichier_alto)/alto:alto/alto:Description/alto:OCRProcessing[last()]/alto:ocrProcessingStep/alto:processingStepDescription[4], 'OCR_TOTAL_CAR=')"/>
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="substring-after(document($url_fichier_alto)/alto:alto/alto:Description/alto:OCRProcessing[last()]/alto:ocrProcessingStep/alto:processingStepDescription[5], 'OCR_TOTAL_CAR_DOUTE=')"/>
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="substring-after(document($url_fichier_alto)/alto:alto/alto:Description/alto:OCRProcessing[last()]/alto:ocrProcessingStep/alto:processingStepDescription[6], 'OCR_TAUX_CAR=')"/>
    
    <xsl:value-of select="$separator"/>
    <xsl:choose>
        <xsl:when test="boolean(document($url_fichier_alto))">
            <!-- Charge le fichier alto et extrait le texte brut sans saut de ligne. -->
            <xsl:apply-templates select="document($url_fichier_alto)"/>
        </xsl:when>
    </xsl:choose>
        
    <xsl:value-of select="$separator"/>
    <xsl:value-of select="substring-before(ancestor::refNum:document/@identifiant, '_')"/>
    
    <xsl:value-of select="$line_end"/>
</xsl:template>

<!-- Row for headers. -->
<xsl:template name="element_sets">
    <xsl:for-each select="$omeka_sets/XMLlist/elementSet">
        <xsl:for-each select="element">
            <xsl:value-of select="$separator"/>
            <xsl:value-of select="../@setName"/>
            <xsl:text>:</xsl:text>
            <xsl:value-of select="."/>
        </xsl:for-each>
    </xsl:for-each>
    <xsl:for-each select="$user_sets/XMLlist/elementSet">
        <xsl:for-each select="element">
            <xsl:value-of select="$separator"/>
            <xsl:value-of select="../@setName"/>
            <xsl:text>:</xsl:text>
            <xsl:value-of select="."/>
        </xsl:for-each>
    </xsl:for-each>
</xsl:template>

<!-- Helper to get last part of a string. -->
<xsl:template name="lastpart">
  <xsl:param name="string"/>
  <xsl:param name="character"/>
  <xsl:choose>
     <xsl:when test="contains($string, $character)">
          <xsl:call-template name="lastpart">
               <xsl:with-param name="string" select="substring-after($string, $character)"/>
               <xsl:with-param name="character" select="$character"/>
           </xsl:call-template>
     </xsl:when>
     <xsl:otherwise>
        <xsl:value-of select="$string"/>
     </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- Helper to get base name of a file path. -->
<xsl:template name="basename">
  <xsl:param name="path"/>
  <xsl:choose>
     <xsl:when test="contains($path, '/')">
        <xsl:call-template name="basename">
           <xsl:with-param name="path" select="substring-after($path, '/')"/>
        </xsl:call-template>
     </xsl:when>
     <xsl:when test="contains($path, '\')">
        <xsl:call-template name="basename">
           <xsl:with-param name="path" select="substring-after($path, '\')"/>
        </xsl:call-template>
     </xsl:when>
     <xsl:otherwise>
        <xsl:value-of select="$path"/>
     </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- Récupération et renommage du nom de fichier. -->
<!-- CsvImport a besoin d'une URL complète pour importer les fichiers. -->
<xsl:template name="url_image">
    <xsl:if test="$chemin_source">
        <xsl:value-of select="$chemin_source"/>
        <xsl:text>/</xsl:text>
    </xsl:if>
    <xsl:value-of select="ancestor::refNum:document/@identifiant"/>
    <xsl:text>/</xsl:text>
    <!--
        Le lien aux fichiers (champ nomImage) diffère selon le prestataire et la catégorie.
        Il faut changer uniquement les noms qui n'ont pas d'extension dans le refNum.
        Le paramètre renommage_fichier permet d'effectuer ce renommage ou non.
        Exemples :
        - Ne pas changer :
        Journal de mission ENPC01_Ms_0375 : ENPC01_Ms_0375_0001.jpg
        Journal de mission ENPC01_Ms_3312 : ENPC01_Ms_3312_0001.jpg
        Phare ENPC01_PH_230 : ENPC01_PH_230_P06.jpg
        Phare ENPC01_PH_663 : ENPC01_PH_663_G001_1873.jpg
        - Changer :
        Cours ENPC02_COU_4_19539_1893 : J0000001 => JENPC02_COU_4_19539_1893/J0000001.jpg
        Cours ENPC02_COU_4_29840_1938 : J0000001 => JENPC02_COU_4_29840_1938/J0000001.jpg
    -->
    
    <!-- Choix de l'utilisateur : renommage ou non. -->
    <xsl:choose>
        <xsl:when test="$renommage_fichier = 'true'">
            <xsl:choose>
                <!-- Pas de changement -->
                <xsl:when test="contains(refNum:image/@nomImage, '.')">
                    <xsl:value-of select="refNum:image/@nomImage"/>
                </xsl:when>
                <!-- Renommage en ajoutant un dossier (le nom de la notice et la première lettre du type de fichier) et l'extension du nom de fichier. -->
                <xsl:otherwise>
                    <xsl:value-of select="substring(refNum:image/@typeFichier, 1, 1)"/>
                    <xsl:value-of select="ancestor::refNum:document/@identifiant"/>
                    <xsl:text>/</xsl:text>
                    <xsl:value-of select="refNum:image/@nomImage"/>
                    <xsl:text>.</xsl:text>
                    <xsl:value-of select="translate(refNum:image/@typeFichier, $majuscule, $minuscule)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
            <xsl:value-of select="refNum:image/@nomImage"/>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<!--
    Le lien aux fichiers (champ nomImage) diffère selon le prestataire et la catégorie.
    Il faut changer uniquement les noms qui n'ont pas d'extension dans le refNum.
    Le paramètre renommage_fichier permet d'effectuer ce renommage ou non.
    Exemples :
    - Ne pas changer :
    Journal de mission ENPC01_Ms_0375 : ENPC01_Ms_0375_0001.jpg
    Journal de mission ENPC01_Ms_3312 : ENPC01_Ms_3312_0001.jpg
    Phare ENPC01_PH_230 : ENPC01_PH_230_P06.jpg
    - Changer :
    Cours ENPC02_COU_4_19539_1893 : J0000001 => ENPC02_COU_4_19539_1893_0001.jpg
    Cours ENPC02_COU_4_29840_1938 : J0000001 => ENPC02_COU_4_29840_1938_0001.jpg
    - Pas de gestion du cas ENPC01_PH_663_G001_1873.jpg, les documents n'étant pas importés.
    Phare ENPC01_PH_663 : ENPC01_PH_663_G001_1873.jpg => ENPC01_PH_663_1873_G001.jpg
-->
<xsl:template name="nom_image">
    <!-- Choix de l'utilisateur : renommage ou non. -->
    <xsl:choose>
        <xsl:when test="$renommage_fichier = 'true'">
            <xsl:choose>
                <!-- Pas de changement -->
                <xsl:when test="contains(refNum:image/@nomImage, '.')">
                    <xsl:value-of select="refNum:image/@nomImage"/>
                </xsl:when>
                <!-- Renommage en utilisant l'identifiant et le nom de fichier. -->
                <xsl:otherwise>
                    <xsl:value-of select="../../@identifiant"/>
                    <xsl:text>_</xsl:text>
                    <xsl:value-of select="substring(refNum:image/@nomImage, 5, 4)"/>
                    <xsl:text>.</xsl:text>
                    <xsl:value-of select="translate(refNum:image/@typeFichier, $majuscule, $minuscule)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
            <xsl:value-of select="refNum:image/@nomImage"/>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<!-- Template pour déterminer le numéro de page. -->
<xsl:template name="nom_page">
    <xsl:choose>
        <!-- Pagination en chiffres arabes. -->
        <xsl:when test="@typePagination = 'A'">
            <xsl:text>page </xsl:text>
            <xsl:value-of select="@numeroPage"/>
        </xsl:when>
        <!-- Pagination en chiffres romains. -->
        <xsl:when test="@typePagination = 'R'">
            <xsl:text>page </xsl:text>
            <xsl:number value="@numeroPage" format="I"/>
        </xsl:when>
        <!-- Foliotation. -->
        <xsl:when test="@typePagination = 'F'">
            <xsl:text>feuillet </xsl:text>
            <xsl:value-of select="@numeroPage"/>
            <xsl:text> (recto)</xsl:text>
        </xsl:when>
        <!-- Pagination autre. -->
        <xsl:when test="@typePagination = 'X'">
            <xsl:text>page </xsl:text>
            <xsl:value-of select="@numeroPage"/>
        </xsl:when>
        <!-- Dans tous les autres cas, la page est non paginée. -->
        <xsl:otherwise>
            <xsl:variable name="précédente_numérotée" select="(preceding-sibling::refNum:vueObjet[@typePagination != 'N'])[last()]"/>
            <xsl:variable name="suivante_numérotée" select="(following-sibling::refNum:vueObjet[@typePagination != 'N'])[1]"/>

            <xsl:choose>
                <!-- Pages initiales. -->
                <xsl:when test="not($précédente_numérotée)">
                    <!-- Exemple : si la première page numérotée est 3, on peut déduire que les deux précédentes sont 1 et 2. -->
                    <!-- Il ne peut pas y avoir de feuillet ici. -->
                    <xsl:choose>
                         <!-- Pagination en chiffres arabes. -->
                         <xsl:when test="($suivante_numérotée/@typePagination = 'A') and ($suivante_numérotée/@numeroPage > 1) and ($suivante_numérotée/@numeroPage + @ordre > $suivante_numérotée/@ordre)">
                              <xsl:text>page </xsl:text>
                              <xsl:value-of select="$suivante_numérotée/@numeroPage - $suivante_numérotée/@ordre + @ordre"/>
                              <xsl:text> (non paginée)</xsl:text>
                         </xsl:when>
                         <!-- Pagination en chiffres romain. -->
                         <xsl:when test="($suivante_numérotée/@typePagination = 'R') and ($suivante_numérotée/@numeroPage > 1) and ($suivante_numérotée/@numeroPage + @ordre > $suivante_numérotée/@ordre)">
                              <xsl:text>page </xsl:text>
                              <xsl:number value="$suivante_numérotée/@numeroPage - $suivante_numérotée/@ordre + @ordre" format="I"/>
                              <xsl:text> (non paginée)</xsl:text>
                         </xsl:when>
                         <!-- Impossible à déterminer, mais probablement la couverture et les pages de garde ; inutile d'aller plus loin. -->
                         <xsl:otherwise>
                             <xsl:text>image non paginée </xsl:text>
                             <xsl:value-of select="@ordre"/>
                         </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <!-- Foliotation. -->
               <xsl:when test="($précédente_numérotée/@typePagination = 'F') and ($précédente_numérotée/@ordre + 1 = @ordre)">
                    <xsl:text>feuillet </xsl:text>
                    <xsl:value-of select="$précédente_numérotée/@numeroPage"/>
                    <xsl:text> (verso)</xsl:text>
               </xsl:when>
                <!-- Pages finales : pas d'élément pour déterminer quelque chose. -->
                <xsl:when test="not($suivante_numérotée)">
                    <xsl:text>image non paginée </xsl:text>
                    <xsl:value-of select="@ordre"/>
                </xsl:when>
               <!-- La page se situe entre deux numéros et son numéro est déterminable avec une bonne probabilité. -->
               <!-- Pagination entre deux chiffres arabes, avec test de cohérence par comparaison de la précédente et de la suivante.. -->
               <xsl:when test="($précédente_numérotée/@typePagination = 'A') and ($suivante_numérotée/@typePagination = 'A') and ($suivante_numérotée/@numeroPage - $suivante_numérotée/@ordre = $précédente_numérotée/@numeroPage - $précédente_numérotée/@ordre)">
                    <xsl:text>page </xsl:text>
                    <xsl:value-of select="$suivante_numérotée/@numeroPage - $suivante_numérotée/@ordre + @ordre"/>
                    <xsl:text> (non paginée)</xsl:text>
               </xsl:when>
               <!-- Pagination entre deux chiffres romains, avec test de cohérence par comparaison de la précédente et de la suivante.. -->
               <xsl:when test="($précédente_numérotée/@typePagination = 'R') and ($suivante_numérotée/@typePagination = 'R') and ($suivante_numérotée/@numeroPage - $suivante_numérotée/@ordre = $précédente_numérotée/@numeroPage - $précédente_numérotée/@ordre)">
                    <xsl:text>page </xsl:text>
                    <xsl:number value="$suivante_numérotée/@numeroPage - $suivante_numérotée/@ordre + @ordre" format="I"/>
                    <xsl:text> (non paginée)</xsl:text>
               </xsl:when>
               <!-- Impossible à déterminer, sans doute avec du hors-texte. -->
               <xsl:otherwise>
                   <xsl:text>image non paginée </xsl:text>
                   <xsl:value-of select="@ordre"/>
               </xsl:otherwise>
           </xsl:choose>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template name="nom_type_pagination">
    <xsl:choose>
        <!-- Pagination en chiffres arabes. -->
        <xsl:when test="@typePagination = 'A'">
            <xsl:text>Page </xsl:text>
        </xsl:when>
        <!-- Pagination en chiffres arabes ou romains. -->
        <xsl:when test="@typePagination = 'R'">
            <xsl:text>Page </xsl:text>
        </xsl:when>
        <!-- Foliotation. -->
        <xsl:when test="@typePagination = 'F'">
            <!-- TODO Distinguer la foliotation recto et verso (non utilisé actuellement à l'école). -->
            <xsl:text>Feuillet </xsl:text>
        </xsl:when>
        <!-- Pagination autre. -->
        <xsl:when test="@typePagination = 'X'">
            <xsl:text>Page </xsl:text>
        </xsl:when>
        <!-- Page non paginée -->
        <xsl:otherwise>
            <xsl:text>Non paginée </xsl:text>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<!-- Retourne l'adresse du fichier Alto associé si le document existe et est lisible. -->
<xsl:template name="retourne_url_fichier_alto">
    <!-- Impossibilité de tester simplement la balise objetAssocié, car certains refNum l'ont oublié. -->
    <xsl:variable name="url_fichier_alto">
        <xsl:call-template name="adresse_objet_associé">
            <xsl:with-param name="préfixe_renommage">X</xsl:with-param>
        </xsl:call-template>
        <xsl:text>.xml</xsl:text>
    </xsl:variable>

    <!-- Nécessité de tester le contenu de l'url pour éviter les erreurs. -->
    <xsl:call-template name="teste_fichier">
        <xsl:with-param name="url" select="$url_fichier_alto"/>
    </xsl:call-template>
</xsl:template>

<!-- Teste la disponibilité et l'accessibilité d'un document via son url. -->
<xsl:template name="teste_fichier">
    <xsl:param name="url"/>

    <xsl:choose>
        <!-- Test de la fonction XSLT 2.0. -->
        <xsl:when test="function-available('fn:unparsed-text-available')">
            <xsl:if test="fn:unparsed-text-available($url)">
                <xsl:value-of select="$url"/>
            </xsl:if>
        </xsl:when>
        <!-- Test de la fonction php. -->
        <xsl:when test="function-available('php:function')">
            <xsl:if test="php:function('file_get_contents', string($url))">
                <xsl:value-of select="$url"/>
            </xsl:if>
        </xsl:when>
        <xsl:otherwise>
        <xsl:message terminate="no">
                <xsl:text>Pas de fonction pour tester la présence d'un document : risque d'erreur.</xsl:text>
        </xsl:message>
        <xsl:value-of select="$url"/>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<!-- Définit l'adresse du fichier associé (vers le fichier original, puisqu'il n'est pas renommé ni chargé). -->
<xsl:template name="adresse_objet_associé">
    <xsl:param name="préfixe_renommage"/>

    <xsl:if test="$chemin_source">
        <xsl:value-of select="$chemin_source"/>
        <xsl:text>/</xsl:text>
    </xsl:if>
    <xsl:value-of select="../../@identifiant"/>
    <xsl:text>/</xsl:text>
    <!--
        Le lien aux fichiers (champ nomImage) diffère selon le prestataire et la catégorie.
        Il faut changer uniquement les noms qui n'ont pas d'extension dans le refNum.
        Le paramètre renommage_fichier permet d'effectuer ce renommage ou non.
        Ce renommage diffère légèrement du renommage pour l'import des fichiers images.
        Exemples :
        - Ne pas changer (sauf la suppression de l'extension) :
        Journal de mission ENPC01_Ms_0375 : ENPC01_Ms_0375_0001.jpg
        Journal de mission ENPC01_Ms_3312 : ENPC01_Ms_3312_0001.jpg
        Phare ENPC01_PH_230 : ENPC01_PH_230_P06.jpg
        Phare ENPC01_PH_663 : ENPC01_PH_663_G001_1873.jpg
        - Changer :
        Cours ENPC02_COU_4_19539_1893 : J0000001 => XENPC02_COU_4_19539_1893/X0000001
        Cours ENPC02_COU_4_29840_1938 : J0000001 => XENPC02_COU_4_29840_1938/X0000001
    -->
    <!-- Choix de l'utilisateur : renommage ou non (dans tous les cas, sans extension). -->
    <xsl:choose>
        <xsl:when test="$renommage_fichier = 'true'">
            <xsl:choose>
                <!-- Pas de changement lorsqu'il y a une extension (conformément aux fichiers de l'ENPC). -->
                <!-- Sauf la suppression de l'extension (simple, car il n'y a qu'un seul "." dans les fichiers de l'ENPC). -->
                <xsl:when test="contains(refNum:image/@nomImage, '.')">
                    <xsl:value-of select="substring-before(refNum:image/@nomImage, '.')"/>
                </xsl:when>
                <!-- Renommage en ajoutant un dossier (le nom de la notice et la première lettre du type de fichier) et l'extension du nom de fichier. -->
                <xsl:otherwise>
                    <xsl:choose>
                        <xsl:when test="$préfixe_renommage">
                            <xsl:value-of select="$préfixe_renommage"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="substring(refNum:image/@typeFichier, 1, 1)"/>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:value-of select="../../@identifiant"/>
                    <xsl:text>/</xsl:text>
                    <xsl:choose>
                        <xsl:when test="$préfixe_renommage">
                            <xsl:value-of select="$préfixe_renommage"/>
                            <xsl:value-of select="substring(refNum:image/@nomImage, 2)"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="refNum:image/@nomImage"/>
                        </xsl:otherwise>
                    </xsl:choose>
                    <!-- Ne pas ajouter d'extension (@typeFichier). -->
                </xsl:otherwise>
            </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
            <xsl:value-of select="substring-before(refNum:image/@nomImage, '.')"/>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<!-- Template principal du fichier Alto XML. -->
<!-- Traitement du contenu. -->
<xsl:template match="/alto:alto/alto:Layout/alto:Page//alto:TextLine/alto:String">
    <!-- Si le mot est coupé, choisir le mot reconstruit (une fois), sinon choisir le mot. -->
    <xsl:choose>
        <xsl:when test="@SUBS_CONTENT">
            <xsl:choose>
                <xsl:when test="@SUBS_TYPE = 'HypPart1'">
                    <xsl:value-of select="normalize-space(@SUBS_CONTENT)"/>
                </xsl:when>
                <xsl:when test="@SUBS_TYPE = 'HypPart2'">
                    <xsl:if test="not(name(following::alto:*[1]) = 'String')">
                        <xsl:text> </xsl:text>
                    </xsl:if>
                </xsl:when>
            </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
            <xsl:value-of select="normalize-space(@CONTENT)"/>
            <xsl:if test="not(name(following::alto:*[1]) = 'String')">
                <xsl:text> </xsl:text>
            </xsl:if>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template match="text()">
    <!-- Ignore tout le reste -->
</xsl:template>

</xsl:stylesheet>
