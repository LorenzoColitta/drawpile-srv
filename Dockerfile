FROM ubuntu:22.04

# Install FUSE and other dependencies
RUN apt-get update && apt-get install -y \
    wget \
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

USER drawpile

# Create storage directories
RUN mkdir -p /home/drawpile/data/sessions

# Use shell form to allow environment variable expansion
CMD sh -c "./squashfs-root/usr/bin/drawpile-srv \
    --database /home/drawpile/data/drawpile.db \
    --sessions /home/drawpile/data/sessions \
    --listen 0.0.0.0 \
    --port 27750 \
    --websocket-listen 0.0.0.0 \
    --websocket-port ${PORT:-10000}"
