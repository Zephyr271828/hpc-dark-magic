#!/bin/bash

export tgt_host="$USER@hpclogin.shanghai.nyu.edu"
export tgt_dir="/scratch/$USER/model_ckpts"
export src_dir="/scratch/$USER/model_ckpts/Llama-3.1-8B-Instruct"

rsync -avz --progress ${src_dir} ${tgt_host}:${tgt_dir}