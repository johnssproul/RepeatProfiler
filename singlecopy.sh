#!/bin/bash
rm -f The_summary.txt
echo "Reference	Sample_index	Read1	Read2	Total_reads	percent_mapped" > The_summary.txt #preparing the summary table

rm -f -r single_cvs
mkdir single_cvs
rm -f -r multi_poly
mkdir multi_poly

ls references_used/*_singlecopy.fa > fofnsingle.txt 2> /dev/null
echo ""

fofnsinglecheck=`cat fofnsingle.txt | wc -l`

if [[ $fofnsinglecheck == 0 ]];then #if both are empty then there was no reads of correct format to begin with
  echo "PROBLEM !"
  echo "No singlecopy genes sequences detected in the Refrence sequence file you provided. Make sure your single copy  refrence names in the Fasta file  end with _singlecopy "
  echo "more info can be found on the github page refer to repeatprof -h "
  exit 1
fi

echo "Normalization calcaulations is starting "

BASE="refbase_"
while read line ; do  # for each line  in the fofnrefs.txt we will loop through it and  carry the following analysis
  ref_char_count=`tail -n +2 $line | tr -cd 'ATGCatgc'  | wc -c` #this gets the refrence sequence length
  name_ref=$(awk -F "/" '{print $NF}' <<< $line) # this awk command is to get the refrence name from the path of references stored in fofnrefs.txt we did earlier
											   # this command sepeartes on / and get the last word which is the refrence name

  if [[ $ref_char_count == 0 ]]; then			   # if the  the length of the specfic refrence is 0 then just skip it.
											   # it skips it by just printing the below message and nothing else will be executed because everything done is in the else statemen of this
    echo ""
    echo "your $name_ref is an empty sequence or not in the correct format. It wont be analyzed or indexed. Please revise it " | tee -a Errors_README.log
    echo ""
  else
    echo "$(tail -n +2 $line)" > ref_temp.txt #this does something similar to above

    The_ref_size=`wc -c < ref_temp.txt` #same as above re_char_count

    bash $1/Readmegen.sh #this starts generating the readme. which will be populated later with the index to read conversions

    bowtie2-build $line $BASE > /dev/null 2> /dev/null # this build index for the current refrence
    echo "The reference sequence currently under analysis:"
    echo "$line"
    echo ""

    #bash index_refs.sh
    name_ref=$(awk -F "/" '{print $NF}' <<< $line) #same as above just to make sure

    Ref_name=$name_ref #assigning it to another variable

    stringe="$Ref_name"
    stringee="_output"
    the_output="$stringe$stringee" #i sum up both variables to create the suboutput folder for that refrence REFname_ouput. The one you see in the big folder

    numPairpile=1 #this will keep count of the index reads

echo "before"
    bash $1/map_mpileup.sh $line $2 $3 $4 $5

    retval=$?

    if [ $retval -ne 0 ]; then #if an error occured and the exit code isnt 0  then exit. The error message will be printed from singlecopy.sh not here
      exit 1
    fi

    while read pairpile # for each pair pile this means for each pileup output from the map_mpileup
    do
      F=`printf "%03d\n" $numPairpile` #this convert 1 to 001 for example this allow naming to be in order

      pile_counted_name="${Ref_name}_${F}" #this is the pileup counted name

      python $1/pileup_basecount_sink.py $pairpile $pile_counted_name $The_ref_size # this pileup script that counts mismatches from the sam pileup.out file and count depth and all aother info

      mv "$pile_counted_name.csv" single_cvs

      ((numPairpile ++))
    done < fofn_pileup.txt
  fi
done < fofnsingle.txt

rm -f  references_used/*_singlecopy.fa
rm -f fofn_pileup.txt
rm -f depth_counts.txt
#rm -f fofn_bam.txt
rm -f ReadMe.txt
rm -f index_conv.txt
rm -f -r multi_poly
