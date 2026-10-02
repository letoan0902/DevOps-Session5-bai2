# Bài 2 - Tái cấu trúc lịch sử commit bằng Interactive Rebase

Session 05 - DevOps. Toàn bộ lệnh dưới đây được chạy thật bằng Git 2.49.0.windows.1 trên Windows 11 (Git Bash). Output được chép nguyên văn từ `terminal_log.txt`.

## 1. Mục tiêu

- Dùng `git rebase -i` để chỉnh sửa lịch sử commit cục bộ, trước khi đẩy lên remote.
- Gộp (squash) 3 commit nhỏ lẻ thành 1 commit có ý nghĩa.
- Đổi thông điệp commit (reword) thành `feat: hoan thien module authentication`.
- Xóa (drop) hoàn toàn commit chứa file rác thử nghiệm `temp.txt`.
- Kết quả mong đợi: nhánh tính năng chỉ còn đúng 1 commit sạch sẽ đại diện cho tính năng, không còn commit phụ rác.

## 2. Kịch bản

Nhánh `feature/auth` được tách từ `main` (có sẵn commit nền `chore: khoi tao du an`). Trên nhánh này có 4 commit theo gợi ý của đề:

| STT | Thao tác | Thông điệp commit |
|-----|----------|-------------------|
| 1 | Tạo `auth.js` (hàm `login`, cố ý có lỗi chính tả `credentails`) | `feat: khoi tao module auth` |
| 2 | Sửa lỗi chính tả trong `auth.js` | `fix typo` |
| 3 | Thêm hàm tiện ích `validateEmail`, `hashPassword` (giả lập) | `adds utility functions` |
| 4 | Tạo `temp.txt` (file rác để debug) | `add temp file for debug` |

Lệnh sẽ chạy: `git rebase -i HEAD~4` với cấu hình `pick` / `squash` / `squash` / `drop`.

### Cách thực hiện trong môi trường tự động

Công cụ chạy lệnh ở đây không mở được trình soạn thảo tương tác (vim/nano/VS Code). Vì vậy dùng hai biến môi trường chuẩn của Git để thay người dùng soạn thảo:

- `GIT_SEQUENCE_EDITOR`: chương trình được gọi để sửa file todo của `rebase -i`. Script `scripts/seq_editor.sh` sao lưu nguyên văn file todo Git sinh ra (chính là "màn hình soạn thảo" lúc mở), rồi dùng `sed` sửa dòng 2 và 3 thành `squash`, dòng 4 thành `drop`, và sao lưu bản sau khi sửa.
- `GIT_EDITOR`: chương trình được gọi để soạn thông điệp commit. Script `scripts/msg_editor.sh` sao lưu nguyên văn thông điệp gộp Git đề xuất rồi ghi đè bằng thông điệp mới.

Khi làm bằng tay (không đặt hai biến này), Git mở đúng nội dung trình bày ở mục 5 và mục 6 trong trình soạn thảo mặc định (vim, nano hoặc VS Code tùy `core.editor`); người dùng tự sửa chữ `pick` thành `squash`/`drop`, lưu và đóng file. Nội dung hiển thị và kết quả hoàn toàn giống nhau.

## 3. Chuẩn bị repo và lịch sử trước rebase

```
$ git init -b main
Initialized empty Git repository in D:/Rikkei/DevOps/Session5/_demo/bai2/rebase-interactive-demo/.git/

$ git config user.name "Lê Toàn"
$ git config user.email "trinhhanh261293@gmail.com"
$ git config core.autocrlf false

$ printf "# Rebase Interactive Demo\n" > README.md
$ git add README.md
$ git commit -m "chore: khoi tao du an"
[main (root-commit) fb70247] chore: khoi tao du an
 1 file changed, 1 insertion(+)
 create mode 100644 README.md

$ git switch -c feature/auth
Switched to a new branch 'feature/auth'
```

Bốn commit trên `feature/auth` có hash lần lượt `fc4014a`, `145fbeb`, `107b139`, `d76d486` (output đầy đủ của từng `git commit` có trong `terminal_log.txt`).

