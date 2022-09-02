#!/bin/bash
# Written by Kelmer Martins-Cunha (kelmermartinscunha@gmail.com)
# NOTE: In order to properly run this script, create a directory called 'rawdata' containing sequencing output files. Also, you'll need a folder with all tools used.

echo "Started running at `date`"
conda activate metaPeld
root=$(pwd)
#change root path to directory were "rawdata" is located

echo 'Annotate contigs (Fungi and Bacteria - RefSeq)'
kraken2-build --download-taxonomy --skip-maps --db ${ROOT}/tools/refseqFB
kraken2-build --download-library fungi --db ${ROOT}/tools/refseqFB
kraken2-build --download-library bacteria --db ${ROOT}/tools/refseqFB
kraken2-build --build --db ${ROOT}/tools/refseqFB
# Build database only if not provided (transfered from UFMG ec2 instance)

mkdir ${root}/04_taxonomy
cd ${root}/03_assembly/01_contigs
for file in *.fa; do
  kraken2 --db ${root}/tools/refseqFB --threads 4 --unclassified-out ${root}/04_taxonomy/unclassified_${file}.fastq --classified-out ${root}/04_taxonomy/classified_${file}.fastq --output ${root}/04_taxonomy/kraken2_output_${file} --minimum-base-quality 5 --report ${root}/04_taxonomy/kraken2_report_${file} --use-names ${file}.fa
# Change db path and number of threads for ec2 instance
done

echo 'Starting abundance estimation with Bracken...'
cd ${root}/04_taxonomy
for report in kraken2_report_*; do
  ${root}/tools/Bracken/bracken -d ${root}/tools/refseqFB -i kraken2_report_${report} -o bracken_report_sp_${report} -l S -t 100
  ${root}/tools/Bracken/bracken -d ${root}/tools/refseqFB -i kraken2_report_${report} -o bracken_report_gen_${report} -l G -t 100
  ${root}/tools/Bracken/bracken -d ${root}/tools/refseqFB -i kraken2_report_${report} -o bracken_report_fam_${report} -l F -t 100
# Change bracken and database path for ec2 instance
done
