#!/bin/bash

scriptName=$(basename $BASH_SOURCE)
thisDir="$(echo $BASH_SOURCE | sed 's:/'$scriptName'::')/scripts"
destinationDir="/usr/ugga_bash_scripts"



if [ "$(whoami)" != "root" ]
then
        echo "error: This script must be run as root."
        exit
fi


echo  "The script is about to replace $destinationDir with $thisDir"
read -p "Are you sure you want to continue? [y/N]: " answer



if [ "${answer:0:1}" == "y" ] || [ "${answer:0:1}" == "Y" ]
then

	echo ""

	if [ -e $destinationDir ]
	then
		rm -r $destinationDir
	fi
	
	mkdir $destinationDir
	
	scriptfiles=$(find $thisDir -name "*.sh")
	thisArray=( $scriptfiles )
	arrayCount=${#thisArray[@]}
	
	for (( index=0; $index<$arrayCount; index++ ))
	do
		fullPath="${thisArray[$index]}"
		
		thisFile=$(echo $fullPath | sed 's:'$thisDir/'::')
		
		subDir="$(echo $thisFile | sed 's:/.*\.sh*$::')"
		
		if [ "$(echo $subDir | sed 's:.*\.sh*$::')" != "" ]
		then
			if [ ! -d "$destinationDir/$subDir" ]
			then
				mkdir -v "$destinationDir/$subDir"
			fi
		fi
		
		cp -v "$thisDir/$thisFile" "$destinationDir/$thisFile"
	done
	
	chmod 755 $destinationDir -R
fi
