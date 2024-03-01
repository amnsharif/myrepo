#!/bin/bash

read -p "Enter the minimum swap memory to view [default: 0 MB] " min
min=${min:-0}
re='^[0-9]+$'
seperator=-------------------
seperator=$seperator$seperator
rows="%-15s| %.7d| %3d| %c\n"
TableWidth=40
printf " %.${TableWidth}s\n" "$seperator"
printf "| %-7s | %-15s | %-6s|\n" PID Process "Swap (MB)"
printf " %.${TableWidth}s\n" "$seperator"
swap() {
overall=0
for status_file in /proc/[0-9]*/status;
do
    swap_mem=$(grep VmSwap "$status_file" | awk '{ print $2 }')
    if [ "$swap_mem" ] && [ "$swap_mem" -gt 0 ]; then
        pid=$(grep Tgid "$status_file" | awk '{ print $2 }')
        name=$(grep Name "$status_file" | awk '{ print $2 }')
	swap_mem_MB=$(($swap_mem/1024))
    if [ $swap_mem_MB -gt $min ]; then
printf "| %-7s | %-15s |    %-6d|\n" "$pid" "$name" "$swap_mem_MB"
    fi
    fi
    overall=$((overall+swap_mem_MB))
done
}
swap > sort_temp.txt
sort -n -r -k 6 sort_temp.txt
printf " %.${TableWidth}s\n" "$seperator"
printf "|    Total swap memory is %d MB      |\n" "$overall"
printf " %.${TableWidth}s\n" "$seperator"
rm sort_temp.txt
