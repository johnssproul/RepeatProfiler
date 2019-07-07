#!/bin/bash


ls *.fa > fofnrefs.txt #makes .txt files containing file names for all .fa reference files. Right now this only works if the script is in the same directory as the reference sequence files.

##makes .txt files containing file names for all .fa reference files and adds DIR to a slash and wildcard search for a given file type, may be a way to make it work from any directory.
#ls ${DIR}/*.fa > fofn3.txt

#loops through fofnrefs.txt (reference file names) and makes indices for each.
BASE="refbase_" #****Need to fix this, this will need to match whatever bowtie is expecting

N1=1
while read line
do
    bowtie2-build $line $BASE
    echo "File names of reference sequences:"
    echo "$line" #haven't tested yet, does this work?
    ((N1 ++))
done < fofnrefs.txt 
#####block above probably needs to be in a separate script

