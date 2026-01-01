FROM ubuntu:22.04

# 1. Install system libraries + curl for Appwrite API
RUN apt-get update && apt-get install -y \
    wget \
    curl \
    jq \
    libgl1 \
    libglib2.0-0 \
    libfontconfig1 \
    libdbus-1-3 \
    libicu70 \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# 2. Create non-root user
RUN useradd -m drawpile
WORKDIR /home/drawpile

# 3. Download and extract Drawpile AppImage
RUN wget https://github.com/drawpile/Drawpile/releases/download/2.2.1/Drawpile-2.2.1-x86_64.AppImage \
    && chmod +x Drawpile-2.2.1-x86_64.AppImage \
    && ./Drawpile-2.2.1-x86_64.AppImage --appimage-extract \
    && chown -R drawpile:drawpile /home/drawpile

# 4. Create backup script that syncs to Appwrite Storage
COPY --chown=drawpile:drawpile sync-to-appwrite.sh /home/drawpile/sync-to-appwrite.sh
RUN chmod +x /home/drawpile/sync-to-appwrite. sh

USER drawpile

# 5. Create local storage directories
RUN mkdir -p /home/drawpile/data/sessions

# 6. Start the server with full persistence
CMD sh -c "./sync-to-appwrite.sh restore && \
    ./squashfs-root/usr/bin/drawpile-srv \
    --database /home/drawpile/data/drawpile.db \
    --sessions /home/drawpile/data/sessions \
    --listen 127.0.0.1 \
    --port 27750 \
    --websocket-listen 0.0.0.0 \
    --websocket-port ${PORT:-10000} \
    --persistence true \
    --archive true \
    --idle-time-limit 0 & \
    SERVER_PID=\$! && \
    while kill -0 \$SERVER_PID 2>/dev/null; do \
        sleep 300 && ./sync-to-appwrite.sh backup; \
    done"
