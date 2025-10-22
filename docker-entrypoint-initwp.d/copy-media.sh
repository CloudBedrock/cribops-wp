#!/bin/bash
# Copy media files directly to WordPress uploads directory
# This is for restoring missing files that are already referenced in the database

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Starting direct media copy process...${NC}"

# Check if WordPress is installed
if [ ! -d /var/www/html/wp-content/uploads ]; then
    echo -e "${YELLOW}WordPress uploads directory not found. Skipping media copy...${NC}"
    exit 0
fi

# Check if local media-copy directory exists and has content
if [ ! -d /local-media-copy ] || [ -z "$(ls -A /local-media-copy 2>/dev/null)" ]; then
    echo -e "${YELLOW}No media files found in /local-media-copy directory${NC}"
    exit 0
fi

echo -e "${GREEN}Found media files to copy...${NC}"

# Counter for statistics
copied_count=0
skipped_count=0
error_count=0

# Copy files from media-copy directory, preserving folder structure
echo -e "${YELLOW}Copying files from /local-media-copy to uploads directory...${NC}"
find /local-media-copy -type f | sort | while read -r source_file; do
    filename=$(basename "$source_file")

    # Get the relative path from /local-media-copy
    relative_path="${source_file#/local-media-copy/}"

    # Destination path in uploads directory
    dest_file="/var/www/html/wp-content/uploads/$relative_path"
    dest_dir=$(dirname "$dest_file")

    # Skip hidden files and system files
    if [[ "$filename" == .* ]] || [[ "$filename" == ".DS_Store" ]] || [[ "$filename" == "Thumbs.db" ]]; then
        continue
    fi

    # Check if file already exists and is identical
    if [ -f "$dest_file" ]; then
        source_hash=$(md5sum "$source_file" | awk '{print $1}')
        dest_hash=$(md5sum "$dest_file" | awk '{print $1}')

        if [ "$source_hash" = "$dest_hash" ]; then
            echo -e "${YELLOW}  ⊘ Already exists (identical): $relative_path${NC}"
            skipped_count=$((skipped_count + 1))
            continue
        else
            echo -e "${YELLOW}  → Overwriting (different): $relative_path${NC}"
        fi
    else
        echo -e "${GREEN}  → Copying: $relative_path${NC}"
    fi

    # Create destination directory if it doesn't exist
    mkdir -p "$dest_dir"

    # Copy the file
    if cp "$source_file" "$dest_file" 2>/dev/null; then
        # Set proper ownership and permissions
        chown www-data:www-data "$dest_file"
        chmod 644 "$dest_file"
        echo -e "${GREEN}  ✓ Successfully copied: $relative_path${NC}"
        copied_count=$((copied_count + 1))
    else
        echo -e "${RED}  ✗ Failed to copy: $relative_path${NC}"
        error_count=$((error_count + 1))
    fi
done

# Print summary
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Direct Media Copy Summary${NC}"
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}✓ Copied: $copied_count file(s)${NC}"
echo -e "${YELLOW}⊘ Skipped: $skipped_count file(s)${NC}"
if [ $error_count -gt 0 ]; then
    echo -e "${RED}✗ Errors: $error_count file(s)${NC}"
fi
echo -e "${GREEN}========================================${NC}"

if [ $copied_count -gt 0 ]; then
    echo -e "${GREEN}Media files have been copied to WordPress uploads directory${NC}"
    echo -e "${GREEN}Files are located in: /var/www/html/wp-content/uploads/${NC}"
fi
