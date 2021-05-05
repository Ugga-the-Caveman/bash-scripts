#!/bin/bash

version="2021.02.02"
scriptName=$(basename $BASH_SOURCE)


function fnc_printTitle()
{
	echo "$scriptName version $version"
	echo "by Ugga the Caveman"
	echo ""
}


function fnc_printHelp()
{
	echo "Description: This script rsyncs / into the given DIRECTORY."
	echo "DIRECTORY must be a subdirectory of /mnt to prevent backup loops."
	echo ""
	echo "Usage: $scriptName DIRECTORY [Option]..."
	echo "Options:"
	echo " -h,--help		prints this help message"
	echo " -v,--version		prints script version"
	echo " -t,--timestamp	creates a subdirectory inside DIRECTORY, using local systemtime as name."
	echo ""
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




#get parameters
option_version=false
option_help=false
option_timestamp=false

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
		
	elif [ "$thisParam" == "-t" ] || [ "$thisParam" == "--timestamp" ]
	then
		option_timestamp=true
		
	elif [ "$thisDir" == "" ]
	then
		thisDir="$thisParam"

	else
		fnc_printTitle
		
		echo "error: invalid option $thisParam"
		echo ""
		
		fnc_printHelp
		exit
	fi
done



if [ $option_version == true ]
then
	echo $version
	exit
fi



fnc_printTitle



if [ $option_help == true ]
then
	fnc_printHelp
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
	fnc_printHelp
	exit
fi

# remove trailing /'s from DIRECTORY
thisDir=$(echo $thisDir | sed 's:/*$::')

if [ "$(echo $thisDir | grep "^/mnt/")" == "" ]
then
	echo "Error: DIRECTORY is not a subdirectory of /mnt."
	echo ""
	fnc_printHelp
	exit
fi




if [ $option_timestamp == true ]
then
	thisDir+="/$(date +%FT%H.%M.%S)"
fi



echo "The script is about to backup the system."
echo "All files in DIRECTORY will be overwritten."
echo "DIRECTORY: $thisDir"
echo ""
read -p "Are you sure you want to continue? [y/N]: " answer

if [ "${answer:0:1}" == "y" ] || [ "${answer:0:1}" == "Y" ]
then
	cd /
	
	startingtime=`date +%s`
	
	rsync -aAXvh --progress --delete / --exclude={"/lost+found","/dev/*","/mnt/*","/proc/*","/run/*","/sys/*","/tmp/*"} "$thisDir"
	
	endingtime=`date +%s`
	runtime=$((endingtime-startingtime))
	
	echo ""
	echo -n "Backup completed after "; fnc_runtime $runtime
	echo ""
else
	echo "Backup canceled."
fi

