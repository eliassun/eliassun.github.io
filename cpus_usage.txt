#!/bin/bash

#script thread_name, scan_times

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <thread_name> <times>"
  exit 1
fi

thread_name="$1"
times="$2"

echo "Thread name: $thread_name"
max_cpu_usage=-1.0
min_cpu_usage=100.0
all_cpu_usage=0.0

for ((i=1; i<=$times; i++)); do
  # Start top in the background
  timeout 2s top -b -n 1 > top_output.txt &
  top_pid=$!

  # Wait for the top process to exit
  wait $top_pid

  # Read and parse the output
  if [ -f "top_output.txt" ]; then
    wanted_line=$(grep "$thread_name" top_output.txt)
    if [ -n "$wanted_line" ]; then
      cpu=$(echo "$wanted_line" | awk '{print $9}')  # Adjust if necessary based on output
      cpu=$(echo "${cpu%\%}" | sed 's/,/./')
      
      # Update max, min, and total CPU usage
      if (( $(echo "$cpu > $max_cpu_usage" | bc -l) )); then
        max_cpu_usage=$cpu
        if (( $(echo "$max_cpu_usage > 20" | bc -l) )); then	
          echo "$wanted_line"
	fi
      fi
      if (( $(echo "$cpu < $min_cpu_usage" | bc -l) )); then
        min_cpu_usage=$cpu
      fi
      all_cpu_usage=$(echo "$all_cpu_usage + $cpu" | bc -l)
    else
      echo "Thread not found: $thread_name"
    fi
    rm top_output.txt
  else
    echo "Failed to run top"
    exit 1
  fi
done

# Calculate average CPU usage
average_cpu=$(echo "scale=2; $all_cpu_usage / $times" | bc -l)

echo "Max CPU usage: $max_cpu_usage%"
echo "Min CPU usage: $min_cpu_usage%"
echo "Average CPU usage: $average_cpu%"

