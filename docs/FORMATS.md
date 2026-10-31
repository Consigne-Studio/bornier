# Formats d'export de Bornier : contenu et provenance

Ce document dit, cible par cible, ce que Bornier écrit, d'où vient chaque format et ce qui a été vérifié. Les fichiers d'exemple de chaque cible sont dans [exemples/](exemples/), générés à partir du projet d'exemple fictif `station-sp12.bornier`.

Règle générale : Bornier n'écrit que des formats d'**import** documentés ou relevés dans des exports réels des outils. Il ne pilote aucun logiciel tiers et n'a besoin d'aucune licence de ces logiciels. Relisez toujours le résultat de l'import dans l'outil cible avant une mise en service.

## Projet Bornier (`.bornier`)

JSON lisible, format `bornier/1`, clés dans un ordre stable et un signal par bloc : un projet suivi dans Git donne des différences lisibles ligne à ligne. Le fichier contient les automates, les signaux, les paramètres et les révisions figées (copie complète de la liste à chaque diffusion).

## Siemens WinCC Unified (TIA Portal)

Fichiers : `…_WinCC_HMITags.xlsx`, `…_WinCC_HMIAlarms.xlsx`, `…_TIA_PLCTags.xlsx`.

| Élément | Provenance | État |
|---|---|---|
| Feuille `Hmi Tags`, colonnes `Name`, `Path`, `Connection`, `PLC tag`, `DataType`, `HMI DataType` | Relevées dans un export « HMI tags » de TIA Portal | Noms de colonnes vérifiés ; import non encore fait par l'éditeur |
| Colonnes `Access Method`, `Address`, `Comment [fr-FR]`, `Linear scaling`, `End/Start value PLC`, `End/Start value HMI` | Libellés de l'éditeur de variables IHM de TIA Portal | Déduit, à confirmer par le mode gabarit |
| Feuille `Multiplexing` (`Name`, `Index`) | Export réel | Vérifié |
| Feuille `DiscreteAlarms`, 44 colonnes de la mise en page Unified | Outil public de conversion de listes WinCC Unified (github.com/paul-rafael/wincc-unified-list-converter) | Vérifié contre cet outil |
| Feuille `AnalogAlarms` (`Limit`, `Limit mode` Higher / Lower) | Libellés de l'éditeur d'alarmes analogiques | Déduit, à confirmer par le mode gabarit |
| Table de variables API (`PLC Tags` : `Name`, `Path`, `Data Type`, `Logical Address`, `Comment`, `Hmi Visible`, `Hmi Accessible`, `Hmi Writeable`) | Format d'import / export des tables de variables API de TIA Portal | Vérifié sur export réel |

**Mode gabarit (recommandé).** Les colonnes des classeurs d'import changent légèrement selon la version de TIA Portal et la langue du projet. Dans la vue Exports, donnez à Bornier un export de *votre* projet (Variables IHM › Exporter, Alarmes › Exporter) : il recopie exactement l'en-tête et l'ordre des colonnes de ce fichier et remplit les colonnes qu'il connaît. Les colonnes inconnues sont laissées vides et signalées.

Types : `DataType` est le type de la variable API (`Int` pour une entrée analogique), `HMI DataType` celui de la variable IHM, `Real` dès que WinCC met la valeur à l'échelle, pour qu'elle ne soit pas tronquée.

Accès absolu : une adresse de DB (`%DB10.DBD0`) est écrite en accès absolu, ce qui suppose un bloc de données non optimisé ; Bornier le signale dans les contrôles. Les variables d'E/S et mémentos passent en accès symbolique.

Hystérésis des alarmes analogiques : non écrite dans le classeur (colonnes propres à chaque version), à régler dans TIA Portal.

Priorités : les priorités Bornier 1 à 4 deviennent les priorités Unified 12, 9, 6 et 3 (échelle 0 à 16). Les classes d'alarme sont réglées dans la vue Projet.

## Inductive Automation Ignition 8.1 et 8.3

Fichier : `…_Ignition_tags.json` (Designer › Tag Browser › Import Tags, format JSON).

