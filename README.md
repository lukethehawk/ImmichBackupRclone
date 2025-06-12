# ImmichBackupRclone
An advanced rclone script for Immich


# 📦 Immich Backup Automation

A Bash script to perform incremental backups of your Immich library using `rclone`, with daily logging and detailed Telegram notifications.

---

## 🛠️ Requirements

- `rclone` configured (e.g. `proton:Immich`)
- `jq`
- `curl`
- A Telegram bot token and chat ID

---

## 📁 Directory Layout

Organize your Immich library like this:

```
/immich-app/library/library/user1_folder
/immich-app/library/library/user2_folder
```

---

## 🚀 Features

- Incremental backup (`--ignore-existing`)
- Daily log rotation (keeps last 20 days)
- Detailed Telegram report:
  - Number of files copied per user and total  
  - Number of checks  
  - Elapsed time  
  - Disk usage (total and per user, including “new” data)
- Creates a compact daily log with only:
  - `Copied (new)` entries  
  - Final `Transferred`, `Checks`, and `Elapsed time` summary

---

## 🔧 Configuration

1. **Edit the script**:
   - Set `SOURCE` and `DEST` for your setup.  
   - Replace `user1_folder` and `user2_folder` with your actual folder names.  
   - Insert your `BOT_TOKEN` and `CHAT_ID`.

2. **Make it executable**:
   ```bash
   chmod +x backup_immich.sh
   ```

3. **Set up cron** (example: daily at 4 AM):
   ```cron
   0 4 * * * /path/to/backup_immich.sh
   ```

---

## ✅ Example Telegram Notification

```
✅ Immich backup succeeded on srv-photo at Thu 12 Jun 2025, 04:44:45, CEST

📁 Files copied:
User1: 1
User2: 1
Total: 2

🔍 Checks: 16316
⏱️ Elapsed time: 28m38.5s
📦 Disk usage: 67G / 195G (36% used)
📂 Per-user disk usage:
- User1: 26.92 GB (new: 1.56 MB)
- User2: 18.34 GB (new: 0.38 MB)
```

---

## 📄 Log File

Each day a log is saved to `/root/log/log_immich_YYYY-MM-DD.txt`, containing only the essentials:

- `Copied (new)` lines  
- Final `Transferred`, `Checks`, `Elapsed time` summary

---

## 🤝 Contributions

Feel free to open issues or pull requests to improve this script!
