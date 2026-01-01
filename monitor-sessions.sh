#!/bin/bash

# Configuration
BOT_NAME="KeepAliveBot"
SERVER_URL="localhost:27750"
CMD_PATH="./squashfs-root/usr/bin/drawpile-cmd"

declare -A user_counts
declare -A bot_pids

echo "[Monitor] Starting session monitor..."

while read -r line; do
    # Print original log line to stdout
    echo "$line"
    
    # Check for Join event
    # Format: Info/Join <timestamp> <ip>: Joined session <sid> as <user>
    if [[ "$line" =~ Info/Join.*Joined\ session\ ([^[:space:]]+)\ as\ ([^[:space:]]+) ]]; then
        sid="${BASH_REMATCH[1]}"
        user="${BASH_REMATCH[2]}"
        
        # Ignore our own bot
        if [ "$user" == "$BOT_NAME" ]; then
            continue
        fi
        
        ((user_counts["$sid"]++))
        echo "[Monitor] User '$user' joined session '$sid'. Active humans: ${user_counts["$sid"]}"
        
        # If a real user joins, we can kill the bot for this session
        if [ -n "${bot_pids["$sid"]}" ]; then
            echo "[Monitor] Real user joined. Terminating bot for session '$sid' (PID: ${bot_pids["$sid"]})"
            kill "${bot_pids["$sid"]}" 2>/dev/null
            unset bot_pids["$sid"]
        fi
        
    # Check for Leave event
    # Format: Info/Leave <timestamp> <ip>: Left session <sid> as <user>
    elif [[ "$line" =~ Info/Leave.*Left\ session\ ([^[:space:]]+)\ as\ ([^[:space:]]+) ]]; then
        sid="${BASH_REMATCH[1]}"
        user="${BASH_REMATCH[2]}"
        
        # Ignore our own bot
        if [ "$user" == "$BOT_NAME" ]; then
            continue
        fi
        
        ((user_counts["$sid"]--))
        if [ ${user_counts["$sid"]} -lt 0 ]; then user_counts["$sid"]=0; fi
        echo "[Monitor] User '$user' left session '$sid'. Active humans: ${user_counts["$sid"]}"
        
        # If no users left, start the bot to prevent expiration
        if [ "${user_counts["$sid"]}" -eq 0 ]; then
            echo "[Monitor] Session '$sid' is empty. Starting bot to keep it alive..."
            # Use xvfb-run in case drawpile-cmd requires a display context
            xvfb-run -a "$CMD_PATH" --join "drawpile://$SERVER_URL/$sid" --headless --username "$BOT_NAME" > /dev/null 2>&1 &
            bot_pids["$sid"]=$!
            echo "[Monitor] Bot started for session '$sid' (PID: ${bot_pids["$sid"]})"
        fi
    fi
done