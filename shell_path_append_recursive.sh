#!/bin/bash

# this script appends given directories and all of the subdirectories to the PATH variable.
# how to use: source shellAppendpath.sh /dir1 /dir2 /dir3
# export PATH


appendpath () {
    case ":$PATH:" in
        *:"$1":*)
            ;;
        *)
			
            PATH="${PATH:+$PATH:}$1"
    esac
}



fnc_a () {
	for thisDir in $@
	do
		if [ -d "$thisDir" ]
		then
			appendpath $thisDir
			
			trimmedPath=$(echo $thisDir | sed 's:/*$::')

			for thisSubDir in $trimmedPath/*
			do
				if [ -d "$thisSubDir" ]
				then
					fnc_a "$thisSubDir"
				fi
			done
		fi
	done

}



for thisParam in $@
do
        fnc_a "$thisParam"
done

