#! /bin/bash -x
# To test differnt BWA settings C Kidner 11 Dec 2018 Assumes trimmed
# reads are inteh folder in the form ${acc}_F.fq.gz, ${acc}_R.fq.gz

echo "Hello world"
echo -n "Which accession would you like to run through from reads to vcf?  Type just the accession name " 
read acc
echo "You picked to work with: $acc "
echo -n "which starting value would you like to use?  "
read n1
echo -n "Which value would you like to end with?  "
read n2
echo -n "Which step would you like to take?  Make sure this is divisible into the interval between starting and ending values " 
read step

value=$n1

while [ $value -le $n2 ]

do

fwd_p=${acc}_F.fq.gz
rev_p=${acc}_R.fq.gz
bam=${acc}_${value}_sorted.bam
stats=${acc}_${value}_stats

bwa mem Ref.fna -T $value $fwd_p $rev_p | samtools view -b -F 4 - > tmp.bam
samtools sort -n -T /tmp tmp.bam | samtools fixmate -mr - - | samtools sort -T /tmp -| samtools markdup -sr - $bam
samtools flagstat $bam > $stats
samtools index $bam
grep -m 1 "mapped " $stats >> Mapped.txt

value=$(($value + $step))

done

exit 0
