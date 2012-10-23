<?xml version="1.0" encoding="UTF-8"?>
<!--
    Document : enpc_refnum_vers_csv_fichiers.xsl
    Crée le : 04/10/2012
    Version : 1.0
    Auteur : Daniel Berthereau pour l'École des Ponts (http://bibliotheque.enpc.fr)
    Description : Convertit les données relatives aux fichiers présentes dans un fichier XML refNum en un fichier en Dublin Core étendu au format CSV, de façon à l'importer dans Omeka par le biais du plugin CsvImport modifié pour l'import.

    Notes
    Cette feuille est complémentaire de enpc_refnum_vers_csv.xsl, avec les mêmes principes, mais peut être utilisée indépendamment.
    Toutes les données ne sont pas utilisées, car Omeka n'est pas conçu pour gérer les notices.
    Certains codes refNum sont convertis afin d'être directement utilisables par Omeka, sachant que les fichiers refNum initiaux peuvent toujours être utilisés pour d'autres traitements.
    La feuille importe également les fichiers associés éventuels d'OCR Alto et le convertit en texte brut.
-->

<!-- fn et php permettent de tester l'existence des fichiers et sont nécessaires compte tenu des erreurs dans les fichiers refNum XML. -->
<!-- Le résultat de la fonction document() varie selon les processeurs et n'est donc pas utilisée. -->
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:php="http://php.net/xsl"
    xmlns:refNum="http://bibnum.bnf.fr/ns/refNum"
    xmlns:alto="http://bibnum.bnf.fr/ns/alto_prod">
<xsl:output method="text"
    media-type="text/csv"
    encoding="UTF-8"/>

