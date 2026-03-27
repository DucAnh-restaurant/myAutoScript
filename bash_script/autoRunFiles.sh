#!/bin/bash
# check null file
if [ -z "$1" ]; then
    echo "Usage: $0 <file>"
    exit 1
fi

file="$1"

# file not exist
if [ ! -f "$file" ]; then
    echo "Error: File not found!"
    exit 1
fi

chmod +x "$file"
echo "Chmod for $file succeed!"
echo "running $file ..."
./$file