line=$1

while read line2;
do 
eval $line2 2> /dev/null


done < vars.txt
line=$(echo $line | tr -cd "[:print:]\n")

mkdir ${PWD}/${line}_tempi
cd ${PWD}/${line}_tempi



echo "$mydir"
echo "$fofncheck"
echo "why"

#echo $line | cat -v 
#exit 1

echo $line

echo $line
echo $refs_full_path

awk '/^>/ { if(NR>1) print "";  printf("%s\n",$0); next; } { printf("%s",$0);}  END {printf("\n");}'  ../all_References.fa | grep -A 1 $line > temp.fa
temp=`awk '/^>/ { if(NR>1) print "";  printf("%s\n",$0); next; } { printf("%s",$0);}  END {printf("\n");}'  ../all_References.fa | grep -A 1 $line | tail -n1`
#echo $temp

ref_char_count=`echo $temp | wc -c` #this gets the reference sequence length

echo $ref_char_count

name_ref=`tr ' 	\\<.,:#"/\|?*' '_' <<<"$line"` # this awk command is to get the reference name from the path of references stored in fofnrefs.txt we did earlier
echo $name_ref
											   # this command separates on / and get the last word which is the reference name

if [[ $ref_char_count == 0 ]]; then			   # if the  the length of the specfic reference is 0 then just skip it.
											   # it skips it by just printing the below message and nothing else will be executed because everything done is in the else statemen of this
echo ""
echo "your $name_ref is an empty sequence or not in the correct format. It will be ignored in this run. " | tee -a Errors_README.log
echo ""

else
The_ref_size=$ref_char_count #same as above re_char_count




  #  bowtie2-build $line $BASE > /dev/null 2> /dev/null # this build index for the current reference
    echo "The reference sequence currently under analysis:"
    echo "$line"
    echo ""

#bash index_refs.sh
name_ref=`tr ' 	\\<.,:#"/\|?*' '_' <<<"$line"`  #same as above just to make sure

Ref_name=$name_ref #assigning it to another variable

stringe="$Ref_name"
stringee="_output"
the_output="$stringe$stringee" #i sum up both variables to create the suboutput folder for that reference REFname_ouput. The one you see in the big folder
rm -f -r $the_output
mkdir $the_output


echo "$the_output" >>fofn_Theoutputs.txt #this appends the fofn_the outputs with the current name (it gets created by the first append at the first reference rest is appennding)
										 # keeping track of the folder names will help in the future when assigining stuff to each folder

##### end read mapping block




numPairpile=1 #this will keep count of the index reads



##### extracts sorted bam for each reference from master bam 

refname_toextract="$line"

M=1
while read mastername
do 
F=`printf "%03d\n" $M` #this puts the number in format 001 for example

samtools index ../$mastername

echo "$refname_toextract" | cat -v

echo $line

samtools view  ../$mastername $line -o ${F}_sorted.bam  #we extract our aligned reference from the master bam for this read index 
#doing calculations used in the run_summary table
READ1=`sed -n "$M p"  ../fofn1.txt`
READ2=`sed -n "$M p"  ../fofn2.txt`
Read1name=$(awk -F "/" '{print $NF}' <<< $READ1) #seprates the read name on / and gets the last thing sperated
Read2name=$(awk -F "/" '{print $NF}' <<< $READ2)
allreads=`sed -n "$M p"  ../reads_lengths.txt`
mappedreads=`samtools view -F 0x4 ${F}_sorted.bam | cut -f 1 | sort | uniq | wc -l`

aligned=`echo "scale=4 ; $mappedreads / $allreads" | bc`

echo "mappedreads: $mappedreads"
echo "aligned : $aligned"

echo "${refname_toextract}	S${F}	$Read1name	$Read2name	$allreads	$aligned" >> ../The_summary.txt


	((M ++))

done < ../master_bams.txt 

##### end extraction of bam files from master bam

##### this block uses mpileup to to gather variant and depth information from bam files, summarizes mipleup output with an external script and write output

N=1 #resets counter for new loop
MAX=`wc -l < ../fofn1.txt`
#Loops through all .bam files and does mpileup command.
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
echo "save me"
#exit 1
#exit 1

ls *.out > fofn_pileup.txt
ls *.bam > fofn_bam.txt

#name_ref

echo "name_poly" > multi_poly_names.txt #this creates a text file called multi_poly_names.txt this is used to keep track of the reads that we are drwaing the graphs for
										# LIKE for example Refrencename_001  001 reference to the read the index we talked about before
rm -f -r multi_poly
mkdir multi_poly
rm -f temp_cvs
mkdir temp_cvs #this store the current postion vs coverage depth of the current reference (this is used in r script)
cp ../index_conv.txt .
while read pairpile # for each pair pile this means for each pileup output from the map_mpileup
do

