#!/bin/bash

version="2021.02.4"
scriptName=$(basename $BASH_SOURCE)


function fnc_title()
{
	echo "$scriptName version $version"
	echo "by Ugga the Caveman"
	echo ""
}


function fnc_help()
{
	echo "Description: Displays colors in the shell."
	echo ""
	echo "Usage: $scriptName [Option]..."
	echo "Options:"
	echo " -h,--help		prints this help message"
	echo " -v,--version		prints script version"
	echo ""
	exit
}

#get parameters
option_version=false
option_help=false

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



for C in {0..255}; do
    tput setab $C
    echo -n "$C "
done

tput sgr0

echo ""
