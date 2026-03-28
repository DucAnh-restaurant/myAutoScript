#!/bin/bash

set -e

echo "[*] Setup Android Portable Toolkit (FULL)..."

BASE_DIR=$(pwd)/android-venv
BIN_DIR=$BASE_DIR/bin
SCRCPY_DIR=$BASE_DIR/scrcpy
LIB_DIR=$BASE_DIR/lib
CONFIG_DIR=$BASE_DIR/config

mkdir -p $BIN_DIR $SCRCPY_DIR $LIB_DIR $CONFIG_DIR

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

SCRCPY_SRC=$(find /tmp/scrcpy -type d -name "scrcpy-*")

cp -r $SCRCPY_SRC/* $SCRCPY_DIR/

chmod +x $SCRCPY_DIR/scrcpy
chmod +x $SCRCPY_DIR/scrcpy-server

# =========================
# 3. Bundle dependencies (.so)
# =========================
echo "[*] Copying shared libraries..."

copy_libs() {
    ldd "$1" | grep "=>" | awk '{print $3}' | while read lib; do
        if [ -f "$lib" ]; then
            cp -n "$lib" $LIB_DIR/ 2>/dev/null || true
        fi
    done
}

# copy dependencies của scrcpy
copy_libs $SCRCPY_DIR/scrcpy

# copy thêm ffmpeg + SDL nếu có
cp /usr/lib/x86_64-linux-gnu/libSDL2* $LIB_DIR/ 2>/dev/null || true
cp /usr/lib/x86_64-linux-gnu/libav* $LIB_DIR/ 2>/dev/null || true
cp /usr/lib/x86_64-linux-gnu/libsw* $LIB_DIR/ 2>/dev/null || true

# =========================
# 4. Create activate.sh
# =========================
cat <<EOF > $BASE_DIR/activate.sh
#!/bin/bash

BASE=\$(cd "\$(dirname "\${BASH_SOURCE[0]}")"; pwd)

export PATH=\$BASE/bin:\$PATH
export LD_LIBRARY_PATH=\$BASE/lib:\$LD_LIBRARY_PATH
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
export LD_LIBRARY_PATH=\$BASE/lib:\$LD_LIBRARY_PATH
export ADB_VENDOR_KEYS=\$BASE/config/adb

adb start-server

\$BASE/scrcpy/scrcpy "\$@"
EOF

chmod +x $BASE_DIR/run.sh

# =========================
# DONE
# =========================
echo "[+] DONE!"
echo ""
echo "Usage:"
echo "cd android-venv"
echo "source activate.sh"
echo "./run.sh"