#### This script (called from 'singlecopy.sh') begins making a readme that includes coverage factor conversions when '-singlecopy' flag is used. 

echo '								************************Repeat_Profiler***********************' > ReadMe.txt

echo "The tool indexes input reads and refers to them internally as numbers. In most cases it converts indexes back your read names,">> ReadMe.txt
echo "however, some output will refer to your reads by index number (i.e., the subfolders within each reference sequence output folder).">> ReadMe.txt
echo "Use the table below to translate index numbers back to your input reads as needed.">> ReadMe.txt
echo '		' >> ReadMe.txt

echo 'Index -> Reads:' >> ReadMe.txt
echo '		' >> ReadMe.txt
