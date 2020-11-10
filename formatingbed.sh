while read line_bed;
	do
		echo "changing names in bed"
		line_bed=$(echo $line_bed | cut -f1 )
		echo $line_bed

		name_edited=$(echo $line_bed | tr ' \\<.,:#"/\|?%' '_')
		sed -i 's/"$line_bed"/"$name_edited"/g' bedfile_toanalyze.bed
		
	done < bedfile_toanalyze.bed
