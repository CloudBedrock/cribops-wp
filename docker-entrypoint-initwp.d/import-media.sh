#!/bin/bash
# Auto-import media files from local media directory to WordPress Media Library

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Starting media import process...${NC}"

# Check if WordPress is installed
if ! wp core is-installed --path=/var/www/html --allow-root 2>/dev/null; then
    echo -e "${YELLOW}WordPress is not installed yet. Skipping media import...${NC}"
    exit 0
fi

# Check if local media directory exists and has content
if [ ! -d /local-media ] || [ -z "$(ls -A /local-media 2>/dev/null)" ]; then
    echo -e "${YELLOW}No media files found in /local-media directory${NC}"
    exit 0
fi

echo -e "${GREEN}Found media files to import...${NC}"

# Create a marker directory to track imported files
MARKER_DIR="/var/www/html/wp-content/.imported-media"
mkdir -p "$MARKER_DIR"

# Counter for statistics
imported_count=0
skipped_count=0
error_count=0

# Supported image extensions
declare -a SUPPORTED_TYPES=("jpg" "jpeg" "png" "gif" "webp" "svg" "bmp" "ico" "tiff" "tif" "pdf" "mp4" "mov" "avi" "mp3" "wav" "zip" "doc" "docx" "xls" "xlsx" "ppt" "pptx")

# Function to check if file type is supported
is_supported_type() {
    local file="$1"
    local ext="${file##*.}"
    ext=$(echo "$ext" | tr '[:upper:]' '[:lower:]')

    for type in "${SUPPORTED_TYPES[@]}"; do
        if [ "$ext" = "$type" ]; then
            return 0
        fi
    done
    return 1
}

# Function to create a marker file for imported media
create_marker() {
    local file_path="$1"
    local file_hash=$(md5sum "$file_path" | awk '{print $1}')
    echo "$file_hash" > "$MARKER_DIR/$(basename "$file_path").marker"
}

# Function to check if file was already imported
is_already_imported() {
    local file_path="$1"
    local marker_file="$MARKER_DIR/$(basename "$file_path").marker"

    if [ ! -f "$marker_file" ]; then
        return 1
    fi

    local file_hash=$(md5sum "$file_path" | awk '{print $1}')
    local stored_hash=$(cat "$marker_file")

    [ "$file_hash" = "$stored_hash" ]
}

# Import files from media directory
echo -e "${YELLOW}Scanning for media files...${NC}"
find /local-media -type f | while read -r media_file; do
    filename=$(basename "$media_file")

    # Skip hidden files and system files
    if [[ "$filename" == .* ]] || [[ "$filename" == ".DS_Store" ]] || [[ "$filename" == "Thumbs.db" ]]; then
        continue
    fi

    # Check if file type is supported
    if ! is_supported_type "$media_file"; then
        echo -e "${YELLOW}  ⊘ Skipping unsupported file type: $filename${NC}"
        skipped_count=$((skipped_count + 1))
        continue
    fi

    # Check if already imported
    if is_already_imported "$media_file"; then
        echo -e "${YELLOW}  ⊘ Already imported (unchanged): $filename${NC}"
        skipped_count=$((skipped_count + 1))
        continue
    fi

    echo -e "${GREEN}  → Importing: $filename${NC}"

    # Import the media file using WP-CLI
    if wp media import "$media_file" --path=/var/www/html --allow-root 2>/dev/null; then
        echo -e "${GREEN}  ✓ Successfully imported: $filename${NC}"
        create_marker "$media_file"
        imported_count=$((imported_count + 1))
    else
        echo -e "${RED}  ✗ Failed to import: $filename${NC}"
        error_count=$((error_count + 1))
    fi
done

# Print summary
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Media Import Summary${NC}"
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}✓ Imported: $imported_count file(s)${NC}"
echo -e "${YELLOW}⊘ Skipped: $skipped_count file(s)${NC}"
if [ $error_count -gt 0 ]; then
    echo -e "${RED}✗ Errors: $error_count file(s)${NC}"
fi
echo -e "${GREEN}========================================${NC}"

if [ $imported_count -gt 0 ]; then
    echo -e "${GREEN}Media files have been imported to WordPress Media Library${NC}"
    echo -e "${GREEN}You can view them at: ${WORDPRESS_SITEURL}/wp-admin/upload.php${NC}"
fi
