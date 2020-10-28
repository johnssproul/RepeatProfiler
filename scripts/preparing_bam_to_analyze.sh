path_of_bam=$1
reference=all_References.fa






ls ${path_of_bam}/*.bam > fofn_pre_bams.txt

mkdir badfastqs
while read line
do
cur_bam=$line
#samtools index $cur_bam

samtools view $cur_bam | cut -f3 | sort | uniq > cur_bam_names.txt

countmatches_bam=$(grep  -c -f  cur_bam_names.txt $reference)
countmatches_refs=$(grep -c ">" $reference)
echo $countmatches_bam
echo $countmatches_refs


if [[ $countmatches_bam == $countmatches_refs ]]; then
echo "$line"

cur_bam_reads=$(samtools view -c $cur_bam)
cur_bam_reads=$(( cur_bam_reads + cur_bam_reads + cur_bam_reads + cur_bam_reads ))

bamname=$(awk -F "/" '{print $NF}' <<< $cur_bam)
echo "$bamname"
yes "pseudoreadplaceholder" | head -n $cur_bam_reads > badfastqs/${bamname}.fastq

else
    echo "${cur_bam} reference names dont match  reference names in fast file provided. Terminating run"
	exit 1 
fi


done < fofn_pre_bams.txt


#awk command to some for preparing the same file sed "s/${var//\//\\/}/replace/g"



