#!/bin/bash
# fix-media-perms.sh
# Fixes permissions across GlusterFS media folders
# Logs actions to /var/log/fix-media-perms.log

LOGFILE="/var/log/fix-media-perms.log"
MEDIA_PATH="/mnt/gluster/media"

echo "[`date`] Starting permission fix for media folders..." >> "$LOGFILE"

find "$MEDIA_PATH" -type f -exec chmod 664 {} + 2>>"$LOGFILE"
find "$MEDIA_PATH" -type d -exec chmod 775 {} + 2>>"$LOGFILE"
chown -R 1000:1000 "$MEDIA_PATH" 2>>"$LOGFILE"

echo "[`date`] Permission fix completed." >> "$LOGFILE"