Lịch sử và thư mục làm việc ngay trước khi rebase:

```
$ git log --oneline
d76d486 add temp file for debug
107b139 adds utility functions
145fbeb fix typo
fc4014a feat: khoi tao module auth
fb70247 chore: khoi tao du an

$ git log --oneline main..feature/auth
d76d486 add temp file for debug
107b139 adds utility functions
145fbeb fix typo
fc4014a feat: khoi tao module auth

$ ls
README.md
auth.js
temp.txt
```

Nhánh có 5 commit, trong đó 4 commit nằm trên `main` (đúng bằng số đối số của `HEAD~4`).

## 4. Lệnh rebase

```
$ GIT_SEQUENCE_EDITOR="bash /d/Rikkei/DevOps/Session5/_demo/bai2/seq_editor.sh" GIT_EDITOR="bash /d/Rikkei/DevOps/Session5/_demo/bai2/msg_editor.sh" git rebase -i HEAD~4
Rebasing (2/4)
Rebasing (3/4)
[detached HEAD 098eeca] feat: hoan thien module authentication
 Date: Fri Oct 2 12:47:59 2026 +0700
 1 file changed, 18 insertions(+)
 create mode 100644 auth.js
Rebasing (4/4)
Successfully rebased and updated refs/heads/feature/auth.
```

(Git in tiến trình `Rebasing (n/m)` bằng ký tự CR để ghi đè lên cùng một dòng; trong file này mỗi mục được tách thành một dòng.)

Khi làm tay, chỉ cần gõ `git rebase -i HEAD~4`.

## 5. Giao diện soạn thảo Interactive Rebase

### 5.1. Lúc mở (nguyên văn file todo do Git sinh ra)

Đây là màn hình hiện ra trong vim/nano/VS Code khi chạy `git rebase -i HEAD~4` (file `rebase_todo_before.txt`):

```
pick fc4014a feat: khoi tao module auth
pick 145fbeb fix typo
pick 107b139 adds utility functions
pick d76d486 add temp file for debug

# Rebase fb70247..d76d486 onto fb70247 (4 commands)
#
# Commands:
# p, pick <commit> = use commit
# r, reword <commit> = use commit, but edit the commit message
# e, edit <commit> = use commit, but stop for amending
# s, squash <commit> = use commit, but meld into previous commit
# f, fixup [-C | -c] <commit> = like "squash" but keep only the previous
#                    commit's log message, unless -C is used, in which case
#                    keep only this commit's message; -c is same as -C but
#                    opens the editor
# x, exec <command> = run command (the rest of the line) using shell
# b, break = stop here (continue rebase later with 'git rebase --continue')
# d, drop <commit> = remove commit
# l, label <label> = label current HEAD with a name
# t, reset <label> = reset HEAD to a label
# m, merge [-C <commit> | -c <commit>] <label> [# <oneline>]
#         create a merge commit using the original merge commit's
#         message (or the oneline, if no original merge commit was
#         specified); use -c <commit> to reword the commit message
# u, update-ref <ref> = track a placeholder for the <ref> to be updated
#                       to this position in the new commits. The <ref> is
#                       updated at the end of the rebase
#
# These lines can be re-ordered; they are executed from top to bottom.
#
# If you remove a line here THAT COMMIT WILL BE LOST.
#
# However, if you remove everything, the rebase will be aborted.
#
```

Lưu ý quan trọng: thứ tự dòng trong todo là CŨ Ở TRÊN, MỚI Ở DƯỚI - ngược với `git log` (mới ở trên). Các dòng được thực thi từ trên xuống dưới. Vì vậy `squash` luôn gộp commit của dòng đó vào commit ở dòng phía trên nó.

### 5.2. Sau khi cấu hình (pick, squash, squash, drop)

Người dùng sửa chữ đầu của dòng 2, 3 thành `squash` (hoặc `s`) và dòng 4 thành `drop` (hoặc `d`), phần chú thích giữ nguyên (nguyên văn file `rebase_todo_after.txt`):

