#!/usr/bin/env bash
# -*- coding: utf-8 -*-


# author: xiaoy li
# file: train_zh_onto.sh
# device: 16G P100


REPO_PATH=/home/lixiaoya/mrc-for-flat-nested-ner
export PYTHONPATH="$PYTHONPATH:$REPO_PATH"
FILE_NAME=train_zh_onto

# data configuration
DATA_SIGN=zh_onto
# conll03, zh_msra, zh_onto, en_onto, genia, ace2004, ace2005
MODEL_SIGN=mrc-ner
ENTITY_SIGN=flat
NUM_DATA_PROCESSOR=1


# model params
MAX_LEN=260
DP=0.1
TRAIN_BZ=12
DEV_BZ=12
TEST_BZ=12
N_GPU=1


# training
OPTIM_TYPE=adamw
LR_SCHEDULER=ladder
LR=1e-5
LR_MIN=8e-6
NUM_EPOCH=6
WARMUP_STEP=500
WEIGHT_DECAY=0.01
GRAD_NORM=1.0
CHECKPOINT=600
GradACC=2


LOSS_TYPE=ce
START_LRATIO=1.0
END_LRATIO=1.0
SPAN_LRATIO=1.0


SEED=2333
DATA_BASE_DIR=/data
LOG_FILE=log.txt
DATA_PATH=${DATA_BASE_DIR}/mrc_ner_data/zh_onto4
BERT_PATH=${DATA_BASE_DIR}/pretrain_ckpt/chinese_L-12_H-768_A-12
EXPORT_DIR=${DATA_BASE_DIR}/output_mrc_ner
CONFIG_PATH=${REPO_PATH}/config/zh_bert.json
OUTPUT_PATH=${DATA_BASE_DIR}/output_mrc_ner/${DATA_SIGN}_${MAX_LEN}_${LR}_${TRAIN_BZ}_${DP}_${FILE_NAME}


rm -rf ${output_path}
mkdir -p ${output_path}


CUDA_VISIBLE_DEVICES=0 nohup python3 $REPO_PATH/run/train_bert_mrc.py \
--optimizer_type $OPTIM_TYPE \
--lr_scheduler_type $LR_SCHEDULER \
--lr_min $LR_MIN \
--loss_type $LOSS_TYPE \
--weight_decay $WEIGHT_DECAY \
--max_grad_norm $GRAD_NORM \
--data_dir $DATA_PATH \
--n_gpu $N_GPU \
--entity_sign $ENTITY_SIGN \
--num_data_processor $NUM_DATA_PROCESSOR \
--data_sign $DATA_SIGN \
--logfile_name $LOG_FILE \
--bert_model $BERT_PATH \
--config_path $CONFIG_PATH \
--output_dir $OUTPUT_PATH \
--dropout $DP \
--checkpoint $CHECKPOINT \
--max_seq_length $MAX_LEN \
--train_batch_size $TRAIN_BZ \
--dev_batch_size $DEV_BZ \
--test_batch_size $TEST_BZ \
--learning_rate $LR \
--weight_start $START_LRATIO \
--weight_end $END_LRATIO \
--weight_span $SPAN_LRATIO \
--num_train_epochs $NUM_EPOCH \
--seed $SEED \
--warmup_steps $WARMUP_STEP \
--gradient_accumulation_steps $GradACC \
--only_eval_dev &

sleep 1 && tail -f ${OUTPUT_PATH}/${LOG_FILE}

