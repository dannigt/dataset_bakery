#!/bin/bash

source ./config_35_lang.sh

for source_lang in $LANS eng; do

	for target_lang in $LANS eng; do

		if [[ ! "$source_lang" == "$target_lang" ]]; then
			echo '*** Translating from' $source_lang 'to' $target_lang 
		
			CUDA_VISIBLE_DEVICES=$GPU fairseq-generate $BIN_DATA_DIR \
				--path $model \
				--task translation_multi_simple_epoch \
				--gen-subset test \
				--beam 5 \
				--source-lang $source_lang \
				--target-lang $target_lang \
				--encoder-langtok "tgt" \
				--decoder-langtok \
				--lang-pairs $LANG_PAIRS \
				--sacrebleu --remove-bpe 'sentencepiece'
		fi
	done
done

