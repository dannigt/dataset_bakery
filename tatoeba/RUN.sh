#!/bin/bash

source ./config.sh

echo 'DATA_DIR' $DATA_DIR

bash ./download-data.sh > stdout-download.txt 2> stderr-download.txt
echo '*** Finished downloading!'

bash ./extract-data.sh > stdout-extract.txt 2> stderr-extract.txt
echo '*** Finished extracting!'
exit
bash ./tokenize-data.sh > stdout-tokenize.txt 2> stderr-tokenize.txt
echo '*** Finished tokenizing!'

bash ./binarize-data.sh > stdout-binarize.txt 2> stderr-binarize.txt
echo '*** Finished binarizing!'
