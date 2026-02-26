#!/bin/bash

RED='\033[0;31m'      # Fixed: single \
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

if ! command -v mpstat &> /dev/null; then
    echo -e "${RED}sysstat missing${NC}"
    exit 1
fi

load_pids=()

cleanup() {
    echo -e "${RED}Stopping generators...${NC}"
    for pid in "${load_pids[@]}"; do
        kill $pid 2>/dev/null || true
    done
    exit 0
}

trap cleanup SIGINT SIGTERM

while true; do
    output=$(mpstat -P ALL 5 1)
    avg_usage=$(echo "$output" | awk '/Average:/ && $2 ~ /[0-9]/ {total+=$NF; count++} END {print 100-total/count}')

    # ACTUAL running count (ps check)
    running_generators=$(ps -C python3 -o pid= | wc -l)

    echo -e "${YELLOW}CPU: $avg_usage%. Generators: $running_generators (array:${#load_pids[@]})${NC}"

    if (( $(echo "$avg_usage < 12.0" | bc -l) )); then
        echo -e "${GREEN}Starting 5 generators...${NC}"
        for i in {1..5}; do
            python3 /home/ansible/loadscripts/load_generator.py 0.01 & load_pids+=($!)
        done
    elif (( $(echo "$avg_usage >=12 && $avg_usage < 15" | bc -l) )); then
        echo -e "${GREEN}Starting 1 generator...${NC}"
        python3 /home/ansible/loadscripts/load_generator.py 0.01 & load_pids+=($!)
    elif (( $(echo "$avg_usage > 20" | bc -l) )); then
        if (( ${#load_pids[@]} > 0 )); then
            echo -e "${RED}Killing last generator...${NC}"
            kill "${load_pids[-1]}"  # Kill by PID
            unset 'load_pids[-1]'    # Fixed pop
        fi
    elif (( $(echo "$avg_usage > 80" | bc -l) )); then
        cleanup
    fi
    sleep 5
done
