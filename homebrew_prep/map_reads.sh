#!/bin/bash

##### This script (called in 'repeatprof') loops through input reads, maps them to the reference sequences using bowtie2, 
##### processes output with samtools



##### defines variables
mkdir mapping_log_files
REF=$1 #the reference name is passed from the repeatprof script

BASE="refbase_" #this is for the indexed reference files that was built by bowtie2-build command in the repeatprof

reads=$2 #the reads path is passed from repeatprof
		
DIR=`pwd` #this is just the current dictionary

rm  -f -r master_bam

mkdir master_bam
echo "Read_Index	Readlength" > read_lengths.txt

##### Looks for input reads, does error handling prior to read mapping

if [ $3 = "-p" ]; then #if user specified paired data then look for this
  ls ${reads}/*_R1.fastq ${reads}/*_R1.gz ${reads}/*_R1.fq ${reads}/*_R1.fq.gz  ${reads}/*_1.fq ${reads}/*_1.fq.gz ${reads}/*_1.gz ${reads}/*_1.fastq > fofn1.txt 2>/dev/null

  ls ${reads}/*_R2.fastq ${reads}/*_R2.gz ${reads}/*_R2.fq ${reads}/*_R2.fq.gz  ${reads}/*_2.fq.gz  ${reads}/*_2.fq ${reads}/*_2.gz ${reads}/*_2.fastq > fofn2.txt 2>/dev/null
fi

if [ $3 = "-u" ]; then
# if user specified unpaired data then look for that. We use it double here because rest of the code was built on paired data, but dont worry it gets dealt with laterye

if [[ -f $reads ]]; then

if [[ $reads == *.fq ]] || [[ $reads == *.fastq ]] || [[ $reads == *.gz ]]; then 
ls $reads > fofn1.txt

ls $reads > fofn2.txt

else 

echo "The path to the unpaired reads file(s) is incorrect, or the file(s)format is not supported"

echo "Make sure the path is correct (note that spaces in directory names can cause errors). Make sure read files have '.fastq' or '.fq' extensions. Compressed (i.e., '.gz') formats also accepted (e.g., 'fastq.gz')."


fi 


else 
  ls ${reads}/*.fastq ${reads}/*.gz ${reads}/*.fq     > fofn1.txt 2>/dev/null

  ls ${reads}/*.fastq ${reads}/*.gz ${reads}/*.fq    > fofn2.txt 2>/dev/null


fi 

fi

#we check if the lines of the fofn for pair 1 is equal to lines fofn of pair 2 if not then give an error because that mean user has missing data if paired
reads1_check=`cat fofn1.txt | wc -l`
reads2_check=`cat fofn2.txt | wc -l `

if [[ $reads1_check == 0 && $reads2_check == 0 ]];then #if both are empty then there was no reads of correct format to begin with
  echo ""

  echo "The path to the paired reads file(s) is incorrect, or the file(s) is/are in a unsupported format"| tee -a Errors_README.log
  echo "Make sure the path is correct (including checking for blanks). Make sure read files have '.fastq' or '.fq' extensions. Compressed (i.e., '.gz') formats also accepted (e.g., 'fastq.gz')."| tee -a Errors_README.log
  
  exit 1
fi

if [ "$reads1_check" != "$reads2_check" ]; then
  echo "There is a pair of read missing. Ensure all reads read pairs are present in input directory"| tee -a Errors_README.log
  exit 1
fi

##### end error handling of input reads



##### loops through all read pairs and makes a variable of file names for each pair to feed to bowtie, calls bowtie to map reads, then converts output to .bam and sorts .bam with samtools

#counts number of lines in fofn1.txt and stores variable as MAX
MAX=`wc -l < fofn1.txt` #this gathers the length of one of the reads fofn.txt files and store that value (only the integer, not int+file name which is returned with standard syntax) as a variable.

N=1 #initiates a counter

echo "mapping reads"

echo "Read1	Read2	Index" > index_conv.txt   #builds index_conv which is used in Rscripts

while ((N<=MAX))
do
	F=`printf "%03d\n" $N` #this puts the number in format 001 for example
	READ1="$(sed "${N}q;d" fofn1.txt)"
	READ2="$(sed "${N}q;d" fofn2.txt)"

	Read1name=$(awk -F "/" '{print $NF}' <<< $READ1) #seprates the read name on / and gets the last thing separated
	Read2name=$(awk -F "/" '{print $NF}' <<< $READ2)
	echo "index= $F" >> ReadMe.txt
	echo "$Read1name	$Read2name	$F" >> index_conv.txt

  if [ $3 = "-p" ]; then
  	echo "Read1= $Read1name		Path: $READ1" >> ReadMe.txt
  	echo "Read2= $Read2name		Path: $READ2" >> ReadMe.txt
  fi

  if [ $3 = "-u" ]; then
  	echo "Read= $Read1name		Path: $READ1" >> ReadMe.txt
  fi

	echo "---------------------------------------------" >> ReadMe.txt
  REF_name=$(awk -F "/" '{print $NF}' <<< $REF)

	if [ $3 = "-p" ]; then
  	echo $READ1
  	echo $READ2
  fi

  if [ $3 = "-u" ]; then
  	echo $READ1
  fi

  if [ $3 = "-p" ]; then #if data is paired then run this
    (bowtie2 -p $4 -x $BASE -1 $READ1 -2 $READ2 $5    | samtools view -bS -h -F 4 /dev/stdin |  samtools sort -o  ${F}_sorted.bam  /dev/stdin) 2> mapping_log_files/${F}_bowtie.log
    retval=$? #catches exit code to check for error
	if [ $6 == "TRUE" ]
	then 
	echo "we are removing duplicates !"

    samtools sort -n -o namesort.bam ${F}_sorted.bam

    samtools fixmate -m namesort.bam fixmate.bam

    # Markdup needs position order
    samtools sort -o positionsort.bam fixmate.bam

    rm -f ${F}_sorted.bam
    # Finally mark and remove duplicates
	samtools markdup positionsort.bam ${F}_sorted.bam
	samtools flagstat ${F}_sorted.bam > mapping_log_files/${F}_dupicate_removal_info.txt
    samtools markdup -r positionsort.bam ${F}_sorted.bam

    rm -f  positionsort.bam fixmate.bam namesort.bam
fi

Read_length=`samtools view ${F}_sorted.bam | awk '{print length($10)}' |   sort -n -r | head -n1`

echo "${F}	${Read_length}" >> read_lengths.txt


  fi

  if [ $3 = "-u" ]; then #if data is unpaired then run that
    (bowtie2 -p $4 -x $BASE -U $READ1 $5   | samtools view -bS -h -F 4 /dev/stdin | samtools sort -o ${F}_sorted.bam /dev/stdin) 2> mapping_log_files/${F}_bowtie.log
    retval=$? #catches exit code to check for error
	if [ $6 == "TRUE" ]
	then 
	echo "we are removing duplicates !"

    samtools sort -n -o namesort.bam ${F}_sorted.bam

    samtools fixmate -m namesort.bam fixmate.bam

    # Markdup needs position order
    samtools sort -o positionsort.bam fixmate.bam

    rm -f ${F}_sorted.bam
    # Finally mark duplicates
	
	samtools markdup positionsort ${F}_sorted.bam
    samtools flagstat ${F}_sorted.bam > mapping_log_files/${F}_dupicate_removal_info.txt
	samtools markdup -r positionsort.bam ${F}_sorted.bam


    rm -f  positionsort.bam fixmate.bam namesort.bam

fi 
Read_length=`samtools view ${F}_sorted.bam | awk '{print length($10)}' |   sort -n -r | head -n1`

echo "${F}	${Read_length}" >> read_lengths.txt

 fi

  if [ $retval -ne 0 ]; then #if bowtie or samtools gave an error this will chatch  and terminate
    echo "Something is wrong with bowtie2 parameters that were input. Refer to repeatprof -h or the user manual for help"

    exit 1
  fi

  #does read mapping in bowtie, uses samtools to covert output to .bam, and sort .bam file.
  #allreads=`head -n 1 bowtie.log | grep -Eo '[+-]?[0-9]+([.][0-9]+)?'`
  
  
 #this checks if the read is actually in gzip format or not, so we know which way to count the reads for summary table 

if gzip -t $Read1; then
	echo "it is gzipped"
	allreads=`echo $(zcat $READ1|wc -l)/4|bc`

else 
	echo "using alternative counting method"

	allreads=`echo $(cat $READ1|wc -l)/4|bc`
fi

  
 # aligned=`tail -n 1 bowtie.log | grep -Eo '[+-]?[0-9]+([.][0-9]+)?'`
  
  #echo "${REF_name}	S${F}	$Read1name	$Read2name	$allreads	$aligned" >> The_summary.txt
  echo "$allreads" >> reads_lengths.txt 
  echo ""

	((N ++)) #increases the value of $N by one
done #< RefList2.txt

##### end read mapping and processing of output


##### cleans up ouptut
mv *.bam  master_bam

ls master_bam/*.bam > master_bams.txt

exit 0

##### end script
