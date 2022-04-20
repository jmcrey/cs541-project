#!/bin/bash

declare -a TASKS=("cb" "copa" "multirc" "rte" "record" "wsc" "wic" "boolq")

MODEL_NAME_OR_PATH="albert-xxlarge-v2"
MODEL_TYPE="albert"
MAX_SEQ_LENGTH=256

for i in "${TASKS[@]}"; do

    case $i in
        boolq)
            PATTERN_IDS="0 3 5"
        ;;
        cb)
            PATTERN_IDS="0 1 2 3 4"
        ;;
        copa)
            PATTERN_IDS="0 1"
        ;;
        multirc)
            PATTERN_IDS="0 1 2 3"
            MAX_SEQ_LENGTH=512
        ;;
        rte)
            PATTERN_IDS="0 1 2 3 4"
        ;;
        record)
            PATTERN_IDS="0"
            MAX_SEQ_LENGTH=512
        ;;
        wsc)
            PATTERN_IDS="0 1 2"
        ;;
        wic)
            PATTERN_IDS="0 1 2"
        ;;
        *)
            echo "Unexpected Error: Pattern IDs for Task '${i}' Not Defined!"
            usage
            exit 1
    esac

    DATA_DIR="data/${i}/"
    OUTPUT_DIR="output/${MODEL_TYPE}/${i}/"

cat << EOF  
Starting training with the following parameters:
    - TASK="${i}"
    - MODEL_TYPE="${MODEL_NAME_OR_PATH}"
    - MODEL_NAME_OR_PATH="${MODEL_TYPE}"
    - MAX_SEQ_LENGTH="${MAX_SEQ_LENGTH}"
    - PATTERN_IDS="${PATTERN_IDS}"
    - DATA_DIR="${DATA_DIR}"
    - OUTPUT_DIR="${OUTPUT_DIR}"

EOF


    python pet/cli.py \
    --method pet \
    --pattern_ids $(echo -n ${PATTERN_IDS}) \
    --data_dir ${DATA_DIR} \
    --model_type ${MODEL_TYPE} \
    --model_name_or_path ${MODEL_NAME_OR_PATH} \
    --task_name ${i} \
    --output_dir ${OUTPUT_DIR} \
    --do_train \
    --do_eval \
    --pet_per_gpu_eval_batch_size 8 \
    --pet_per_gpu_train_batch_size 2 \
    --pet_gradient_accumulation_steps 8 \
    --pet_max_steps 250 \
    --pet_max_seq_length ${MAX_SEQ_LENGTH} \
    --pet_repetitions 3 \
    --sc_per_gpu_train_batch_size 2 \
    --sc_per_gpu_unlabeled_batch_size 2 \
    --sc_gradient_accumulation_steps 8 \
    --sc_max_steps 5000 \
    --sc_max_seq_length ${MAX_SEQ_LENGTH} \
    --sc_repetitions 1

done
