#!/bin/bash

FILE="#!$(which Rscript)"

echo "$FILE" | cat - functions.R > temp && mv temp functions.R
echo "$FILE" | cat - predict.R > temp && mv temp predict.R
echo "$FILE" | cat - model_train.R > temp && mv temp model_train.R
echo "$FILE" | cat - sahibinden.R > temp && mv temp sahibinden.R
