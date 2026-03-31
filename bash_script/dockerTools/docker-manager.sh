#!/bin/bash

# ==============================
# Docker Port Manager Full
# ==============================

# ===== AUTO PRIVILEGE =====
if ! docker ps >/dev/null 2>&1; then
    echo "[!] Không có quyền Docker, thử chạy lại với sudo..."
    exec sudo "$0" "$@"
fi

# ===== MENU =====
function show_menu() {
    echo "======================================"
    echo " Docker Port Manager"
    echo "======================================"
    echo "[1] Liệt kê port Docker đang dùng"
    echo "[2] Đóng container theo port"
    echo "[3] Restart container theo port"
    echo "[4] Tìm & kill process theo port (ngoài Docker)"
    echo "[0] Thoát"
    echo "======================================"
}

# ===== LIST PORT =====
function list_ports() {
    echo "[*] Đang lấy danh sách container..."

    mapfile -t DOCKER_PORTS < <(docker ps --format "{{.ID}} {{.Names}} {{.Ports}}" | grep -v '^$')

    if [ ${#DOCKER_PORTS[@]} -eq 0 ]; then
        echo "[!] Không có container nào đang chạy."
        return
    fi

    declare -gA PORT_MAP
    INDEX=1

    echo "--------------------------------------"
    echo "Danh sách port:"
    echo "--------------------------------------"

    for line in "${DOCKER_PORTS[@]}"; do
        CID=$(echo "$line" | awk '{print $1}')
        NAME=$(echo "$line" | awk '{print $2}')
        PORTS=$(echo "$line" | cut -d ' ' -f3-)

        IFS=',' read -ra PORT_LIST <<< "$PORTS"
        for p in "${PORT_LIST[@]}"; do
            HOST_PORT=$(echo "$p" | grep -oP '0\.0\.0\.0:\K[0-9]+')

            if [ ! -z "$HOST_PORT" ]; then
                echo "[$INDEX] Port: $HOST_PORT | $NAME ($CID)"
                PORT_MAP[$INDEX]="$CID|$HOST_PORT|$NAME"
                ((INDEX++))
            fi
        done
    done

    if [ ${#PORT_MAP[@]} -eq 0 ]; then
        echo "[!] Không có port public."
    fi
}

# ===== SELECT PORT =====
function select_port() {
    read -p "[?] Chọn số: " CHOICE
    SELECTED="${PORT_MAP[$CHOICE]}"

    if [ -z "$SELECTED" ]; then
        echo "[!] Lựa chọn không hợp lệ"
        return 1
    fi

    CID=$(echo "$SELECTED" | cut -d '|' -f1)
    PORT=$(echo "$SELECTED" | cut -d '|' -f2)
    NAME=$(echo "$SELECTED" | cut -d '|' -f3)
}

# ===== STOP =====
function stop_container() {
    list_ports
    select_port || return

    echo "[!] Dừng container $NAME (port $PORT)..."
    docker stop "$CID"

    if [ $? -eq 0 ]; then
        echo "[✓] Đã giải phóng port $PORT"
    else
        echo "[!] Lỗi khi dừng"
    fi
}

# ===== RESTART =====
function restart_container() {
    list_ports
    select_port || return

    echo "[*] Restart container $NAME..."
    docker restart "$CID"
}

# ===== KILL PROCESS =====
function kill_process() {
    read -p "[?] Nhập port: " PORT

    PID=$(lsof -t -i:$PORT)

    if [ -z "$PID" ]; then
        echo "[!] Không có process nào dùng port $PORT"
        return
    fi

    echo "[!] Process PID: $PID đang dùng port $PORT"
    read -p "[?] Kill? (y/n): " CONFIRM

    if [[ "$CONFIRM" == "y" ]]; then
        kill -9 $PID
        echo "[✓] Đã kill process"
    else
        echo "[*] Hủy"
    fi
}

# ===== MAIN LOOP =====
while true; do
    show_menu
    read -p "[?] Chọn: " OPTION

    case $OPTION in
        1)
            list_ports
            ;;
        2)
            stop_container
            ;;
        3)
            restart_container
            ;;
        4)
            kill_process
            ;;
        0)
            echo "[*] Thoát."
            exit 0
            ;;
        *)
            echo "[!] Không hợp lệ"
            ;;
    esac
done
