FROM drawpile/drawpile-srv:2.2

# Render default port is 10000, but we use the environment variable
EXPOSE 10000

# 1. Correct the database path typo (removed the space)
# 2. Use 'sh -c' to allow Render's $PORT variable to work
# 3. Bind the WebSocket server to 0.0.0.0 and the Render $PORT
# 4. Keep the native TCP port on 27750 (internal use)
CMD ["sh", "-c", "drawpile-srv --database /home/drawpile/drawpile.db --sessions /home/drawpile/sessions --listen 0.0.0.0 --port 27750 --websocket-listen 0.0.0.0 --websocket-port ${PORT:-10000}"]
