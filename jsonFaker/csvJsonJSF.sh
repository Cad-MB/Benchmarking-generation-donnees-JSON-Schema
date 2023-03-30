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
errorsFile=JSFErrors.csv

# Ajouter la ligne "objectId,inSize,totalTime,generated,validated,error" uniquement si le fichier n'existe pas encore
if [ ! -f "$resultsPath/$resultsFile" ]; then
    echo "objectId;inSize;totalTime;generated;validated" >> "$resultsPath/$resultsFile"
fi

# Ajouter la ligne "objectId,error" uniquement si le fichier n'existe pas encore
if [ ! -f "$resultsPath/$errorsFile" ]; then
    echo "objectId;error" >> "$resultsPath/$errorsFile"
fi

totalValidated=0
totalGenerated=0

for schema in $(ls -rS "$dataset")
do
    
    pathToSchema="$dataset/$schema"
    if [ -f "$pathToSchema" ]
    then
        size=$(wc -c < "$pathToSchema")
        echo "$(date +"%d%m%Y_%Hh%Mm%Ss") : started processing $schema (size : $size)"
        
        touch "$resultsPath/$(basename "$pathToSchema" .json)_witness.json"
        
        start=$(date +%s%N | cut -b1-13)
        
        if [ "$withTimeout" == "true" ]
        then
            timeout "$timeout" generate-json "$pathToSchema" "$resultsPath/$(basename "$pathToSchema" .json)_witness.json"
        else
            generate-json "$pathToSchema" "$resultsPath/$(basename "$pathToSchema" .json)_witness.json"
        fi
        

        sizeWitness=$(wc -c < "$resultsPath/$(basename "$pathToSchema" .json)_witness.json")
        
        if [ "$sizeWitness" == "0" ]
        then
            generated=False
            validated=False
            error="empty file"
            echo "$(basename "$pathToSchema" .json);\"$error\"" >> "$resultsPath/$errorsFile"
        else
            generated=True
            
            # Call the Python script with the schema and instance paths as arguments, and store the output in a variable
            output=$(python3 /mnt/c/Users/Surface/Documents/GitHub/Benchmarking-de-solutions-optimistes-pour-generation-de-donnees-test-partir-de-JSON-Schema/jsonFaker/validation.py "$(cat "$pathToSchema")" "$(cat "$resultsPath/$(basename "$pathToSchema" .json)_witness.json")")

            # Extract the valid and errors values from the output JSON
            valid=$(echo "$output" | awk '{print $1}')
            errors=$(echo "$output" | awk '{ $1=""; print $0 }')
            
            if [ "$valid" = "True" ]
            then
                validated=True
                error=""
                ((totalValidated++))
            else
                validated=False
                error=$errors
                echo "$(basename "$pathToSchema" .json);\"$error\"" >> "$resultsPath/$errorsFile"
            fi
        fi
        
        end=$(date +%s%N | cut -b1-13)

        totalTime=$((end-start))

                    echo "$(basename $pathToSchema .json);$size;$totalTime;$generated;$validated;" >> $resultsPath/$resultsFile
            ((totalGenerated++))
        fi
done

if [ $totalGenerated -eq 0 ]
then
    rate=0
else
    rate=$(echo "scale=2; $totalValidated / $totalGenerated * 100" | bc)
fi

echo "Percentage of validated instances : $rate%" >> $resultsPath/$resultsFile