#!/bin/bash

PREPRO_DIR=$BASE_DIR/data/bpe_$BPESIZE

mkdir $PREPRO_DIR -p
echo 'PREPRO_DIR' $PREPRO_DIR
##### learn BPE #####
# cap the number of sents per direction to a maximum when learning BPE
# taking english only once to avoid BPE being biased to English

for f in `ls $DATA_DIR/data/*-eng/train.src $DATA_DIR/data/eng-*/train.trg $DATA_DIR/data/deu-eng/train.trg`; do
        head -70000 $f >> $PREPRO_DIR/learn_bpe_input.tmp
done

spm_train \
--input=$PREPRO_DIR/learn_bpe_input.tmp \
--model_prefix=$PREPRO_DIR/sentencepiece.bpe \
--vocab_size=$BPESIZE \
--character_coverage=1.0 \
--model_type=bpe

rm $PREPRO_DIR/learn_bpe_input.tmp

##### apply BPE #####
echo '*** Will spawn' $(ls $DATA_DIR/data/*eng*/train.src | wc -l) 'processes for X-en training sets'

# apply BPE on X-en training sets
for ext in src trg; do
	
	mkdir $PREPRO_DIR/train -p

        for f in `ls -S $DATA_DIR/data/*eng*/train\.$ext`; do

                lan_pair=`echo $f | rev | cut -d/ -f2 | rev`

                echo '*** Applying BPE to' $f 
                spm_encode \
                        --model=$PREPRO_DIR/sentencepiece.bpe.model \
                        --output_format=piece \
                        --vocabulary_threshold=50 < $f > $PREPRO_DIR/train/$lan_pair.$ext &
        done
        wait
done

# apply BPE on all dev and test sets
echo '*** Will spawn' $(ls $DATA_DIR/data/*/dev.src | wc -l) 'processes for X-en dev sets'
echo '*** Will spawn' $(ls $DATA_DIR/data/*/test.src | wc -l) 'processes for all test sets'
mkdir $PREPRO_DIR/$set -p

for set in dev test; do

        mkdir $PREPRO_DIR/$set -p

        for ext in src trg; do

                for f in `ls -S $DATA_DIR/data/*/$set\.$ext`; do

                        lan_pair=`echo $f | rev | cut -d/ -f2 | rev`

                        echo '*** Applying BPE to' $f 
                        spm_encode \
                        --model=$PREPRO_DIR/sentencepiece.bpe.model \
                        --output_format=piece \
                        --vocabulary_threshold=50 < $f > $PREPRO_DIR/$set/$lan_pair.$ext &
                done
                wait
        done
        wait
done

exit
for ext in src trg; do

	for f in `ls -S $DATA_DIR/data/*/test\.$ext`; do

		lan_pair=`echo $f | rev | cut -d/ -f2 | rev`

		echo '*** Applying BPE to' $f 
                spm_encode \
			--model=$PREPRO_DIR/sentencepiece.bpe.model \
                        --output_format=piece \
                        --vocabulary_threshold=50 < $f > $PREPRO_DIR/$set/$lan_pair.$ext &
        done
	wait
done

