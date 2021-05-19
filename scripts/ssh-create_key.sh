#!/bin/bash

version="2021.05.19"
scriptName=$(basename $BASH_SOURCE)

function fnc_version()
{
	echo $version
	exit
}

function fnc_help()
{
	echo "Description: Creates a ssh key pair and adds it to the authorized_keys file."
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
		echo "error: invalid option $thisParam"
		echo ""
		fnc_help
		exit
	fi
done

if [ $option_version == true ]
then
	fnc_version
	exit
fi



echo "$scriptName version $version"
echo "by Ugga the Caveman"
echo ""


if [ $option_help == true ]
then
	fnc_help
	exit
fi


benutzername="$(whoami)"

if [ $benutzername == "root" ]
then
	echo "You are not allowed to use root for ssh"
	exit
fi


homedirectory="$(getent passwd $benutzername | cut -d: -f6)"

if [ ! -d "$homedirectory" ]
then
	echo "Error: This user has no home directory."
	exit
fi





if [ ! -d "$homedirectory/.ssh" ]
then
	mkdir $homedirectory/.ssh
fi



keyname="localkey"

if [ -e "$homedirectory/.ssh/$keyname-public" ]
then
	rm "$homedirectory/.ssh/$keyname-public"
fi

if [ -e "$homedirectory/.ssh/$keyname-private" ]
then
	rm "$homedirectory/.ssh/$keyname-private"
fi



ssh-keygen -t ed25519 -o -a 100 -f "$homedirectory/.ssh/$keyname-private" -N "" < /dev/null >> /dev/null
mv "$homedirectory/.ssh/$keyname-private.pub" "$homedirectory/.ssh/$keyname-public"

cat "$homedirectory/.ssh/$keyname-public" >> "$homedirectory/.ssh/authorized_keys"



#cat "$homedirectory/.ssh/$keyname-private"
