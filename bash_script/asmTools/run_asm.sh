#!/bin/bash

set -e

if [ -z "$1" ]; then
    echo "Usage: $0 file.asm"
    exit 1
fi

FILE="$1"
BASENAME=$(basename "$FILE" .asm)
OBJ="$BASENAME.o"
BIN="$BASENAME"

detect_arch() {
    if grep -q "syscall" "$FILE"; then
        ARCH="x64"
    elif grep -q "int 0x80" "$FILE"; then
        ARCH="x86"
    elif grep -Eq "\b(rax|rdi|rsi|rdx)\b" "$FILE"; then
        ARCH="x64"
    elif grep -Eq "\b(eax|ebx|ecx|edx)\b" "$FILE"; then
        ARCH="x86"
    else
        echo "[!] Unknown → default x64"
        ARCH="x64"
    fi
}

set_flags() {
    if [ "$ARCH" == "x64" ]; then
        FORMAT="elf64"
        LINKFLAG=""
    else
        FORMAT="elf32"
        LINKFLAG="-m elf_i386"
    fi
}

echo "[*] Detecting architecture..."
detect_arch
set_flags

echo "[*] Format: $FORMAT"

echo "[*] Assembling..."
nasm -f "$FORMAT" "$FILE" -o "$OBJ"

echo "[*] Linking..."
ld $LINKFLAG "$OBJ" -o "$BIN"

echo "[*] Running..."
echo "------------------"
./"$BIN"
echo "------------------"