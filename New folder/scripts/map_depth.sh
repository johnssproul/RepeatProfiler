#!/bin/bash
#index="aeruginosum.rDNA.reference.fa"

BASE="refbase_" #****Need to fix this


if [ "$1" == "" ]; then

DIR=`pwd`

fi
if [ "$1" != "" ]; then

DIR= $1

fi #makes variable = output of system pwd command


echo $DIR

#makes .txt files containing file names for all R1, R2, and .fa reference files. adds DIR to a slash and wildcard search for a given file type
#ls ${DIR}/*R1*.gz > fofn1.txt 
#ls ${DIR}/*R2*.gz > fofn2.txt 
#ls ${DIR}/*.fa > fofn3.txt


#ls $DIR *.fa > refs.txt #right now this only works if the script is in the same directory as the reference sequence files.
#ls *.fa > fofnrefs.txt ###right now this only works if the script is in the same directory as the reference sequence files.



 
MAX=`wc -l < fofn1.txt` #this gathers the length of one of the reads fofn.txt files and store that value (only the integer, not int+file name which is returned with standard syntax) as a variable.

N=1 #initiates a counter is N2 cause a previous block that was N1 has since been removed.
#loops through all reads file pairs and maps reads to reference sequence
while ((N<=MAX)) 
	#if ((count<=max))
do
	READ1="$(sed "${N}q;d" fofn1.txt)"
	READ2="$(sed "${N}q;d" fofn2.txt)"
	
	#READ3="$(sed "${N}q;d" fofn2.txt)" ###This is exactly the same as the previous command. It really needs to meet the needs of the -x command (find some clever way to make a unique base file name for each reference sequence)
	
	
	echo $READ1
	echo $READ2	
	echo $BASE
	
#	bowtie2 -p 1 -x $BASE -1 $READ1 -2 $READ2 | samtools view -bS -h -F 4 /dev/stdin | samtools sort -o ${N}_sorted.bam /dev/stdin ##need to update the samtools output name so it is unique and sensible for each iteration
	
	#echo -e "$count \c"
	#sleep 1 	
	((N ++))

done #< RefList2.txt


#ls ${DIR}/*.bam > fofn_bam.txt 
#echo -e "\n\nDONE!!"

MAX2=`wc -l < fofn1.txt` #this gathers the length of one of the reads fofn.txt files and store that value (only the integer, not int+file name which is returned with standard syntax) as a variable.

N=1 #initiates a counter is N2 cause a previous block that was N1 has since been removed. same as N2 above, which should be fine
while ((N<=MAX)) 
	#if ((count<=max))
do
	#BAMIN="$(sed "${N2}q;d" fofn_bam.txt)"
		
	echo $BAMIN
	
	#samtools sort -o ${N2}_sorted.bam $BAMIN #fix naming later
	samtools depth -aa -d 0 ${N}_sorted.bam > ${N}_mapped.depth.txt	
	
	#echo -e "$count \c"
	#sleep 1 	
	((N ++))

done #< RefList2.txt

ls ${DIR}/*.depth.txt > fofn_depth.txt 

echo $BASE > yarab.txt
