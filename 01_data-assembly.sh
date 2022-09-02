#!/bin/bash
# Written by Kelmer Martins-Cunha (kelmermartinscunha@gmail.com)
# NOTE: In order to properly run this script, create a directory called 'rawdata' containing sequencing output files. Also, you'll need a folder with all tools used.

echo "Started running at `date`"
conda activate metaPeld
root=$(pwd)
#change root path to directory were "rawdata" is located

echo 'Proceeding to assembly with MEGAHIT...'
mkdir ${root}/03_assembly
mkdir ${root}/03_assembly/01_contigs
cd ${root}/02_filtered-data
for file in *_1P.fastq; do
 ARQNAME=${file%%_*}
 megahit -1 ${ARQNAME}_1P.fastq \ 
 -2 ${ARQNAME}_2P.fastq \ 
 -m 7e9 \ 
 --presets meta-large
 -o ${root}/03_assembly/${ARQNAME}_megahit
 cp ${root}/03_assembly/${ARQNAME}_megahit/final.contigs.fa ${root}/03_assembly/01_contigs/${ARQNAME}.fa
done

echo 'Evaluating assembly with METAquast...'
cd ${root}/03_assembly/01_contigs
for dir in $(ls); do
  DIRNAME=${DIR%%_*}
  python ${root}/tools/quast/metaquast.py -o ${root}/03_assembly/${DIRNAME}_metaquast \ 
  ${DIR}.fa
# fix metaquast.py path in ec2 instance (create variable)
done

echo 'Create all sample contig file...'
cat ${root}/03_assembly/01_contigs/*.fa > ${root}/03_assembly/all-samples-contigs.fasta

echo "Finished running at `date`"
