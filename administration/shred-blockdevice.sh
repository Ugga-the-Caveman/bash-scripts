#!/bin/bash

version="2021.01.14"
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
	
	if [ "$device" == "" ]
	then
		device="$thisParam"
	fi
	
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



if [ "$device" == "" ];
then
	echo "Error: No Blockdevice specified."
	echo ""
	fnc_help
fi

test=0
disksize=$(blockdev --getsize64 $device) && test=1

if [ "$test" == "0" ];
then
	echo "Error: $device is not a blockdevice."
	echo ""
	fnc_help
fi




echo "Select the source."

sources=(/dev/zero /dev/random /dev/urandom)

select thisSource in "${sources[@]}"
do
	if [ "$REPLY" -ge "1" ] && [ "$REPLY" -le ${#sources[@]} ];
	then
		break;
	else
		echo "Bad Input. Enter a number between 1 and ${#sources[@]}."
	fi
done




blocksize=$(blockdev --getbsz $device)

disksize=$(lsblk $device -o SIZE | tail -n 1)


echo ""
echo "Selected Blockdevice: $device"
echo "Size of Blockdevice: $disksize"
echo "Block-Size: $blocksize Bytes"
echo "Selected Inputsource: $thisSource"




echo ""
echo "WARNING! The Script is about to erase all Data on the selected Device."
read -p "Enter uppercase 'YES' if you want to continue: " answer

if [ "$answer" == "YES" ];
then
	echo ""
	echo "`date +%X`: Erasing Data on $device started"
	
	startingtime=`date +%s`
	
	#dd if=$thisSource of=$device bs=$blocksize status=progress
	sleep 1.23;
	
	endingtime=`date +%s`
	
	echo "`date +%X`: Erasing Data on $device finished."
	
	runtime=$((endingtime-startingtime))
	echo -n "Runtime: "; fnc_runtime $runtime
	echo ""
else
	echo "Process canceled."
fi
