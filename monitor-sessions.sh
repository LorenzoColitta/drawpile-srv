#!/bin/bash

BOT_NAME="KeepAliveBot"
SERVER_URL="localhost:27750"
CMD_PATH="./squashfs-root/usr/bin/drawpile-cmd"

declare -A user_counts
declare -A bot_pids

echo "[Monitor] Starting session monitor for ALL sessions..."

while read -r line; do
    echo "$line"
    
    if [[ "$line" =~ Joined\ session\ ([^[: space:]]+)\ as\ ([^[:space:]]+) ]]; then
        sid="${BASH_REMATCH[1]}"
        user="${BASH_REMATCH[2]}"
        
        if [ "$user" == "$BOT_NAME" ]; then continue; fi
        
        if [ -z "${user_counts["$sid"]}" ]; then user_counts["$sid"]=0; fi
        ((user_counts["$sid"]++))
        echo "[Monitor] User '$user' joined '$sid'.  Humans: ${user_counts["$sid"]}"
        
        if [ -n "${bot_pids["$sid"]}" ] && kill -0 "${bot_pids["$sid"]}" 2>/dev/null; then
            echo "[Monitor] Terminating bot for '$sid'"
            kill "${bot_pids["$sid"]}" 2>/dev/null
            unset bot_pids["$sid"]
        fi
        
    elif [[ "$line" =~ Left\ session\ ([^[:space:]]+)\ as\ ([^[:space:]]+) ]]; then
        sid="${BASH_REMATCH[1]}"
        user="${BASH_REMATCH[2]}"
        
        if [ "$user" == "$BOT_NAME" ]; then continue; fi
        
        ((user_counts["$sid"]--))
        if [ ${user_counts["$sid"]} -lt 0 ]; then user_counts["$sid"]=0; fi
        echo "[Monitor] User '$user' left '$sid'.  Humans: ${user_counts["$sid"]}"
        
        if [ "${user_counts["$sid"]}" -eq 0 ]; then
            echo "[Monitor] Starting bot for '$sid'..."
            xvfb-run -a "$CMD_PATH" --join "drawpile://$SERVER_URL/$sid" --headless --username "$BOT_NAME" >/dev/null 2>&1 &
            bot_pids["$sid"]=$!
        fi
    fi
done
