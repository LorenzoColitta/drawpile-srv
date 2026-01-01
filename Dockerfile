FROM ubuntu:22.04

# Install dependencies for Drawpile and AppImage extraction
RUN apt-get update && apt-get install -y \
    wget \
    libqt5core5a \
    libqt5network5 \
    libqt5sql5 \
    libqt5sql5-sqlite \
    libqt5websockets5 \
    ca-certificates \
    binutils \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /home/drawpile

# Download the official 2.2.1 AppImage (contains the server with WS support)
RUN wget https://github.com/drawpile/Drawpile/releases/download/2.2.1/Drawpile-2.2.1-x86_64.AppImage \
    && chmod +x Drawpile-2.2.1-x86_64.AppImage

# Extract the AppImage so we can run the server binary directly (FUSE doesn't work in Docker)
RUN ./Drawpile-2.2.1-x86_64.AppImage --appimage-extract

# Create sessions directory
RUN mkdir sessions

# Start the server
# 1. We move the internal TCP port to 27750
# 2. we bind the WEBSOCKET server to the Render $PORT. 
# This handles the HTTP health check and allows browser clients.
CMD sh -c "./squashfs-root/usr/bin/drawpile-srv \
    --database /home/drawpile/drawpile.db \
    --sessions /home/drawpile/sessions \
    --listen 127.0.0.1 \
    --port 27750 \
    --websocket-listen 0.0.0.0 \
    --websocket-port ${PORT:-10000}"
