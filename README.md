# ImmichBackupRclone
An advanced rclone script for Immich

## Index

- [How the script works](#how-the-script-works)
- [Installation](#installation)
- [Cronjob Setup](#cronjob-setup)
- [Telegram Bot Setup](#how-to-create-a-telegram-bot-with-botfather)



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

## 🤖 How to Create a Telegram Bot with BotFather

To receive backup notifications via Telegram, you'll need to create a bot and get its API token. Here's how:

### 1. Start a Chat with BotFather
- Open Telegram and search for `@BotFather`
- Click **Start** or type `/start` to begin

### 2. Create a New Bot
- Send the command: `/newbot`
- BotFather will ask you for:
  - A **name** for your bot (e.g. `Immich Backup Bot`)
  - A **username** that ends in `bot` (e.g. `immich_backup_bot`)

### 3. Get Your Bot Token
- Once created, BotFather will return an **API token** like this:

    ```
    123456789:ABCDefGhIJKlmNoPQRstuVWxyZ
    ```

- **Copy and save this token** — you'll need it for the script.

### 4. Start the Bot
- Open a chat with your new bot (use the link provided by BotFather)
- Click **Start** to activate it

### 5. Get Your Chat ID

To receive messages, you'll also need your personal chat ID.

#### Method A: Use Telegram API directly
1. Visit:  
   `https://api.telegram.org/bot<YOUR_BOT_TOKEN>/getUpdates`  
   (Replace `<YOUR_BOT_TOKEN>` with your actual token)
2. Send a message to your bot on Telegram
3. Reload the URL above
4. Look for a section like:

    ```json
    "chat":{"id":123456789,...
    ```

   That number (`123456789`) is your **Chat ID**

#### Method B (Alternative): Use @userinfobot
- In Telegram, search for `@userinfobot`
- Start it, and it will display your **user ID** (which is your Chat ID)

### 6. Add Token and Chat ID to Your Script
Edit the script and replace these lines:

```bash
BOT_TOKEN="your-telegram-bot-token"
CHAT_ID="your-chat-id"


## 🤝 Contributions

Feel free to open issues or pull requests to improve this script!
