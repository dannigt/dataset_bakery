#!/bin/bash

PREPRO_DIR=$BASE_DIR/data/bpe_$BPESIZE
BIN_DATA_DIR=$BASE_DIR/data/bpe_${BPESIZE}_bin

mkdir $BIN_DATA_DIR -p

SHARED_DICT=$BIN_DATA_DIR/dict.txt

# combine all sentences to create a joint vocab
for f in $PREPRO_DIR/train/*; do
	cat $f >> $PREPRO_DIR/train/tmp.src
done

# We'll translate bidirectionally, therefore joint vocab on both sides are the same
ln -s $PREPRO_DIR/train/tmp.src $PREPRO_DIR/train/tmp.trg	

# create joint vocab
fairseq-preprocess \
  --source-lang src --target-lang trg \
  --trainpref $PREPRO_DIR/train/tmp \
  --destdir $BIN_DATA_DIR \
  --joined-dictionary \
  --workers $NUM_WORKER

rm $PREPRO_DIR/train/tmp.src $PREPRO_DIR/train/tmp.trg

# point to shared dictionary for reusing later
# use the same shared dictionary for all language pairs
ln -s $BIN_DATA_DIR/dict.src.txt $SHARED_DICT

# We split train/dev/test binarization in three steps due to possibly missing data
# (e.g. there is training data for one direction but no data in dev/test).

# binarize training set (en-X)
for f in $PREPRO_DIR/train/*eng*\.src; do
	fname="${f##*/}"
	lan_pair="${fname%.*}"
	lan_pair_path="${f%.*}"

	echo '*** Binarizing direction (train):' $lan_pair
	src_lang=$(echo $lan_pair | cut -f1 -d-) #(${lan_pair//-/ })
	trg_lang=$(echo $lan_pair | cut -f2 -d-)
	
	# prepare pointers to fit fairseq-preprocess
	ln -s $f $PREPRO_DIR/train/$src_lang-$trg_lang.$src_lang
	ln -s $f $PREPRO_DIR/train/$trg_lang-$src_lang.$src_lang
	ln -s $lan_pair_path.trg $PREPRO_DIR/train/$src_lang-$trg_lang.$trg_lang
	ln -s $lan_pair_path.trg $PREPRO_DIR/train/$trg_lang-$src_lang.$trg_lang

	# src --> trg
	fairseq-preprocess \
		--source-lang $src_lang --target-lang $trg_lang \
		--trainpref $PREPRO_DIR/train/$src_lang-$trg_lang \
		--destdir $BIN_DATA_DIR/ \
		--thresholdtgt 0 \
		--thresholdsrc 0 \
		--srcdict $SHARED_DICT \
		--tgtdict $SHARED_DICT \
		--workers $NUM_WORKER &

	# trg --> src
	fairseq-preprocess \
                --source-lang $trg_lang --target-lang $src_lang \
                --trainpref $PREPRO_DIR/train/$trg_lang-$src_lang \
                --destdir $BIN_DATA_DIR/ \
                --thresholdtgt 0 \
                --thresholdsrc 0 \
                --srcdict $SHARED_DICT \
                --tgtdict $SHARED_DICT \
                --workers $NUM_WORKER
	wait
done

# binarize dev set
for f in $PREPRO_DIR/dev/*\.src; do
        fname="${f##*/}"
        lan_pair="${fname%.*}"
	lan_pair_path="${f%.*}"

	echo '*** Binarizing direction (dev):' $lan_pair
        src_lang=$(echo $lan_pair | cut -f1 -d-) #(${lan_pair//-/ })
        trg_lang=$(echo $lan_pair | cut -f2 -d-)

        # prepare pointers to fit fairseq-preprocess
        ln -s $f $PREPRO_DIR/dev/$src_lang-$trg_lang.$src_lang
        ln -s $f $PREPRO_DIR/dev/$trg_lang-$src_lang.$src_lang
	ln -s $lan_pair_path.trg $PREPRO_DIR/dev/$src_lang-$trg_lang.$trg_lang
        ln -s $lan_pair_path.trg $PREPRO_DIR/dev/$trg_lang-$src_lang.$trg_lang

        fairseq-preprocess \
                --source-lang $src_lang --target-lang $trg_lang \
                --validpref $PREPRO_DIR/dev/$src_lang-$trg_lang \
                --destdir $BIN_DATA_DIR/ \
                --thresholdtgt 0 \
                --thresholdsrc 0 \
                --srcdict $SHARED_DICT \
                --tgtdict $SHARED_DICT \
                --workers $NUM_WORKER &

        # trg --> src
        fairseq-preprocess \
                --source-lang $trg_lang --target-lang $src_lang \
                --validpref $PREPRO_DIR/dev/$trg_lang-$src_lang \
                --destdir $BIN_DATA_DIR/ \
                --thresholdtgt 0 \
                --thresholdsrc 0 \
                --srcdict $SHARED_DICT \
                --tgtdict $SHARED_DICT \
                --workers $NUM_WORKER
	wait
done

# binarize test set
for f in $PREPRO_DIR/test/*\.src; do
        fname="${f##*/}"
        lan_pair="${fname%.*}"
	lan_pair_path="${f%.*}"
	
	if [[ $(wc -l <$f) -le 1000 ]]; then
		echo '*** Skipping test direction' $lan_pair 'because it has < 1000 sentences.'
	else
		echo '*** Binarizing direction (test):' $lan_pair
        	src_lang=$(echo $lan_pair | cut -f1 -d-)
	        trg_lang=$(echo $lan_pair | cut -f2 -d-)

        	# prepare pointers to fit fairseq-preprocess
        	ln -s $f $PREPRO_DIR/test/$src_lang-$trg_lang.$src_lang
            	ln -s $f $PREPRO_DIR/test/$trg_lang-$src_lang.$src_lang
		ln -s $lan_pair_path.trg $PREPRO_DIR/test/$src_lang-$trg_lang.$trg_lang
	        ln -s $lan_pair_path.trg $PREPRO_DIR/test/$trg_lang-$src_lang.$trg_lang

	        # src --> trg
	        fairseq-preprocess \
                --source-lang $src_lang --target-lang $trg_lang \
                --testpref $PREPRO_DIR/test/$src_lang-$trg_lang \
                --destdir $BIN_DATA_DIR/ \
                --thresholdtgt 0 \
                --thresholdsrc 0 \
                --srcdict $SHARED_DICT \
                --tgtdict $SHARED_DICT \
                --workers $NUM_WORKER &

        	# trg --> src
	        fairseq-preprocess \
                --source-lang $trg_lang --target-lang $src_lang \
                --testpref $PREPRO_DIR/test/$trg_lang-$src_lang \
                --destdir $BIN_DATA_DIR/ \
                --thresholdtgt 0 \
                --thresholdsrc 0 \
                --srcdict $SHARED_DICT \
                --tgtdict $SHARED_DICT \
                --workers $NUM_WORKER
		wait
	fi
done
