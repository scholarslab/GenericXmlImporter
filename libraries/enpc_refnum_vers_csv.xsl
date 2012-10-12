<?xml version="1.0" encoding="UTF-8"?>
<!--
    Document : enpc_refnum_vers_csv.xsl
    Crée le : 18/07/2012
    Version : 1.0
    Auteur : Daniel Berthereau pour l'École des Ponts (http://bibliotheque.enpc.fr)
    Description : Convertit un fichier refNum en Dublin Core au format CSV de façon à l'importer dans Omeka, logiciel libre de création de bibliothèque numérique, par le biais du plugin CsvImport.


    Notes
    Cette feuille XSLT respecte au plus près le format refNum de la Bibliothèque nationale de France ((http://bibnum.bnf.fr/refNum/). Toutefois, elle presente certaines particularités pour deux raisons.
    * Les fichiers fournis par les prestataires ne contiennent pas tous les champs du format refNum et certains sont mal transcrits.
    * Le système et les besoins pour la bibliothèque numérique de l'École des Ponts sont également spécifiques.
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

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="1.0"
                xmlns:refNum="http://bibnum.bnf.fr/ns/refNum">
<xsl:output method="text"
            media-type="text/csv"
            encoding="UTF-8"
            omit-xml-declaration="yes"/>

<!-- Paramètres -->
<xsl:param name="delimiter">|</xsl:param>
<xsl:param name="enclosure">"</xsl:param>
<!-- Actuellement, CsvImport ne prend en charge que la virgule pour les champs multivalués. -->
<xsl:param name="délimiteur_multivaleur">,</xsl:param>
<xsl:param name="ajoute_entêtes">true</xsl:param>
<!-- CsvImport ne semble pas prendre en compte les fichiers locaux : il faut donc utiliser un lien ou un montage sur le serveur. -->
<xsl:param name="chemin_source">http://127.0.0.1/images</xsl:param>
<!-- Collections principales : Annales, Cours, Journaux_mission, Phares, Cartes -->
<xsl:param name="collection">Autres</xsl:param>
<!-- Utilisation de la fonction de renommage -->
<xsl:param name="renommage_fichier">true</xsl:param>
<!-- Préfixe à ajouter pour identifier le document -->
<xsl:param name="préfixe">document:</xsl:param>
<!-- Copyright du document papier. -->
<xsl:param name="copyright">Domaine public (original papier)</xsl:param>
<!-- Copyright pour les images numériques. -->
<xsl:param name="copyright_2">École Nationale des Ponts et Chaussées (image numérisée)</xsl:param>

<!-- Constantes -->
<xsl:variable name="saut_ligne">
<xsl:text>
</xsl:text>
</xsl:variable>
<xsl:variable name="séparateur">
    <xsl:value-of select="$enclosure"/>
    <xsl:value-of select="$delimiter"/>
    <xsl:value-of select="$enclosure"/>
</xsl:variable>
<xsl:variable name="début_ligne">
    <xsl:value-of select="$enclosure"/>
</xsl:variable>
<xsl:variable name="fin_ligne">
    <xsl:value-of select="$enclosure"/>
    <xsl:value-of select="$saut_ligne"/>
</xsl:variable>
<!-- Permet la mise en minuscule du type de fichier (xslt 1.0) -->
<xsl:variable name="majuscule" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'" />
<xsl:variable name="minuscule" select="'abcdefghijklmnopqrstuvwxyz'" />

<!-- Template principal -->
<xsl:template match="/">
    <xsl:if test="$ajoute_entêtes = 'true'">
        <!-- Complet sauf référence et Historique, inutilisés dans les fichiers de numérisation de l'ENPC, et pour Structure, uniquement les fichiers. -->
        <!-- Utilisation des champs DublinCore français pour permettre la correspondance automatique lors de l'import -->
        <!-- pour avoir un mapping automatique avec CsvImport, mettre Omeka en Français et activer le patch https://gist.github.com/2599484. -->
        <xsl:value-of select="$début_ligne"/>
        <xsl:text>Identifiant</xsl:text>
        <xsl:value-of select="$séparateur"/>
        <xsl:text>Type</xsl:text>
        <xsl:value-of select="$séparateur"/>
        <xsl:text>Titre</xsl:text>
        <xsl:value-of select="$séparateur"/>
        <xsl:text>Créateur</xsl:text>
        <xsl:value-of select="$séparateur"/>
        <xsl:text>Description</xsl:text>
        <xsl:value-of select="$séparateur"/>
        <xsl:text>Éditeur</xsl:text>
        <xsl:value-of select="$séparateur"/>
        <xsl:text>Date</xsl:text>
        <xsl:value-of select="$séparateur"/>
        <xsl:text>Droits</xsl:text>
        <xsl:value-of select="$séparateur"/>
        <xsl:text>Droits_2</xsl:text>
        <xsl:value-of select="$séparateur"/>
        <xsl:text>Format_1</xsl:text>
        <xsl:value-of select="$séparateur"/>
        <xsl:text>Format_2</xsl:text>
        <xsl:value-of select="$séparateur"/>
        <xsl:text>Format_3</xsl:text>
        <xsl:value-of select="$séparateur"/>
        <xsl:text>Format_4</xsl:text>
        <xsl:value-of select="$séparateur"/>
        <xsl:text>Capture Date</xsl:text>
        <xsl:value-of select="$séparateur"/>
        <!-- Compte tenu des spécifications de numérisation, le nombre d'objet est toujours égal au nombre d'images. -->
        <xsl:text>Nombre vue objet</xsl:text>
        <xsl:value-of select="$séparateur"/>
        <xsl:text>Format_5</xsl:text>
        <xsl:value-of select="$séparateur"/>
        <xsl:text>Identifiant support</xsl:text>
        <xsl:value-of select="$séparateur"/>
        <xsl:text>Objet associé</xsl:text>
        <xsl:value-of select="$séparateur"/>
        <xsl:text>Objet associé date</xsl:text>
        <xsl:value-of select="$séparateur"/>
        <xsl:text>Commentaire type</xsl:text>
        <xsl:value-of select="$séparateur"/>
        <xsl:text>Commentaire date</xsl:text>
        <xsl:value-of select="$séparateur"/>
        <xsl:text>Commentaire</xsl:text>
        <xsl:value-of select="$séparateur"/>
        <xsl:text>Fichiers</xsl:text>
        <xsl:value-of select="$fin_ligne"/>
    </xsl:if>
    <xsl:apply-templates/>
</xsl:template>

<!-- Template d'un document refNum -->
<xsl:template match="refNum:document">
    <xsl:variable name="Ligne">
        <xsl:value-of select="$début_ligne"/>
        <xsl:value-of select="$préfixe"/>
        <xsl:value-of select="@identifiant"/>
        <xsl:apply-templates select="refNum:bibliographie"/>
        <xsl:apply-templates select="refNum:production"/>
        <xsl:apply-templates select="refNum:structure"/>
    </xsl:variable>

    <!-- La normalisation est nécessaire, car les fichiers originaux peuvent avoir des sauts de ligne, notamment sur dateNumerisation et description. -->
    <xsl:value-of select="normalize-space($Ligne)"/>
    <xsl:value-of select="$fin_ligne"/>
</xsl:template>

<xsl:template match="refNum:bibliographie">
    <xsl:value-of select="$séparateur"/>
    <xsl:choose>
        <xsl:when test="refNum:genre = 'MONOGRAPHIE'">
            <xsl:text>Monographie imprimée</xsl:text>
        </xsl:when>
        <xsl:when test="refNum:genre = 'PERIODIQUE'">
            <xsl:text>Publication en série imprimée</xsl:text>
        </xsl:when>
        <xsl:when test="refNum:genre = 'LOT'">
            <xsl:text></xsl:text>
        </xsl:when>
        <xsl:otherwise>
            <xsl:value-of select="refNum:genre"/>
        </xsl:otherwise>
    </xsl:choose>
    <xsl:value-of select="$séparateur"/>
    <xsl:value-of select="refNum:titre"/>
    <xsl:value-of select="$séparateur"/>
    <xsl:value-of select="refNum:auteur"/>
    <xsl:value-of select="$séparateur"/>
    <xsl:value-of select="refNum:description"/>
    <xsl:value-of select="$séparateur"/>
    <xsl:value-of select="refNum:editeur"/>
    <xsl:value-of select="$séparateur"/>
    <xsl:value-of select="refNum:dateEdition"/>
    <xsl:value-of select="$séparateur"/>
    <xsl:value-of select="$copyright"/>
    <xsl:value-of select="$séparateur"/>
    <xsl:value-of select="$copyright_2"/>

    <!-- Tomaison variant entre 0 et 3 dans refNum , trois colonnes sont utilisées. -->
    <xsl:value-of select="$séparateur"/>
    <xsl:if test="refNum:tomaison[1]">
        <xsl:value-of select="refNum:tomaison[1]/refNum:type"/>
        <xsl:text> : </xsl:text>
        <xsl:value-of select="refNum:tomaison[1]/refNum:valeur"/>
    </xsl:if>
    <xsl:value-of select="$séparateur"/>
    <xsl:if test="refNum:tomaison[2]">
        <xsl:value-of select="refNum:tomaison[2]/refNum:type"/>
        <xsl:text> : </xsl:text>
        <xsl:value-of select="refNum:tomaison[2]/refNum:valeur"/>
    </xsl:if>
    <xsl:value-of select="$séparateur"/>
    <xsl:if test="refNum:tomaison[3]">
        <xsl:value-of select="refNum:tomaison[3]/refNum:type"/>
        <xsl:text> : </xsl:text>
        <xsl:value-of select="refNum:tomaison[3]/refNum:valeur"/>
    </xsl:if>

    <xsl:value-of select="$séparateur"/>
    <!-- Le mot Pages est ajouté, car cela serait incompréhensible dans dc:format. -->
    <xsl:if test="refNum:nombrePages != ''">
        <xsl:text>Pages : </xsl:text>
        <xsl:value-of select="refNum:nombrePages"/>
    </xsl:if>
    <!-- Non utilisé dans les fichiers de numérisation de l'ENPC. -->
    <!--
    <xsl:value-of select="$séparateur"/>
    <xsl:value-of select="refNum:reference"/>
    -->
</xsl:template>

<xsl:template match="refNum:production">
    <xsl:value-of select="$séparateur"/>
    <!-- Ce champ n'est pas rempli correctement dans les fichiers refNum d'un prestataire (un espace et/ou un saut de ligne en trop). -->
    <xsl:choose>
        <xsl:when test="refNum:dateNumerisation = normalize-space(refNum:dateNumerisation)">
            <xsl:value-of select="refNum:dateNumerisation"/>
        </xsl:when>
        <xsl:otherwise>
            <xsl:choose>
                <xsl:when test="substring(normalize-space(refNum:dateNumerisation), string-length(normalize-space(refNum:dateNumerisation)), 1) = ' '">
                    <xsl:value-of select="substring(normalize-space(refNum:dateNumerisation), 1, string-length(normalize-space(refNum:dateNumerisation)) - 1)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="normalize-space(refNum:dateNumerisation)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:otherwise>
    </xsl:choose>
    <xsl:value-of select="$séparateur"/>
    <xsl:value-of select="refNum:nombreVueObjets"/>
    <xsl:value-of select="$séparateur"/>
    <!-- Le mot Images est ajouté, car cela serait incompréhensible dans dc:format. -->
    <xsl:text>Images : </xsl:text>
    <xsl:value-of select="refNum:nombreImages"/>
    <xsl:value-of select="$séparateur"/>
    <xsl:value-of select="refNum:identifiantSupport"/>
    <xsl:value-of select="$séparateur"/>
    <xsl:value-of select="refNum:objetAssocie"/>
    <xsl:value-of select="$séparateur"/>
    <xsl:value-of select="refNum:objetAssocie/@date"/>

    <!-- Non utilisé dans les fichiers de numérisation de l'ENPC. -->
    <!--
    <xsl:value-of select="$séparateur"/>
    <xsl:value-of select="refNum:historique"/>
    -->
</xsl:template>

<xsl:template match="refNum:structure">
    <xsl:value-of select="$séparateur"/>
    <xsl:value-of select="./refNum:commentaire/@type"/>
    <xsl:value-of select="$séparateur"/>
    <xsl:value-of select="./refNum:commentaire/@date"/>
    <xsl:value-of select="$séparateur"/>
    <xsl:value-of select="./refNum:commentaire"/>

    <!-- Récupération et renommage des noms de fichiers dans un champ multivalué. -->
    <!-- CsvImport a besoin d'une URL complète pour importer les fichiers. -->
    <!-- Les autres métadonnées des fichiers seront importés ensuite. -->
    <xsl:for-each select="refNum:vueObjet/refNum:image">
        <!-- Le premier nom de fichier est sélectionné séparément car le délimiteur est le séparateur complet.-->
        <xsl:choose>
            <xsl:when test="position() = 1">
                <xsl:value-of select="$séparateur"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$délimiteur_multivaleur"/>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:if test="$chemin_source">
            <xsl:value-of select="$chemin_source"/>
            <xsl:text>/</xsl:text>
        </xsl:if>
        <xsl:if test="$collection">
            <xsl:value-of select="$collection"/>
            <xsl:text>/</xsl:text>
        </xsl:if>
        <xsl:value-of select="../../../@identifiant"/>
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
                    <xsl:when test="contains(@nomImage, '.')">
                        <xsl:value-of select="@nomImage"/>
                    </xsl:when>
                    <!-- Renommage en ajoutant un dossier (le nom de la notice et la première lettre du type de fichier) et l'extension du nom de fichier. -->
                    <xsl:otherwise>
                        <xsl:value-of select="substring(@typeFichier, 1, 1)"/>
                        <xsl:value-of select="../../../@identifiant"/>
                        <xsl:text>/</xsl:text>
                        <xsl:value-of select="@nomImage"/>
                        <xsl:text>.</xsl:text>
                        <xsl:value-of select="translate(@typeFichier, $majuscule, $minuscule)"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="@nomImage"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:for-each>
</xsl:template>

<xsl:template match="text()">
    <!-- Ignore tout le reste -->
</xsl:template>

</xsl:stylesheet>
