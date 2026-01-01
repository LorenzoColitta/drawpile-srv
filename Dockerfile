FROM ubuntu:22.04

# Install required dependencies
RUN apt-get update && apt-get install -y \
    wget \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt

# Download and extract the correct AppImage version
# Use the actual download URL from drawpile.net
RUN wget https://github.com/drawpile/Drawpile/releases/download/2.2.1/Drawpile-2.2.1-x86_64.AppImage \
    && chmod +x Drawpile-2.2.1-x86_64.AppImage

# Create necessary directories
RUN mkdir -p /home/drawpile/sessions /home/drawpile/config

# Expose the default Drawpile server port
EXPOSE 27750

# Set environment variables for web admin
ENV DRAWPILESRV_WEB_ADMIN_AUTH=admin:yourpassword

# Run the server with the AppImage
CMD ["./Drawpile-2.2.1-x86_64.AppImage", "--server", \
     "--sessions", "/home/drawpile/sessions", \
     "--database", "/home/drawpile/config. db", \
     "--port", "27750", \
     "--web-admin-port", "27780", \
     "--web-admin-access", "all"]
