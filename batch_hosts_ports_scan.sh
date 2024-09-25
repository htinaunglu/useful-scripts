#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <file_with_ip_addresses>"
    exit 1
fi

FILE=$1

while IFS= read -r ip; do
    echo "Scanning $ip for open ports..."
    nmap -p- --min-rate 500 -T4 -Pn -oN "${ip}_all_ports.txt" $ip

    echo "Scanning $ip for service and banner grabbing..."
    open_ports=$(grep -oP '^\d+/tcp\s+open' "${ip}_all_ports.txt" | cut -d '/' -f 1 | tr '\n' ',' | sed 's/,$//')

    if [ -n "$open_ports" ]; then
        nmap -sV --script=banner -p"$open_ports" --min-rate 50 -T3 -Pn -oN "${ip}_service_fingerprint.txt" $ip
    else
        echo "No open ports found on $ip"
    fi
done < "$FILE"

//Mui0 with MS CoPilot