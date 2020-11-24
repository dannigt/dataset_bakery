## Training

### Languages
The languages to be included into training can be modified in `config_*_lang.sh`.

### Models
#### baseline
```
bash train_baseline.sh 
```
#### drop residual once
To drop residual once, call `--drop-residual-at ENC_LAYER_NUMER`, for example in
```
bash train_r5.sh 
```
#### drop residual once + variational dropout
To use variational dropout instead normal dropout, call `--encoder-vardrop --decoder-vardrop`, for example in
```
bash train_r5_vardrop.sh
```

## Inference
Run prediction (zero-shot and supervised) on the test sets:
```
bash pred.sh
```
