#!/bin/bash

# CPU temperature (AMD Ryzen uses Tctl)
TEMP_CPU=$(sensors | awk '/Tctl:/ {print $2; exit}')

# GPU temperature (amdgpu uses edge)
TEMP_GPU=$(sensors | awk '/edge:/ {print $2; exit}')

# CPU fan speed (asus boards use cpu_fan)
FAN=$(sensors | awk '/cpu_fan:/ {print $2; exit}')

# RAM usage
read -r _ total used free shared buff_cache available <<< "$(LC_ALL=C free -h | awk 'NR==2 {print $1, $2, $3, $4, $5, $6, $7}')"

RAM_USED=$used
RAM_FREE=$available

# fallback safety
[ -z "$TEMP_CPU" ] && TEMP_CPU="N/A"
[ -z "$TEMP_GPU" ] && TEMP_GPU="N/A"
[ -z "$FAN" ] && FAN="N/A"
[ -z "$RAM_FREE" ] && RAM_FREE="N/A"
[ -z "$RAM_USED" ] && RAM_USED="N/A"

echo "{\"text\": \"🌡 $TEMP_CPU\", \"tooltip\": \"CPU: $TEMP_CPU\nGPU: $TEMP_GPU\nCPU Fan: ${FAN}\nUsed RAM: ${RAM_USED}\nFree RAM: ${RAM_FREE}\"}"
#echo "{\"text\": \"🌡 $TEMP_CPU | 🎮 $TEMP_GPU\", \"tooltip\": \"CPU: $TEMP_CPU\nGPU: $TEMP_GPU\nCPU Fan: ${FAN}\nUsed RAM: ${RAM_USED}\nFree RAM: ${RAM_FREE}\"}"