```
pick fc4014a feat: khoi tao module auth
squash 145fbeb fix typo
squash 107b139 adds utility functions
drop d76d486 add temp file for debug

# Rebase fb70247..d76d486 onto fb70247 (4 commands)
#
# Commands:
# p, pick <commit> = use commit
# r, reword <commit> = use commit, but edit the commit message
# e, edit <commit> = use commit, but stop for amending
# s, squash <commit> = use commit, but meld into previous commit
# f, fixup [-C | -c] <commit> = like "squash" but keep only the previous
#                    commit's log message, unless -C is used, in which case
#                    keep only this commit's message; -c is same as -C but
#                    opens the editor
# x, exec <command> = run command (the rest of the line) using shell
# b, break = stop here (continue rebase later with 'git rebase --continue')
# d, drop <commit> = remove commit
# l, label <label> = label current HEAD with a name
# t, reset <label> = reset HEAD to a label
# m, merge [-C <commit> | -c <commit>] <label> [# <oneline>]
#         create a merge commit using the original merge commit's
#         message (or the oneline, if no original merge commit was
#         specified); use -c <commit> to reword the commit message
# u, update-ref <ref> = track a placeholder for the <ref> to be updated
#                       to this position in the new commits. The <ref> is
#                       updated at the end of the rebase
#
# These lines can be re-ordered; they are executed from top to bottom.
#
# If you remove a line here THAT COMMIT WILL BE LOST.
#
# However, if you remove everything, the rebase will be aborted.
#
```

Ý nghĩa cấu hình:

| Dòng | Lệnh | Tác dụng |
|------|------|----------|
| 1 | `pick fc4014a` | Giữ nguyên commit khởi tạo `auth.js`, làm "gốc" cho commit gộp |
| 2 | `squash 145fbeb` | Gộp `fix typo` vào commit ở dòng 1 |
| 3 | `squash 107b139` | Gộp `adds utility functions` vào commit đã gộp ở trên |
| 4 | `drop d76d486` | Bỏ hoàn toàn commit `add temp file for debug`, kéo theo `temp.txt` biến mất |

### 5.3. Bảng các lệnh trong todo

| Lệnh | Viết tắt | Ý nghĩa |
|------|----------|---------|
| `pick` | `p` | Giữ nguyên commit, áp dụng lại như cũ |
| `reword` | `r` | Giữ nội dung thay đổi nhưng mở trình soạn thảo để sửa thông điệp |
| `edit` | `e` | Dừng lại tại commit đó để người dùng sửa nội dung (amend, tách commit); xong dùng `git rebase --continue` |
| `squash` | `s` | Gộp vào commit phía trên, giữ cả hai thông điệp và mở trình soạn thảo để soạn lại |
| `fixup` | `f` | Giống `squash` nhưng bỏ thông điệp của commit này, chỉ giữ thông điệp commit phía trên, không mở trình soạn thảo |
| `drop` | `d` | Xóa commit khỏi lịch sử (xóa dòng cũng có tác dụng tương tự) |
| `exec` | `x` | Chạy một lệnh shell sau commit phía trên (ví dụ chạy test); lệnh lỗi thì rebase dừng lại |

### 5.4. Khác nhau giữa squash và fixup

- `squash`: thay đổi được gộp, thông điệp của cả hai commit được nối lại và Git mở trình soạn thảo cho phép chỉnh sửa. Phù hợp khi muốn viết lại thông điệp tổng hợp (như bài này).
- `fixup`: thay đổi được gộp nhưng thông điệp của commit bị gộp bị bỏ đi, chỉ giữ thông điệp của commit phía trên, không hỏi lại. Phù hợp với các commit vá lỗi nhỏ như `fix typo`, `wip`.
- Cả hai đều gộp vào commit phía trên, nên dòng đầu tiên của todo không thể là `squash` hay `fixup` (Git báo lỗi vì không có commit trước đó để gộp).

## 6. Màn hình soạn thông điệp gộp

