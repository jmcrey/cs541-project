#!/bin/bash

############################################################################################
##  Template of the argument reading and the usage pattern is taken from StackOverflow:   ##
##                                                                                        ##
##  https://stackoverflow.com/questions/16483119/an-example-of-how-to-use-getopts-in-bash ##
##                                                                                        ##
############################################################################################

usage() {
cat << EOF  
Usage: ./run.sh -m {albert,gpt3} -t {BoolQ,CB,COPA,MultiRC,RTE,ReCoRD,WSC,WiC} -d /path/to/data -o /path/to/output -c
Runs the training and evaluation of the SuperGLUE tasks on the specified model. Returns the results in the output directory specified.

    -h, --help                  Display help
    -m, --model                 The name of the model. One of {albert, gpt3}
    -t, --task                  The name of the SuperGLUE task. One of: {BoolQ, CB, COPA, MultiRC, RTE, 
                                ReCoRD, WSC, WiC}
    -c, --compressed            Whether or not the data directory is compressed (only supports tar.gz format)

EOF
}


options=$(getopt -l "help,model:,task:,output-dir:,compressed" -o "hm:t:o:c" -a -- "$@")
TASKS="BoolQ CB COPA MultiRC RTE ReCoRD WSC WiC"

# Default values
COMPRESSED=0
MAX_SEQ_LENGTH=256

# To be determined
MODEL_NAME_OR_PATH=""
MODEL_TYPE=""
TRAIN_TYPE=""
TASK=""
DATA_DIR=""
OUTPUT_DIR=""

eval set -- "${options}"

while true; do
    case $1 in
    -h|--help)
        usage
        exit 0
        ;;
    -m|--model)
        shift
        MODEL=$1
        if [ ${MODEL} == "gpt3" ]; then
            MODEL_NAME_OR_PATH="Nicki/gpt3-base"
            MODEL_TYPE="gpt2"  # Using gpt2 for compatibility with library
            TRAIN_TYPE="priming"
        elif [ ${MODEL} == "albert" ]; then
            MODEL_NAME_OR_PATH="albert-xxlarge-v2"
            MODEL_TYPE="albert"
            TRAIN_TYPE="pet"
        else
            echo "Invalid option for '-m|--model': ${MODEL}"
            usage
            exit 1
        fi
        shift
        ;;
    -t|--task)
        shift
        if echo $TASKS | grep -w -q -i $1; then
            TASK=$(echo $1 | awk '{print tolower($0)}')
        else
            echo "Invalid option for '-t|--task': ${1}"
            usage
            exit 1
        fi
        shift
        ;;
    -o|--output-dir)
        shift
        OUTPUT_DIR=$1
        shift
        ;;
    -c|--compressed)
        COMPRESSED=1
        shift
        ;;
    --)
        shift
        break
        ;;
    *)
        echo "Unexpected option discovered: {$1}"
        exit 1
        ;;
    esac
done

if [ ! -z ${TASK} ] & [ ! -z ${MODEL} ]; then
    DATA_DIR=data/${TASK}/
fi


if [ -z ${MODEL_NAME_OR_PATH} ] || [ -z "${MODEL_TYPE}" ] || [ -z "${TRAIN_TYPE}" ] || \
   [ -z ${TASK} ] || [ -z "${DATA_DIR}" ] || [ -z "${OUTPUT_DIR}" ]; then
    echo "Error: Missing required argument"
    usage
    exit 1
fi

case $TASK in
    boolq)
        PATTERN_IDS="3 5"
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
        echo "Unexpected Error: Pattern IDs for Task '${TASK}' Not Defined!"
        usage
        exit 1
esac

cat << EOF  
Starting training with the following parameters:

    - MODEL_TYPE="${MODEL_NAME_OR_PATH}"
    - MODEL_NAME_OR_PATH="${MODEL_TYPE}"
    - TRAIN_TYPE="${TRAIN_TYPE}"
    - MAX_SEQ_LENGTH="${MAX_SEQ_LENGTH}"
    - TASK="${TASK}"
    - PATTERN_IDS="${PATTERN_IDS}"
    - DATA_DIR="${DATA_DIR}"
    - OUTPUT_DIR="${OUTPUT_DIR}"

EOF


if [ ${TRAIN_TYPE} == "pet" ]; then
    python pet/cli.py \
    --method pet \
    --pattern_ids $(echo -n ${PATTERN_IDS}) \
    --data_dir ${DATA_DIR} \
    --model_type ${MODEL_TYPE} \
    --model_name_or_path ${MODEL_NAME_OR_PATH} \
    --task_name ${TASK} \
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
elif [ ${TRAIN_TYPE} == "priming" ]; then
    MAX_SEQ_LENGTH=5000
    python pet/cli.py \
    --method pet \
    --pattern_ids $(print ${PATTERN_IDS}) \
    --data_dir ${DATA_DIR} \
    --model_type ${MODEL_TYPE} \
    --model_name_or_path ${MODEL_NAME_OR_PATH} \
    --task_name ${TASK} \
    --output_dir ${OUTPUT_DIR} \
    --do_eval \
    --priming \
    --no-distillation \
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
else
    echo "Unexpected Internal Error: Value for `TRAIN_TYPE` is not supported"
    exit 1
fi
