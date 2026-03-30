#!/bin/bash

set -e

echo "[*] Building Portable Reverse Engineering Toolkit..."

BASE_DIR=$(pwd)/re-toolkit
TOOLS_DIR=$BASE_DIR/tools
BIN_DIR=$BASE_DIR/bin
LOG_FILE=$BASE_DIR/build.log

mkdir -p "$TOOLS_DIR" "$BIN_DIR"
exec > >(tee -a "$LOG_FILE") 2>&1

# =========================
# CONFIG
# =========================
FALLBACK_GHIDRA_URL="https://github.com/NationalSecurityAgency/ghidra/releases/download/Ghidra_11.0.3_build/ghidra_11.0.3_PUBLIC_20240215.zip"

JDK_URL="https://download.oracle.com/java/21/latest/jdk-21_linux-x64_bin.tar.gz"
JDK_FALLBACK_URL="https://github.com/adoptium/temurin21-binaries/releases/latest/download/OpenJDK21U-jdk_x64_linux_hotspot.tar.gz"

# =========================
# HELPER
# =========================
check_command() {
    command -v "$1" >/dev/null 2>&1
}

# =========================
# DOWNLOAD GHIDRA
# =========================
download_ghidra() {
    echo "[*] Downloading Ghidra..."

    cd "$TOOLS_DIR"

    if [ -f ghidra.zip ]; then
        echo "[+] Using cached ghidra.zip"
        return
    fi

    echo "[*] Attempting dynamic fetch..."

    if check_command curl; then
        GHIDRA_URL=$(curl -s https://api.github.com/repos/NationalSecurityAgency/ghidra/releases/latest \
            | grep browser_download_url \
            | grep ".zip" \
            | cut -d '"' -f 4)
    fi

    if [ -n "$GHIDRA_URL" ]; then
        if wget -O ghidra.zip "$GHIDRA_URL"; then
            echo "[+] Download success (dynamic)"
            return
        fi
    fi

    echo "[!] Using fallback..."
    wget -O ghidra.zip "$FALLBACK_GHIDRA_URL" || {
        echo "[X] Ghidra download failed"
        exit 1
    }
}

# =========================
# INSTALL JDK
# =========================
install_jdk() {
    echo "[*] Installing JDK 21..."

    cd "$TOOLS_DIR"

    if [ -d jdk ]; then
        echo "[+] JDK already exists"
        return
    fi

    if wget -O jdk.tar.gz "$JDK_URL"; then
        echo "[+] Oracle JDK downloaded"
    else
        echo "[!] Fallback OpenJDK..."
        wget -O jdk.tar.gz "$JDK_FALLBACK_URL" || {
            echo "[X] JDK download failed"
            exit 1
        }
    fi

    mkdir jdk
    tar -xzf jdk.tar.gz -C jdk --strip-components=1

    echo "[+] JDK ready"
}

# =========================
# INSTALL GHIDRA
# =========================
install_ghidra() {
    echo "[*] Installing Ghidra..."

    cd "$TOOLS_DIR"
    unzip -o ghidra.zip

    GHIDRA_DIR=$(find . -maxdepth 1 -type d -name "ghidra_*" | head -n 1)

    if [ -z "$GHIDRA_DIR" ]; then
        echo "[X] Ghidra folder not found"
        exit 1
    fi

    cat <<EOF > "$BIN_DIR/ghidra"
#!/bin/bash
DIR=\$(dirname "\$(readlink -f "\$0")")
export JAVA_HOME=\$DIR/../tools/jdk
export PATH=\$JAVA_HOME/bin:\$PATH
\$DIR/../tools/$GHIDRA_DIR/ghidraRun
EOF

    chmod +x "$BIN_DIR/ghidra"

    echo "[+] Ghidra ready"
}

# =========================
# CUTTER
# =========================
install_cutter() {
    echo "[*] Installing Cutter (portable mode)..."

    cd "$TOOLS_DIR"

    if [ ! -f cutter.AppImage ]; then
        wget -O cutter.AppImage https://github.com/rizinorg/cutter/releases/download/v2.4.1/Cutter-v2.4.1-Linux-x86_64.AppImage || {
            echo "[!] Cutter download failed"
            return
        }
    fi

    chmod +x cutter.AppImage

    # Extract AppImage để tránh phụ thuộc FUSE
    if [ ! -d cutter-extract ]; then
        echo "[*] Extracting AppImage..."
        ./cutter.AppImage --appimage-extract || {
            echo "[X] Extraction failed"
            return
        }
        mv squashfs-root cutter-extract
    fi

    # Wrapper chạy binary trực tiếp
    cat <<EOF > "$BIN_DIR/cutter"
#!/bin/bash
DIR=\$(dirname "\$(readlink -f "\$0")")
\$DIR/../tools/cutter-extract/AppRun
EOF

    chmod +x "$BIN_DIR/cutter"

    echo "[+] Cutter ready (no FUSE needed)"
}



# =========================
# RADARE2
# =========================
install_radare2() {
    echo "[*] Installing radare2..."

    cd "$TOOLS_DIR"

    if [ ! -d radare2 ]; then
        git clone https://github.com/radareorg/radare2.git
    fi

    cd radare2
    ./sys/install.sh PREFIX="$TOOLS_DIR/r2-install"

    ln -sf "$TOOLS_DIR/r2-install/bin/r2" "$BIN_DIR/r2"
}

# =========================
# PYTHON
# =========================
install_python_env() {
    echo "[*] Installing Python env..."

    cd "$TOOLS_DIR"

    python3 -m venv pyenv
    source pyenv/bin/activate

    pip install --upgrade pip
    pip install capstone unicorn keystone-engine pwntools binwalk

    deactivate

    cat <<EOF > "$BIN_DIR/pytool"
#!/bin/bash
DIR=\$(dirname "\$(readlink -f "\$0")")
source \$DIR/../tools/pyenv/bin/activate
python3 "\$@"
EOF

    chmod +x "$BIN_DIR/pytool"
}

# =========================
# ENV + RUNNER
# =========================
setup_env() {
    cat <<EOF > "$BASE_DIR/env.sh"
export RE_HOME=\$(cd "\$(dirname "\${BASH_SOURCE[0]}")" && pwd)
export PATH=\$RE_HOME/bin:\$PATH
EOF
}

setup_runner() {
    cat <<EOF > "$BASE_DIR/run.sh"
#!/bin/bash
DIR=\$(cd "\$(dirname "\$0")" && pwd)
source \$DIR/env.sh
bash
EOF

    chmod +x "$BASE_DIR/run.sh"
}

# =========================
# MAIN
# =========================
download_ghidra
install_jdk
install_ghidra
install_cutter
install_radare2
install_python_env
setup_env
setup_runner

echo "[+] BUILD SUCCESS"
echo "[+] Usage: cd re-toolkit && ./run.sh"
