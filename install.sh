#!/bin/bash

# ---------- USER INPUT ----------
read -p "Enter the app folder path (relative to home, e.g., my-app): " APP_FOLDER
read -p "Enter panel username: " PANEL_USER
read -sp "Enter panel password: " PANEL_PASS
echo
read -p "Is your GitHub repo private? (y/n): " PRIVATE_REPO

if [[ "$PRIVATE_REPO" == "y" || "$PRIVATE_REPO" == "Y" ]]; then
    read -p "Enter your GitHub Personal Access Token: " GH_TOKEN
fi

APP_FOLDER_FULL="$HOME/$APP_FOLDER"

# ---------- VARIABLES ----------
GITHUB_REPO="https://github.com/Mindula-Dilthushan/Ax-File-Manager.git" # Replace with your repo
APP_NAME="file-panel"
APP_DIR="$HOME/$APP_NAME"
NODE_VERSION="20"

# ---------- CREATE ROOT FOLDER ----------
mkdir -p "$APP_FOLDER_FULL"
chmod -R 755 "$APP_FOLDER_FULL"
chown -R $USER:$USER "$APP_FOLDER_FULL"
echo "ROOT_FOLDER created at $APP_FOLDER_FULL"

# ---------- INSTALL SYSTEM TOOLS ----------
sudo apt update -y && sudo apt upgrade -y
sudo apt install -y curl git build-essential

# ---------- INSTALL NODE ----------
curl -fsSL https://deb.nodesource.com/setup_$NODE_VERSION.x | sudo -E bash -
sudo apt install -y nodejs

# ---------- INSTALL PM2 ----------
sudo npm install -g pm2

# ---------- CLONE REPO ----------
if [ -d "$APP_DIR" ]; then
    echo "App folder exists. Pulling latest changes..."
    cd "$APP_DIR"
    git pull
else
    if [[ "$PRIVATE_REPO" == "y" || "$PRIVATE_REPO" == "Y" ]]; then
        git clone "https://$GH_TOKEN@github.com/Mindula-Dilthushan/Ax-File-Manager.git" "$APP_DIR"
    else
        git clone "$GITHUB_REPO" "$APP_DIR"
    fi
    cd "$APP_DIR"
fi

# ---------- CREATE CONFIG.JSON ----------
cat > config.json <<EOL
{
  "ROOT_FOLDER": "$APP_FOLDER_FULL",
  "USERNAME": "$PANEL_USER",
  "PASSWORD": "$PANEL_PASS"
}
EOL
echo "config.json created successfully."

# ---------- INSTALL DEPENDENCIES ----------
npm install

# ---------- START PANEL WITH PM2 ----------
pm2 start panel.js --name "$APP_NAME"
pm2 save

# Setup PM2 to auto-start on reboot
STARTUP_CMD=$(pm2 startup systemd | tail -n 1)
echo "Run the following command to enable PM2 startup on reboot:"
echo "$STARTUP_CMD"

# ---------- Final Instructions ----------
echo "---------------------------------------------"
echo "Setup complete!"
echo "Panel is running at: http://<your-vm-ip>:4000"
echo "Make sure port 4000 is open in your firewall."
echo "---------------------------------------------"
