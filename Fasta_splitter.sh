#!/bin/bash

##### This script is called by the 'repeatprof' script. It processes input references, does error handling, and organizes them for downstream analysis.

Fasta_file=$1

Start=`head -c1 $Fasta_file`
end=`tail -c1 $Fasta_file`

if [[ $Start != '>' ]]; then
  echo "file dont appear to be in fasta format. it doesnt start with >"
  exit 2
fi

if [[ ! -z $end  ]]; then
  echo "Please make sure the file is unix formated. Which means it ends with an empty line. You can use tool like dos2unix to make sure it is"
  exit 2
fi

echo "The references input:"


while read line
do
  if [[ ${line:0:1} == '>' ]]
  then
  	File_name=`tr ' 	\\<.,:#"/\|?*' '_' <<<"$line"`
  	File_name_nofa=`tr ' 	\\<.,:#"/\|?*' '_' <<<"$line"`
    #	File_name=$line

  	File_extention=".fa"

  	File_name="${File_name:1}$File_extention"

	  echo $File_name | tee -a references_names_toextract.txt 

    echo "$File_name_nofa" > references_used/$File_name
  else
    echo $line >> references_used/$File_name
  fi
done < $Fasta_file

exit 0
