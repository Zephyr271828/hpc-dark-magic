#!/bin/bash

if [[ $(hostname -f) == *"hpc.nyu.edu"* ]]; then

  echo "setting up configs for NYU Greene"

  # == set up sbatch commands == #
  export ACCOUNT="pr_133_tandon_advanced"
  export DEFAULT_PARTITION="tandon_h100_1"

  # == set up conda commands == #
  export LD_LIBRARY_PATH="${CUDA_HOME}/lib64:${LD_LIBRARY_PATH}"
  source /share/apps/anaconda3/2020.07/etc/profile.d/conda.sh
  conda activate $CONDA_ENV

  # == set up directories == #
  export PROJ_DIR="/scratch/$USER/Research/"
  export MODEL_DIR="/scratch/$USER/model_ckpts"

elif [[ $(hostname -f) == *"hpclogin"* ]]; then

  echo "setting up configs for NYU Shanghai HPC"

  # == set up sbatch commands == #
  export ACCOUNT=""
  export DEFAULT_PARTITION="sfscai"
  
  # == set up conda commands == #
  source /gpfsnyu/packages/miniconda/2023.2.7/etc/profile.d/conda.sh
  conda activate $CONDA_ENV
  source /etc/profile.d/modules.sh
  module load gcc/13.1.0

  # == set up directories == #
  export PROJ_DIR="/scratch/$USER/Research"
  export MODEL_DIR="/scratch/$USER/model_ckpts"
fi

generate_sbatch_header() {
  local job_name="${1:-cool_job}"
  local output_dir="logs"
  local cpus_per_task="$2"
  local account="${ACCOUNT}"
  local partition="${6:-${DEFAULT_PARTITION}}"
  local mem="${3:-64GB}"
  local ntasks="1"
  local time="$4"
  local gpus="$5"
  local mail_user="$USER@nyu.edu"

  export SBTACH_HEADER="#!/bin/bash

#SBATCH --job-name=$job_name
#SBATCH --output=$output_dir/$job_name.out
#SBATCH --error=$output_dir/$job_name.err
#SBATCH --cpus-per-task=$cpus_per_task
#SBATCH --account=$account
#SBATCH --partition=$partition
#SBATCH --mem=${mem}GB
#SBATCH --ntasks=$ntasks
#SBATCH --time=$time:00:00
#SBATCH --gres=gpu:$gpus
#SBATCH --mail-type=all
#SBATCH --mail-user=$mail_user
#SBATCH --requeue"
}

check_sbash() {
  if [[ "$SBASH_MODE" == "1" ]]; then
    TMP_SCRIPT=$(mktemp /tmp/sbatch_script.XXXXXX.sh)

    # == generate sbatch header == #
    generate_sbatch_header "$@"
    echo "$SBTACH_HEADER" > "$TMP_SCRIPT"

    # == source setup.sh explicitly == #
    echo "source \"$(realpath "${BASH_SOURCE%/*}/../configs/setup.sh")\"" >> "$TMP_SCRIPT"

    # == append the current script to the tmp script == #
    awk '
      BEGIN { skip = 0 }
      /^\s*check_sbash/ { skip = 1; next }
      skip { print }
    ' "$0" >> "$TMP_SCRIPT"

    sbatch "$TMP_SCRIPT"
    cat $TMP_SCRIPT
    rm $TMP_SCRIPT
    exit 0
  fi
}

# == usage == #
# == bash your_script.sh: directly execute your script == #
# == sbash your_script.sh: submit your script with sbatch == #