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
report=${acc}_dup_report
output=${acc}_consensus.fna
rc=${acc}_rc.txt
vcf=${acc}.vcf.gz
Q_vcf=${acc}_qual.vcf.gz
bwa=${acc}_bwa.bam
bwa_report=${acc}_bwa_report

echo "You're working on accession $1"

# Trimmomatic
java -jar ~/../../opt/Trimmomatic-0.36/trimmomatic-0.36.jar PE -phred33 $F $R forward_paired.fq.gz forward_unpaired.fq.gz reverse_paired.fq.gz reverse_unpaired.fq.gz ILLUMINACLIP:~/../../opt/Trimmomatic-0.36/adapters/TruSeq3-PE.fa:2:30:10 LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36

# BWA
bwa mem Baits.fna forward_paired.fq.gz reverse_paired.fq.gz > output.sam 2> $bwa_report

rm *fq.gz

#to sorted, de-duplicated bam
samtools view -bu output.sam | samtools sort -n -T /tmp - | samtools fixmate -mr - - | samtools sort -T /tmp -| samtools markdup -sr - ~/Process/Hairdrier/$bwa

#run without de-dup
#samtools view -bu output.sam | samtools sort -n -T /tmp - | samtools fixmate -mr - - | samtools sort - ~/Process/Hairdrier/$bwa

rm output.sam

# call 

bcftools mpileup -B -Ou -f Baits.fna ~/Process/Hairdrier/$bwa  | bcftools call -mv -Ou | bcftools filter -S . -i 'FMT/GT="1/1" & QUAL > 29' -Oz -o $Q_vcf

tabix $Q_vcf

# get consensus fasta from vcf
bcftools consensus  -f Baits.fna  $Q_vcf > $output


exit 0

