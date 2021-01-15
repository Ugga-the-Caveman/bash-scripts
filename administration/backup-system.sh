#!/bin/bash

function fnc_help()
{
	echo "Usage: backup-system.sh DIRECTORY [Option]..."
	echo "This script will create a backup of the operating system, into the specified Directory."
	echo ""
	echo " -h,--help               	prints this help message"
	echo " -t,--timestamp          	creates a subdirectory, using the current system-date and -time."
	echo " -s,--subdirectory [name]	creates a subdirectory with the specified name."
	exit
}

function fnc_exit()
{
	echo ""
	fnc_help
	exit
}

function fnc_runtime()
{
	runtime=$1
	runHours=0
	runMins=0
	runSecs=0

	if (($runtime == 0))
	then
		echo -n "0 Seconds"
		exit
	fi

	if (($runtime > 60))
	then
		runSecs=$((runtime % 60))
		runtime=$((runtime - runSecs))
	
		runtime=$((runtime / 60))
	
		if (($runtime > 60))
		then
			runMins=$((runtime % 60))
			runtime=$((runtime - runMins))
	
			runtime=$((runtime / 60))
		
			if (($runtime > 60))
			then
				runHours=$((runtime % 60))
				runtime=$((runtime - runHours))
	
				runtime=$((runtime / 60))
		
			else
				runHours=$runtime
			fi
		else
			runMins=$runtime
		fi
	
	else
		runSecs=$runtime
	fi


	separator1=""
	separator2=""

	if (($runHours > 0))
	then
		if (($runMins > 0)) && (($runSecs > 0))
		then
			separator1=", "
			separator2=" and "
		else
			if (($runMins > 0)) || (($runSecs > 0))
			then
				separator1=" and "
			fi
		fi

	else
		if (($runMins > 0)) && (($runSecs > 0))
		then
			separator2=" and "
		fi
	fi

	if (($runHours > 0))
	then
		echo -n "$runHours Hour"
	
		if (($runHours > 1))
		then
			echo -n "s"
		fi
	fi

	echo -n "$separator1"

	if (($runMins > 0))
	then
		echo -n "$runMins Minute"
	
		if (($runMins > 1))
		then
			echo -n "s"
		fi
	fi

	echo -n "$separator2"

	if (($runSecs > 0))
	then
		echo -n "$runSecs Second"
		
		if (($runSecs > 1))
		then
			echo -n "s"
		fi
	fi
}


## Checking for root privileges
if [ "$(whoami)" != "root" ]
then
	echo "This script must be run as root."
	exit
fi



## Checking parameters
if [ -z "$1" ];
then
	echo "You did not provide any parameters."
	fnc_exit
fi

option_help=false
option_t=false
option_s=false
subDir=""

paramArray=( "$@" )
paramCount=${#paramArray[@]}

for (( index=1; $index<$paramCount; index++ ))
do
	thisParam="${paramArray[$index]}"
	
	if [ "$thisParam" == "-h" ] || [ "$thisParam" == "--help" ]
	then
		option_help=true
	fi
	
	if [ "$thisParam" == "-t" ] || [ "$thisParam" == "--timestamp" ]
	then
		option_t=true
		subDir="$(date +%FT%H.%M.%S)"
	fi
	
	if [ "$thisParam" == "-s" ] || [ "$thisParam" == "--subdirectory" ]
	then
		option_s=true
		
		if [ $((index+1)) -lt $paramCount ]
		then
			subDir=${paramArray[$((index+1))]}
		else
			echo "Error: Option -s needs a subdirectory name"
			fnc_exit
		fi
		
	fi
done

if [ $option_help == true ]
then
	fnc_help
	exit
fi

if [ $option_s == true ] && [ $option_t == true ]
then
	echo "Error: You cannot use Option -s and option -t at the same time."
	fnc_exit
fi

if [ ! -d "$1" ] 
then
	echo "$1 is not a directory."
	fnc_exit
fi

if [ "$(echo $1 | grep "^/mnt")" == "" ]
then
	echo "The Backup-Directory has to be a subdirectory of /mnt/."
	fnc_exit
fi

# remove trailing /'s
backupDir=$(echo $1 | sed 's:/*$::')


if [ ! "$subDir" == "" ]
then
	temp=$(echo $subDir | sed 's:/*$::')
	backupDir=$backupDir/$temp
fi





echo ""
echo "trying to show rsync version..."
rsync --version


echo ""
echo "Ready to backup the system into $backupDir?"

if [ -d "$backupDir" ]
then
	if [ "$(ls $backupDir)" != "" ]
	then
		echo "Attention!!! This directory is not empty."
	fi
fi

read -p "Are you sure you want to continue? [y/N]: " answer

if [ "${answer:0:1}" == "y" ] || [ "${answer:0:1}" == "Y" ]
then
	cd /
	
	startingtime=`date +%s`
	
	rsync -aAXvh --progress --delete / --exclude={"/lost+found","/dev/*","/mnt/*","/proc/*","/run/*","/sys/*","/tmp/*"} "$backupDir"
	
	endingtime=`date +%s`
	runtime=$((endingtime-startingtime))
	
	echo ""
	echo -n "Backup completed after "; fnc_runtime $runtime
	echo ""
	
else
	echo "Backup canceled."
fi
