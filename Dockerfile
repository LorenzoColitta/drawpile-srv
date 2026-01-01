FROM drawpile/drawpile-srv:2.2

# Expose ports
EXPOSE 27750

# Start with persistence and no session timeout
# Remove --verbose as it's not a valid option
CMD ["--database", "/home/drawpile/drawpile.db", \
     "--sessions", \
     "--session-timeout", "0", \
     "--listen", "0.0.0.0", \
     "--port", "27750"]