F=`printf "%03d\n" $numPairpile` #this convert 1 to 001 for example this allow naming to be in order

pile_counted_name="${Ref_name}_${F}" #this is the pileup counted name

echo $pile_counted_name >> multi_poly_names.txt #now populate the  multi_poly_names


## calls python script to summarize mpileup info

echo $The_ref_size
python $mydir/pileup_basecount.py $pairpile $pile_counted_name $The_ref_size # this script simplifies the output from the mpileup commmand above and makes a table of  file and count depth read depth and variant information for each sample

cp "$pile_counted_name.csv" ../map_depth_allrefs # cp the selected .csv produced by the python script
mv "$pile_counted_name.csv" temp_cvs #this moves it to temp_cvs  also. both steps are needed to be done because all_depths_cvs runs at the end for the all references statistcs   while temp_cvs just for this reference combined graphs and scaling

output=$Ref_name

stringpile2="$F"
stringpile3="_"
output="$output$stringpile3$stringpile2" #this just combines the output with its number to create the sub folder of the reference folder you see REF_001 for example where it contains the graphs

##### end mpileup and variant summary







########################################### begin plotting data for profile visualization ##########################################


##### makes variant plots for each sample using output from the python script above that summarizes variant and depth information

echo "$output" >> fofn_folders.txt #adds the name to the fofn_folders.txt

## calls R script that makes depth profiles that summarize variants


$Rscript $mydir/var_plots.R $output $R_packages 
rm -f -r $output
mkdir $output

mv  *.pdf  depth_counts.txt  $output
#mv $output $the_output  # we are not moving now we move in next pile up loop

((numPairpile ++))
done < fofn_pileup.txt #after finishing all the mapping and creating the csv files now we can start plotting graphs by scaling among all data
#loops through all samples and makes indiviual color ramp graphs and saves them in a folder
while read folder_names #for each line in folder name where we stored the folder name like REF_001
do

echo $folder_names #say it


## calls R script that makes color gradient profiles from read depth information
$Rscript $mydir/mk_profiles.R $folder_names $R_packages $Normalized $verticalplots

mv $folder_names $the_output
done < fofn_folders.txt

rm -f *.pdf
##This makes the combined colorful plots with plots from all samples for a given reference 
$Rscript $mydir/mk_profiles_ref.R $R_packages $Normalized


##This makes the combined variant plots with plots from all samples for a given reference 
$Rscript $mydir/multi_var_plots.R $R_packages

rm -f Rplots.pdf
#move R scripts to their relevant output folder
mv *scaled_profiles* $the_output
mv *.pdf $the_output
rm -f *.phy

##### end plotting of variant and color depth profiles



##### calls script that converts variant information for each profile into an alignment of molecular morphological characters for phylogenetic analysis
$Rscript $mydir/encode_var.R  > Closely_related_reads_analysis.txt

mv *.phy $the_output

#mv *variation_analysis* $the_output
rm -f Closely_related_reads_analysis.txt #we dont need this anymore

###### end variant summary in alignments




############## MAY REMOVE ######   It was used for validating all_corr analysis 

 # if [[ $@  ==  *"-corr"* ]]; then #if the user enter -corr check for user_groups.txt is in the same directory then run it and see if there is errors and run it
#  rm -f  R_correlation_errors.txt
# 
#  if [[ !(-f user_groups.txt) ]]; then
#  echo "user_groups.txt was not found. Matrix of pairwise correlation values will be generated, but no analysis of groups will be conducted." > R_correlation_errors.txt
#  fi
# 
# 
# ## if no errors, do prep for correlation analysis by calling external script that preps corr analysis (the output of this script isn't saved in the end, the final corr ouptut is generated by all_corr.R called below)
#  $Rscript $mydir/corr_test.R $the_output $R_packages $Normalized  2> /dev/null
# 
# 
#  if [ -f R_correlation_errors.txt ]; then
# 
#  mv R_correlation_errors.txt $the_output
#  fi
# 

#mv multi_poly $the_output    uncomment when testing
#mv multi_poly_names.txt $the_output

##### end initial prep for correlation analysis (that should may be removed, see ln 690)



##### This block moves output for a given reference to the relevant folders.

fi # end of pile up
if [[ -f ../fofn_bam.txt ]];
then
echo "exists"
else
cp fofn_bam.txt ..
fi
mv temp_cvs $the_output #for testing
#mv multi_poly $the_output #for testing
#mv multi_poly_names.txt $the_output #for testing
rm -f -r multi_poly_names.txt multi_poly
mv $the_output ../$The_folder
rm -f folder_names.txt

rm -f *bt2
rm -f -r temp_cvs
rm -f fofn_folders.txt
echo "$The_folder"
echo "done"


