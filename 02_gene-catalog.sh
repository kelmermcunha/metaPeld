#!/bin/bash
# Written by Kelmer Martins-Cunha (kelmermartinscunha@gmail.com)
# NOTE: In order to properly run this script, create a directory called 'rawdata' containing sequencing output files. Also, you'll need a folder with all tools used.

echo "Started running at `date`"
conda activate metaPeld
root=$(pwd)

cd ${root}/03_assembly
echo 'Predicting protein-coding genes for all samples contigs...'
prodigal -i all-samples-contigs.fasta -a all-samples-protein.faa -d all-samples-nucl.fna -o all-samples-coords -p meta


echo 'Gene dereplication for gene catalog generation...'
cd-hit -i all-sample-nucl.fna -o gene-catalog.fna -c 0.9 -n 5 -M 2000

echo 'Gene catalog funcional annotation...'
mkdir ${root}/04_gene-catalog
for dir in $(ls); do
  emapper.py -i gene-catalog.fna -o ${root}/04_gene-catalog-eggnog --data_dir /media/kelmer/44ABAB863891DC2D/Fungi-papers-desktop/Fungi-papers/Metagen__mica/Shotgun/kombucha/tools
# fix data-dir for ec2 instance
done

echo "Finished running at `data`"
