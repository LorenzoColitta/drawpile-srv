FROM ubuntu:22.04

RUN apt-get update && apt-get install -y wget curl libfuse2 libgl1 libglib2.0-0 libfontconfig1 libdbus-1-3 libicu70 ca-certificates && rm -rf /var/lib/apt/lists/*

RUN useradd -m drawpile
WORKDIR /home/drawpile

RUN wget https://github.com/drawpile/Drawpile/releases/download/2.2.1/Drawpile-2.2.1-x86_64.AppImage && chmod +x Drawpile-2.2.1-x86_64.AppImage && ./Drawpile-2.2.1-x86_64.AppImage --appimage-extract && chown -R drawpile:drawpile /home/drawpile

COPY --chown=drawpile:drawpile sync-to-appwrite.sh /home/drawpile/sync-to-appwrite.sh
COPY --chown=drawpile:drawpile drawpile.cfg /home/drawpile/drawpile.cfg
COPY --chown=drawpile:drawpile rollover-sessions.sh /home/drawpile/rollover-sessions.sh
RUN chmod +x /home/drawpile/*.sh

USER drawpile
RUN mkdir -p /home/drawpile/data/sessions

CMD sh -c "./sync-to-appwrite.sh restore && (while true; do sleep 10 && ./sync-to-appwrite.sh backup; done) & BACKUP_PID=\$! && ./rollover-sessions.sh & ROLLOVER_PID=\$! && ./squashfs-root/usr/bin/drawpile-srv --config /home/drawpile/drawpile.cfg --listen 0.0.0.0 --port 27750; kill \$BACKUP_PID \$ROLLOVER_PID"
