FROM drawpile/drawpile-srv:latest

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
