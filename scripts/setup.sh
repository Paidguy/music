#!/bin/bash

echo "🎵 Starting Music Stack Setup..."
TARGET_USER="${SUDO_USER:-$USER}"
TARGET_HOME="$(eval echo "~$TARGET_USER")"

# 1. Update & Install System Dependencies
# We need xfce (desktop), tightvnc (server), novnc (web bridge), and libfuse2 (for AppImage)
echo "📦 Installing Desktop & Dependencies..."
sudo apt update
sudo apt install -y xfce4 xfce4-goodies tightvncserver novnc python3-websockify libfuse2 wget

# 2. Download SpotiFLAC (The Downloader)
# We download it to the root project folder for easy access
echo "⬇️ Downloading SpotiFLAC v7.0.6..."
wget -q --show-progress -O SpotiFLAC.AppImage https://github.com/afkarxyz/SpotiFLAC/releases/download/v7.0.6/SpotiFLAC-Linux-x86_64.AppImage
chmod +x SpotiFLAC.AppImage

# 2.5 Create data folders with user-owned permissions
mkdir -p ./music ./data/navidrome ./data/syncthing
sudo chown -R "$TARGET_USER:$TARGET_USER" ./music ./data

# 3. Configure VNC Startup
# This ensures the gray screen doesn't happen
echo "⚙️ Configuring VNC Startup..."
mkdir -p "$TARGET_HOME/.vnc"
echo -e "#!/bin/bash\nxrdb \$HOME/.Xresources\nstartxfce4 &" > "$TARGET_HOME/.vnc/xstartup"
chmod +x "$TARGET_HOME/.vnc/xstartup"
sudo chown -R "$TARGET_USER:$TARGET_USER" "$TARGET_HOME/.vnc"

# 4. Install noVNC System Service
# Copies the service file from your repo to the system folder
echo "🔗 Installing Web Desktop Service..."
if [ -f "./scripts/novnc.service" ]; then
    sudo sed "s/__NOVNC_USER__/$TARGET_USER/" ./scripts/novnc.service > /tmp/novnc.service
    sudo cp /tmp/novnc.service /etc/systemd/system/novnc.service
    sudo systemctl daemon-reload
    sudo systemctl enable novnc
    echo "   -> Service installed and enabled."
else
    echo "   ⚠️ Warning: scripts/novnc.service not found. Skipping service install."
fi

echo "✅ Installation Complete!"
echo "------------------------------------------------"
echo "NEXT STEPS:"
echo "1. Run 'vncserver' to set your password and start the screen."
echo "2. Run 'sudo systemctl start novnc' to open the web bridge."
echo "3. Run 'docker compose up -d' to start the music server."
echo "------------------------------------------------"
