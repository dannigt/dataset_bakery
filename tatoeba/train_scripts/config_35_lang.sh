export BPESIZE=64000
export BIN_DATA_DIR=/home/dliu/data/lrt/tatoeba/data/bpe_${BPESIZE}_bin
export OUT_DIR=/home/dliu/data/lrt/tatoeba/data/

export GPU=0

export LANG_PAIRS=""

export LANS="afr bel bul cat cor dan deu ell fas fra gle glg hbs hin hye isl ita lav mar mkd nds nld nor pol por ron rus slv spa sqi swe ukr urd yid"

for lan in $LANS; do
        if [ -z "$LANG_PAIRS" ]; then
                LANG_PAIRS="${lan}-eng,eng-${lan}"
        else
                LANG_PAIRS="$LANG_PAIRS,${lan}-eng,eng-${lan}"
        fi
done

