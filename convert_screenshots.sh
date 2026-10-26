#!/bin/bash

# Script to convert screenshots to 1242x2688 with no alpha channel

BACKUP_DIR="/Users/hanguyenvan/Work/FlutterApp/expense/scrs/originals_backup"
OUTPUT_DIR="/Users/hanguyenvan/Work/FlutterApp/expense/scrs"
TARGET_WIDTH=1242
TARGET_HEIGHT=2688

# Color codes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Screenshot Converter for App Store${NC}"
echo -e "${BLUE}Target: ${TARGET_WIDTH} x ${TARGET_HEIGHT} (no alpha)${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Count files
TOTAL=$(ls "$BACKUP_DIR"/*.png 2>/dev/null | wc -l | tr -d ' ')

if [ "$TOTAL" -eq 0 ]; then
    echo -e "${YELLOW}No PNG files found in ${BACKUP_DIR}${NC}"
    exit 1
fi

echo -e "${GREEN}Found ${TOTAL} screenshots to convert${NC}"
echo ""

COUNTER=0

# Process each PNG file
for file in "$BACKUP_DIR"/*.png; do
    # Skip if it's a directory
    if [ -d "$file" ]; then
        continue
    fi

    FILENAME=$(basename "$file")
    OUTPUT_FILE="${OUTPUT_DIR}/${FILENAME}"

    COUNTER=$((COUNTER + 1))

    echo -e "${BLUE}[${COUNTER}/${TOTAL}]${NC} Processing: ${FILENAME}"

    # Get current dimensions
    CURRENT_SIZE=$(sips -g pixelWidth -g pixelHeight "$file" 2>/dev/null | grep -E "pixelWidth|pixelHeight" | awk '{print $2}' | tr '\n' 'x' | sed 's/x$//')
    HAS_ALPHA=$(sips -g hasAlpha "$file" 2>/dev/null | grep "hasAlpha" | awk '{print $2}')

    echo "  Current: ${CURRENT_SIZE}, Alpha: ${HAS_ALPHA}"

    # Copy to output directory first
    cp "$file" "$OUTPUT_FILE"

    # Step 1: Resize to exact dimensions
    sips -z "$TARGET_HEIGHT" "$TARGET_WIDTH" "$OUTPUT_FILE" > /dev/null 2>&1

    # Step 2: Remove alpha channel by converting to JPEG and back to PNG
    # This ensures no transparency
    TEMP_JPG="${OUTPUT_FILE%.png}.jpg"
    sips -s format jpeg "$OUTPUT_FILE" --out "$TEMP_JPG" > /dev/null 2>&1
    sips -s format png "$TEMP_JPG" --out "$OUTPUT_FILE" > /dev/null 2>&1
    rm -f "$TEMP_JPG"

    # Verify results
    VERIFY_WIDTH=$(sips -g pixelWidth "$OUTPUT_FILE" 2>/dev/null | grep "pixelWidth" | awk '{print $2}')
    VERIFY_HEIGHT=$(sips -g pixelHeight "$OUTPUT_FILE" 2>/dev/null | grep "pixelHeight" | awk '{print $2}')
    VERIFY_ALPHA=$(sips -g hasAlpha "$OUTPUT_FILE" 2>/dev/null | grep "hasAlpha" | awk '{print $2}')

    if [ "$VERIFY_WIDTH" = "$TARGET_WIDTH" ] && [ "$VERIFY_HEIGHT" = "$TARGET_HEIGHT" ] && [ "$VERIFY_ALPHA" = "no" ]; then
        echo -e "  ${GREEN}Success: ${VERIFY_WIDTH}x${VERIFY_HEIGHT}, Alpha: ${VERIFY_ALPHA}${NC}"
    else
        echo -e "  ${YELLOW}Warning: ${VERIFY_WIDTH}x${VERIFY_HEIGHT}, Alpha: ${VERIFY_ALPHA}${NC}"
    fi

    echo ""
done

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Conversion Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Final verification
echo -e "${BLUE}Final Verification:${NC}"
echo ""
ALL_CORRECT=true
for file in "$OUTPUT_DIR"/*.png; do
    if [ -d "$file" ]; then
        continue
    fi
    FILENAME=$(basename "$file")
    FINAL_WIDTH=$(sips -g pixelWidth "$file" 2>/dev/null | grep "pixelWidth" | awk '{print $2}')
    FINAL_HEIGHT=$(sips -g pixelHeight "$file" 2>/dev/null | grep "pixelHeight" | awk '{print $2}')
    FINAL_ALPHA=$(sips -g hasAlpha "$file" 2>/dev/null | grep "hasAlpha" | awk '{print $2}')

    if [ "$FINAL_WIDTH" = "$TARGET_WIDTH" ] && [ "$FINAL_HEIGHT" = "$TARGET_HEIGHT" ] && [ "$FINAL_ALPHA" = "no" ]; then
        echo -e "  ${GREEN}✓${NC} ${FILENAME}: ${FINAL_WIDTH}x${FINAL_HEIGHT}, Alpha: ${FINAL_ALPHA}"
    else
        echo -e "  ${YELLOW}✗${NC} ${FILENAME}: ${FINAL_WIDTH}x${FINAL_HEIGHT}, Alpha: ${FINAL_ALPHA}"
        ALL_CORRECT=false
    fi
done

echo ""
if [ "$ALL_CORRECT" = true ]; then
    echo -e "${GREEN}✓ All screenshots are ready for App Store!${NC}"
else
    echo -e "${YELLOW}⚠ Some screenshots need attention. Check above.${NC}"
fi
echo ""
echo -e "Summary:"
echo -e "  • Converted: ${COUNTER} screenshots"
echo -e "  • Target: ${TARGET_WIDTH} x ${TARGET_HEIGHT}"
echo -e "  • Alpha channel: Removed"
echo -e "  • Output: ${OUTPUT_DIR}"
echo -e "  • Originals: ${BACKUP_DIR}"
echo ""
