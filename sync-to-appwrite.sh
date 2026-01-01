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
    tar -czf "$BACKUP_FILE" -C "$DATA_DIR" . 
    
    # Delete old backup from Appwrite
    curl -X DELETE \
        "${APPWRITE_ENDPOINT}/storage/buckets/${APPWRITE_BUCKET_ID}/files/${FILE_ID}" \
        -H "X-Appwrite-Project: ${APPWRITE_PROJECT_ID}" \
        -H "X-Appwrite-Key: ${APPWRITE_API_KEY}" 2>/dev/null
    
    # Upload new backup
    echo "Uploading to Appwrite..."
    curl -X POST \
        "${APPWRITE_ENDPOINT}/storage/buckets/${APPWRITE_BUCKET_ID}/files" \
        -H "X-Appwrite-Project: ${APPWRITE_PROJECT_ID}" \
        -H "X-Appwrite-Key: ${APPWRITE_API_KEY}" \
        -F "fileId=${FILE_ID}" \
        -F "file=@${BACKUP_FILE}"
    
    rm "$BACKUP_FILE"
    echo "Backup complete!"
}

restore() {
    echo "Checking for existing backup..."
    
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
