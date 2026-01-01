FROM ubuntu:22.04

# Install wget and other necessary packages
RUN apt-get update && apt-get install -y \
    wget \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Download and extract the Drawpile server AppImage
WORKDIR /opt
RUN wget https://drawpile.net/files/bin/drawpile-2.2.1-appimage.tar.gz \
    && tar -xzf drawpile-2.2.1-appimage.tar.gz \
    && rm drawpile-2.2.1-appimage. tar.gz \
    && chmod +x Drawpile-*. AppImage

# Extract the AppImage to access drawpile-srv
RUN ./Drawpile-*.AppImage --appimage-extract \
    && mv squashfs-root /opt/drawpile

# Expose the default Drawpile server port
EXPOSE 27750

# Set the working directory
WORKDIR /opt/drawpile

# Run the server
CMD ["./usr/bin/drawpile-srv", "--port", "27750", "--listen", "0.0.0.0"]
