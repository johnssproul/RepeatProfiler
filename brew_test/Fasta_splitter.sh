#!/bin/bash

Fasta_file=$1



while read line
do
    if [[ ${line:0:1} == '>' ]]
    then
	File_name=`tr '> 	<.,:#"/\|?*' '_' <<<"$line"`
	File_name_nofa=`tr '> 		<:#",/\|?*' '_' <<<"$line"`
#	File_name=$line
	
	File_extention=".fa"

	File_name="${File_name:1}$File_extention"

	
	
	
	
	
	echo $File_name

        echo ">$File_name_nofa" > Repeat_Profiler_temp/$File_name
    else
        echo $line >> Repeat_Profiler_temp/$File_name
    fi
done < $Fasta_file



