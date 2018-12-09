#! /bin/bash -x
# to gather a table of stats on vcf files 
# assumes list of samples in is text file List 
# assumes format of vcf files is ACC.vcf.gz run 
# as ./gather_vcf_stats.sh ref_vcf_file
 
 
# Catherine Kidner 9 Dec 2018
 
ref_vcf=$1 
echo "Hello world" 

while read f; do
echo "$f"
#generate the comparisons
	bcftools isec -p dir $ref_vcf "$f".vcf.gz
#Make the colums
	grep "GT:PL" dir/0000.vcf | grep -v "INDEL"| cut -f6 > qual_0
	grep "GT:PL" dir/0000.vcf | grep -v "INDEL"| cut -f8 | cut -f1 -d ";" | sed 's/DP=//g' > dep_0
	grep "GT:PL" dir/0001.vcf | grep -v "INDEL"| cut -f6 > qual_1
	grep "GT:PL" dir/0001.vcf | grep -v "INDEL"| cut -f8 | cut -f1 -d ";" | sed 's/DP=//g' > dep_1
	grep "GT:PL" dir/0002.vcf | grep -v "INDEL"| cut -f6 > qual_2
	grep "GT:PL" dir/0002.vcf | grep -v "INDEL"| cut -f8 | cut -f1 -d ";" | sed 's/DP=//g' > dep_2
#Join colums to a table
	paste dep_* > all_dep
	paste qual_* > all_qual
	paste all_dep all_qual > data 

	echo "Ref_dep    Sample_dep    Both_dep    Ref_qual    Sample_qual    Both_qual" > row1
	cat row1 data > "$f"_data
	rm -r dir
done < List

exit 0
