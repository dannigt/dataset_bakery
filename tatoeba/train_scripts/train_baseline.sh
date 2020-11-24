#!/bin/bash

# Followed the example at: https://github.com/pytorch/fairseq/blob/master/examples/multilingual/train_multilingual_model.sh

source ./config_35_lang.sh

CUDA_VISIBLE_DEVICES=$GPU fairseq-train \
    $BIN_DATA_DIR \
    --arch transformer --share-all-embeddings \
    --encoder-layers 8 --decoder-layers 8 \
    --encoder-embed-dim 512 --decoder-embed-dim 512 \
    --encoder-ffn-embed-dim 2048 --decoder-ffn-embed-dim 2048 \
    --encoder-attention-heads 8 --decoder-attention-heads 8 \
    --encoder-normalize-before --decoder-normalize-before \
    --dropout 0.2 --attention-dropout 0.2 --relu-dropout 0.2 \
    --weight-decay 0.0001 \
    --label-smoothing 0.1 --criterion label_smoothed_cross_entropy \
    --optimizer adam --clip-norm 0 \
    --lr-scheduler inverse_sqrt --warmup-updates 4000 --warmup-init-lr 1e-7 \
    --lr 1e-3 --min-lr 1e-9 \
    --max-tokens 4000 \
    --update-freq 4 \
    --save-interval 1 --save-interval-updates 5000 --keep-interval-updates 5 --no-epoch-checkpoints \
    --max-epoch 20 \
    --fp16 \
    --task translation_multi_simple_epoch \
    --sampling-method "temperature" \
    --sampling-temperature 1.5 \
    --encoder-langtok "tgt" \
    --decoder-langtok \
    --lang-pairs $LANG_PAIRS \
    --save-dir $OUT_DIR/baseline
