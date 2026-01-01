#!/bin/bash

# Handle shutdown gracefully
shutdown() {
    echo "Received SIGTERM, initiating graceful shutdown..."
    
    # Stop background processes
    if [ -n "$BACKUP_PID" ]; then
        kill $BACKUP_PID 2>/dev/null
    fi
    if [ -n "$ROLLOVER_PID" ]; then
        kill $ROLLOVER_PID 2>/dev/null
    fi
    if [ -n "$SERVER_PID" ]; then
        kill $SERVER_PID 2>/dev/null
    fi
    
    # Run final backup with timeout
    echo "Running final backup..."
    if timeout 180 ./sync-to-appwrite.sh backup; then
        echo "Final backup completed successfully"
    else
        EXIT_CODE=$?
        if [ $EXIT_CODE -eq 124 ]; then
            echo "ERROR: Final backup timed out after 180 seconds" >&2
        else
            echo "ERROR: Final backup failed - data may not be preserved" >&2
        fi
    fi
    
    echo "Shutdown complete"
    exit 0
}

# Trap SIGTERM signal
trap shutdown SIGTERM SIGINT

# Restore from backup if needed
./sync-to-appwrite.sh restore

# Start backup loop in background
(while true; do 
    sleep 10
    ./sync-to-appwrite.sh backup
done) &
BACKUP_PID=$!

# Start rollover script in background
./rollover-sessions.sh &
ROLLOVER_PID=$!

# Start Drawpile server in background
./squashfs-root/usr/bin/drawpile-srv \
    --config /home/drawpile/drawpile.cfg \
    --templates /home/drawpile/data/templates \
    --listen 0.0.0.0 \
    --port 27750 &
SERVER_PID=$!

# Wait for server process
wait $SERVER_PID
