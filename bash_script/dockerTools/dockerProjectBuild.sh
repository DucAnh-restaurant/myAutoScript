#!/bin/bash
set -e

APP_DIR="$1"

# ==========================
# Find free port
# ==========================
find_free_port() {
    PORT=8080
    while true; do
        # Kiểm tra port có đang bị sử dụng không
        if ! ss -tuln | grep -q ":$PORT "; then
            echo $PORT
            return
        fi
        PORT=$((PORT+1))
    done
}

# ==========================
# Detect compose command
# ==========================
get_compose_cmd() {
    if docker compose version &>/dev/null; then
        echo "docker compose"
    elif command -v docker-compose &>/dev/null; then
        echo "docker-compose"
    else
        echo ""
    fi
}

# ==========================
# Detect sudo requirement
# ==========================
need_sudo() {
    if docker ps &>/dev/null; then
        echo ""
    else
        echo "sudo"
    fi
}

# ==========================
# Install Docker
# ==========================
install_docker() {
    echo "[*] Installing docker.io + docker-compose..."
    sudo apt update
    sudo apt install -y docker.io docker-compose
    sudo systemctl enable docker
    sudo systemctl start docker
    if ! groups $USER | grep -q '\bdocker\b'; then
        sudo usermod -aG docker $USER
        echo "[!] Added to docker group (re-login recommended)"
    fi
    echo "[✓] Docker installed"
}

# ==========================
# Get port from running container
# ==========================
get_running_port() {
    CONTAINER_ID=$($SUDO docker ps -q | head -n1)
    if [ -z "$CONTAINER_ID" ]; then
        echo ""
        return
    fi
    $SUDO docker port "$CONTAINER_ID" \
        | grep -Eo '0.0.0.0:[0-9]+' \
        | head -n1 \
        | cut -d: -f2
}

# ==========================
# Check Docker
# ==========================
if ! command -v docker &>/dev/null; then
    echo "[!] Docker not found"
    install_docker
    [ -z "$APP_DIR" ] && exit 0
fi

# ==========================
# Usage
# ==========================
if [ -z "$APP_DIR" ]; then
    echo "Usage: $0 <folder_name/>"
    exit 0
fi

# ==========================
# Validate folder
# ==========================
if [ ! -d "$APP_DIR" ]; then
    echo "[!] Folder not found: $APP_DIR"
    exit 1
fi

cd "$APP_DIR"

# ==========================
# Detect compose tool
# ==========================
COMPOSE_CMD=$(get_compose_cmd)
if [ -z "$COMPOSE_CMD" ]; then
    echo "[!] docker-compose not found → installing..."
    sudo apt install -y docker-compose
    COMPOSE_CMD="docker-compose"
fi

echo "[*] Using: $COMPOSE_CMD"

# ==========================
# Detect sudo
# ==========================
SUDO=$(need_sudo)
[ ! -z "$SUDO" ] && echo "[!] Using sudo (docker permission not ready)"

# ==========================
# DEPLOY
# ==========================
if [ -f "docker-compose.yml" ]; then
    echo "[*] Detected docker-compose project"

    # Tìm port trống
    PORT=$(find_free_port)
    export APP_PORT=$PORT
    echo "[*] Using port: $PORT"

    $SUDO $COMPOSE_CMD down || true
    $SUDO $COMPOSE_CMD up -d --build

elif [ -f "Dockerfile" ]; then
    echo "[*] Detected Dockerfile project"

    IMAGE_NAME="myapp_image_$(date +%s)"
    CONTAINER_NAME="myapp_container_$(date +%s)"
    PORT=$(find_free_port)
    echo "[*] Using port: $PORT"

    $SUDO docker build -t $IMAGE_NAME .

    if [ "$($SUDO docker ps -aq -f name=$CONTAINER_NAME)" ]; then
        $SUDO docker rm -f $CONTAINER_NAME
    fi

    $SUDO docker run -d -p $PORT:80 --name $CONTAINER_NAME $IMAGE_NAME

else
    echo "[!] No Dockerfile or docker-compose.yml found"
    exit 1
fi

# ==========================
# GET PORT (runtime)
# ==========================
sleep 2
PORT=$(get_running_port)
[ -z "$PORT" ] && PORT=$(find_free_port)

URL="http://localhost:$PORT"

# ==========================
# OUTPUT
# ==========================
echo "[✓] Deploy completed"
echo "[*] Access: $URL"

# ==========================
# Auto open browser
# ==========================
if command -v xdg-open &>/dev/null; then
    xdg-open "$URL" &>/dev/null &
fi
