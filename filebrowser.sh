#!/usr/bin/env bash
set -euo pipefail

# --- Random username/password ---
FB_USER="fbuser"
FB_PASS="M57tnM57tn0EdZC0EdM57tnM57t"

# --- Default directory and port ---
ROOT_DIR="$HOME/Desktop"
PORT=8080
BIND_ADDR="0.0.0.0"    # listen on all network interfaces

# --- Install dependencies ---
sudo apt update -y
sudo apt install -y curl unzip >/dev/null

# --- Download latest File Browser binary ---
echo "Downloading latest File Browser..."
curl -fsSL https://github.com/filebrowser/filebrowser/releases/latest/download/linux-amd64-filebrowser.tar.gz -o /tmp/filebrowser.tar.gz

echo "Extracting..."
tar -xzf /tmp/filebrowser.tar.gz -C /tmp
sudo mv /tmp/filebrowser /usr/local/bin/
sudo chmod +x /usr/local/bin/filebrowser

# --- Prepare configuration ---
CONFIG_DIR="$HOME/.config/filebrowser"
DB_FILE="$CONFIG_DIR/filebrowser.db"
mkdir -p "$CONFIG_DIR"

# --- Initialize configuration ---
filebrowser -d "$DB_FILE" config init
filebrowser -d "$DB_FILE" config set --root "$ROOT_DIR"
filebrowser -d "$DB_FILE" config set --address "$BIND_ADDR"
filebrowser -d "$DB_FILE" config set --port "$PORT"

# --- Create admin user ---
filebrowser -d "$DB_FILE" users add "$FB_USER" "$FB_PASS" --perm.admin

# --- Run in background ---
echo "Starting File Browser (exposed on $BIND_ADDR:$PORT)..."
nohup filebrowser -d "$DB_FILE" -a "$BIND_ADDR" -p "$PORT" > "$HOME/filebrowser.log" 2>&1 &

echo
echo "✅ File Browser is now running!"
echo "🌐 Access it from:"
echo "   http://$(hostname -I | awk '{print $1}'):$PORT"
echo
echo "👤 Username: $FB_USER"
echo "🔑 Password: $FB_PASS"
echo
echo "📁 Root directory: $ROOT_DIR"
echo "🗄  Database: $DB_FILE"
echo "📝 Log: $HOME/filebrowser.log"
echo
echo "To stop it: pkill -f filebrowser"
