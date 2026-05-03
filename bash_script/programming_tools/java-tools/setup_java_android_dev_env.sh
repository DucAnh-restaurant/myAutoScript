#!/bin/bash

# Smart Java + Android Development Environment Installer
# Includes:
# - OpenJDK
# - Maven
# - Gradle
# - Git
# - VS Code
# - Android SDK basics
# - adb / fastboot
# - Java + Android extensions
# - Only installs missing packages

set -e

echo "=========================================="
echo " Java + Android Dev Environment Installer "
echo "=========================================="

# -----------------------------
# Detect package manager
# -----------------------------
if command -v apt >/dev/null 2>&1; then
    PKG="apt"
elif command -v dnf >/dev/null 2>&1; then
    PKG="dnf"
elif command -v pacman >/dev/null 2>&1; then
    PKG="pacman"
else
    echo "[!] Unsupported package manager"
    exit 1
fi

echo "[+] Package manager detected: $PKG"

# -----------------------------
# Helper: check command exists
# -----------------------------
exists() {
    command -v "$1" >/dev/null 2>&1
}

# -----------------------------
# Helper: apt package installed
# -----------------------------
apt_installed() {
    dpkg -s "$1" >/dev/null 2>&1
}

# -----------------------------
# Install package if missing
# -----------------------------
install_if_missing_apt() {
    PKG_NAME=$1

    if apt_installed "$PKG_NAME"; then
        echo "[✓] $PKG_NAME already installed"
    else
        echo "[+] Installing $PKG_NAME ..."
        sudo apt install -y "$PKG_NAME"
    fi
}

# -----------------------------
# APT Install Section
# -----------------------------
install_apt() {
    sudo apt update

    packages=(
        openjdk-21-jdk
        maven
        gradle
        git
        curl
        wget
        unzip
        zip
        build-essential
        gdb
        net-tools
        python3
        python3-pip
        ca-certificates
        software-properties-common
        adb
        fastboot
        default-jdk
    )

    for pkg in "${packages[@]}"; do
        install_if_missing_apt "$pkg"
    done

    # VS Code
    if exists code; then
        echo "[✓] VS Code already installed"
    else
        echo "[+] Installing VS Code..."

        wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg

        sudo install -D -o root -g root -m 644 packages.microsoft.gpg \
            /etc/apt/keyrings/packages.microsoft.gpg

        echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" \
            | sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null

        sudo apt update
        sudo apt install -y code

        rm -f packages.microsoft.gpg
    fi
}

# -----------------------------
# DNF Install Section
# -----------------------------
install_dnf() {
    packages=(
        java-21-openjdk-devel
        maven
        gradle
        git
        curl
        wget
        unzip
        zip
        gcc
        gcc-c++
        gdb
        net-tools
        python3
        python3-pip
        android-tools
        code
    )

    for pkg in "${packages[@]}"; do
        sudo dnf install -y "$pkg"
    done
}

# -----------------------------
# Pacman Install Section
# -----------------------------
install_pacman() {
    packages=(
        jdk-openjdk
        maven
        gradle
        git
        curl
        wget
        unzip
        zip
        base-devel
        gdb
        net-tools
        python
        python-pip
        android-tools
        code
    )

    sudo pacman -Sy --noconfirm "${packages[@]}"
}

case $PKG in
    apt) install_apt ;;
    dnf) install_dnf ;;
    pacman) install_pacman ;;
esac

# -----------------------------
# Install VS Code Extensions
# -----------------------------
if exists code; then
    echo "[+] Installing VS Code Extensions..."

    extensions=(
        vscjava.vscode-java-pack
        redhat.java
        vscjava.vscode-maven
        vscjava.vscode-gradle
        vscjava.vscode-java-debug
        vscjava.vscode-java-test
        vscjava.vscode-spring-initializr
        vmware.vscode-spring-boot
        eamodio.gitlens

        # Android / Mobile
        Dart-Code.dart-code
        Dart-Code.flutter
        ms-vscode.vscode-json
        formulahendry.code-runner
    )

    for ext in "${extensions[@]}"; do
        echo "[+] Installing extension: $ext"
        code --install-extension "$ext" --force || true
    done
else
    echo "[!] VS Code not found, skipping extensions"
fi

# -----------------------------
# Android SDK Note
# -----------------------------
echo ""
echo "[!] Android full SDK recommendation:"
echo "For complete Android development:"
echo "Install Android Studio once for SDK Manager setup."
echo ""
echo "VS Code is excellent for:"
echo "- Flutter"
echo "- React Native"
echo "- Android Java/Kotlin editing"
echo "- ADB debugging"
echo ""
echo "But Android Studio is still best for:"
echo "- Emulator"
echo "- SDK Manager"
echo "- Device Manager"
echo "- Native Android Build tools"

# -----------------------------
# Verification
# -----------------------------
echo ""
echo "=========================================="
echo " Verification "
echo "=========================================="

java -version || true
javac -version || true
mvn -version || true
gradle -version || true
git --version || true
adb version || true
fastboot --version || true
code --version || true

echo ""
echo "=========================================="
echo " Installation Completed Successfully "
echo "=========================================="

echo ""
echo "Recommended stack:"
echo "VS Code + Java + Android + Git + Terminal"
echo ""
echo "Ready for:"
echo "- Java backend"
echo "- Spring Boot"
echo "- REST API"
echo "- Android app development"
echo "- Flutter"
echo "- React Native"
echo "- Source audit"
echo "- Security research"
echo "- Reverse engineering"
