# DevOps Session 05 - Bài 2: Tái cấu trúc lịch sử commit bằng Interactive Rebase

Bài tập thực hành dùng `git rebase -i` để chỉnh sửa lịch sử cục bộ: gộp (squash) 3 commit nhỏ lẻ thành 1 commit có ý nghĩa, đổi thông điệp (reword) thành `feat: hoan thien module authentication` và xóa (drop) commit chứa file rác `temp.txt`.

Báo cáo đầy đủ: [homework/session_05/ex2/README.md](homework/session_05/ex2/README.md)

## Danh sách file

| File | Nội dung |
|------|----------|
| `homework/session_05/ex2/README.md` | Báo cáo chi tiết |
| `homework/session_05/ex2/terminal_log.txt` | Toàn bộ lệnh và output thật |
| `homework/session_05/ex2/rebase_todo_before.txt` | File todo lúc mở (nguyên văn) |
| `homework/session_05/ex2/rebase_todo_after.txt` | File todo sau khi sửa (pick, squash, squash, drop) |
| `homework/session_05/ex2/squash_message_before.txt` | Thông điệp gộp Git đề xuất |
| `homework/session_05/ex2/squash_message_after.txt` | Thông điệp gộp sau khi sửa |
| `homework/session_05/ex2/auth.js` | Bản cuối cùng của file |
| `homework/session_05/ex2/scripts/seq_editor.sh` | Script thay `GIT_SEQUENCE_EDITOR` |
| `homework/session_05/ex2/scripts/msg_editor.sh` | Script thay `GIT_EDITOR` |
| `homework/session_05/ex2/scripts/reword_seq_editor.sh`, `reword_msg_editor.sh` | Script cho phần trình diễn reword |
