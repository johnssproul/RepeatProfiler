#!/bin/bash

Fasta_file=$1

Start=`cat -A $Fasta_file  | head -c1`
end=`cat -A $Fasta_file  | tail -c2`

if [[ $Start != '>' ]]; then 
 
echo "file dont appear to be in fasta format. it doesnt start with >"


exit 1 

fi 

if [[ $end != '$' ]]; then 


echo "Please make sure the file is unix formated. Which means it ends with an empty line. You can use tool like dos2unix to make sure it is"
exit 1 

fi 

while read line
do
    if [[ ${line:0:1} == '>' ]]
    then
	File_name=`tr '> 	\\<.,:#"/\|?*' '_' <<<"$line"`
	File_name_nofa=`tr '> 		<:#",/\\|?*' '_' <<<"$line"`
#	File_name=$line
	
	File_extention=".fa"

	File_name="${File_name:1}$File_extention"

	
	
	
	
	
	echo $File_name

        echo ">$File_name_nofa" > Refrences_used/$File_name
    else
        echo $line >> Refrences_used/$File_name
    fi
done < $Fasta_file



