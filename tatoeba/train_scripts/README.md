## Training

### Languages
The languages to be included into training can be modified in `config_*_lang.sh`.

### Models
#### baseline
```
bash train_baseline.sh 
```
#### drop residual once
```
bash train_r5.sh 
```
#### drop residual once + variational dropout
```
bash train_r5_vardrop.sh
```

## Inference
Run prediction (zero-shot and supervised) on the test sets:
```
bash pred.sh
```
