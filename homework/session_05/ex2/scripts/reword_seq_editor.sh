#!/bin/bash
# reword_seq_editor.sh - minh họa lệnh reword: đổi "pick" ở dòng 1 thành "reword".
# Khi thao tác tay: mở file todo, sửa chữ "pick" thành "reword" (hoặc "r"), lưu và đóng.
TODO="$1"
BACKUP_DIR="${BACKUP_DIR:-$(cd "$(dirname "$0")" && pwd)/backup}"
mkdir -p "$BACKUP_DIR"

cp "$TODO" "$BACKUP_DIR/reword_todo_before.txt"
sed -i -e '1s/^pick /reword /' "$TODO"
cp "$TODO" "$BACKUP_DIR/reword_todo_after.txt"
