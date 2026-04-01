# Usage - run_asm.sh

## 1. Cấp quyền thực thi
```bash
chmod +x run_asm.sh
```

---

## 2. Cách chạy
```bash
./run_asm.sh <file.asm>
```

### Ví dụ:
```bash
./run_asm.sh hello.asm
```

---

## 3. Kết quả
Script sẽ tự động:

1. Detect kiến trúc (32-bit / 64-bit)
2. Compile bằng NASM
3. Link bằng LD
4. Chạy chương trình

---

## 4. Output mẫu
```text
[*] Detecting architecture...
[*] Detected architecture: x64
[*] Format: elf64
[*] Assembling...
[*] Linking...
[*] Running...
------------------
Hello, World!
------------------
```

---

## 5. Lưu ý

- File phải có đuôi `.asm`
- Đã cài `nasm` và `ld`
- Script chạy trong thư mục chứa file `.asm`
