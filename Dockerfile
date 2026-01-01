FROM ubuntu:22.04

# 1. Install all system dependencies required by the Drawpile binary (Qt/OpenGL)
RUN apt-get update && apt-get install -y \
    libgl1 \
    libglib2.0-0 \
    libfontconfig1 \
    libdbus-1-3 \
    libicu70 \
    wget \
    && rm -rf /var/lib/apt/lists/*

# 2. Download the official 2.2.1 AppImage
RUN wget https://github.com/drawpile/Drawpile/releases/download/2.2.1/Drawpile-2.2.1-x86_64.AppImage -O /drawpile.AppImage
RUN chmod +x /drawpile.AppImage

# 3. Extract the AppImage so we can run the binary directly
RUN /drawpile.AppImage --appimage-extract

# 4. Prepare directories
RUN mkdir /sessions
WORKDIR /

# 5. Set environment for headless execution
ENV QT_QPA_PLATFORM=offscreen

# 6. Start the server
# We use Render's $PORT for the WebSocket server (required for the health check)
CMD sh -c "./squashfs-root/usr/bin/drawpile-srv --database /drawpile.db --sessions /sessions --listen 0.0.0.0 --port 27751 --websocket-listen 0.0.0.0 --websocket-port ${PORT:-10000}"
