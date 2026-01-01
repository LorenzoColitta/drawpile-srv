FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install build dependencies and runtime requirements
RUN apt-get update && apt-get install -y \
    git \
    cmake \
    build-essential \
    qtbase5-dev \
    libqt5svg5-dev \
    qtmultimedia5-dev \
    libsodium-dev \
    libmicrohttpd-dev \
    libsystemd-dev \
    libvpx-dev \
    extra-cmake-modules \
    libkf5archive-dev \
    libzip-dev \
    && rm -rf /var/lib/apt/lists/*

# Clone and build Drawpile server
WORKDIR /tmp
RUN git clone --depth 1 --branch 2.2.1 https://github.com/drawpile/Drawpile. git \
    && cd Drawpile \
    && mkdir build \
    && cd build \
    && cmake .. -DCMAKE_BUILD_TYPE=Release -DSERVER=ON -DCLIENT=OFF -DTOOLS=OFF \
    && make -j$(nproc) \
    && make install \
    && cd / \
    && rm -rf /tmp/Drawpile

# Create data directory
RUN mkdir -p /data

EXPOSE 27750

CMD ["drawpile-srv", \
     "--database", "/data/drawpile. db", \
     "--sessions", \
     "--session-timeout", "0", \
     "--port", "27750", \
     "--listen", "0.0.0.0", \
     "--verbose"]
