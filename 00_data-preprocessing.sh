#!/bin/bash
# Written by Kelmer Martins-Cunha (kelmermartinscunha@gmail.com)
# NOTE: In order to properly run this script, create a directory called 'rawdata' containing sequencing output files. Also, you'll need a folder with all tools used.

echo "Started running at `date`"
conda activate metaPeld
root=$(pwd)
#change root path to directory were "rawdata" is located

echo "Raw data FASTQC visualization..."
mkdir ${root}/01_fastqc-outputs
mkdir ${root}/01_fastqc-outputs/00_raw-data
for file in $(ls './00_rawdata'); do
  SAMPLE=$(basename $file)
  fastqc ${ROOT}/rawdata/${SAMPLE} \ 
  -o ${ROOT}/fastqc-outputs/raw-data
done

echo "Trimmomatic with default parameters..."
mkdir ${root}/02_filtered-data
cd ${root}/00_rawdata
for file in *_1.fastq; do
  ARQNAME=${file%%_*}
  java -jar ${root}/tools/Trimmomatic-0.39/trimmomatic-0.39.jar PE -basein ${ARQNAME}_1.fastq \ 
  -baseout ${root}/02_filtered-data/${ARQNAME}.fastq \ 
  -phred33 \ 
   HEADCROP:24 \ 
   LEADING:3 \ 
   TRAILING:3 \ 
   SLIDINGWINDOW:4:15 \ 
   MINLEN:50
# fix path to trimmomatic inside ec2 isntance (create variable)
# remove 'headcrop' from test data
done

echo "Clean data FASTQC visualization..."
mkdir ${root}/01_fastqc-outputs/01_filtered-data
cd ${root}/02_filtered-data
for file in *P.fastq; do
  SAMPLE=$(basename $file)
  fastqc ${SAMPLE} \ 
  -o ${root}/01_fastqc-outputs/01_filtered-data
done

echo "Finished running at `date`"
