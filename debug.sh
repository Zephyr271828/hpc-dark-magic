#!/bin/bash

source setup.sh
check_sbash debug_%j 16 256 6 1 "tandon_h100_1,tandon_a100_1,tandon_a100_2"

nohup python keep_alive.py --interval 1 --size 512 \
     > keepalive.log 2>&1 &

disown