#!/bin/bash


version="2021.01.15"
scriptName=$(basename $BASH_SOURCE)

function fnc_version()
{
	echo $version
	exit
}

function fnc_help()
{
	echo "Description: Write random bits to BLOCKDEVICE to securely erase all data from it."
	echo "Usage: shred-blockdevice.sh BLOCKDEVICE [Option]..."
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





echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
echo "en_DK.UTF-8 UTF-8" >> /etc/locale.gen
echo "de_DE.UTF-8 UTF-8" >> /etc/locale.gen
echo "/etc/locale.gen created"

locale-gen

echo "LANG=en_DK.UTF-8" > /etc/locale.conf
echo "LANGUAGE=en_US.UTF-8" >> /etc/locale.conf
echo "LC_MONETARY=de_DE.UTF-8" >> /etc/locale.conf
echo "/etc/locale.conf created"

echo "KEYMAP=de-latin1" > /etc/vconsole.conf
echo "FONT=lat9w-16" >> /etc/vconsole.conf
echo "/etc/vconsole.conf created"

ln -sfv /usr/share/zoneinfo/Europe/Berlin /etc/localtime


