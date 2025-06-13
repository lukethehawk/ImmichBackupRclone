#!/bin/bash

IMMICH_ROOT="/root/immich-app/library"  # use the path where you have the folders "profile" and "upload"
DEST="proton:Immich"                    # use your rclone mount

# === DATABASE BACKUP ===
DB_DUMP_PATH="$IMMICH_ROOT/db-backup"
mkdir -p "$DB_DUMP_PATH"
DB_FILE="$DB_DUMP_PATH/dump_$(date +%F).sql.gz"
docker exec -t immich_postgres pg_dumpall --clean --if-exists --username=postgres | gzip > "$DB_FILE"


# === RCLONE COPY: UPLOAD, PROFILE, DB BACKUP (UNIFIED) ===
rclone sync "$IMMICH_ROOT" "$DEST" \
  --include "db-backup/**" \
  --include "upload/**" \
  --include "profile/**" \
  --drive-chunk-size 128M \
  --fast-list \
  --transfers 2 \
  --checkers 2 \
  --retries 2 \
  --low-level-retries 2 \
  --timeout 5m \
  --progress
