

echo "ref	pos	depth	insertion	deletetion	median_ins	median_del" > ref_indels_001.txt


grep   -e  '\-[0-9][ATGCatgc*#]*\|\+[0-9][ATGCatgc*#]*' 001_pileup.out > indel_temp.txt


while read line 
do

# awk -v var=$t ' -1*$1 > var { print }'

echo $line > temp_indel                      
 
refname=$(cut -f1 -d " " temp_indel )
 
pos=$(cut -f2 -d " " temp_indel)
depth=$(cut -f4 -d " " temp_indel)
ins=$(cut -f5 -d " " temp_indel  | grep -o -e "\+[0-9]" | wc -l )
del=$(cut -f5 -d " " temp_indel  | grep -o -e  "\-[0-9]" |  wc -l )



median_ins=$(cut -f5 -d " " temp_indel   | grep -o -e "\+[0-9]"  | sed 's/+//g' | sort  | awk ' { a[i++]=$1; }
    END { x=int((i+1)/2); if (x < (i+1)/2) print (a[x-1]+a[x])/2; else print a[x-1]; }' )
median_del=$(cut -f5 -d " " temp_indel  | grep -o -e "\-[0-9]"  | sed 's/-//g' | sort  | awk ' { a[i++]=$1; }
    END { x=int((i+1)/2); if (x < (i+1)/2) print (a[x-1]+a[x])/2; else print a[x-1]; }' )





echo "$refname	$pos	$ins	$del $median_ins $median_del" >> ref_indels_001.txt

rm -f temp_indel





done < indel_temp.txt