### 6.1. Trước khi sửa (Git đề xuất, file `squash_message_before.txt`)

Sau khi gộp xong 3 commit, Git mở trình soạn thảo với nội dung ghép sẵn:

```
# This is a combination of 3 commits.
# This is the 1st commit message:

feat: khoi tao module auth

# This is the commit message #2:

fix typo

# This is the commit message #3:

adds utility functions

# Please enter the commit message for your changes. Lines starting
# with '#' will be ignored, and an empty message aborts the commit.
#
# Date:      Fri Oct 2 12:47:59 2026 +0700
#
# interactive rebase in progress; onto fb70247
# Last commands done (3 commands done):
#    squash 145fbeb fix typo
#    squash 107b139 adds utility functions
# Next command to do (1 remaining command):
#    drop d76d486 add temp file for debug
# You are currently rebasing branch 'feature/auth' on 'fb70247'.
#
# Changes to be committed:
#	new file:   auth.js
#
```

### 6.2. Sau khi sửa (file `squash_message_after.txt`)

Xóa toàn bộ nội dung cũ, thay bằng thông điệp mới:

```
feat: hoan thien module authentication

- khoi tao module auth voi ham login
- sua loi chinh ta trong thong bao loi
- bo sung ham tien ich validateEmail va hashPassword
```

Dòng tiêu đề đúng như đề yêu cầu: `feat: hoan thien module authentication`. Phần thân gạch đầu dòng là tùy chọn; `git log --oneline` chỉ hiển thị tiêu đề.

## 7. Lịch sử sau rebase

```
$ git log --oneline
098eeca feat: hoan thien module authentication
fb70247 chore: khoi tao du an

$ git log --oneline main..feature/auth
098eeca feat: hoan thien module authentication

$ git log -n 1
commit 098eecae4ca8b52cf7f405f027b53bdad7ffdcee
Author: Lê Toàn <trinhhanh261293@gmail.com>
Date:   Fri Oct 2 12:47:59 2026 +0700

    feat: hoan thien module authentication
    
    - khoi tao module auth voi ham login
    - sua loi chinh ta trong thong bao loi
    - bo sung ham tien ich validateEmail va hashPassword

$ git show --stat HEAD
commit 098eecae4ca8b52cf7f405f027b53bdad7ffdcee
Author: Lê Toàn <trinhhanh261293@gmail.com>
Date:   Fri Oct 2 12:47:59 2026 +0700

    feat: hoan thien module authentication
    
    - khoi tao module auth voi ham login
    - sua loi chinh ta trong thong bao loi
    - bo sung ham tien ich validateEmail va hashPassword

 auth.js | 18 ++++++++++++++++++
 1 file changed, 18 insertions(+)

$ ls
README.md
auth.js

$ git status
On branch feature/auth
nothing to commit, working tree clean
```

Nhận xét:

- Lịch sử chỉ còn commit nền và đúng 1 commit tính năng (`main..feature/auth` có đúng 1 dòng).
- `git show --stat HEAD` chỉ có `auth.js` (18 dòng thêm vào); không có `temp.txt`, `ls` xác nhận file rác đã biến mất.
- Nội dung `auth.js` có đủ thay đổi của cả 3 commit (hàm `login`, thông báo đã sửa chính tả `credentials`, `validateEmail`, `hashPassword`):

```
$ cat auth.js
// Module authentication
function login(username, password) {
  if (!username || !password) {
    return { ok: false, message: "Invalid credentials" };
  }
  return { ok: true, message: "Login success" };
}

function validateEmail(email) {
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
}

function hashPassword(password) {
  // Gia lap: dao nguoc chuoi, chi dung de demo
  return "hashed_" + password.split("").reverse().join("");
}

module.exports = { login, validateEmail, hashPassword };
```

### Reflog ghi lại các bước rebase

