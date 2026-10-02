#!/bin/bash
# msg_editor.sh - thay thế trình soạn thảo thông điệp commit (GIT_EDITOR).
# Khi squash xong, Git mở file thông điệp gộp ("This is a combination of 3 commits...")
# và truyền đường dẫn vào $1. Khi thao tác tay, đây là màn hình vim/nano/VS Code.
#
# Các bước:
#   1. Sao lưu NGUYÊN VĂN nội dung Git đề xuất.
#   2. Ghi đè bằng thông điệp mới: tiêu đề + thân gạch đầu dòng.
#   3. Sao lưu thông điệp sau khi sửa.
MSG_FILE="$1"
BACKUP_DIR="${BACKUP_DIR:-$(cd "$(dirname "$0")" && pwd)/backup}"
mkdir -p "$BACKUP_DIR"

cp "$MSG_FILE" "$BACKUP_DIR/squash_message_before.txt"

cat > "$MSG_FILE" <<'MSG'
feat: hoan thien module authentication

- khoi tao module auth voi ham login
- sua loi chinh ta trong thong bao loi
- bo sung ham tien ich validateEmail va hashPassword
MSG

cp "$MSG_FILE" "$BACKUP_DIR/squash_message_after.txt"
