#!/bin/bash

# === CONFIGURATION ===
SOURCE="/root/immich-app/library/library" 	# Path to the local Immich library
DEST="proton:Immich" 						            # rclone remote destination (must be configured)

# Define user folders (replace with your actual subfolders)
USER1_NAME="User1" 							      # Display name for first user
USER2_NAME="User2"							      # Display name for second user
USER1_PATH="$SOURCE/user1_folder"			# Local path to first user's subfolder
USER2_PATH="$SOURCE/user2_folder"			# Local path to second user's subfolder
LOGDIR="/root/log"
mkdir -p "$LOGDIR"							      # Ensure log directory exists

# Delete logs older than 20 days
find "$LOGDIR" -type f -name 'log_immich_*.txt' -mtime +20 -delete		# Remove old logs (older than 20 days)

# Create log files
MAINLOGFILE="$LOGDIR/log_immich_$(date +%F).txt"		# Daily log file
TEMPLOGFILE=$(mktemp)									              # Temporary log file for current run

# === TELEGRAM NOTIFICATION CONFIGURATION ===
BOT_TOKEN="INSERT_YOUR_TELEGRAM_BOT_TOKEN"				# Telegram bot token (insert your own)
CHAT_ID="INSERT_YOUR_CHAT_ID"							        # Telegram chat ID (insert your own)

# === EXECUTE BACKUP ===
# Start rclone backup with parameters
rclone sync "$SOURCE" "$DEST" \
# --backup-dir="proton:Immich/archive/$(date +%F_%H-%M-%S)" \  # Optional: move deleted/modified files here instead of losing them. Useful for archival. Use only if you have enough space on your remote!
  --ignore-existing \
  --drive-chunk-size 128M \
  --fast-list \
  --tpslimit 4 \
  --transfers 2 \
  --checkers 2 \
  --retries 3 \
  --low-level-retries 5 \
  --retries-sleep 15s \
  --timeout 10m \
  --contimeout 30s \
  --expect-continue-timeout 10s \
  --log-file="$TEMPLOGFILE" \
  --log-level INFO

STATUS=$?		# Save rclone exit status

if [ $STATUS -eq 0 ]; then
  TOTAL=$(grep 'Copied (new)' "$TEMPLOGFILE" | grep -v '/\.' | wc -l)
  # Count number of new files copied (total)
  U1_COUNT=$(grep 'Copied (new)' "$TEMPLOGFILE" | grep ' user1_folder/' | wc -l)
  # Count number of new files copied for user 1
  U2_COUNT=$(grep 'Copied (new)' "$TEMPLOGFILE" | grep ' user2_folder/' | wc -l)
  # Count number of new files copied for user 2
  CHECKS=$(grep 'Checks:' "$TEMPLOGFILE" | tail -n1 | awk '{print $2}')
  # Extract number of file checks from log
  ELAPSED=$(grep 'Elapsed time' "$TEMPLOGFILE" | tail -n1 | awk -F': ' '{print $2}')
  # Extract elapsed time from log
  DISK_USAGE=$(df -h / | awk 'NR==2 {print "📦 Disk usage: "$3" / "$2" ("$5" used)"}')
  # Get overall disk usage

  U1_NEW=$(grep 'Copied (new)' "$TEMPLOGFILE" | grep ' user1_folder/' | awk -F': ' '{print $2}' | xargs -I{} stat --format="%s" "$SOURCE/{}" 2>/dev/null | awk '{sum+=$1} END {printf "%.2f MB", sum/1024/1024}')
  # Calculate size of new files copied for each user
  U2_NEW=$(grep 'Copied (new)' "$TEMPLOGFILE" | grep ' user2_folder/' | awk -F': ' '{print $2}' | xargs -I{} stat --format="%s" "$SOURCE/{}" 2>/dev/null | awk '{sum+=$1} END {printf "%.2f MB", sum/1024/1024}')
  # Calculate size of new files copied for each user

  U1_TOTAL=$(rclone size "$DEST/user1_folder" --json | jq '.bytes' | awk '{printf "%.2f GB", $1/1024/1024/1024}')
  # Get total storage used by each user on remote
  U2_TOTAL=$(rclone size "$DEST/user2_folder" --json | jq '.bytes' | awk '{printf "%.2f GB", $1/1024/1024/1024}')
  # Get total storage used by each user on remote

  if [ "$TOTAL" -eq 0 ]; then
  # If no new files were copied, prepare minimal message
    MESSAGE="📦 Immich backup completed on $(hostname) at $(date)

No new files to backup.
🔍 Checked files: $CHECKS
⏱️ Duration: $ELAPSED
$DISK_USAGE"
  else
    MESSAGE="✅ Immich backup completed successfully on $(hostname) at $(date)

📁 Files copied:
$USER1_NAME: $U1_COUNT
$USER2_NAME: $U2_COUNT
Total: $TOTAL

🔍 Checked files: $CHECKS
⏱️ Duration: $ELAPSED
$DISK_USAGE
📂 Per-user disk usage:
- $USER1_NAME: $U1_TOTAL (new: $U1_NEW)
- $USER2_NAME: $U2_TOTAL (new: $U2_NEW)"
  fi

else
# If backup failed, prepare error message
  if grep -qE "ERROR|401|503|504" "$TEMPLOGFILE"; then
  # Detect API-related errors in the log
    MESSAGE="❌ Immich backup failed (API errors) on $(hostname) at $(date)

Check the log file: $MAINLOGFILE"
  else
    MESSAGE="❌ Immich backup failed with unknown error on $(hostname). Manual check recommended."
  fi
fi

# === OPTIONAL: DELETE OLD ARCHIVE FOLDERS ===
DELETE_OLD_ARCHIVES=false              # Set to true to enable archive cleanup
ARCHIVE_PATH="proton:Immich/archive" # Path where --backup-dir saves deleted files
KEEP_DAYS=30                          # Number of days to keep

if [ "$DELETE_OLD_ARCHIVES" = true ]; then
  # Get date threshold in seconds
  THRESHOLD=$(date -d "$KEEP_DAYS days ago" +%s)

  # List remote archive directories
  rclone lsf "$ARCHIVE_PATH" --dirs-only | while read -r dir; do
    # Remove trailing slash and extract timestamp from directory name
    clean_dir=$(echo "$dir" | sed 's:/*$::')
    dir_date=$(echo "$clean_dir" | cut -d_ -f1)  # Extract YYYY-MM-DD
    dir_epoch=$(date -d "$dir_date" +%s 2>/dev/null)

    if [ -n "$dir_epoch" ] && [ "$dir_epoch" -lt "$THRESHOLD" ]; then
      rclone purge "$ARCHIVE_PATH/$clean_dir" || logger "Failed to delete $clean_dir from archive"
    fi
  done
fi

# === COMPACT LOG CREATION ===
{
  grep 'Copied (new)' "$TEMPLOGFILE"
  echo ""
  tail -100 "$TEMPLOGFILE" | grep -E 'Transferred:|Checks:|Elapsed time:'
} > "$MAINLOGFILE"

rm "$TEMPLOGFILE"

# Clean up temporary log

# === SEND TELEGRAM NOTIFICATION ===
curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" \
# Send Telegram text message
  -d chat_id="$CHAT_ID" \
  -d "text=$MESSAGE"

curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendDocument" \
# Send Telegram log file as document
  -F chat_id="$CHAT_ID" \
  -F caption="📎 Immich backup log - $(date)" \
  -F document=@"$MAINLOGFILE"
