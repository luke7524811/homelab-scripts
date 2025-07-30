#!/bin/bash
# deduplicate-files.sh
# Deletes older duplicates, keeps the largest or newest file
# Logs to /var/log/deduplicate-files.log

LOGFILE="/var/log/deduplicate-files.log"
TARGET_DIR="/mnt/gluster/media/audiobooks"

echo "[`date`] Starting duplicate cleanup..." >> "$LOGFILE"

# Find duplicate filenames in the same directory
find "$TARGET_DIR" -type f -printf '%P\n' | sort | uniq -d | while read FILENAME; do
  echo "[`date`] Checking: $FILENAME" >> "$LOGFILE"
  matches=$(find "$TARGET_DIR" -type f -name "$FILENAME")

  # Count number of duplicates
  count=$(echo "$matches" | wc -l)
  if [ "$count" -le 1 ]; then
    continue  # skip if not actually a duplicate
  fi

  # Find the LARGEST version of the file and keep it
  file_to_keep=$(echo "$matches" | xargs -I{} stat -c "%s %n" {} | sort -nr | head -n1 | cut -d' ' -f2-)
  echo "[`date`] Keeping: $file_to_keep" >> "$LOGFILE"

  # Delete all others
  for file in $matches; do
    if [[ "$file" != "$file_to_keep" ]]; then
      echo "[`date`] Deleting: $file" >> "$LOGFILE"
      rm -f "$file"
    fi
  done
done

echo "[`date`] Duplicate cleanup completed." >> "$LOGFILE"
