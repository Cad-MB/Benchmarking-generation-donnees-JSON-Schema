#!/bin/bash

dataset=$1
withTimeout=$2

if [ "$withTimeout" == "true" ]
then
    if [ $# -lt 3 ]
    then 
        echo Missing arguments
        exit
    else
        timeout=$3
    fi
fi    

resultsPath=$dataset/JSFResults

currentDate=$(date +"%d%m%Y_%Hh%Mm%Ss")
resultsFile=JSFResults.csv

# Ajouter la ligne "objectId,inSize,totalTime,generated,validated,error" uniquement si le fichier n'existe pas encore
if [ ! -f $resultsPath/$resultsFile ]; then
    echo "objectId;inSize;totalTime;generated;validated;error;Taux" >> $resultsPath/$resultsFile
fi

totalValidated=0
totalGenerated=0

for schema in $(ls -rS $dataset)
do
    for i in {1..20}
    do
        pathToSchema=$dataset/$schema
        if [ -f $pathToSchema ]
        then
            size=$(wc -c < $pathToSchema)
            echo $(date +"%d%m%Y_%Hh%Mm%Ss") : started processing $schema "(size : $size)"
            
            touch $resultsPath/$(basename $pathToSchema .json)"_witness_"$i.json
            
            start=$(date +%s%N | cut -b1-13)
            
            if [ "$withTimeout" == "true" ]
            then
                timeout $timeout generate-json $pathToSchema $resultsPath"/"$(basename $pathToSchema .json)"_witness_"$i.json
            else
                generate-json $pathToSchema $resultsPath"/"$(basename $pathToSchema .json)"_witness_"$i.json
            fi
            
            sizeWitness=$(wc -c < $resultsPath"/"$(basename $pathToSchema .json)"_witness_"$i.json)
            
            if [ $sizeWitness == "0" ]
            then
                generated=False
                validated=False
                error="empty file"
            else
                generated=True
                
                # Appel de la commande validate-json pour valider l'instance générée
                
                jsonschema -i $resultsPath"/"$(basename $pathToSchema .json)"_witness_"$i.json $pathToSchema
                
                if [ $? -eq 0 ]
                then
                    validated=True
                    error=""
                    ((totalValidated++))
                else
                    validated=False
                    error=$(jsonschema -i $resultsPath"/"$(basename $pathToSchema .json)"_witness_"$i.json $pathToSchema 2>&1)
                fi
            fi
            
            end=$(date +%s%N | cut -b1-13)

            totalTime=$((end-start))

            echo "$(basename $pathToSchema .json);$size;$totalTime;$generated;$validated;\"$error\"" >> $resultsPath/$resultsFile
            ((totalGenerated++))
        fi
    done 
done

if [ $totalGenerated -eq 0 ]
then
    rate=0
else
    rate=$(echo "scale=2; $totalValidated / $totalGenerated * 100" | bc)
fi

echo "Percentage of validated instances : $rate%" >> $resultsPath/$resultsFile