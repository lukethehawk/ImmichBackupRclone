# ImmichBackupRclone

An advanced `rclone`-based backup script for [Immich](https://github.com/immich-app/immich), featuring multi-user support, Telegram notifications, and minimal logs. You can backup your database, Profile and Upload folders using the BackupEssentials script.



---

## 📚 Index

- [How the script works](#how-the-script-works)
- [Installation](#installation)
- [Cronjob Setup](#cronjob-setup)
- [Telegram Bot Setup](#telegram-bot-setup)
- [Example Telegram Notification](#example-telegram-notification)
- [Log Output](#log-output)
- [Backup DB and essentials directories](#backup-essentials)

---

<h2 id="how-the-script-works">📦 How the script works</h2>

This Bash script performs **incremental backups** of your Immich library using `rclone`, stores essential logs, and sends Telegram notifications with user-based statistics.

Each user's folder is backed up separately, and disk usage is calculated both globally and per-user (including the amount of **new data** copied in the current run).

---

<h2 id="installation">🛠️ Installation</h2>

### 1. Requirements

Make sure you have the following installed:

- [`rclone`](https://rclone.org/)
- `jq`
- `curl`
- A Telegram bot and your chat ID (see [Telegram Bot Setup](#telegram-bot-setup))

### 2. Directory Structure

Your Immich library must follow this format:

```
/immich-app/library/library/user1_folder
/immich-app/library/library/user2_folder
```

---

## ⚙️ Configuration

### Edit the script:
- Set:
  - `SOURCE` (e.g. `/root/immich-app/library/library`)
  - `DEST` (e.g. `proton:Immich`)
- Replace `user1_folder` and `user2_folder` with actual user folders
- Add your `BOT_TOKEN` and `CHAT_ID`

### Make the script executable:
```bash
chmod +x backup_immich.sh
```

---

<h2 id="cronjob-setup">⏰ Cronjob Setup</h2>

To run the backup every day at 4:00 AM:

```cron
0 4 * * * /path/to/backup_immich.sh
```

Logs are automatically rotated and deleted after 20 days.

---

<h2 id="telegram-bot-setup">📬 Telegram Bot Setup</h2>

### 1. Create the bot via BotFather
- Open Telegram and search for `@BotFather`
- Send `/newbot` and follow instructions (choose name + username)
- Save the **API token** returned (e.g. `123456789:ABCDefGhIJKlmNoPQRstuVWxyZ`)

### 2. Start the bot
- Open the chat with your new bot and press **Start**

### 3. Get your Chat ID

**Method A – Telegram API:**
1. Visit:  
   `https://api.telegram.org/bot<YOUR_BOT_TOKEN>/getUpdates`
2. Send a message to the bot
3. Reload the URL and find:
   ```json
   "chat":{"id":123456789,...
   ```

**Method B – @userinfobot**
- Search for `@userinfobot` in Telegram
- It replies with your Telegram user ID (chat ID)

### 4. Edit the script
Replace:
```bash
BOT_TOKEN="your-telegram-bot-token"
CHAT_ID="your-chat-id"
```

---

<h2 id="example-telegram-notification">✅ Example Telegram Notification</h2>

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

<h2 id="log-output">📄 Log Output</h2>

Each day, the script generates a minimal log at:

```
/root/log/log_immich_YYYY-MM-DD.txt
```

It includes:

- `Copied (new)` lines (new files uploaded)
- Final statistics:
  - `Transferred`
  - `Checks`
  - `Elapsed time`

Example:
```
2025/06/12 04:32:19 INFO  : user1/2025/2025-06-11/IMG_1234.jpg: Copied (new)

Transferred:   	    1.561 MiB / 1.561 MiB, 100%, 1.626 MiB/s, ETA 0s
Checks:             16316 / 16316, 100%
Transferred:            2 / 2, 100%
Elapsed time:     28m38.5s
```

---

<h2 id="backup-essentials"> 🧠 Backup of Immich Database and Additional Folders (upload, profile)</h2>

To ensure full backup coverage beyond the media library, you may also want to include:

    The PostgreSQL database (user data, metadata)

    The upload folder (temporary media)

    The profile folder (user profile images and other config assets)

Download and run the BackupEssentials.sh

---

## 🤝 Contributions

Contributions, improvements, and ideas are welcome!  
Feel free to fork, submit a PR, or open an issue.

---