<!-- Paramètres -->
<!-- Délimiteur : tabulation par défaut, car c'est le seul caractère que l'on ne trouve jamais dans les fichiers refNum. -->
<!-- Attention : CsvImport ne le permet pas dans la version originale. -->
<xsl:param name="delimiter"><xsl:text>&#x9;</xsl:text></xsl:param>
<!-- Avec la tabulation, pas besoin de protecteur. -->
<xsl:param name="enclosure"></xsl:param>
<!-- Actuellement, CsvImport ne prend en charge que la virgule pour les champs multivalués. -->
<xsl:param name="délimiteur_multivaleur">,</xsl:param>
<xsl:param name="ajoute_entêtes">true</xsl:param>
<!-- CsvImport ne semble pas prendre en compte les fichiers locaux : il faut donc utiliser un lien ou un montage sur le serveur. -->
<!-- Ce champ est nécessaire pour charger les documents associés (en l'occurrence xml Alto). -->
<xsl:param name="chemin_source">http://127.0.0.1/images</xsl:param>
<!-- Collections principales : Annales, Cours, Journaux_mission, Phares, Cartes. -->
<xsl:param name="collection"></xsl:param>
<!-- Utilisation de la fonction de renommage -->
<xsl:param name="renommage_fichier">true</xsl:param>

<!-- Constantes -->
<xsl:variable name="saut_ligne">
    <xsl:text>&#x0A;</xsl:text>
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
<!-- Liste des codes utilisés dans refNum. -->
<xsl:variable name="refNum_codes" select="document('refNum_codes.xml')"/>

<!-- Template principal refNum. -->
<xsl:template match="/refNum:refNum">
    <xsl:if test="$ajoute_entêtes = 'true'">
        <!-- Utilisation des champs DublinCore français pour permettre la correspondance automatique lors de l'import -->
        <!-- pour avoir un mapping automatique avec CsvImport, mettre Omeka en Français et activer le patch https://gist.github.com/2599484. -->
        <xsl:value-of select="$début_ligne"/>
        <xsl:text>Filename</xsl:text><!-- Identifiant du fichier, pour le nom de fichier (court). -->
        <xsl:value-of select="$séparateur"/>
        <xsl:text>Identifiant du document</xsl:text><!-- Identifiant de la notice de rattachement. -->
        <xsl:value-of select="$séparateur"/>
        <xsl:text>Identifiant</xsl:text><!-- Identifiant du fichier. -->
        <xsl:value-of select="$séparateur"/>
        <xsl:text>Titre</xsl:text>
        <xsl:value-of select="$séparateur"/>
        <xsl:text>Type de page</xsl:text>
        <xsl:value-of select="$séparateur"/>
        <xsl:text>Type de pagination</xsl:text>
        <xsl:value-of select="$séparateur"/>
        <xsl:text>Numéro de page</xsl:text>
        <xsl:value-of select="$séparateur"/>
        <xsl:text>Nom de page</xsl:text>
        <xsl:value-of select="$séparateur"/>
        <xsl:text>Numéro d'ordre</xsl:text>
        <xsl:value-of select="$séparateur"/>
        <xsl:text>Support d'origine</xsl:text>
        <xsl:value-of select="$séparateur"/>
        <xsl:text>Date de numérisation</xsl:text>
        <!-- Gestion d'un seul objet associé. -->
        <xsl:value-of select="$séparateur"/>
        <xsl:text>Objet associé</xsl:text>
        <xsl:value-of select="$séparateur"/>
        <xsl:text>Alto XML</xsl:text>
        <xsl:value-of select="$séparateur"/>
        <xsl:text>OCR Nombre NC</xsl:text>
        <xsl:value-of select="$séparateur"/>
        <xsl:text>OCR Nombre NC dico</xsl:text>
        <xsl:value-of select="$séparateur"/>
        <xsl:text>OCR Taux NC</xsl:text>
        <xsl:value-of select="$séparateur"/>
        <xsl:text>OCR Nombre de caractères</xsl:text>
        <xsl:value-of select="$séparateur"/>
        <xsl:text>OCR Caractères douteux</xsl:text>
        <xsl:value-of select="$séparateur"/>
        <xsl:text>OCR Taux des caractères douteux</xsl:text>
        <xsl:value-of select="$séparateur"/>
        <xsl:text>OCR Texte</xsl:text>
        <xsl:value-of select="$séparateur"/>
        <xsl:text>Prestataire</xsl:text>

        <xsl:value-of select="$fin_ligne"/>
    </xsl:if>
    <xsl:apply-templates/>
</xsl:template>

<!-- Template d'un document refNum. -->
<xsl:template match="/refNum:refNum/refNum:document">
    <xsl:for-each select="refNum:structure/refNum:vueObjet">
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

        <xsl:value-of select="$début_ligne"/>
        <xsl:value-of select="$identifiantImage"/>

        <xsl:value-of select="$séparateur"/>
        <xsl:value-of select="../../@identifiant"/>

        <xsl:value-of select="$séparateur"/>
        <xsl:value-of select="$identifiantImage"/>

        <xsl:value-of select="$séparateur"/>
        <xsl:value-of select="concat(translate(substring($nomPage, 1, 1), $minuscule, $majuscule), substring($nomPage, 2))"/>
        <xsl:text> (document </xsl:text>
        <xsl:value-of select="../../@identifiant"/>
        <xsl:text>, image </xsl:text>
        <xsl:value-of select="@ordre"/>
        <xsl:text>)</xsl:text>

        <xsl:value-of select="$séparateur"/>
        <xsl:variable name="typePage" select="@typePage"/>
        <xsl:value-of select="$refNum_codes/XMLlist/typePage/entry[@code = $typePage]"/>

        <xsl:value-of select="$séparateur"/>
        <xsl:variable name="typePagination" select="@typePagination"/>
        <xsl:value-of select="$refNum_codes/XMLlist/typePagination/entry[@code = $typePagination]"/>

        <xsl:value-of select="$séparateur"/>
        <xsl:if test="@typePagination != 'N'">
            <xsl:value-of select="@numeroPage"/>
        </xsl:if>
        <xsl:value-of select="$séparateur"/>
        <xsl:value-of select="$nomPage"/>

        <xsl:value-of select="$séparateur"/>
        <xsl:value-of select="@ordre"/>

        <xsl:value-of select="$séparateur"/>
        <xsl:variable name="supportOrigine" select="refNum:image/@supportOrigine"/>
        <xsl:value-of select="$refNum_codes/XMLlist/supportOrigine/entry[@code = $supportOrigine]"/>

        <xsl:value-of select="$séparateur"/>
        <!-- Ce champ n'est pas rempli correctement dans les fichiers refNum d'un prestataire (un espace et/ou un saut de ligne en trop). -->
        <xsl:value-of select="normalize-space(../../refNum:production/refNum:dateNumerisation)"/>

        <xsl:value-of select="$séparateur"/>
        <!-- Ce champ n'est pas rempli par l'un des prestataires. Il faut donc s'appuyer sur l'adresse du fichier associé. -->
        <!-- <xsl:value-of select="../../refNum:production/refNum:objetAssocie"/> -->
        <!-- Actuellement, seuls des fichiers Alto sont associés pour certains documents. -->
        <xsl:choose>
            <xsl:when test="boolean(document($url_fichier_alto))">
                <xsl:text>ALTO</xsl:text>
            </xsl:when>
        </xsl:choose>

        <xsl:value-of select="$séparateur"/>
        <!-- Récupération intégrale du fichier associé. -->
        <xsl:if test="boolean(document($url_fichier_alto))">
<!-- TODO (actuellement, seul le texte brut est extrait, cf. champ suivant ci-dessous). -->
            <!-- Charge le fichier alto et le copie intégralement. -->
            <!-- Supprime les sauts de ligne du fichier alto pour pouvoir le charger en CSV (sans problème compte tenu des données disponibles dans un fichier Alto).-->
        </xsl:if>

        <!-- Statistiques OCR -->
        <xsl:value-of select="$séparateur"/>
        <xsl:value-of select="substring-after(document($url_fichier_alto)/alto:alto/alto:Description/alto:OCRProcessing[last()]/alto:ocrProcessingStep/alto:processingStepDescription[1], 'OCR_TOTAL_NC=')"/>
        <xsl:value-of select="$séparateur"/>
        <xsl:value-of select="substring-after(document($url_fichier_alto)/alto:alto/alto:Description/alto:OCRProcessing[last()]/alto:ocrProcessingStep/alto:processingStepDescription[2], 'OCR_TOTAL_NC_DICO=')"/>
        <xsl:value-of select="$séparateur"/>
        <xsl:value-of select="substring-after(document($url_fichier_alto)/alto:alto/alto:Description/alto:OCRProcessing[last()]/alto:ocrProcessingStep/alto:processingStepDescription[3], 'OCR_TAUX_NC=')"/>
        <xsl:value-of select="$séparateur"/>
        <xsl:value-of select="substring-after(document($url_fichier_alto)/alto:alto/alto:Description/alto:OCRProcessing[last()]/alto:ocrProcessingStep/alto:processingStepDescription[4], 'OCR_TOTAL_CAR=')"/>
        <xsl:value-of select="$séparateur"/>
        <xsl:value-of select="substring-after(document($url_fichier_alto)/alto:alto/alto:Description/alto:OCRProcessing[last()]/alto:ocrProcessingStep/alto:processingStepDescription[5], 'OCR_TOTAL_CAR_DOUTE=')"/>
        <xsl:value-of select="$séparateur"/>
        <xsl:value-of select="substring-after(document($url_fichier_alto)/alto:alto/alto:Description/alto:OCRProcessing[last()]/alto:ocrProcessingStep/alto:processingStepDescription[6], 'OCR_TAUX_CAR=')"/>

        <xsl:value-of select="$séparateur"/>
        <xsl:choose>
            <xsl:when test="boolean(document($url_fichier_alto))">
                <!-- Charge le fichier alto et extrait le texte brut sans saut de ligne. -->
                <xsl:apply-templates select="document($url_fichier_alto)"/>
            </xsl:when>
        </xsl:choose>

        <xsl:value-of select="$séparateur"/>
        <xsl:value-of select="substring-before(../../@identifiant, '_')"/>

        <xsl:value-of select="$fin_ligne"/>
    </xsl:for-each>
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
    <xsl:if test="$collection">
        <xsl:value-of select="$collection"/>
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
