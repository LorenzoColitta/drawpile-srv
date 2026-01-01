#!/bin/bash

# Enable nullglob to handle cases where no session files exist
shopt -s nullglob

SESSION_DIR="/home/drawpile/data/sessions"
ROLLOVER_THRESHOLD=252000  # 70 hours in seconds (before 72h timeout)

echo "[Rollover] Session rollover monitor started"
echo "[Rollover] Checking sessions every hour for rollover at 70h mark"

while true; do
    echo "[Rollover] Checking for sessions needing rollover..."
    
    for session_file in "$SESSION_DIR"/*.session; do
        # Skip if no session files exist
        [ -f "$session_file" ] || continue
        
        session_id=$(basename "$session_file" .session)
        
        # Skip archived sessions (those with .archived extension in the basename)
        [[ "$session_id" == *.archived ]] && continue
        
        # Get file age in seconds
        file_age=$(($(date +%s) - $(stat -c %Y "$session_file")))
        hours_old=$((file_age / 3600))
        
        # If session is 70+ hours old, trigger rollover
        if [ $file_age -gt $ROLLOVER_THRESHOLD ]; then
            echo "[Rollover] ⚠️  Session '$session_id' is ${hours_old}h old - initiating rollover..."
            
            # Create timestamped backup name
            backup_name="${session_id}_backup_$(date +%Y%m%d_%H%M%S)"
            
            # Collect all session-related files
            session_files=("$SESSION_DIR/${session_id}".*)
            
            # Copy all session-related files to backup
            file_count=0
            for file in "${session_files[@]}"; do
                [ -f "$file" ] || continue
                
                ext="${file##*.}"
                cp "$file" "$SESSION_DIR/${backup_name}.${ext}"
                file_count=$((file_count + 1))
            done
            
            # Reset timestamps on original files to extend their life
            for file in "${session_files[@]}"; do
                [ -f "$file" ] || continue
                touch "$file"
            done
            
            echo "[Rollover] ✅ Session '$session_id' rolled over successfully"
            echo "[Rollover]    - Backed up $file_count files as '$backup_name'"
            echo "[Rollover]    - Session lifetime reset to 0h"
            echo "[Rollover]    - Users can continue working without interruption"
        fi
    done
    
    sleep 3600  # Check every hour
done
