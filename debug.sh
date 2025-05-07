source ../configs/setup.sh
check_sbash debug_%j 16 256 6 2 "tandon_h100_1,tandon_a100_1,tandon_a100_2"

export end_time="2025-05-08T10:00:00"
# e.g. 2025-05-07T10:00:00
python utils/debug.py --end-time ${end_time}

echo "Sleeping..."
sleep 2d