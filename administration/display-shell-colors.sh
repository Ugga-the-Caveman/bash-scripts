#!/bin/bash

version="2021.01.14"
scriptName=$(basename $BASH_SOURCE)


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


function fnc_version()
{
	echo $version
	exit
}

#get parameters
option_version=false
option_help=false

paramArray=( "$@" )
paramCount=${#paramArray[@]}

for (( index=0
; $index<$paramCount; index++ ))
do
	thisParam="${paramArray[$index]}"
	
	if [ "$thisParam" == "-h" ] || [ "$thisParam" == "--help" ]
	then
		option_help=true
	fi
	
	if [ "$thisParam" == "-v" ] || [ "$thisParam" == "--version" ]
	then
		option_version=true
	fi
done



if [ $option_version == true ]
then
	fnc_version
	exit
fi



#Title
echo "$scriptName version $version"
echo "by Ugga the Caveman"
echo ""



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
