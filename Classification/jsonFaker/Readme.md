Lien github : <https://github.com/json-schema-faker/json-schema-faker>

Lien client : <https://github.com/oprogramador/json-schema-faker-cli>

Lien interface : <https://json-schema-faker.js.org/>

Exécution du script (on utilise le client pour exécuter)

* Faut exécuter sur un terminal :
  * npm install -g json-schema-faker-cli
  * npm install
* La commande : ./[csvJsonJSF.sh](http://csvJsonJSF.sh) pathToFolder true/false timeoutValue
* pathToFolder est le path vers le dossier contenant les schémas qu'on veut tester
* Y a parfois des schémas pour lesquels le programme tourne à l'infini, c'est pour ça le timeout
* Donc si on met true on doit mettre un autre argument qui est la valeur du timeout, par défaut c'est en secondes
* Même principe que pour json-everything, ça crée un dossier dans lequel y a les instances et un fichier csv

cd /mnt/c/Users/Surface/Documents/GitHub/Benchmarking-de-solutions-optimistes-pour-generation-de-donnees-test-partir-de-JSON-Schema/new_Classification/

bash ./csvJsonJSF.sh /mnt/c/Users/Surface/Documents/GitHub/Benchmarking-de-solutions-optimistes-pour-generation-de-donnees-test-partir-de-JSON-Schema/new_Classification/snowplow

bash ./analysis.sh /mnt/c/Users/Surface/Documents/GitHub/Benchmarking-de-solutions-optimistes-pour-generation-de-donnees-test-partir-de-JSON-Schema/new_Classification/snowplow/JSFResults/JSFErrors.csv