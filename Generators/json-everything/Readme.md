Lien github : <https://github.com/gregsdennis/json-everything>

Lien interface : <https://json-everything.net/>

Pour exécuter des tests :

* Une fois le contenu du zip est extrait :
  * Suivre le chemin experiments-for-json-everything/JsonSchema.DataGeneration
  * À l'intérieur se trouve un dossier nommé massiveTesting, ouvrir le dossier avec visual code
  * Ouvrir le fichier massiveTests.cs
  * Le programme prend en entrée le path vers le dossier **X** contenant les schémas JSON qu'on veut tester
  * La variable à modifier est pathToDataset
  * Pour exécuter, ouvrir un terminal et taper dotnet run
  * L'exécution crée un dossier dans **X** nommé JSONEverythingResults, dans ce dossier on trouve les instances et 2 fichiers csv (1 qui liste les exceptions s'il y en a, l'autre contient 4 colonnes : nom du schéma, taille, temps de la génération, et si on a pu généré ou pas)