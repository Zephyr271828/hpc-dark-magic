#!/bin/bash

source setup.sh
check_sbash debug_%j 16 256 6 1 

nohup python keep_alive.py --size 1024 > /dev/null 2>&1 &

sleep 2d