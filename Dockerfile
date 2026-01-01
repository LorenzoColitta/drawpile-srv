FROM ubuntu:22.04

RUN apt-get update && apt-get install -y \
    wget \
        ca-certificates \
            libfuse2 \
                && rm -rf /var/lib/apt/lists/*

                WORKDIR /app

                RUN wget https://github.com/drawpile/Drawpile/releases/download/2.2.1/drawpile-srv-2.2.1-Linux-x86_64.AppImage \
                    && chmod +x drawpile-srv-2.2.1-Linux-x86_64.AppImage \
                        && ./drawpile-srv-2.2.1-Linux-x86_64.AppImage --appimage-extract \
                            && mv squashfs-root drawpile

                            RUN mkdir -p /data

                            EXPOSE 27750

                            CMD ["/app/drawpile/AppRun", \
                                 "--database", "/data/drawpile.db", \
                                      "--sessions", \
                                           "--session-timeout", "0", \
                                                "--port", "27750", \
                                                     "--listen", "0.0.0.0"]
