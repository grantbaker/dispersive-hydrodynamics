#!/bin/bash

IM_DIR="images/"
DATA_IM="_data.png"
REF_IM="_ref.png"

DATA_IM=$IM_DIR$1$DATA_IM
REF_IM=$IM_DIR$1$REF_IM

echo $DATA_IM
echo $REF_IM

cp "$DATA_IM" "dataim.png"
cp "$REF_IM" "refim.png"
