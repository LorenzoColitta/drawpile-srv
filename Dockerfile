FROM drawpile/drawpile-srv:2.2

# Create data directory
RUN mkdir -p /data

# Expose ports
EXPOSE 27750

# Start with persistence and no session timeout
CMD ["--database", "/data/drawpile.db", \
     "--sessions", \
     "--session-timeout", "0", \
     "--listen", "0.0.0.0", \
     "--port", "27750", \
     "--verbose"]
