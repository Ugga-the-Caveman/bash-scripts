#!/bin/bash

version="2021.05.02"
scriptName=$(basename $BASH_SOURCE)

function fnc_version()
{
	echo $version
	exit
}

function fnc_help()
{
	#Title
	echo "$scriptName version $version"
	echo "by Ugga the Caveman"
	echo ""
	echo "Description: format a string of numbers into the form of HH:MM:SS."
	echo "Usage: $scriptName STRING [Option]..."
	echo ""
	echo " -h,--help		prints this help message"
	echo " -v,--version		prints script version"
	echo ""
	exit
}

#get parameters
option_version=false
option_help=false
runtime=""

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
		
	elif [ "$runtime" == "" ]
	then
		runtime=$(echo "$thisParam" | sed 's/[^0-9]*//g')
		
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



if [ $option_help == true ]
then
	fnc_help
	exit
fi




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



if [ "$runtime" != "" ]
then
	fnc_runtime $runtime
fi


