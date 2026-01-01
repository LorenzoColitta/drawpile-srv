FROM ubuntu:22.04

# Prevent interactive prompts during installation
ENV DEBIAN_FRONTEND=noninteractive

# Install Drawpile server from Ubuntu repository
RUN apt-get update && apt-get install -y \
    drawpile-srv \
    && rm -rf /var/lib/apt/lists/*

# Create data directory
RUN mkdir -p /data

# Expose the server port
EXPOSE 27750

# Start server with persistence and no timeout
CMD ["drawpile-srv", \
     "--database", "/data/drawpile. db", \
     "--sessions", \
     "--session-timeout", "0", \
     "--port", "27750", \
     "--listen", "0.0.0.0", \
     "--verbose"]