```
$ git reflog -n 10
098eeca HEAD@{0}: rebase (finish): returning to refs/heads/feature/auth
098eeca HEAD@{1}: rebase (squash): feat: hoan thien module authentication
144b9b2 HEAD@{2}: rebase (squash): # This is a combination of 2 commits.
fc4014a HEAD@{3}: rebase (start): checkout HEAD~4
d76d486 HEAD@{4}: commit: add temp file for debug
107b139 HEAD@{5}: commit: adds utility functions
145fbeb HEAD@{6}: commit: fix typo
fc4014a HEAD@{7}: commit: feat: khoi tao module auth
fb70247 HEAD@{8}: checkout: moving from main to feature/auth
fb70247 HEAD@{9}: commit (initial): chore: khoi tao du an
```

Đọc từ dưới lên: 4 commit gốc -> `rebase (start)` checkout `HEAD~4` -> `squash` lần 1 (gộp 2 commit, tạo `144b9b2` trung gian) -> `squash` lần 2 (commit cuối `098eeca` với thông điệp mới) -> `rebase (finish)` trỏ nhánh `feature/auth` về `098eeca`. Không có dòng `pick` cho commit đầu vì `fc4014a` có cha và nội dung không đổi nên Git chỉ "tua" qua, giữ nguyên hash. Commit `drop` không để lại dòng reflog riêng: nó đơn giản bị bỏ qua.

## 8. Sơ đồ ASCII trước và sau

Trước rebase (nhánh `feature/auth`, commit mới nhất bên phải):

```
main
  |
  v
fb70247 --- fc4014a --- 145fbeb --- 107b139 --- d76d486   <- feature/auth, HEAD
 chore      feat:       fix typo    adds         add temp
 khoi tao   khoi tao                utility      file for
 du an      module auth             functions    debug
            (pick)      (squash)    (squash)     (drop)
```

Sau rebase:

```
main
  |
  v
fb70247 --- 098eeca   <- feature/auth, HEAD
 chore      feat: hoan thien module authentication
 khoi tao   (auth.js: login + sua loi chinh ta + validateEmail + hashPassword)
 du an

Cac commit cu khong con duoc nhanh nao tro toi (chi con trong reflog):
   fc4014a, 145fbeb, 107b139, d76d486
```

## 9. Vì sao hash thay đổi

Hash của commit được tính từ toàn bộ nội dung commit: cây thư mục (tree), commit cha (parent), tác giả, thời điểm, thông điệp. Chỉ cần một trường đổi thì hash đổi. Trong bài này:

- Commit đầu `fc4014a` (`pick`) có cha `fb70247` và nội dung không đổi nên Git giữ nguyên hash. Commit gộp có tree khác (chứa cả nội dung của `145fbeb` và `107b139`) và thông điệp mới, nên được hash mới `098eeca`; ba hash `fc4014a`, `145fbeb`, `107b139` không còn nằm trong lịch sử của nhánh.
- Rebase không "sửa" commit cũ mà tạo commit mới và đưa nhãn nhánh sang commit mới; commit cũ vẫn còn trong object database cho đến khi bị dọn rác (khoảng 30 đến 90 ngày) nên vẫn khôi phục được qua reflog.
- Nếu rebase làm thay đổi commit cha, mọi commit phía sau đều bị tạo lại và đổi hash theo dây chuyền. Chính vì vậy việc rebase lịch sử đã chia sẻ gây rắc rối cho người khác (mục 10).

## 10. Nguyên tắc vàng

- Chỉ rebase lịch sử CHƯA CHIA SẺ (chưa push, hoặc nhánh cá nhân chỉ mình bạn dùng). Bài này làm đúng điều đó: dọn nhánh `feature/auth` trước khi đẩy lên remote.
- Không rebase các nhánh dùng chung như `main`, `develop`. Người khác đã có các hash cũ; sau khi bạn viết lại, lịch sử của họ và của bạn phân kỳ, dẫn tới merge lộn xộn, commit bị nhân đôi.
- Nếu lỡ đã push rồi mới rebase (nhánh cá nhân), `git push` thường sẽ bị từ chối vì lịch sử đã phân kỳ. Khi đó phải dùng `git push --force-with-lease` (không dùng `--force` trần): lệnh này chỉ ghi đè nếu remote vẫn đúng như lần bạn fetch gần nhất, tránh vô tình xóa commit của người khác. Cần báo cho đồng đội trên nhánh đó biết.
- Đây là chỉ dẫn, không chạy trong bài này vì không có remote.

