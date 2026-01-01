FROM drawpile/drawpile-srv:2.2

# Expose ports
EXPOSE 27750

# Start with persistence and no session timeout
# Use /home/drawpile for data storage (we have permission here)
CMD ["--database", "/home/drawpile/drawpile.db", \
     "--sessions", \
     "--session-timeout", "0", \
     "--listen", "0.0.0.0", \
     "--port", "27750", \
     "--verbose"]
