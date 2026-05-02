#!/bin/bash

echo "===== KIỂM TRA MÔI TRƯỜNG PHP CHO CACTI ====="

# Màu sắc
GREEN="\e[32m"
RED="\e[31m"
YELLOW="\e[33m"
NC="\e[0m"

check_command () {
    if command -v "$1" >/dev/null 2>&1; then
        echo -e "${GREEN}[OK]${NC} $1 đã cài"
        command -v "$1"
    else
        echo -e "${RED}[MISSING]${NC} $1 chưa cài"
    fi
    echo
}

check_php_module () {
    if php -m | grep -i "^$1$" >/dev/null 2>&1; then
        echo -e "${GREEN}[OK]${NC} PHP module: $1"
    else
        echo -e "${RED}[MISSING]${NC} PHP module: $1"
    fi
}

echo ">>> Kiểm tra các package chính"
check_command php
check_command phpize
check_command php-config
check_command composer
check_command mysql
check_command mariadb
check_command apache2
check_command nginx
check_command git
check_command make
check_command gcc
check_command unzip
check_command curl
check_command wget

echo ">>> Phiên bản PHP"
if command -v php >/dev/null 2>&1; then
    php -v
else
    echo -e "${RED}PHP chưa được cài.${NC}"
fi

echo
echo ">>> Kiểm tra các PHP extension cần cho Cacti"

modules=(
    session
    sockets
    pcre
    json
    gd
    gettext
    gmp
    ldap
    mbstring
    openssl
    posix
    mysqli
    pdo_mysql
    snmp
    xml
    ctype
    curl
    dom
    filter
    hash
    iconv
    intl
    libxml
    pcre
    pdo
    phar
    readline
    simplexml
    tokenizer
    xmlreader
    xmlwriter
    zlib
    zip
)

for module in "${modules[@]}"
do
    check_php_module "$module"
done

echo
echo ">>> php.ini location"
php --ini 2>/dev/null

echo
echo ">>> Composer version"
if command -v composer >/dev/null 2>&1; then
    composer --version
fi

echo
echo "===== KIỂM TRA HOÀN TẤT ====="
