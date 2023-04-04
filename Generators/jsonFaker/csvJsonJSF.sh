#!/bin/bash

dataset=$1
withTimeout=$2

if [ $withTimeout == "true" ]
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

if [ ! -d $resultsPath ] 
then
    mkdir $resultsPath
else
	rm $resultsPath/*.json

fi

currentDate=$(date +"%d%m%Y_%Hh%Mm%Ss")
resultsFile=JSFResults_$currentDate.csv


echo "objectId,inSize,totalTime,generated" >> $resultsPath/$resultsFile



for schema in $(ls -rS $dataset)
do
	pathToSchema=$dataset/$schema
	if [ -f $pathToSchema ]
	then
		size=$(wc -c < $pathToSchema)
		echo $(date +"%d%m%Y_%Hh%Mm%Ss") : started processing $schema "(size : $size)"
		
		touch $resultsPath/$(basename $pathToSchema .json)"_witness".json
		
		start=$(date +%s%N | cut -b1-13)
		
		if [ $withTimeout == "true" ]
		then
			timeout $timeout generate-json $pathToSchema $resultsPath"/"$(basename $pathToSchema .json)"_witness".json
		else
			generate-json $pathToSchema $resultsPath"/"$(basename $pathToSchema .json)"_witness".json
		fi
		
		sizeWitness=$(wc -c < $resultsPath"/"$(basename $pathToSchema .json)"_witness".json)
		
		if [ $sizeWitness == "0" ]
		then
			generated=False
			rm $resultsPath"/"$(basename $pathToSchema .json)"_witness".json
		else
			generated=True
		fi
		
		end=$(date +%s%N | cut -b1-13)

		totalTime=$((end-start))

		echo "$(basename $pathToSchema .json),$size,$totalTime,$generated" >> $resultsPath/$resultsFile
	fi
    
done 
