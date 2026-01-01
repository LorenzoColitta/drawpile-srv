# Drawpile Server for EuroTunnel

A persistent Drawpile collaborative drawing server deployed on Render with Appwrite backup integration.

## Features

- 🎨 **Persistent Sessions**: Sessions survive after all users leave and server restarts
- 💾 **Automatic Backups**: Sessions backed up to Appwrite every 10 seconds
- 🔄 **Auto-Restore**: Sessions restored from backup on server restart
- ⏱️ **72-Hour Idle Timeout**: Sessions automatically cleaned up after 72 hours of inactivity

## Deployment on Render

1. Fork this repository
2. Connect to Render using the `render.yaml` blueprint
3. Set the following environment variables in Render dashboard:
   - `APPWRITE_ENDPOINT` - Your Appwrite server URL
   - `APPWRITE_PROJECT_ID` - Your Appwrite project ID
   - `APPWRITE_API_KEY` - Your Appwrite API key
   - `APPWRITE_BUCKET_ID` - Your Appwrite storage bucket ID

## Using Persistent Sessions

### Creating a Persistent Session

1. Connect to the server using Drawpile client: `drawpile://your-render-url.onrender.com:27750`
2. Host a new session
3. **Important**: In the session settings, check the **"Persistent"** checkbox
4. Set a password if desired

### Returning to Your Session

1. Connect to the same server
2. Your session will still be available even if everyone left
3. Join using the same session ID or alias

## Configuration

The server is configured with:
- **Persistence**: Enabled (`--persistence true`)
- **Session Storage**: File-backed at `/home/drawpile/data/sessions`
- **Database**: SQLite at `/home/drawpile/data/drawpile.db`
- **Idle Timeout**: 72 hours (`--idle-time-limit 72h`)
- **Backup Frequency**: Every 10 seconds to Appwrite

## Technical Details

- **Server Version**: Drawpile 2.2.1
- **Platform**: Ubuntu 22.04 via Docker
- **Port**: 27750
- **Backup Strategy**: Full backups to Appwrite Storage every 10 seconds
- **Disk Space**: 1GB persistent disk on Render

## Troubleshooting

### Sessions Not Persisting
- Ensure you checked "Persistent" when creating the session
- Verify the Render disk is properly mounted
- Check Render logs for errors

### Backup Failures
- Verify all Appwrite environment variables are set correctly
- Check Appwrite bucket permissions
- Review Render logs for backup errors

## License

MIT License - See LICENSE file for details
