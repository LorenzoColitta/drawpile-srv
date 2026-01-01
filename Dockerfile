FROM drawpile/drawpile-srv:2.2

# Expose ports
EXPOSE 27750

# Start with persistence
CMD ["--database", "/home/drawpile/drawpile. db", \
     "--sessions", "/home/drawpile/sessions", \
     "--listen", "0.0.0.0", \
     "--port", "27750"]