## 11. Trình diễn reword

Thêm một commit có thông điệp kém trên `feature/auth`:

```
$ printf "\nModule auth cung cap login, validateEmail, hashPassword.\n" >> README.md
$ git add README.md
$ git commit -m "update"
[feature/auth d1b1bef] update
 1 file changed, 2 insertions(+)

$ git log --oneline
d1b1bef update
098eeca feat: hoan thien module authentication
fb70247 chore: khoi tao du an
```

Chạy `git rebase -i HEAD~1`. File todo lúc mở (`pick`):

```
pick d1b1bef update

# Rebase 098eeca..d1b1bef onto 098eeca (1 command)
#
# Commands:
# ... (phần chú thích giống mục 5.1) ...
```

File todo sau khi đổi `pick` thành `reword`:

```
reword d1b1bef update

# Rebase 098eeca..d1b1bef onto 098eeca (1 command)
#
# Commands:
# ... (phần chú thích giống mục 5.1) ...
```

Git mở thông điệp cũ (`update` kèm các dòng chú thích), người dùng thay bằng `docs: bo sung huong dan su dung module auth`:

```
$ GIT_SEQUENCE_EDITOR="bash /d/Rikkei/DevOps/Session5/_demo/bai2/reword_seq_editor.sh" GIT_EDITOR="bash /d/Rikkei/DevOps/Session5/_demo/bai2/reword_msg_editor.sh" git rebase -i HEAD~1
Rebasing (1/1)
[detached HEAD 344eb4c] docs: bo sung huong dan su dung module auth
 Date: Fri Oct 2 12:48:02 2026 +0700
 1 file changed, 2 insertions(+)
Successfully rebased and updated refs/heads/feature/auth.

$ git log --oneline
344eb4c docs: bo sung huong dan su dung module auth
098eeca feat: hoan thien module authentication
fb70247 chore: khoi tao du an
```

Commit `d1b1bef update` đã đổi thành `344eb4c docs: ...`: nội dung giữ nguyên nhưng thông điệp đổi nên hash đổi. Commit `098eeca` bên dưới không bị ảnh hưởng. (Phần trình diễn này nằm ngoài yêu cầu chính; để kiểm tra lịch sử "một commit sạch" của bài, xem mục 7, kết quả ngay sau lần rebase đầu.)

Với commit mới nhất, `git commit --amend` cũng đổi được thông điệp; `reword` dùng cho commit nằm sâu trong lịch sử.

## 12. Cách hoàn tác nếu rebase sai

1. Đang dở dang (đã dừng vì xung đột, hoặc ở `edit`): `git rebase --abort` đưa nhánh về đúng trạng thái trước khi bắt đầu rebase.
2. Rebase đã xong nhưng kết quả không đúng ý:
   - Dùng `ORIG_HEAD`: Git ghi lại vị trí HEAD trước khi rebase vào `ORIG_HEAD`. Chạy `git reset --hard ORIG_HEAD` để quay lại (lưu ý: `ORIG_HEAD` bị ghi đè bởi các thao tác như rebase/merge/reset tiếp theo).
   - Dùng reflog: `git reflog` tìm dòng ngay trước `rebase (start)` rồi `git reset --hard HEAD@{n}` (hoặc `git reset --hard <hash>`).

Minh chứng `ORIG_HEAD` tồn tại ngay sau lần rebase chính (trước phần reword):

```
$ git rev-parse ORIG_HEAD
d76d48661a9573e2d991f4497d8ca9feeec49637

$ git log --oneline ORIG_HEAD
d76d486 add temp file for debug
107b139 adds utility functions
145fbeb fix typo
fc4014a feat: khoi tao module auth
fb70247 chore: khoi tao du an
```

