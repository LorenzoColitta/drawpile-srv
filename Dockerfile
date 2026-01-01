FROM drawpile/drawpile-srv:2.2

# Expose ports
EXPOSE 27750

# Start with persistence
CMD sh -c "drawpile-srv --database /home/drawpile/drawpile.db --sessions /home/drawpile/sessions --listen 0.0.0.0 --port 27750 --websocket-listen 0.0.0.0 --websocket-port ${PORT:-10000}"
