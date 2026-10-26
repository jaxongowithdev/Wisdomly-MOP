#!/bin/bash

# Resize all screenshots in srcs directory to 1242 × 2688 (App Store size)

SRCS_DIR="./srcs"

# Check if srcs directory exists
if [ ! -d "$SRCS_DIR" ]; then
    echo "Error: $SRCS_DIR directory not found!"
    exit 1
fi

# Find all PNG files and resize them
echo "Resizing screenshots to 1242 × 2688..."

find "$SRCS_DIR" -name "*.png" -type f | while read -r file; do
    echo "Processing: $file"
    sips -z 2688 1242 "$file"
done

echo "Done! All screenshots resized."
