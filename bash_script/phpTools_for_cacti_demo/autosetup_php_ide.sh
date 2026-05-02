#!/bin/bash

echo "===== AUTO SETUP: VS Code + Git + Burp + Browser + PHP DEV ====="

GREEN="\e[32m"
YELLOW="\e[33m"
RED="\e[31m"
NC="\e[0m"

if [[ $EUID -ne 0 ]]; then
    echo -e "${RED}Hãy chạy bằng sudo:${NC}"
    echo "sudo ./setup_dev_env.sh"
    exit 1
fi

echo -e "${YELLOW}>>> Update hệ thống...${NC}"
apt update && apt upgrade -y

echo
echo -e "${YELLOW}>>> Cài công cụ cơ bản...${NC}"

apt install -y \
git \
curl \
wget \
unzip \
zip \
vim \
nano \
build-essential \
gcc \
g++ \
make \
python3 \
python3-pip

echo
echo -e "${YELLOW}>>> Cài PHP môi trường dev cho Cacti...${NC}"

apt install -y \
php \
php-cli \
php-dev \
php-pear \
php-mysql \
php-gd \
php-gmp \
php-ldap \
php-mbstring \
php-snmp \
php-xml \
php-curl \
php-intl \
php-zip \
php-bcmath \
php-common \
php-opcache \
composer

echo
echo -e "${YELLOW}>>> Cài database + webserver...${NC}"

apt install -y \
mariadb-server \
apache2 \
nginx \
snmp \
rrdtool

echo
echo -e "${YELLOW}>>> Cài Browser (Firefox ESR + Chromium)...${NC}"

apt install -y \
firefox-esr \
chromium

echo
echo -e "${YELLOW}>>> Cài Burp Suite Community...${NC}"

apt install -y \
burpsuite

echo
echo -e "${YELLOW}>>> Cài Visual Studio Code...${NC}"

if command -v code >/dev/null 2>&1; then
    echo -e "${GREEN}VS Code đã tồn tại.${NC}"
else
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
    install -o root -g root -m 644 microsoft.gpg /usr/share/keyrings/
    rm microsoft.gpg

    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/code stable main" \
    > /etc/apt/sources.list.d/vscode.list

    apt update
    apt install -y code
fi

echo
echo -e "${YELLOW}>>> Gợi ý extension cho VS Code...${NC}"

cat <<EOF

Cài thêm trong VS Code:

1. PHP Intelephense
2. PHP Debug
3. GitLens
4. SQLTools
5. Apache Conf
6. YAML
7. Docker
8. Remote SSH
9. Error Lens
10. REST Client

EOF

echo
echo -e "${GREEN}===== HOÀN TẤT =====${NC}"

echo "Kiểm tra nhanh:"
echo "php -v"
echo "composer --version"
echo "git --version"
echo "burpsuite"
echo "code"

echo
echo "Môi trường đã sẵn sàng cho:"
echo "- nghiên cứu source Cacti"
echo "- audit code"
echo "- debug PoC"
echo "- patch vulnerability"
echo "- local exploit lab"
