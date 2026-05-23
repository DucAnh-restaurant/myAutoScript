#!/bin/bash
# ================================================
# Full Python Installation Script using pyenv (Updated 2026)
# Cài Python 2.7 + 3.11 → 3.14
# ================================================

echo "🚀 Bắt đầu cài đặt pyenv và nhiều phiên bản Python..."

# 1. Cài dependencies
echo "📦 Cài dependencies..."
sudo apt update -y
sudo apt install -y build-essential libssl-dev zlib1g-dev libbz2-dev \
libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev \
libncursesw5-dev xz-utils tk-dev libffi-dev liblzma-dev \
python3-openssl git make

# 2. Cài pyenv
echo "🔧 Đang cài pyenv..."
curl -fsSL https://pyenv.run | bash

# 3. Cấu hình pyenv
echo "⚙️  Cấu hình pyenv vào .zshrc..."
cat >> ~/.zshrc << 'EOF'

# pyenv configuration
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"
EOF

# Áp dụng ngay
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

# 4. Cài các phiên bản Python
echo "📥 Đang cài các phiên bản Python..."

echo "   → Cài Python 2.7.18"
CFLAGS='-std=c11' pyenv install -v 2.7.18

echo "   → Cài Python 3.11.11"
pyenv install -v 3.11.11

echo "   → Cài Python 3.12.10"
pyenv install -v 3.12.10

echo "   → Cài Python 3.13.3"
pyenv install -v 3.13.3

echo "   → Cài Python 3.14.5 (Latest)"
pyenv install -v 3.14.5

# 5. Thiết lập mặc định
echo "🌟 Thiết lập Python 3.12.10 làm global default..."
pyenv global 3.12.10

# 6. Kết quả
echo ""
echo "========================================"
echo "✅ CÀI ĐẶT HOÀN TẤT!"
echo "========================================"
echo "Các phiên bản đã cài:"
pyenv versions
echo ""
echo "Phiên bản mặc định: $(python --version)"
echo ""
echo "🔧 Lệnh hữu ích:"
echo "   pyenv versions"
echo "   pyenv install --list     # Xem tất cả phiên bản khả dụng"
echo "   pyenv global 3.14.5"
echo "   pyenv local 3.11.11"
echo ""
echo "🎉 Hoàn tất! Script đã được tối ưu."