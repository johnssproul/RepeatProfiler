#!/bin/bash
rm -f *.out *.bam *fofn*

currentDate=`date`
currentDate=`tr ' ' '_' <<<"$currentDate"`
rm -f Errors_README.txt
echo $currentDate


commands=$@ 

#echo "$(brew --cellar repeat)/$(brew list --versions repeat | tr ' ' '\n' | tail -1)/lib this lists all version paths 

#mydir=`echo "$(brew --cellar repeat)/1.0/libexec"`  #this is brew stuff
mydir=`pwd`
num_commands=`echo $commands | wc -w `

echo $num_commands
if ((num_commands == 0 ))
 then

echo "please use -h flag to view help menu for how to use this tool"

exit 1

fi

if (( num_commands < 4 ))
 then

echo "Not all madantory flags were used. please review a sample usage using  the  -h flag to view help menu"

exit 1

fi


The_folder="$currentDate"
mkdir $The_folder


BASE="refbase_"
commands=$@ 


#it works 	


if [[ -d $3 ]]; then
	refs=$3

elif [[ -f $3 ]]; then
	rm -f -r Repeat_Profiler_temp
		mkdir Repeat_Profiler_temp


echo "The refrences inputed:"

bash $mydir/Fasta_splitter.sh $3

refs=Repeat_Profiler_temp


else
    echo "The path to folder of Refrences files  or The path to your Refrecnes file is not valid"
    exit 1
fi
rm -f -r Errors.log  2> /dev/null
rm *bam *bt2  2> /dev/null
rm -f -r all_depth_cvs  2> /dev/null
mkdir all_depth_cvs




