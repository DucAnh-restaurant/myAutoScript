#!/bin/bash

set -e

echo "=========================================="
echo " FULL Java + Android + DB Dev Environment "
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

exists() {
    command -v "$1" >/dev/null 2>&1
}

# -----------------------------
# APT SECTION (Ubuntu/Debian)
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

        # Android
        adb
        fastboot

        # Databases (FIXED)
        postgresql
        postgresql-contrib
        mariadb-server
        sqlite3
    )

    for pkg in "${packages[@]}"; do
        if dpkg -s "$pkg" >/dev/null 2>&1; then
            echo "[✓] $pkg already installed"
        else
            echo "[+] Installing $pkg ..."
            sudo apt install -y "$pkg"
        fi
    done

    # VS Code
    if ! exists code; then
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

    # DBeaver
    if ! exists dbeaver; then
        echo "[+] Installing DBeaver..."
        wget -O - https://dbeaver.io/debs/dbeaver.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/dbeaver.gpg
        echo "deb [signed-by=/etc/apt/keyrings/dbeaver.gpg] https://dbeaver.io/debs/dbeaver-ce /" \
            | sudo tee /etc/apt/sources.list.d/dbeaver.list
        sudo apt update
        sudo apt install -y dbeaver-ce
    fi

    # -----------------------------
    # Start & enable DB services
    # -----------------------------
    echo "[+] Configuring databases..."

    sudo systemctl enable postgresql || true
    sudo systemctl start postgresql || true

    sudo systemctl enable mariadb || true
    sudo systemctl start mariadb || true

    # PostgreSQL password
    sudo -u postgres psql -c "ALTER USER postgres PASSWORD 'password';" || true
}

# -----------------------------
# DNF SECTION
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

        postgresql-server
        postgresql-contrib
        mariadb-server
        sqlite

        code
    )

    for pkg in "${packages[@]}"; do
        sudo dnf install -y "$pkg"
    done

    sudo postgresql-setup --initdb || true
    sudo systemctl enable postgresql
    sudo systemctl start postgresql

    sudo systemctl enable mariadb
    sudo systemctl start mariadb
}

# -----------------------------
# PACMAN SECTION
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

        postgresql
        mariadb
        sqlite

        code
    )

    sudo pacman -Sy --noconfirm "${packages[@]}"

    sudo -iu postgres initdb --locale $LANG -E UTF8 -D /var/lib/postgres/data || true
    sudo systemctl enable postgresql
    sudo systemctl start postgresql

    sudo mariadb-install-db --user=mysql --basedir=/usr --datadir=/var/lib/mysql || true
    sudo systemctl enable mariadb
    sudo systemctl start mariadb
}

# -----------------------------
# RUN INSTALL
# -----------------------------
case $PKG in
    apt) install_apt ;;
    dnf) install_dnf ;;
    pacman) install_pacman ;;
esac

# -----------------------------
# VS Code Extensions
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
        ms-vscode.vscode-json
        formulahendry.code-runner
    )

    for ext in "${extensions[@]}"; do
        code --install-extension "$ext" --force || true
    done
fi

# -----------------------------
# VERIFY
# -----------------------------
echo ""
echo "=========== VERIFY ==========="

java -version || true
mvn -version || true
gradle -version || true
git --version || true
adb version || true
psql --version || true
mysql --version || true
sqlite3 --version || true

echo ""
echo "=========================================="
echo " DONE - ENV READY "
echo "=========================================="