* Un dossier racine (`tagType: Folder`) au nom du projet, puis un dossier par zone, puis des `AtomicTag`.
* Champs écrits : `valueSource: opc`, `opcServer`, `opcItemPath`, `dataType` (`Float4` dès qu'Ignition met la valeur à l'échelle, sinon le type de l'automate), `engUnit`, `engLow`, `engHigh`, `scaleMode: Linear` avec `rawLow`, `rawHigh`, `scaledLow`, `scaledHigh`, `readOnly`, `documentation`.
* Alarmes : `AboveValue`, `BelowValue` ou `Equality`, avec `setpointA`, une priorité `Critical`, `High`, `Medium` ou `Low`, et pour les seuils une hystérésis `deadband` en unités physiques (`deadbandMode: Absolute`).
* Chemin OPC : modèle réglable par automate. Par défaut, notation du pilote Siemens d'Ignition (`ns=1;s=[SP12_API1]IX0.0`, `II64`, `DB10,REAL4`) ; pour CODESYS, nœud du serveur OPC UA CODESYS (`ns=4;s=|var|<automate>.Application.<GVL>.<variable>`, où `<automate>` est le nom réglé dans la vue Automates, par défaut `CODESYS Control Win V3 x64`).

Provenance : documentation des tags et de l'import / export JSON d'Inductive Automation. Vérifié : structure et noms de propriétés conformes à cette documentation ; l'import sur une passerelle réelle n'a pas encore été fait par l'éditeur. Si une propriété est refusée, Ignition l'ignore et importe le reste : signalez-le au support.

## CODESYS V3 (IEC 61131-3)

Fichiers : `…_CODESYS_<automate>.xml` (PLCopenXML, Projet › Importer PLCopenXML) et `…_texte.st` (le même contenu en texte structuré, à copier-coller).

* `GVL_IO` : variables d'E/S avec leur adresse (`AT %IX4.0 : BOOL;`), valeurs brutes suffixées `_BRUT` pour les analogiques.
* `GVL_Mesures` et `GVL_Alarmes` : grandeurs mises à l'échelle et bits d'alarme de seuil (LL, L, H, HH).
* `PRG_Bornier` (ST) : mise à l'échelle linéaire et seuils avec hystérésis (`A := X >= S OR (A AND X > S - h)`), à appeler dans la tâche principale.
* GVL déclarées dans l'extension `http://www.3s-software.com/plcopenxml/globalvars`, attribut `qualified_only`.

Vérifié : chaque fichier est validé contre le schéma XSD PLCopen TC6 (version 2.01 ; seul l'espace de noms diffère de la 2.00 utilisée par CODESYS) et le texte structuré généré est compilé puis exécuté avec le compilateur libre matiec, avec des valeurs d'entrée de test (mise à l'échelle, seuils H et HH, sortie analogique à 50 %).

Adressage : CODESYS adresse à l'élément (`%IW2` couvre les octets 4 et 5), Siemens à l'octet (`%IW64`). Bornier calcule l'emprise réelle de chaque adresse pour signaler les recouvrements.

## Kepware (KEPServerEX)

Fichiers : un CSV par appareil, `…_Kepware_<appareil>.csv` (clic droit sur l'appareil › Import CSV).

En-tête : `Tag Name, Address, Data Type, Respect Data Type, Client Access, Scan Rate, Scaling, Raw Low, Raw High, Scaled Low, Scaled High, Scaled Data Type, Clamp Low, Clamp High, Eng Units, Description, Negate Value`. Encodage UTF-8 avec BOM. Adresses Siemens sans `%` (`I0.0`, `IW64`, `DB10.DBD4`).

Provenance : format d'export CSV des tags de Kepware, en-tête confirmé sur un export publié par un tiers. À confirmer par un export de votre serveur : en cas d'écart, exportez un appareil depuis Kepware et comparez l'en-tête.

## Liste d'E/S Excel et rapport d'écarts

Livrables pour le client : liste mise en page (`Liste d'E-S`, `Bilan` par nature et par automate, `Révisions`) et rapport d'écarts entre deux révisions (ajouts, suppressions, modifications champ par champ). Format Excel standard (ExcelJS), ouvert sans macro.

## Import

Bornier lit les classeurs `.xlsx` / `.xlsm` et les fichiers `.csv` / `.txt` (séparateur détecté, UTF-8 ou Windows-1252). Les colonnes sont reconnues par leurs noms usuels en français, en anglais et ceux de TIA Portal ; la correspondance reste modifiable avant import.
