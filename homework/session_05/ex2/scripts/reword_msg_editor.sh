#!/bin/bash
# reword_msg_editor.sh - Git mở thông điệp cũ của commit cần reword; script sao lưu rồi ghi đè.
MSG_FILE="$1"
BACKUP_DIR="${BACKUP_DIR:-$(cd "$(dirname "$0")" && pwd)/backup}"
mkdir -p "$BACKUP_DIR"

cp "$MSG_FILE" "$BACKUP_DIR/reword_message_before.txt"
printf 'docs: bo sung huong dan su dung module auth\n' > "$MSG_FILE"
cp "$MSG_FILE" "$BACKUP_DIR/reword_message_after.txt"
