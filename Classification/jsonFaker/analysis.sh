#!/bin/bash

inputFile=$1
outputFile=$(dirname "$inputFile")/JSFErrorsAnalysis.csv
schemasDir=$(pwd)/0_dataset
AnalysisSchemasDir=$(pwd)/0_dataset/JSFResults/JSFErrorsAnalysis_schemas


# Vérifier si le fichier d'entrée existe
if [ ! -f "$inputFile" ]; then
    echo "Le fichier $inputFile n'existe pas"
    exit 1
fi

# Compter le nombre total d'objectID dans le fichier
total_object_ids=$(cut -d "," -f 1 "$inputFile" | tail -n +2 | sort -u | wc -l)

# Ajouter l'en-tête au fichier de sortie si le fichier n'existe pas encore
if [ ! -f "$outputFile" ]; then
    echo "error;objectId;taux" >> "$outputFile"
fi

# Initialiser un dictionnaire pour stocker les erreurs et les objectIDs associés
declare -A error_dict

# Parcourir chaque ligne du fichier d'entrée et extraire les erreurs JSON de la colonne "error"
count=0
while read -r line; do
    # Exclure la première ligne d'en-tête "error"
    if [ $count -gt 0 ]; then
        objectId=$(echo "$line" | cut -d "," -f 1)
        error=$(echo "$line" | cut -d "," -f 2 | cut -d "," -f 1-2 | sed -n "s/.*\/\([^\/]*\)$/\1/p" | sed 's/"$//')

        # Ajouter l'objetID à la liste des objectIDs associés à cette erreur dans le dictionnaire
if [ ! -z "$error" ]; then
    if [[ ${error_dict[$error]+_} ]]; then
        error_dict[$error]=${error_dict[$error]},$objectId
    else
        error_dict[$error]=$objectId
    fi
fi

    fi
    count=$((count+1))
done < "$inputFile"

# Écrire les erreurs, les objectIDs associés et les taux dans le fichier de sortie
for error in "${!error_dict[@]}"; do
    # Compter le nombre d'objectID associés à l'erreur en cours
    error_object_ids=$(echo "${error_dict[$error]}" | tr ',' '\n' | sort -u | wc -l)

    # Calculer le pourcentage d'objectID associés à l'erreur en cours par rapport à l'ensemble des objectID dans le fichier
    error_object_ids_pct=$(echo "scale=2; $error_object_ids/$total_object_ids*100" | bc)

    echo "$error;${error_dict[$error]};$error_object_ids_pct%" >> "$outputFile"

    # Créer le répertoire de schémas s'il n'existe pas encore
    if [ ! -d "$AnalysisSchemasDir/$error" ]; then
        mkdir "$AnalysisSchemasDir/$error"
    fi
    
    # Copier les fichiers de schémas correspondant à l'erreur dans le répertoire de schémas correspondant
    object_ids=$(echo "${error_dict[$error]}" | tr ',' '\n' | sort -u)
    for object_id in $object_ids; do
        cp "$schemasDir/$object_id.json" "$AnalysisSchemasDir/$error/$object_id.json"
    done
done
