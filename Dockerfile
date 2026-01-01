FROM ubuntu:22.04

# Install FUSE and other dependencies
RUN apt-get update && apt-get install -y \
    wget \
    curl \
    libfuse2 \
    libgl1 \
    libglib2.0-0 \
    libfontconfig1 \
    libdbus-1-3 \
    libicu70 \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN useradd -m drawpile
WORKDIR /home/drawpile

# Download and extract Drawpile AppImage
RUN wget https://github.com/drawpile/Drawpile/releases/download/2.2.1/Drawpile-2.2.1-x86_64.AppImage \
    && chmod +x Drawpile-2.2.1-x86_64.AppImage \
    && ./Drawpile-2.2.1-x86_64.AppImage --appimage-extract \
    && chown -R drawpile:drawpile /home/drawpile

# Copy backup script
COPY --chown=drawpile:drawpile sync-to-appwrite.sh /home/drawpile/sync-to-appwrite.sh
RUN chmod +x /home/drawpile/sync-to-appwrite.sh

USER drawpile

# Create storage directories
RUN mkdir -p /home/drawpile/data/sessions

# Start server with 10-second backup interval
CMD sh -c "./sync-to-appwrite.sh restore && \
    ./squashfs-root/usr/bin/drawpile-srv \
    --database /home/drawpile/data/drawpile.db \
    --sessions /home/drawpile/data/sessions \
    --listen 0.0.0.0 \
    --port 27750 \
    --websocket-listen 0.0.0.0 \
    --websocket-port ${PORT:-10000} & \
    SERVER_PID=\$! && \
    while kill -0 \$SERVER_PID 2>/dev/null; do \
        sleep 10 && ./sync-to-appwrite.sh backup; \
    done"
