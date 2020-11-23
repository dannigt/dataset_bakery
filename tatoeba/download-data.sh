#!/bin/bash

TMP_DIR=$DATA_DIR/tmp

mkdir -p $DATA_DIR
mkdir -p $TMP_DIR

echo 'TMP_DIR' $TMP_DIR

wget https://github.com/Helsinki-NLP/Tatoeba-Challenge/blob/master/Data.md -P $TMP_DIR

grep -io '<a href=['"'"'"][^"'"'"']*['"'"'"]'  $TMP_DIR/Data.md |
        sed -e 's/^<a href=["'"'"']//i' -e 's/["'"'"']$//i' |
        grep 'https://object.pouta.csc.fi/Tatoeba-Challenge.*tar' > $TMP_DIR/all_link.txt

cat $TMP_DIR/all_link.txt | while read line; do
        fname="$(basename -- $line)"
        if [ ! -f $DATA_DIR/$fname ]; then
#                if [[ $fname == *"eng"* ]]; then
                        echo '*** Downloading' $line
                        wget $line -P $DATA_DIR -q
                        sleep 3
#                fi
        fi
done

rm -r $TMP_DIR
