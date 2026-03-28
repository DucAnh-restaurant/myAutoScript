#!/bin/bash

set -e

echo "[*] Creating Android portable venv..."

BASE_DIR=$(pwd)/android-venv
BIN_DIR=$BASE_DIR/bin
SCRCPY_DIR=$BASE_DIR/scrcpy
CONFIG_DIR=$BASE_DIR/config

mkdir -p $BIN_DIR $SCRCPY_DIR $CONFIG_DIR

# =========================
# 1. Download ADB
# =========================
echo "[*] Downloading ADB..."

wget -q https://dl.google.com/android/repository/platform-tools-latest-linux.zip -O /tmp/adb.zip
rm -rf /tmp/platform-tools
unzip -q /tmp/adb.zip -d /tmp/

cp /tmp/platform-tools/adb $BIN_DIR/
chmod +x $BIN_DIR/adb

# =========================
# 2. Download SCRCPY
# =========================
echo "[*] Downloading scrcpy..."

SCRCPY_URL=$(curl -s https://api.github.com/repos/Genymobile/scrcpy/releases/latest \
  | grep browser_download_url \
  | grep linux-x86_64 \
  | cut -d '"' -f 4)

rm -rf /tmp/scrcpy
mkdir -p /tmp/scrcpy

wget -q $SCRCPY_URL -O /tmp/scrcpy.tar.gz
tar -xzf /tmp/scrcpy.tar.gz -C /tmp/scrcpy

# =========================
# 3. Copy FULL folder (FIX LỖI)
# =========================
SCRCPY_SRC=$(find /tmp/scrcpy -type d -name "scrcpy-*")

cp -r $SCRCPY_SRC/* $SCRCPY_DIR/

chmod +x $SCRCPY_DIR/scrcpy
chmod +x $SCRCPY_DIR/scrcpy-server

# =========================
# 4. Create activate.sh (giống venv)
# =========================
cat <<EOF > $BASE_DIR/activate.sh
#!/bin/bash

BASE=\$(cd "\$(dirname "\${BASH_SOURCE[0]}")"; pwd)

export PATH=\$BASE/bin:\$PATH
export ADB_VENDOR_KEYS=\$BASE/config/adb

echo "[+] Android VENV Activated"
echo "[+] adb: \$(which adb)"
echo "[+] scrcpy: \$BASE/scrcpy/scrcpy"
EOF

chmod +x $BASE_DIR/activate.sh

# =========================
# 5. Create run.sh
# =========================
cat <<EOF > $BASE_DIR/run.sh
#!/bin/bash

BASE=\$(cd "\$(dirname "\$0")"; pwd)

export PATH=\$BASE/bin:\$PATH
export ADB_VENDOR_KEYS=\$BASE/config/adb

adb start-server

# chạy đúng scrcpy portable
\$BASE/scrcpy/scrcpy "\$@"
EOF

chmod +x $BASE_DIR/run.sh

# =========================
# 6. DONE
# =========================
echo "[+] DONE!"
echo ""
echo "Usage:"
echo "cd android-venv"
echo "source activate.sh"
echo "./run.sh"
