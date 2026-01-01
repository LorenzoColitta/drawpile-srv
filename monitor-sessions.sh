#!/bin/bash

BOT_NAME="KeepAliveBot"
SERVER_URL="drawpile://localhost: 27750"
CMD_PATH="./squashfs-root/usr/bin/drawpile-cmd"

declare -A user_counts
declare -A bot_pids

echo "[Monitor] Starting session monitor - bot joins all sessions..."

while read -r line; do
    echo "$line"
    
    if [[ "$line" =~ Info/Join.*\ ([^@]+)@([^:  ]+):\ Joined\ session ]]; then
        user="${BASH_REMATCH[1]}"
        sid="${BASH_REMATCH[2]}"
        
        echo "[Monitor] Detected:   user='$user' sid='$sid'"
        
        if [ "$user" == "$BOT_NAME" ]; then 
            echo "[Monitor] Bot joined, ignoring"
            continue
        fi
        
        if [ -z "${user_counts["$sid"]}" ]; then 
            user_counts["$sid"]=0
            echo "[Monitor] NEW SESSION '$sid' - Starting bot..."
            xvfb-run -a "$CMD_PATH" --join "$SERVER_URL/$sid" --headless --username "$BOT_NAME" >/dev/null 2>&1 &
            bot_pids["$sid"]=$!
            echo "[Monitor] Bot started with PID ${bot_pids["$sid"]}"
        fi
        
        ((user_counts["$sid"]++))
        echo "[Monitor] User '$user' in '$sid'.   Humans: ${user_counts["$sid"]}"
        
    elif [[ "$line" =~ Info/Leave.*\ ([^@]+)@([^:]+):\ Left\ session ]]; then
        user="${BASH_REMATCH[1]}"
        sid="${BASH_REMATCH[2]}"
        
        echo "[Monitor] Detected leave: user='$user' sid='$sid'"
        
        if [ "$user" == "$BOT_NAME" ]; then continue; fi
        
        ((user_counts["$sid"]--))
        if [ ${user_counts["$sid"]} -lt 0 ]; then user_counts["$sid"]=0; fi
        echo "[Monitor] User '$user' left '$sid'.  Humans: ${user_counts["$sid"]}"
    fi
done
