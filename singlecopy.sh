#!/bin/bash

##### This script (called from 'repeatprof') when the '-singlecopy' flag is used. It includes some steps from the 'repeatprof' script but makes them compatible with normalization.
##### this script only manages the read mapping (by calling 'singlecopy_map_reads.sh') and pileup for the singlecopy version of the run, the calculations that report normalized values are done in 'repeatprof'


##### directory management, checking of input file and error handling
rm -f The_summary.txt #removes old summary table
echo "Reference	Sample_index	Read1	Read2	Total_reads	percent_mapped" > The_summary.txt #preparing the summary table
DIR=`pwd`
rm -f -r single_cvs
mkdir single_cvs
rm -f -r multi_poly
mkdir multi_poly
refs_full_path=all_References.fa 
#ls references_used/*_singlecopy.fa > fofnsingle.txt 2> /dev/null
grep "_singlecopy" all_References.fa | sed 's/^.//'  > fofnsingle.txt

echo ""

fofnsinglecheck=`cat fofnsingle.txt | wc -l`

if [[ $fofnsinglecheck == 0 ]];then #if both are empty then there was no reads of correct format to begin with
  echo "PROBLEM !"
  echo "No singlecopy genes sequences detected in the reference sequence file you provided. Make sure your single copy reference names in the Fasta file end with '_singlecopy' "
  echo "more info can be found on the github page, or try repeatprof -h "
  exit 1
fi

echo "Starting normalization calculations"

##### end directory management, input checks and error handling



##### lots of code block is similar to 'repeatprof' but it runs versions of the commands/scripts compatible with normalization workflow.

BASE="refbase_"
while read line ; do  # for each line in the fofnrefs.txt we will loop through it and carry the following analysis
  
  line=$(echo $line | tr -cd "[:print:]\n")

  awk '/^>/ { if(NR>1) print "";  printf("%s\n",$0); next; } { printf("%s",$0);}  END {printf("\n");}'  $refs_full_path | grep -A 1 $line > temp.fa
  temp=`awk '/^>/ { if(NR>1) print "";  printf("%s\n",$0); next; } { printf("%s",$0);}  END {printf("\n");}'  $refs_full_path | grep -A 1 $line | tail -n1`

  ref_char_count=`echo $temp | wc -c` #this gets the reference sequence length
  name_ref=`tr ' 	\\<.,:#"/\|?*' '_' <<<"$line"` # this awk command is to get the reference name from the path of references stored in fofnrefs.txt we did earlier
											   # this command separates on / and get the last word which is the reference name

  if [[ $ref_char_count == 0 ]]; then			   # if the  the length of the specfic reference is 0 then just skip it.
											   # it skips it by just printing the below message and nothing else will be executed because everything done is in the else statemen of this
    echo ""
    echo "your $name_ref is an empty sequence or not in the correct format. It wont be analyzed or indexed. Please revise it " | tee -a Errors_README.log
    echo ""
  
  else

    The_ref_size=$ref_char_count #same as above re_char_count

	### this starts generating the readme. which will be populated later with the index to read conversions
    bash $1/readme_gen.sh 
    
    ### builds index for the current reference
   # bowtie2-build $line $BASE > /dev/null 2> /dev/null 
    
    echo "The reference sequence currently under analysis:"
    echo "$line"
    echo ""

    #bash index_refs.sh
   # name_ref=$(awk -F "/" '{print $NF}' <<< $line) #same as above just to make sure

    Ref_name=$name_ref #assigning it to another variable

    stringe="$Ref_name"
    stringee="_output"
    the_output="$stringe$stringee" #i sum up both variables to create the suboutput folder for that reference REFname_ouput. The one you see in the big folder
    numPairpile=1 #this will keep count of the index reads

refname_toextract="${name_ref%.*}"


echo "refnameto : $refname_toextract "
M=1
while read mastername
do 
F=`printf "%03d\n" $M` #this puts the number in format 001 for example

samtools index $mastername

samtools view  $mastername $line -o ${F}_sorted.bam  #we extract our aligned reference from the master bam for this read index 


#doing calculations used in the run_summary table
READ1=`sed -n "$M p"  fofn1.txt`
READ2=`sed -n "$M p"  fofn2.txt`
Read1name=$(awk -F "/" '{print $NF}' <<< $READ1) #seprates the read name on / and gets the last thing sperated
Read2name=$(awk -F "/" '{print $NF}' <<< $READ2)
allreads=`sed -n "$M p"  reads_lengths.txt`
mappedreads=`samtools view -F 0x4 ${F}_sorted.bam | cut -f 1 | sort | uniq | wc -l`

aligned=`echo "scale=4 ; $mappedreads / $allreads" | bc`

echo "mappedreads: $mappedreads"
echo "aligned : $aligned"
echo "${refname_toextract}	S${F}	$Read1name	$Read2name	$allreads	$aligned" >> The_summary.txt


	((M ++))

done < master_bams.txt 

N=1 #resets counter for new loop
MAX=`wc -l < fofn1.txt`

while ((N<=MAX))
	#if ((count<=max))
do
	F=`printf "%03d\n" $N`
	echo "calculating read depth at each position" #put a comment

## runs samtools mpileup
	samtools faidx temp.fa
	samtools mpileup -f temp.fa -q 0 -Q 13 -d 0 -A -o ${F}_pileup.out -O ${F}_sorted.bam 

	((N ++))
done #< RefList2.txt

ls ${DIR}/*.out > fofn_pileup.txt


echo "before"
	
	### runs a singlecopy version of the map_reads.sh script
  #  bash $1/singlecopy_map_reads.sh $line $2 $3 $4 $5 $6

    retval=$?

    if [ $retval -ne 0 ]; then #if an error occured and the exit code isnt 0 then exit. The error message will be printed from singlecopy.sh not here
      exit 1
    fi

    while read pairpile # for each pair pile this means for each pileup output from the map_mpileup
    do
      F=`printf "%03d\n" $numPairpile` #this convert 1 to 001 for example this allow naming to be in order

      pile_counted_name="${Ref_name}_${F}" #this is the pileup counted name

      ### runs a singlecopy version of the python basecount script
      python $1/pileup_basecount.py $pairpile $pile_counted_name $The_ref_size 
      mv "$pile_counted_name.csv" single_cvs

      ((numPairpile ++))
    done < fofn_pileup.txt
  fi
done < fofnsingle.txt

rm -f  references_used/*_singlecopy.fa
rm -f depth_counts.txt
#rm -f fofn_bam.txt
rm -f -r multi_poly

##### end script
