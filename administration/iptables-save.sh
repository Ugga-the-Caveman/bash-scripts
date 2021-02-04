#!/bin/bash

version="2021.01.31"
scriptName=$(basename $BASH_SOURCE)

function fnc_title()
{
	echo "$scriptName version $version"
	echo "by Ugga the Caveman"
	echo ""
}

function fnc_help()
{
	echo "Description: Saves iptables into /etc/iptables."
	echo ""
	echo "Usage: $scriptName [Option]..."
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


if [ "$(whoami)" != "root" ]
then
        echo "error: This script must be run as root."
        exit
fi



if [ -f "/etc/iptables/iptables.rules" ]
then
	echo "warning: /etc/iptables/iptables.rules allready exist."
fi

read -p "Do you want to save current iptables into /etc/iptables/iptables.rules? [y/N] " answer

if [ "${answer:0:1}" == "y" ] || [ "${answer:0:1}" == "Y" ]
then
        iptables-save > /etc/iptables/iptables.rules
fi

echo ""

if [ -f "/etc/iptables/ip6tables.rules" ]
then
	echo "warning: /etc/iptables/ip6tables.rules allready exist."
fi

read -p "Do you want to save current ip6tables into /etc/iptables/ip6tables.rules? [y/N] " answer

if [ "${answer:0:1}" == "y" ] || [ "${answer:0:1}" == "Y" ]
then
        ip6tables-save > /etc/iptables/ip6tables.rules
fi

