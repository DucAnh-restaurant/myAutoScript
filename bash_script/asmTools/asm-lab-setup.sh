#!/bin/bash

set -e

# ==============================
# CONFIG
# ==============================
INSTALL_IDE=false
FULL=false

# ==============================
# UI
# ==============================
show_menu() {
    echo "=============================="
    echo " ASM / RE ENVIRONMENT SETUP"
    echo "=============================="
    echo "1. Install basic ASM tools"
    echo "2. Install FULL (ASM + RE + Debug + QEMU + pwndbg)"
    echo "3. Install IDE only"
    echo "4. Exit"
    echo "=============================="
    read -p "Choose: " choice

    case $choice in
        1) ;;
        2)
            FULL=true
            INSTALL_IDE=true
            ;;
        3)
            INSTALL_IDE=true
            ;;
        *)
            exit 0
            ;;
    esac
}

# ==============================
# LOG
# ==============================
log() { echo "[*] $1"; }
ok() { echo "[+] $1"; }
err() { echo "[!] $1"; }

# ==============================
# DETECT PACKAGE MANAGER
# ==============================
detect_pkg() {
    if command -v apt >/dev/null; then
        PKG="apt"
    elif command -v dnf >/dev/null; then
        PKG="dnf"
    elif command -v pacman >/dev/null; then
        PKG="pacman"
    else
        err "Unsupported package manager"
        exit 1
    fi
    log "Detected: $PKG"
}

# ==============================
# UPDATE
# ==============================
update_system() {
    log "Updating system..."
    case $PKG in
        apt) sudo apt update ;;
        dnf) sudo dnf check-update ;;
        pacman) sudo pacman -Sy ;;
    esac
}

# ==============================
# BASIC ASM TOOLS
# ==============================
install_basic() {
    log "Installing ASM basic tools..."

    case $PKG in
        apt)
            sudo apt install -y \
                nasm gcc g++ make \
                gdb binutils \
                radare2 \
                strace ltrace \
                file \
                python3 python3-pip
            ;;
        dnf)
            sudo dnf install -y \
                nasm gcc gcc-c++ make \
                gdb binutils \
                radare2 \
                strace ltrace \
                file \
                python3 python3-pip
            ;;
        pacman)
            sudo pacman -S --noconfirm \
                nasm gcc make \
                gdb binutils \
                radare2 \
                strace ltrace \
                file \
                python python-pip
            ;;
    esac

    ok "Basic tools installed"
}

# ==============================
# OPTIONAL TOOLS
# ==============================
install_optional() {
    log "Installing optional tools..."

    case $PKG in
        apt)
            sudo apt install -y \
                vim nano \
                hexedit xxd \
                tmux htop \
                wget curl git
            ;;
        dnf)
            sudo dnf install -y \
                vim nano \
                hexedit \
                tmux htop \
                wget curl git
            ;;
        pacman)
            sudo pacman -S --noconfirm \
                vim nano \
                hexedit \
                tmux htop \
                wget curl git
            ;;
    esac

    ok "Optional tools installed"
}

# ==============================
# FULL RE ENVIRONMENT
# ==============================
install_full() {
    if [ "$FULL" = true ]; then
        log "Installing FULL Reverse Engineering suite..."

        case $PKG in
            apt)
                sudo apt install -y \
                    gdb-multiarch \
                    qemu-user qemu-system \
                    cmake \
                    libc6-dbg
                ;;
            dnf)
                sudo dnf install -y \
                    qemu \
                    cmake
                ;;
            pacman)
                sudo pacman -S --noconfirm \
                    qemu \
                    cmake
                ;;
        esac

        # pwndbg
        log "Installing pwndbg..."
        if [ ! -d "$HOME/pwndbg" ]; then
            git clone https://github.com/pwndbg/pwndbg ~/pwndbg
            cd ~/pwndbg
            ./setup.sh
        fi

        # radare2 latest
        log "Updating radare2 (latest)..."
        if [ ! -d "$HOME/radare2" ]; then
            git clone https://github.com/radareorg/radare2 ~/radare2
            cd ~/radare2
            sys/install.sh
        fi

        ok "FULL setup installed"
    fi
}

# ==============================
# IDE
# ==============================
install_ide() {
    if [ "$INSTALL_IDE" = true ]; then
        log "Installing VSCode..."

        case $PKG in
            apt)
                sudo apt install -y code || true
                ;;
            dnf)
                sudo dnf install -y code || true
                ;;
            pacman)
                sudo pacman -S --noconfirm code || true
                ;;
        esac

        ok "IDE installed (if available)"
    fi
}

# ==============================
# VERIFY
# ==============================
verify() {
    log "Verifying tools..."

    echo "---- NASM ----"
    nasm -v || true

    echo "---- GCC ----"
    gcc --version | head -n 1

    echo "---- GDB ----"
    gdb --version | head -n 1

    echo "---- RADARE2 ----"
    r2 -v | head -n 1 || true

    ok "Verification completed"
}

# ==============================
# MAIN
# ==============================
show_menu
detect_pkg
update_system
install_basic
install_optional
install_full
install_ide
verify

ok "Environment setup completed!"