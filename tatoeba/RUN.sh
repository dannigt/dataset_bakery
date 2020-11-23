#!/bin/bash

source ./config.sh

echo 'DATA_DIR' $DATA_DIR
echo 'BASE_DIR' $BASE_DIR

bash ./download-data.sh > 0_stdout-download.txt 2> 0_stderr-download.txt
echo '*** Finished downloading!'

bash ./extract-data.sh > 1_stdout-extract.txt 2> 1_stderr-extract.txt
echo '*** Finished extracting!'

bash ./tokenize-data.sh > 2_stdout-tokenize.txt 2> 2_stderr-tokenize.txt
echo '*** Finished tokenizing!'

bash ./binarize-data.sh > 3_stdout-binarize.txt 2> 3_stderr-binarize.txt
echo '*** Finished binarizing!'
