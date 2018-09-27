#! /bin/bash -x
# to go from raw seq to consensus
# Assumes files are in form *_1.fastq.gz and are in the folder ~/Process/Hairdrier
# Assumes baits sequences are in the file Baits.fna and that a BWA index has been made using the command
# bwa index Baits.fna
# Catherine Kidner 26 Sept 2018


echo "Hello world"

acc=$1

F=~/Process/Hairdrier/${acc}_1.fastq.gz
R=~/Process/Hairdrier/${acc}_2.fastq.gz

output=${acc}_consensus.fna
rc=${acc}_rc.txt
vcf=${acc}.vcf.gz
Q_vcf=${acc}_qual.vcf.gz
bwa=${acc}_bwa_output
dup_bam=no_dup_${bam}

echo "You're working on accession $1"

# Trimmomatic
java -jar ~/../../opt/Trimmomatic-0.36/trimmomatic-0.36.jar PE -phred33 $F $R forward_paired.fq.gz forward_unpaired.fq.gz reverse_paired.fq.gz reverse_unpaired.fq.gz ILLUMINACLIP:~/../../opt/Trimmomatic-0.36/adapters/TruSeq3-PE.fa:2:30:10 LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36

# BWA
bwa mem Baits.fna forward_paired.fq.gz reverse_paired.fq.gz > output.sam 2> $bwa

#to sorted, de-duplicate, indexed bam
samtools view -bS output.sam | samtools sort -n -o namesort.bam
samtools fixmate -m namesort.bam fixmate.bam
samtools sort -o positionsort.bam fixmate.bam
samtools markdup -s -r positionsort.bam ~/Process/Hairdrier/$dup_bam 2>$report
samtools index ~/Process/Hairdrier/$dup_bam
rm output.sam
rm namesort.bam
rm fixmate.bam
rm positionsort.bam
rm *fastq.gz

# call 
bcftools mpileup -Ou -f Hannah_Begonia_baits.fna ~/Process/Hairdrier/$dup_bam  > $vcf
bcftools call -mv -Oz $vcf | bcftools filter -S . -i 'FMT/GT="1/1" & QUAL > 29' | bcftools view -Oz -o $Q_vcf
tabix $Q_vcf

# get consensus fasta from vcf
bcftools consensus -H A -f Hannah_Begonia_baits.fna  $Q_vcf > $output


exit 0
