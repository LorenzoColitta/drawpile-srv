#!/bin/bash

# Appwrite Configuration (set these as environment variables in Render)
APPWRITE_ENDPOINT="${APPWRITE_ENDPOINT}"
APPWRITE_PROJECT_ID="${APPWRITE_PROJECT_ID}"
APPWRITE_API_KEY="${APPWRITE_API_KEY}"
APPWRITE_BUCKET_ID="${APPWRITE_BUCKET_ID}"

DATA_DIR="/home/drawpile/data"
BACKUP_FILE="/tmp/drawpile-backup.tar.gz"
FILE_ID="drawpile-sessions-latest"

backup() {
    echo "Creating backup..."
    
    # Safely backup SQLite database if it exists
    if [ -f "$DATA_DIR/drawpile.db" ]; then
        echo "Creating safe SQLite backup..."
        sqlite3 "$DATA_DIR/drawpile.db" ".backup '$DATA_DIR/drawpile.db.bak'"
    fi
    
    # Create tar backup (excluding the live database if it exists)
    if [ -f "$DATA_DIR/drawpile.db.bak" ]; then
        tar -czf "$BACKUP_FILE" -C "$DATA_DIR" --exclude='drawpile.db' --transform='s/drawpile.db.bak/drawpile.db/' .
        rm "$DATA_DIR/drawpile.db.bak"
    else
        tar -czf "$BACKUP_FILE" -C "$DATA_DIR" .
    fi
    
    # Upload new backup with temporary ID first (ensures we have a backup before deleting old one)
    echo "Uploading backup to Appwrite..."
    TEMP_FILE_ID="${FILE_ID}-temp"
    
    # Clean up any existing temp backup first
    curl -s -X DELETE \
        "${APPWRITE_ENDPOINT}/storage/buckets/${APPWRITE_BUCKET_ID}/files/${TEMP_FILE_ID}" \
        -H "X-Appwrite-Project: ${APPWRITE_PROJECT_ID}" \
        -H "X-Appwrite-Key: ${APPWRITE_API_KEY}" 2>/dev/null
    
    UPLOAD_RESPONSE=$(curl -s -w "\n%{http_code}" -X POST \
        "${APPWRITE_ENDPOINT}/storage/buckets/${APPWRITE_BUCKET_ID}/files" \
        -H "X-Appwrite-Project: ${APPWRITE_PROJECT_ID}" \
        -H "X-Appwrite-Key: ${APPWRITE_API_KEY}" \
        -F "fileId=${TEMP_FILE_ID}" \
        -F "file=@${BACKUP_FILE}")
    
    HTTP_CODE=$(echo "$UPLOAD_RESPONSE" | tail -n1)
    
    # Check if upload was successful (HTTP 201 Created)
    if [ "$HTTP_CODE" = "201" ]; then
        echo "Backup uploaded successfully, replacing old version..."
        
        # Now safe to delete the old backup
        curl -s -X DELETE \
            "${APPWRITE_ENDPOINT}/storage/buckets/${APPWRITE_BUCKET_ID}/files/${FILE_ID}" \
            -H "X-Appwrite-Project: ${APPWRITE_PROJECT_ID}" \
            -H "X-Appwrite-Key: ${APPWRITE_API_KEY}" 2>/dev/null
        
        # Upload with the permanent ID
        FINAL_RESPONSE=$(curl -s -w "\n%{http_code}" -X POST \
            "${APPWRITE_ENDPOINT}/storage/buckets/${APPWRITE_BUCKET_ID}/files" \
            -H "X-Appwrite-Project: ${APPWRITE_PROJECT_ID}" \
            -H "X-Appwrite-Key: ${APPWRITE_API_KEY}" \
            -F "fileId=${FILE_ID}" \
            -F "file=@${BACKUP_FILE}")
        
        FINAL_HTTP_CODE=$(echo "$FINAL_RESPONSE" | tail -n1)
        
        if [ "$FINAL_HTTP_CODE" = "201" ]; then
            # Clean up temp backup
            curl -s -X DELETE \
                "${APPWRITE_ENDPOINT}/storage/buckets/${APPWRITE_BUCKET_ID}/files/${TEMP_FILE_ID}" \
                -H "X-Appwrite-Project: ${APPWRITE_PROJECT_ID}" \
                -H "X-Appwrite-Key: ${APPWRITE_API_KEY}" 2>/dev/null
            echo "Backup complete!"
        else
            echo "Warning: Final upload failed (HTTP $FINAL_HTTP_CODE), but temp backup exists at ${TEMP_FILE_ID}"
        fi
    else
        echo "Upload failed (HTTP $HTTP_CODE), old backup remains intact"
    fi
    
    rm "$BACKUP_FILE"
}

restore() {
    echo "Checking if restore is needed..."
    
    # Check if sessions directory exists and has content
    if [ -d "$DATA_DIR/sessions" ] && [ -n "$(ls -A "$DATA_DIR/sessions" 2>/dev/null)" ]; then
        echo "Local data already exists. Skipping restore to avoid overwriting newer data."
        return 0
    fi
    
    echo "No local data found. Checking for existing backup..."
    
    # Download backup from Appwrite
    HTTP_CODE=$(curl -s -o "$BACKUP_FILE" -w "%{http_code}" \
        "${APPWRITE_ENDPOINT}/storage/buckets/${APPWRITE_BUCKET_ID}/files/${FILE_ID}/download" \
        -H "X-Appwrite-Project: ${APPWRITE_PROJECT_ID}" \
        -H "X-Appwrite-Key: ${APPWRITE_API_KEY}")
    
    if [ "$HTTP_CODE" = "200" ]; then
        echo "Restoring from backup..."
        mkdir -p "$DATA_DIR"
        tar -xzf "$BACKUP_FILE" -C "$DATA_DIR"
        rm "$BACKUP_FILE"
        echo "Restore complete!"
    else
        echo "No existing backup found. Starting fresh."
        mkdir -p "$DATA_DIR/sessions"
    fi
}

case "$1" in
    backup)
        backup
        ;;
    restore)
        restore
        ;;
    *)
        echo "Usage: $0 {backup|restore}"
        exit 1
        ;;
esac
