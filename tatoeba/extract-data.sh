#!/bin/bash

for f in $DATA_DIR/*tar; do  # if only eng-X then use *eng*tar

        fname="${f##*/}"
	lan_pair="${fname%.*}"
        
	if [ ! -d $DATA_DIR/data/$lan_pair ]; then
                echo '*** Extracting' $f
                tar -xf $f --directory $DATA_DIR/
		
                if [ -f $DATA_DIR/data/$lan_pair/train.src.gz ]; then
			pigz -dc $DATA_DIR/data/$lan_pair/train.src.gz > $DATA_DIR/data/$lan_pair/train.src
                        pigz -dc $DATA_DIR/data/$lan_pair/train.trg.gz > $DATA_DIR/data/$lan_pair/train.trg

                        rm $DATA_DIR/data/$lan_pair/train.trg.gz
                        rm $DATA_DIR/data/$lan_pair/train.src.gz
                fi
        fi
done

