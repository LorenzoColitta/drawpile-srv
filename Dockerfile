FROM ubuntu:22.04

# 1. Install all necessary system libraries (fixes the libGL.so.1 error)
RUN apt-get update && apt-get install -y \
    wget \
    libgl1 \
    libglib2.0-0 \
    libfontconfig1 \
    libdbus-1-3 \
    libicu70 \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# 2. Create a non-root user (fixes the "should not be run as root" error)
RUN useradd -m drawpile
WORKDIR /home/drawpile

# 3. Download and extract the official AppImage (guarantees WebSocket support)
RUN wget https://github.com/drawpile/Drawpile/releases/download/2.2.1/Drawpile-2.2.1-x86_64.AppImage \
    && chmod +x Drawpile-2.2.1-x86_64.AppImage \
    && ./Drawpile-2.2.1-x86_64.AppImage --appimage-extract \
    && chown -R drawpile:drawpile /home/drawpile

# 4. Switch to the non-root user
USER drawpile

# 5. Create storage directories
RUN mkdir -p /home/drawpile/sessions

# 6. Start the server
# We bind the WebSocket server to Render's $PORT to pass the health check.
CMD sh -c "./squashfs-root/usr/bin/drawpile-srv \
    --database /home/drawpile/drawpile.db \
    --sessions /home/drawpile/sessions \
    --listen 127.0.0.1 \
    --port 27750 \
    --websocket-listen 0.0.0.0 \
    --websocket-port ${PORT:-10000}"
