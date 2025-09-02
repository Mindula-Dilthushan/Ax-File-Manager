#!/bin/bash

# ---------- USER INPUT ----------
read -p "Enter the app folder path (relative to home, e.g., my-app): " APP_FOLDER
read -p "Enter panel username: " PANEL_USER
read -sp "Enter panel password: " PANEL_PASS
echo

APP_FOLDER_FULL="$HOME/$APP_FOLDER"

# ---------- VARIABLES ----------
GITHUB_REPO="https://github.com/Mindula-Dilthushan/Ax-File-Manager.git" # Replace with your repo
APP_NAME="file-panel"
APP_DIR="$HOME/$APP_NAME"
NODE_VERSION="20"

# ---------- INSTALL SYSTEM TOOLS ----------
sudo apt update -y && sudo apt upgrade -y
sudo apt install -y curl git

# ---------- INSTALL NODE ----------
curl -fsSL https://deb.nodesource.com/setup_$NODE_VERSION.x | sudo -E bash -
sudo apt install -y nodejs

# ---------- INSTALL PM2 ----------
sudo npm install -g pm2

# ---------- CLONE REPO DIRECTLY ----------
if [ -d "$APP_DIR" ]; then
  echo "App folder exists. Pulling latest changes..."
  cd $APP_DIR
  git pull
else
  git clone $GITHUB_REPO $APP_DIR
  cd $APP_DIR
fi

# ---------- CREATE CONFIG.JSON DYNAMICALLY ----------
cat > config.json <<EOL
{
  "ROOT_FOLDER": "$APP_FOLDER_FULL",
  "USERNAME": "$PANEL_USER",
  "PASSWORD": "$PANEL_PASS"
}
EOL

# ---------- INSTALL DEPENDENCIES ----------
npm install

# ---------- START PANEL ----------
pm2 start panel.js --name $APP_NAME
pm2 save
pm2 startup systemd

echo "Setup complete!"
echo "Panel is running at 4000"
