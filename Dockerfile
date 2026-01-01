FROM drawpile/drawpile-srv:2.2

# Start with persistence
# We bind the WebSocket server to the Render-assigned $PORT
# We move the internal TCP server to 27751 to avoid port conflicts
CMD sh -c "drawpile-srv --database /home/drawpile/drawpile.db --sessions /home/drawpile/sessions --listen 127.0.0.1 --port 27751 --websocket-listen 0.0.0.0 --websocket-port ${PORT:-10000}"
