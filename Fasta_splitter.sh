#!/bin/bash

##### This script is called by the 'repeatprof' script. It processes input references, does error handling, and organizes them for downstream analysis.

Fasta_file=$1

Start=`head -c1 $Fasta_file`
end=`tail -c1 $Fasta_file`

awk '/^>/ { if(NR>1) print "";  printf("%s\n",$0); next; } { printf("%s",$0);}  END {printf("\n");}'  $Fasta_file > all_References.fa


tr ' 	\\<.,:#"/\|?*' '_'  < all_References.fa >test.fa

 
cat test.fa  > all_References.fa




if [[ $Start != '>' ]]; then
  echo "file dont appear to be in fasta format. it doesnt start with >"
  exit 2
fi

if [[ ! -z $end  ]]; then
  echo "Please make sure the file is unix formated. Which means it ends with an empty line. You can use tool like dos2unix to make sure it is"
  exit 2
fi

echo "The references input:"


#awk 'sub(/^>/, "")' $Fasta_file > fofnrefs.txt


grep ">" all_References.fa | sed 's/>//'  > fofnrefs.txt



exit 0
