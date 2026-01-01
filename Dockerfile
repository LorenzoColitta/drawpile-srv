# Use 2.2.1 or latest because 2.2.0 does not support the WebSocket flags required by Render
FROM drawpile/drawpile-srv:2.2.1

# Expose the default port for local testing, though Render will use $PORT
EXPOSE 10000

# 1. Corrected database path (/drawpile.db)
# 2. WebSocket server listens on $PORT (Render's requirement for 'Web Services')
# 3. Standard TCP server moved to 27750 (internal use)
CMD sh -c "drawpile-srv --database /home/drawpile/drawpile.db --sessions /home/drawpile/sessions --listen 0.0.0.0 --port 27750 --websocket-listen 0.0.0.0 --websocket-port ${PORT:-10000}"
