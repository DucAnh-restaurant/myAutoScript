# ASM Development & Reverse Engineering Environment Setup

## 1. Giới thiệu
Script `asm-dev-setup.sh` được thiết kế để tự động cài đặt môi trường học Assembly và Reverse Engineering trên Linux.

Mục tiêu:
- Thiết lập nhanh môi trường từ cơ bản đến nâng cao
- Hỗ trợ nhiều distro Linux (Ubuntu/Debian, Fedora, Arch)
- Phù hợp cho học ASM, debugging, exploit development, malware analysis

---

## 2. Tính năng chính

### 2.1 Cài đặt cơ bản
- NASM (assembler x86/x64)
- GCC / G++ (compiler + linker)
- GDB (debugger)
- Binutils (objdump, objcopy)
- Radare2 (reverse engineering framework)
- strace / ltrace (tracing)

### 2.2 Công cụ hỗ trợ
- Vim / Nano
- Hexedit / xxd
- tmux / htop
- wget / curl / git

### 2.3 Chế độ FULL
Khi chọn FULL, script sẽ cài thêm:
- gdb-multiarch
- QEMU (emulation)
- libc debug symbols
- pwndbg (GDB plugin cho exploit dev)
- radare2 bản mới nhất (build từ source)

### 2.4 IDE (tuỳ chọn)
- VSCode (nếu có trong repo hệ thống)

---

## 3. Yêu cầu hệ thống

- Linux (Ubuntu, Debian, Fedora, Arch)
- Quyền sudo
- Kết nối internet

---

## 4. Hướng dẫn sử dụng

### 4.1 Tạo file
```bash
nano asm-dev-setup.sh
```

Dán nội dung script vào file và lưu.

### 4.2 Cấp quyền thực thi
```bash
chmod +x asm-dev-setup.sh
```

### 4.3 Chạy script
```bash
./asm-dev-setup.sh
```

---

## 5. Menu lựa chọn

Khi chạy script, bạn sẽ thấy menu:

```
1. Install basic ASM tools
2. Install FULL (ASM + RE + Debug + QEMU + pwndbg)
3. Install IDE only
4. Exit
```

### Giải thích:

1. **Basic**:
   - Cài tool cần thiết để học Assembly

2. **Full**:
   - Cài toàn bộ môi trường reverse engineering
   - Phù hợp cho:
     - Malware analysis
     - Exploit development
     - CTF / Binary exploitation

3. **IDE only**:
   - Chỉ cài VSCode

---

## 6. Kiểm tra sau cài đặt

Script sẽ tự động verify:

- nasm
- gcc
- gdb
- radare2

Bạn có thể kiểm tra thủ công:

```bash
nasm -v
gcc --version
gdb --version
r2 -v
```

---

## 7. Cấu trúc môi trường sau khi cài

### Thư mục được tạo:
- `~/pwndbg` (GDB plugin)
- `~/radare2` (source code nếu build)

---

## 8. Use-case thực tế

### 8.1 Học Assembly
- Viết và compile chương trình ASM
- Debug từng instruction

### 8.2 Reverse Engineering
- Phân tích binary
- Disassemble với radare2 / objdump

### 8.3 Exploit Development
- Debug với pwndbg
- Phân tích stack, heap

### 8.4 Malware Analysis
- Trace syscall (strace)
- Phân tích hành vi chương trình

---

## 9. Troubleshooting

### 9.1 Lỗi thiếu package

Cập nhật lại repo:
```bash
sudo apt update
```

### 9.2 VSCode không cài được

Do repo hệ thống không có sẵn package `code`.

Giải pháp:
- Cài thủ công từ trang chính thức

### 9.3 pwndbg lỗi

Chạy lại:
```bash
cd ~/pwndbg
./setup.sh
```

---

## 10. Mở rộng

Có thể nâng cấp script để:

- Cài Ghidra
- Cài IDA Free
- Tạo lab ASM tự động
- Tích hợp workflow build + debug

---

## 11. Kết luận

Script này cung cấp một môi trường hoàn chỉnh để:

- Học Assembly từ cơ bản
- Phân tích binary
- Phát triển exploit
- Nghiên cứu malware

Phù hợp cho sinh viên an toàn thông tin, reverse engineer, hoặc pentester muốn đi sâu vào low-level.

---

## 12. License

Sử dụng tự do cho mục đích học tập và nghiên cứu.

