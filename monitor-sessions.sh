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
            xvfb-run -a "$CMD_PATH" --join "drawpile://$SERVER_URL/$sid" --headless --username "$BOT_NAME" > /dev/null 2>&1 &
            bot_pids["$sid"]=$!
        fi
    fi
done#!/bin/bash

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
#!/bin/bash

BOT_NAME="KeepAliveBot"
SERVER_URL="localhost:27750"
CMD_PATH="./squashfs-root/usr/bin/drawpile-cmd"

declare -A user_counts
declare -A bot_pids

echo "[Monitor] Starting session monitor..."

while read -r line; do
    echo "$line"
    
    if [[ "$line" =~ Joined\ session\ ([^[: space:]]+)\ as\ ([^[:space:]]+) ]]; then
        sid="${BASH_REMATCH[1]}"
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
            xvfb-run -a "$CMD_PATH" --join "drawpile://$SERVER_URL/$sid" --headless --username "$BOT_NAME" > /dev/null 2>&1 &
            bot_pids["$sid"]=$!
        fi
    fi
done
