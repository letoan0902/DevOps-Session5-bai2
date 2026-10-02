#!/bin/bash
# seq_editor.sh - thay thế trình soạn thảo file todo của "git rebase -i" (GIT_SEQUENCE_EDITOR).
# Git truyền đường dẫn file todo vào tham số $1. Khi thao tác tay, file này
# được mở trong vim/nano/VS Code; ở đây script làm thay người dùng.
#
# Các bước:
#   1. Sao lưu NGUYÊN VĂN file todo do Git sinh ra (màn hình soạn thảo lúc mở).
#   2. Sửa dòng 2 và 3 thành squash, dòng 4 thành drop (dòng 1 giữ pick).
#   3. Sao lưu file todo sau khi sửa (màn hình lúc lưu và đóng).
TODO="$1"
BACKUP_DIR="${BACKUP_DIR:-$(cd "$(dirname "$0")" && pwd)/backup}"
mkdir -p "$BACKUP_DIR"

cp "$TODO" "$BACKUP_DIR/rebase_todo_before.txt"

sed -i -e '2s/^pick /squash /' -e '3s/^pick /squash /' -e '4s/^pick /drop /' "$TODO"

cp "$TODO" "$BACKUP_DIR/rebase_todo_after.txt"