`ORIG_HEAD` trỏ đúng về `d76d486`, đỉnh của lịch sử 4 commit cũ; nghĩa là có thể khôi phục toàn bộ lịch sử gốc. Phần này chỉ mô tả và chứng minh tham chiếu tồn tại, không thực thi `reset --hard` vì sẽ phá kết quả cần nộp.

## 13. Bảng đối chiếu yêu cầu đề bài

| Yêu cầu | Kết quả | Bằng chứng |
|---------|---------|------------|
| Tạo 4 commit theo gợi ý | Đạt | Mục 3: `fc4014a`, `145fbeb`, `107b139`, `d76d486` |
| Chạy `git rebase -i HEAD~4` | Đạt | Mục 4, `Successfully rebased and updated refs/heads/feature/auth.` |
| Commit 1 `pick`, 2 và 3 `squash`, 4 `drop` | Đạt | Mục 5.2, file `rebase_todo_after.txt` |
| Gộp 3 commit nhỏ cuối thành 1 | Đạt | `098eeca` chứa nội dung của cả 3 commit (mục 7) |
| Thông điệp sau khi gộp là `feat: hoan thien module authentication` | Đạt | Mục 6.2, `git log -n 1` |
| Xóa hoàn toàn commit chứa `temp.txt` | Đạt | `ls` không còn `temp.txt`; `git show --stat HEAD` chỉ có `auth.js` |
| `git log --oneline` chỉ còn 1 commit tính năng | Đạt | `git log --oneline main..feature/auth` đúng 1 dòng (mục 7) |
| Chụp lại giao diện soạn thảo (pick, squash, reword, drop) | Đạt | Mục 5, 6 (todo trước/sau, thông điệp trước/sau) và mục 11 (reword) |
| Log lịch sử sạch sẽ sau khi hoàn tất | Đạt | Mục 7 |

## 14. Kết luận

- Interactive rebase cho phép "dọn" lịch sử cục bộ trước khi chia sẻ: gộp các commit vụn (`squash`), sửa thông điệp (`reword`), loại commit rác (`drop`). Kết quả là một commit tính năng duy nhất, thông điệp rõ ràng theo quy ước Conventional Commits (`feat:`).
- Cần nhớ thứ tự todo là cũ ở trên, `squash` gộp vào dòng phía trên; sai thứ tự sẽ gộp nhầm commit.
- Rebase tạo commit mới (đổi hash), nên chỉ dùng cho lịch sử chưa chia sẻ; nếu đã push thì phải `git push --force-with-lease` và báo đồng đội.
- An toàn: `git rebase --abort` khi đang dở, `ORIG_HEAD` hoặc reflog để quay lại khi đã xong.
- Điểm lệch nhỏ khi tái hiện: do môi trường không có trình soạn thảo tương tác, các bước sửa todo và thông điệp được thực hiện qua `GIT_SEQUENCE_EDITOR` và `GIT_EDITOR`, nội dung các màn hình soạn thảo được sao lưu nguyên văn; kết quả tương đương thao tác tay.

## 15. Danh sách file

| File | Nội dung |
|------|----------|
| `README.md` | Báo cáo này |
| `terminal_log.txt` | Toàn bộ lệnh và output thật |
| `rebase_todo_before.txt` | File todo lúc mở (nguyên văn) |
| `rebase_todo_after.txt` | File todo sau khi sửa |
| `squash_message_before.txt` | Thông điệp gộp Git đề xuất |
| `squash_message_after.txt` | Thông điệp gộp sau khi sửa |
| `auth.js` | Bản cuối cùng của file |
| `scripts/seq_editor.sh` | Script thay `GIT_SEQUENCE_EDITOR` (pick, squash, squash, drop) |
| `scripts/msg_editor.sh` | Script thay `GIT_EDITOR` cho thông điệp gộp |
| `scripts/reword_seq_editor.sh`, `scripts/reword_msg_editor.sh` | Hai script cho phần trình diễn reword |