rm -f *out  2> /dev/null
ls $refs/*.fa > fofnrefs.txt 
echo "Reference	Sample_index	Read1	Read2	Total_reads	percent_mapped" > The_summary.txt

while read line
do

ref_char_count=`tail -n +2 $line | tr -cd 'ATGCatgc'  | wc -c`
name_ref=$(awk -F "/" '{print $NF}' <<< $line) 


if [[ $ref_char_count == 0 ]]; then
echo ""
echo "your $name_ref is an empty sequence or not in the correct format. It wont be analyzed or indexed. Please revise it " | tee -a Errors_README.log
echo ""


else

echo "$(tail -n +2 $line)" > ref_temp.txt

The_ref_size=`wc -c < ref_temp.txt`

bash $mydir/Readmegen.sh

    bowtie2-build $line $BASE > /dev/null 2> /dev/null
    echo "The name of the reference  sequence whose index was built and currently under analysis :"
    echo "$line" 
    echo ""
	


#bash index_refs.sh
name_ref=$(awk -F "/" '{print $NF}' <<< $line) 

Ref_name=$name_ref
ReadPair=1

stringe="$Ref_name"
stringee="_output"
the_output="$stringe$stringee"
rm -f -r $the_output
mkdir $the_output

echo "$the_output" >>fofn_Theoutputs.txt







numPairpile=1


if [ "$1" == "pileup" ]; then
p=8
if [[ $@  ==  *"-t"* ]]; then

commands=$@
p=`echo "$commands" | awk '{for (I=1;I<=NF;I++) if ($I == "-t") {print $(I+1)};}' `	
re='^[0-9]+$'
if ! [[ $p =~ $re ]] ; then
   p=8	
fi


echo "Threads used: $p"
fi

a="--very-sensitive-local"
commands=$@
array=(${commands})

for i in "${array[@]}"
do

if [[ $i  ==  "--very-fast" ]] || [[ $i  ==  "--local" ]] || [[ $i  ==  "--fast" ]] || [[ $i  ==  "--sensitive" ]] || [[ $i  == "--very-sensitive" ]] || [[ $i  ==  "--very-fast-local" ]] || [[ $i  ==  "--fast-local" ]] || [[ $i  ==  "--sensitive-local" ]] || [[ $i  ==  "--very-sensitive-local" ]]; then
		a=$i
    fi
done



if [[ $@  ==  *"-D"* ]]; then
commands=$@
a=`echo "$commands" | awk '{for (I=1;I<=NF;I++) if ($I == "-D") {print $I " " $(I+1) " " $(I+2) " " $(I+3)" " $(I+4) " " $(I+5) " " $(I+6) " " $(I+7) " " $(I+8) " " $(I+9) };}' `	


fi

echo "Bowtie2 alignment settings: $a"


bash $mydir/map_mpileup.sh $line $4 $2 $p $a 
retval=$?

if [ $retval -ne 0 ]; then
    
exit 1

fi

echo "name_poly" > multi_poly_names.txt
rm -f -r multi_poly
mkdir multi_poly
rm -f temp_cvs
mkdir temp_cvs
while read pairpile
do

F=`printf "%03d\n" $numPairpile`

pile_counted_name="${Ref_name}_${F}"

echo $pile_counted_name >> multi_poly_names.txt

python $mydir/pileup_basecount_sink.py $pairpile $pile_counted_name $The_ref_size


cp "$pile_counted_name.csv" all_depth_cvs
mv "$pile_counted_name.csv" temp_cvs

output=$Ref_name

stringpile2="$F"
stringpile3="_"
output="$output$stringpile3$stringpile2"
	
echo "$output" >> fofn_folders.txt
Rscript $mydir/polymorphism_2.0.R $output



rm -f -r $output	
	
mkdir $output
mv *.pdf  pileup_counted.txt  $output
#mv $output $the_output  # we are not moving now  we move in next pile up loop 
	
((numPairpile ++))

done < fofn_pileup.txt


while read folder_names
do


echo $folder_names

Rscript $mydir/RP_4.0.R $folder_names

mv $folder_names $the_output
done < fofn_folders.txt


Rscript $mydir/All_RP_graphs_reference.R

mv *Plots_all_reads_combined* $the_output

Rscript $mydir/multi_Poly_maker.R 

mv *all_Poly_reads_graphs_combinded* $the_output
rm -f phylip.phy
Rscript $mydir/fraction_bases.R > Closely_related_reads_analysis.txt

mv phylip.phy $the_output

mv *age_analysis* $the_output
mv Closely_related_reads_analysis.txt $the_output



	



if [[ $@  ==  *"-corr"* ]]; then

if [[ !(-f user_provided.txt) ]]; then

echo "user_provided.txt wasnt provided, so the graph of correlation between reads for a refrence  wont be produced. Only the matrix." >> Errors_README.log

fi

Rscript $mydir/Corr_test.R $the_output 2> R_correlation_errors.txt

mv R_correlation_errors.txt $the_output





fi






mv multi_poly $the_output
mv multi_poly_names.txt $the_output

mv *.bam *out ReadMe.txt $the_output
fi # end of pile up 
mv $the_output $The_folder
rm -f folder_names.txt

rm *bt2
rm -f -r temp_cvs
rm -f fofn_folders.txt

fi #this an fi for error handling dont mess with it. this is the end of the refrence
done < fofnrefs.txt

	


#rm -f *csv
Rscript $mydir/The_depth_analyser.R 2> /dev/null
Number=`wc -l < fofn_bam.txt`

rm -f -r all_graphs_scaled
mkdir all_graphs_scaled

Rscript $mydir/All_RP_graphs.R $Number
#mv *pdf all_graphs_scaled
mv all_graphs_scaled $The_folder


rm -f The_summary.txt ref_temp.txt bowtie.log Index_conv.txt *db.2*

mv Repeat_Profiler_temp $The_folder
mv all_depth_cvs $The_folder
mv The_summary_final.csv Errors_README.log $The_folder 2> /dev/null
mv *Rplots* $The_folder	

rm *fofn*

rm -f -r multi_poly
rm -f  *multi*

#design of the cow was borrowed from the famous cowsay command

echo "________________________________"                      
echo "< WOW what a great pipeline !!!! >"
echo "--------------------------------"
echo "       \   ^__^"       
echo "        \  (oo)\_______         "
echo "           (__)\       )\/\  "
echo "               ||----w |    "
echo "               ||     ||    "
