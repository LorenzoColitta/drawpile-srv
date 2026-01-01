FROM ubuntu:22.04

# Install FUSE, Drawpile dependencies, and xvfb for headless bot
RUN apt-get update && apt-get install -y \
    wget \
FROM ubuntu:22.04

# Install FUSE, Drawpile dependencies, and xvfb for headless bot
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
    xvfb \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN useradd -m drawpile
WORKDIR /home/drawpile
FROM ubuntu:22.04

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
    xvfb \
    && rm -rf /var/lib/apt/lists/*

RUN useradd -m drawpile
WORKDIR /home/drawpile

RUN wget https://github.com/drawpile/Drawpile/releases/download/2.2.1/Drawpile-2.2.1-x86_64.AppImage \
    && chmod +x Drawpile-2.2.1-x86_64.AppImage \
    && ./Drawpile-2.2.1-x86_64.AppImage --appimage-extract \
    && chown -R drawpile:drawpile /home/drawpile

COPY --chown=drawpile: drawpile sync-to-appwrite.sh /home/drawpile/sync-to-appwrite.sh
COPY --chown=drawpile:drawpile monitor-sessions. sh /home/drawpile/monitor-sessions.sh
RUN chmod +x /home/drawpile/*.sh

USER drawpile
RUN mkdir -p /home/drawpile/data/sessions

CMD sh -c "./sync-to-appwrite.sh restore && \
    (while true; do sleep 10 && ./sync-to-appwrite.sh backup; done) & \
    BACKUP_PID=\$!  && \
    ./squashfs-root/usr/bin/drawpile-srv \
    --database /home/drawpile/data/drawpile.db \
    --sessions /home/drawpile/data/sessions \
    --listen 0.0.0.0 \
    --port 27750 \
    --websocket-listen 0.0.0.0 \
    --websocket-port ${PORT:-10000} \
    --allow-guest-hosts true 2>&1 | ./monitor-sessions.sh; \
    kill \$BACKUP_PID"2>&1 | ./monitor-sessions.sh; \
    kill \$BACKUP_PID"
    --database /home/drawpile/data/drawpile.db \
    --sessions /home/drawpile/data/sessions \
    --listen 0.0.0.0 \
    --port 27750 \
    --websocket-listen 0.0.0.0 \
    --websocket-port ${PORT:-10000} \
    --allow-guest-hosts true 2>&1 | ./monitor-sessions.sh; \
    kill \$BACKUP_PID"
