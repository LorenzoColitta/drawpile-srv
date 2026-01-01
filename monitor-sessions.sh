#!/bin/bash

BOT_NAME="KeepAliveBot"
SERVER_URL="wss://localhost:${PORT:-10000}"
CMD_PATH="./squashfs-root/usr/bin/drawpile-cmd"

declare -A user_counts
declare -A bot_pids

echo "[Monitor] Starting session monitor - bot joins all sessions..."

while read -r line; do
    echo "$line"
    
    if [[ "$line" =~ Session\ created\ by\ ([^[: space:]]+) ]]; then
        # Extract session ID from next "Joined session" message or use a different approach
        sleep 0.5
        continue
    fi
    
    if [[ "$line" =~ Joined\ session\ ([^[:  space:]]+)\ as\ ([^[:space:]]+) ]]; then
        sid="${BASH_REMATCH[1]}"
        user="${BASH_REMATCH[2]}"
        
        if [ "$user" == "$BOT_NAME" ]; then continue; fi
        
        if [ -z "${user_counts["$sid"]}" ]; then 
            user_counts["$sid"]=0
            # New session detected - start bot immediately
            echo "[Monitor] New session '$sid' detected, starting bot..."
            xvfb-run -a "$CMD_PATH" --join "$SERVER_URL/$sid" --headless --username "$BOT_NAME" >/dev/null 2>&1 &
            bot_pids["$sid"]=$!
        fi
        
        ((user_counts["$sid"]++))
        echo "[Monitor] User '$user' joined '$sid'.   Humans: ${user_counts["$sid"]}"
        
    elif [[ "$line" =~ Left\ session\ ([^[: space:]]+)\ as\ ([^[:space:]]+) ]]; then
        sid="${BASH_REMATCH[1]}"
        user="${BASH_REMATCH[2]}"
        
        if [ "$user" == "$BOT_NAME" ]; then continue; fi
        
        ((user_counts["$sid"]--))
        if [ ${user_counts["$sid"]} -lt 0 ]; then user_counts["$sid"]=0; fi
        echo "[Monitor] User '$user' left '$sid'.   Humans: ${user_counts["$sid"]}"
    fi
done
