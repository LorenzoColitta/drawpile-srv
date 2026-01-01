#!/bin/bash

# Configuration
BOT_NAME="KeepAliveBot"
SERVER_URL="localhost:27750"
CMD_PATH="./squashfs-root/usr/bin/drawpile-cmd"

declare -A user_counts
declare -A bot_pids

echo "[Monitor] Starting session monitor for ALL sessions..."

# Function to ensure bot is running for a session
ensure_bot_running() {
    local sid="$1"
    
    # Check if bot is already running for this session
    if [ -n "${bot_pids["$sid"]}" ] && kill -0 "${bot_pids["$sid"]}" 2>/dev/null; then
        return 0
    fi
    
    echo "[Monitor] Starting Keep-Alive Bot for session '$sid'..."
    xvfb-run -a "$CMD_PATH" --join "drawpile://$SERVER_URL/$sid" --headless --username "$BOT_NAME" > /dev/null 2>&1 &
    bot_pids["$sid"]=$!
    echo "[Monitor] Bot started for '$sid' (PID: ${bot_pids["$sid"]})"
}

while read -r line; do
    echo "$line"
    
    # Detect User Join
    if [[ "$line" =~ Joined\ session\ ([^[: space:]]+)\ as\ ([^[:space:]]+) ]]; then
        sid="${BASH_REMATCH[1]}"
        user="${BASH_REMATCH[2]}"
        
        if [ "$user" == "$BOT_NAME" ]; then continue; fi
        
        # Initialize counter if this is a new session
        if [ -z "${user_counts["$sid"]}" ]; then
            user_counts["$sid"]=0
        fi
        
        ((user_counts["$sid"]++))
        echo "[Monitor] User '$user' joined '$sid'.  Humans: ${user_counts["$sid"]}"
        
        # Kill bot when human joins
        if [ -n "${bot_pids["$sid"]}" ] && kill -0 "${bot_pids["$sid"]}" 2>/dev/null; then
            echo "[Monitor] Human present.  Terminating bot for '$sid' (PID: ${bot_pids["$sid"]})"
            kill "${bot_pids["$sid"]}" 2>/dev/null
            unset bot_pids["$sid"]
        fi
        
    # Detect User Leave
    elif [[ "$line" =~ Left\ session\ ([^[:space:]]+)\ as\ ([^[:space:]]+) ]]; then
        sid="${BASH_REMATCH[1]}"
        user="${BASH_REMATCH[2]}"
        
        if [ "$user" == "$BOT_NAME" ]; then continue; fi
        
        ((user_counts["$sid"]--))
        if [ ${user_counts["$sid"]} -lt 0 ]; then user_counts["$sid"]=0; fi
        echo "[Monitor] User '$user' left '$sid'.  Humans: ${user_counts["$sid"]}"
        
        # Start bot if session is now empty
        if [ "${user_counts["$sid"]}" -eq 0 ]; then
            echo "[Monitor] Session '$sid' is empty. Starting Keep-Alive Bot..."
            ensure_bot_running "$sid"
        fi
        
    # Detect Session Close (optional:  clean up tracking)
    elif [[ "$line" =~ Closed\ session\ ([^[:space:]]+) ]]; then
        sid="${BASH_REMATCH[1]}"
        echo "[Monitor] Session '$sid' closed. Cleaning up..."
        
        # Kill bot if running
        if [ -n "${bot_pids["$sid"]}" ]; then
            kill "${bot_pids["$sid"]}" 2>/dev/null
            unset bot_pids["$sid"]
        fi
        
        unset user_counts["$sid"]
    fi
done
