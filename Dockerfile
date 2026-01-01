FROM drawpile/drawpile-srv:2.2

# Expose both the Drawpile port and Render's PORT
ENV PORT=10000
EXPOSE 27750 ${PORT}

# Start drawpile-srv with the --port flag to use Render's PORT
CMD ["drawpile-srv", \
     "--listen", "0.0.0.0", \
     "--port", "${PORT}", \
     "--sessions", "/home/drawpile/sessions", \
     "--database", "/home/drawpile/config. db", \
     "--web-admin-port", "27780", \
     "--web-admin-access", "all"]
