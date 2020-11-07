#!/bin/bash
FILE="#!$(which Rscript)"

if [[ "$(cat functions.R | head -n1)" != "$FILE" ]]; then
    echo "$FILE" | cat - functions.R > temp && mv temp functions.R
fi

if [[ "$(cat predict.R | head -n1)" != "$FILE" ]]; then
    echo "$FILE" | cat - predict.R > temp && mv temp predict.R
fi

if [[ "$(cat sahibinden.R | head -n1)" != "$FILE" ]]; then
    echo "$FILE" | cat - sahibinden.R > temp && mv temp sahibinden.R
fi

if [[ "$(cat model_train.R | head -n1)" != "$FILE" ]]; then
    echo "$FILE" | cat - model_train.R > temp && mv temp model_train.R
fi

sudo chmod +x *.R
