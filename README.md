# Drawpile Server for EuroTunnel

A persistent Drawpile collaborative drawing server with automatic session rollover, deployed on Render with Appwrite backup integration.

## Features

- 🎨 **Persistent Sessions**: Sessions survive after all users leave and server restarts
- 🔄 **Automatic Session Rollover**: Sessions automatically renew every 70 hours, preventing timeout
- 💾 **Automatic Backups**: Sessions backed up to Appwrite every 10 seconds
- 🔄 **Auto-Restore**: Sessions restored from backup on server restart
- ⏱️ **72-Hour Idle Timeout**: Base timeout with automatic rollover before expiry
- 📦 **Session Versioning**: Automatic backups created during rollover

## How It Works

### Session Rollover System
1. When a session reaches 70 hours of age, the rollover system activates
2. A timestamped backup is created (e.g., `myproject_backup_20260101_120000`)
3. The original session files are "touched" to reset their age to 0 hours
4. Your team continues working on the same session name without interruption
5. Process repeats every 70 hours automatically

**Result**: Your sessions effectively never expire, and you always work under the same session name!

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
4. Give your session a memorable name (e.g., "TeamProject")
5. Set a password if desired

### Working with Your Team

1. Everyone connects to `drawpile://your-render-url.onrender.com:27750`
2. Join the session by name (e.g., "TeamProject")
3. Draw and collaborate as normal
4. Everyone can leave and come back anytime
5. Session automatically renews every 70 hours in the background
6. **No need to create new sessions** - the same one persists indefinitely!

### Session Lifecycle Example

```
Hour 0:   Create "TeamProject" session
Hour 24:  Team continues working
Hour 48:  Team takes a break, everyone leaves
Hour 70:  🔄 Automatic rollover (backup created, session renewed)
Hour 72:  Team returns, continues working on "TeamProject"
Hour 140: 🔄 Another automatic rollover
...and so on forever!
```

## Configuration

The server is configured with:
- **Persistence**: Enabled via `drawpile.cfg`
- **Session Storage**: File-backed at `/home/drawpile/data/sessions`
- **Database**: SQLite at `/home/drawpile/data/drawpile.db`
- **Idle Timeout**: 72 hours with automatic rollover at 70 hours
- **Backup Frequency**: Every 10 seconds to Appwrite
- **Rollover Check**: Every 60 minutes

## Technical Details

- **Server Version**: Drawpile 2.2.1
- **Platform**: Ubuntu 22.04 via Docker
- **Port**: 27750 (configurable via `PORT` env var)
- **Backup Strategy**: Incremental backups to Appwrite Storage
- **Rollover Strategy**: Timestamp reset with versioned backups
- **Disk Space**: 1GB persistent disk on Render

## Background Services

The server runs three background processes:

1. **Backup Service** (`sync-to-appwrite.sh`): Backs up all data every 10 seconds
2. **Rollover Service** (`rollover-sessions.sh`): Checks sessions hourly and renews old ones
3. **Drawpile Server** (`drawpile-srv`): Main drawing server

## Troubleshooting

### Sessions Not Persisting
- Ensure you checked "Persistent" when creating the session
- Verify the Render disk is properly mounted at `/home/drawpile/data`
- Check Render logs for errors

### Sessions Still Timing Out
- Check rollover logs: `[Rollover]` prefix in Render logs
- Verify session files exist in `/home/drawpile/data/sessions/`
- Ensure rollover script is running (check for `[Rollover] Session rollover monitor started`)

### Backup Failures
- Verify all Appwrite environment variables are set correctly
- Check Appwrite bucket permissions
- Review Render logs for backup errors with `[Backup]` prefix

### Finding Old Session Versions
- Old versions are saved as `sessionname_backup_YYYYMMDD_HHMMSS`
- These are also backed up to Appwrite
- Can be manually restored if needed

## Monitoring

Check Render logs for these indicators:

```
[Rollover] Session rollover monitor started
[Rollover] Checking for sessions needing rollover...
[Rollover] ⚠️  Session 'TeamProject' is 70h old - initiating rollover...
[Rollover] ✅ Session 'TeamProject' rolled over successfully
```

## License

MIT License - See LICENSE file for details
