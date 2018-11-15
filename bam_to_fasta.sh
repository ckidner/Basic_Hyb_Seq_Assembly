#! /bin/bash -x
# to go from raw seq to consensus
# Assumes files are in form *_1.fastq.gz and are in the folder ~/Process/Hairdrier
# Assumes baits sequences are in the file Baits.fna and that a BWA index has been made using the command
# bwa index Baits.fna
# Catherine Kidner 10 Oct 2018


echo "Hello world"

acc=$1

F=~/Process/Hairdrier/${acc}_1.fastq.gz
R=~/Process/Hairdrier/${acc}_2.fastq.gz
report=${acc}_dup_report
output=${acc}_consensus.fna
Q_vcf=${acc}_qual.vcf.gz
bwa=${acc}_bwa.bam

echo "You're working on accession $1"

# Trimmomatic
#java -jar ~/../../opt/Trimmomatic-0.36/trimmomatic-0.36.jar PE -phred33 $F $R forward_paired.fq.gz forward_unpaired.fq.gz reverse_paired.fq.gz reverse_unpaired.fq.gz ILLUMINACLIP:~/../../opt/Trimmomatic-0.36/adapters/TruSeq3-PE.fa:2:30:10 LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36

# BWA
#bwa mem 1_ref.fna -B 20  forward_paired.fq.gz reverse_paired.fq.gz | samtools view -b -F 4 - > tmp.bam
# -B 20 sets  a high mapping stringency
# -b outpus as bam format
# -F 4 outputs only mapped reads

#rm *fq.gz

#to sorted, de-duplicated bam
#samtools sort -n -T /tmp tmp.bam | samtools fixmate -mr - - | samtools sort -T /tmp -| samtools markdup -sr - ~/Process/Hairdrier/$bwa
# -n sorts  by read names
# -T writes temprory files to specified folder
# -m marks best reads od uplicates for markdup to remove
# -r removes secondary reads and unmapped reads
# -s prins basic stats on duplicated reads
# -r removes duplicated reads

# call 
bcftools mpileup -B -Ou -f Baits.fna ~/Process/Hairdrier/$bwa  | bcftools call -c -Ou | bcftools filter -i 'QUAL>20 && DP>10' -Ou | bcftools view -o tmp.vcf
# -B disable re-calculation of P values to reduce false SNPs
# -Ou output as uncompressed for piping
# -m allow multialleic caller
# -v output varietn sites only
# -i include only those which match the filter (here for homozgous alternate)
# -c use oringal calling method

# index vcf file
# tabix $Q_vcf

# get consensus fasta from vcf
#bcftools consensus  -f Baits.fna  $Q_vcf > $output
perl vcfutils_fasta.pl vcf2fq  tmp.vcf > $output

exit 0

