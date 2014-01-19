#!/bin/bash
DATA_DIR=${PWD}/Images/
TEMPLATE_DIR=${DATA_DIR}/Template/
OUT_DIR=${PWD}/Output/

export ANTSPATH=/Users/ntustison/Pkg/ANTs/bin/bin/

bash ${ANTSPATH}antsAtroposN4.sh \
  -d 2 \
  -a ${DATA_DIR}/KKI2009-01-MPRAGE_slice150.nii.gz \
  -x ${DATA_DIR}/KKI2009-01-MPRAGE_slice150_mask.nii.gz \
  -p ${DATA_DIR}/priorWarped%d.nii.gz \
  -c 3 \
  -o ${OUT_DIR}example
