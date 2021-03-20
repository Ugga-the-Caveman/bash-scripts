#!/bin/bash

version="2021.03.20"
scriptName=$(basename $BASH_SOURCE)


function fnc_title()
{
	echo "$scriptName version $version"
	echo "by Ugga the Caveman"
	echo ""
}

function fnc_help()
{
	echo "Description: updates /usr/ugga_bash-scripts with files in DIRECTORY."
  echo "Additional Information on https://github.com/Ugga-the-Caveman/ugga_bash_scripts"
	echo ""
	echo "Usage: $scriptName DIRECTORY [Option]..."
	echo ""
	echo "Options:"
	echo " -h,--help		prints this help message"
	echo " -v,--version		prints script version"
	echo ""
	exit
}



#get parameters
option_version=false
option_help=false

thisDir=""

paramArray=( "$@" )
paramCount=${#paramArray[@]}

for (( index=0; $index<$paramCount; index++ ))
do
	thisParam="${paramArray[$index]}"
	
	if [ "$thisParam" == "-h" ] || [ "$thisParam" == "--help" ]
	then
		option_help=true
		
	elif [ "$thisParam" == "-v" ] || [ "$thisParam" == "--version" ]
	then
		option_version=true
  elif [ "$thisDir" == "" ]
	then
		thisDir="$thisParam"
	else
		fnc_title
		
		echo "error: invalid option $thisParam"
		echo ""
		
		fnc_help
		exit
	fi
done


if [ $option_version == true ]
then
	echo $version
	exit
fi



fnc_title



if [ $option_help == true ]
then
	fnc_help
	exit
fi


if [ "$(whoami)" != "root" ]
then
        echo "error: This script must be run as root."
        exit
fi


if [ ! -d $thisDir ] 
then
	echo "Error: DIRECTORY is not a directory."
	echo ""
	fnc_help
	exit
fi

destinationDir="/usr/ugga_bash_scripts"

echo  "script will overwrite $destinationDir with $thisDir"
read -p "Are you sure you want to continue? [y/N]: " answer

if [ "${answer:0:1}" == "y" ] || [ "${answer:0:1}" == "Y" ]
then
	echo "blöp"
fi


#chmod 755 ugga_bash_scripts -R
#sudo rm -r /usr/ugga_bash_scripts
#sudo mv ugga_bash_scripts /usr/ugga_bash_scripts
