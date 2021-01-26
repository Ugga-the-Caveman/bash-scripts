#!/bin/bash


version="2021.01.27"
scriptName=$(basename $BASH_SOURCE)

function fnc_version()
{
	echo $version
	exit
}

function fnc_help()
{
	echo "Description: sets up german locale configuration."
	echo "Usage: $scriptName [Option]..."
	echo ""
	echo " -h,--help		prints this help message"
	echo " -v,--version		prints script version"
	echo ""
	exit
}


#get parameters
option_version=false
option_help=false
device=""

paramArray=( "$@" )
paramCount=${#paramArray[@]}

for (( index=0; $index<$paramCount; index++ ))
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



if [ "$(whoami)" != "root" ]
then
	echo "This script can only be run as root."
	exit
fi





echo "LANG=en_DK.UTF-8" > /etc/locale.conf
echo "LANGUAGE=en_US.UTF-8" >> /etc/locale.conf
echo "LC_MONETARY=de_DE.UTF-8" >> /etc/locale.conf

echo "#/etc/locale.conf"
cat /etc/locale.conf
echo ""




echo "KEYMAP=de-latin1" > /etc/vconsole.conf
echo "FONT=lat9w-16" >> /etc/vconsole.conf

echo "#/etc/vconsole.conf"
cat /etc/vconsole.conf
echo ""




ln -sfv /usr/share/zoneinfo/Europe/Berlin /etc/localtime




echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
echo "en_DK.UTF-8 UTF-8" >> /etc/locale.gen
echo "de_DE.UTF-8 UTF-8" >> /etc/locale.gen

echo ""

locale-gen

