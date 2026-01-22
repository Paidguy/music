<div align="center">

# 🎵 Cloud Music Stack (CMS)

### *Self-Hosted Lossless Streaming & Virtual Studio - Deploy Anywhere*

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![Docker](https://img.shields.io/badge/Docker-Compose-2496ED?logo=docker&logoColor=white)](https://www.docker.com/)
[![Navidrome](https://img.shields.io/badge/Powered%20by-Navidrome-00C9FF)](https://www.navidrome.org/)

A flexible music streaming solution that combines a containerized server (Navidrome) with a browser-accessible virtual desktop for music management. Works on any Linux server - cloud VPS, home lab, or local machine.

**[Features](#-features)** • **[Quick Start](#-quick-start)** • **[Installation](#-detailed-installation)** • **[Troubleshooting](#-troubleshooting)**

---

</div>

## 📖 Table of Contents

- [What Is This?](#-what-is-this)
- [Architecture](#-architecture)
- [Features](#-features)
- [Prerequisites](#-prerequisites)
- [Quick Start](#-quick-start)
- [Detailed Installation](#-detailed-installation)
- [Configuration](#-configuration)
- [Usage Guide](#-usage-guide)
- [Troubleshooting](#-troubleshooting)
- [File Structure](#-file-structure)
- [Advanced Topics](#-advanced-topics)
- [Credits](#-credits)

---

## 🎯 What Is This?

**Cloud Music Stack** turns any Linux server into your personal music streaming platform. Think Spotify, but you own everything.

### Why Use This?

✅ Stream your music collection from anywhere  
✅ Access a full desktop environment in your browser  
✅ Automatic HTTPS with zero configuration  
✅ Compatible with popular mobile apps  
✅ Full FLAC/lossless audio support  
✅ No subscription fees or data sharing

### Who Is This For?

- Music enthusiasts who want to own their library
- Audiophiles who demand lossless quality
- Anyone wanting to break free from streaming subscriptions
- Self-hosting enthusiasts looking for a complete solution

---

## 🏗 Architecture

This project uses a **hybrid approach** that elegantly solves the challenge of running GUI applications on headless servers.

### The Two Layers

**1. Host Layer (Your Server's OS)**
- **XFCE Desktop**: Lightweight GUI environment
- **TigerVNC Server**: Provides the desktop video stream
- **noVNC + Websockify**: Converts VNC to browser-accessible WebSocket
- **SpotiFLAC**: GUI application for music acquisition

**2. Container Layer (Docker)**
- **Navidrome**: Scans your music folder and serves it via Subsonic API
- **Caddy**: Reverse proxy that automatically handles SSL certificates

### How They Connect

```
Browser → Caddy (Port 443) → Navidrome (Port 4533) → Music Library
Browser → Caddy (Port 8443) → noVNC (Port 6080) → VNC Desktop
```

Caddy sits at the edge, routing requests to either your music server or your virtual desktop, both secured with automatic HTTPS.

---

## 🚀 Features

### Core Capabilities

- **🎼 Lossless Streaming** - Native FLAC support with no quality loss
- **🖥️ Browser Desktop** - Full Linux GUI accessible from any device
- **🔒 Auto SSL** - Let's Encrypt certificates provisioned automatically
- **💾 Persistent Storage** - Music survives container restarts
- **📱 Mobile Ready** - Works with Amperfy, Symfonium, and more
- **🔄 Docker-Based** - Easy updates and portable configuration

### What Makes It Different

Most music servers require you to upload files manually. With CMS, you get a **virtual studio** - a full desktop environment in your browser where you can download, organize, and manage music directly on the server. Everything stays in one place.

---

## 📋 Prerequisites

### Server Requirements

**Minimum Specs:**
- **CPU**: 2 cores (1 core works but slower)
- **RAM**: 2GB (or 1GB + 4GB swap)
- **Storage**: 20GB for system + your music collection
- **OS**: Ubuntu 20.04/22.04/24.04 or Debian 10+

**Hosting Options:**
- Cloud: AWS EC2, Google Cloud, DigitalOcean, Linode, Vultr, Hetzner
- Home: Raspberry Pi 4 (4GB+), old laptop, mini PC, NAS
- Local: Any Linux machine you can access remotely

### Network Requirements

Your server must have these ports accessible:

| Port | Purpose | Required |
|------|---------|----------|
| `22` | SSH access | Yes |
| `80` | HTTP (for SSL verification) | Yes |
| `443` | HTTPS (web player) | Yes |
| `8443` | HTTPS (virtual desktop) | Yes |

**Cloud providers:** Configure your security group/firewall  
**Home servers:** Set up port forwarding on your router

### Additional Requirements

1. **Domain name** - Free options available:
   - [DuckDNS](https://www.duckdns.org) (easiest, free)
   - [No-IP](https://www.noip.com)
   - [Afraid.org](https://freedns.afraid.org)

2. **Basic Linux skills** - Comfortable with SSH and command line

3. **Docker knowledge** (helpful but not required)

---

## ⚡ Quick Start

**For experienced users who want to get running fast:**

```bash
# 1. Clone and enter directory
git clone https://github.com/Paidguy/music-stack.git
cd music-stack

# 2. Run auto-installer
chmod +x scripts/setup.sh
sudo ./scripts/setup.sh

# 3. Set VNC password
vncserver
# Enter password, choose 'n' for view-only

# 4. Edit domain in Caddyfile
nano Caddyfile
# Replace 'paidguy.duckdns.org' with your domain

# 5. Start everything
sudo systemctl start novnc
docker compose up -d

# 6. Access your desktop
# Browser: https://your-domain.com:8443/vnc.html
# Music player: https://your-domain.com
```

**First time with Docker or Linux?** Skip to [Detailed Installation](#-detailed-installation) below.

---

## 📦 Detailed Installation

### Step 1: Prepare Your Server

Connect to your server via SSH and update the system:

```bash
# Update package lists and upgrade installed packages
sudo apt update && sudo apt upgrade -y

# Install essential tools
sudo apt install -y git curl wget nano
```

### Step 2: Install Docker (If Not Already Installed)

Docker runs the containerized services. Install it with these commands:

```bash
# Download Docker's official installation script
curl -fsSL https://get.docker.com -o get-docker.sh

# Run the installation script
sudo sh get-docker.sh

# Add your user to docker group (avoids needing sudo every time)
sudo usermod -aG docker $USER

# Install Docker Compose
sudo apt install -y docker-compose

# Log out and back in for group changes to take effect
exit
# Then reconnect via SSH

# Verify installation
docker --version
docker-compose --version
```

### Step 3: Clone the Repository

Get the project files onto your server:

```bash
# Navigate to your home directory
cd ~

# Clone the repository
git clone https://github.com/Paidguy/music-stack.git

# Enter the project directory
cd music-stack

# Check the contents
ls -la
```

You should see files like `Caddyfile`, `docker-compose.yml`, and the `scripts/` directory.

### Step 4: Run the Automated Setup Script

This script installs all the desktop environment components:

```bash
# Make the script executable
chmod +x scripts/setup.sh

# Run it (requires sudo for system-wide installation)
sudo ./scripts/setup.sh
```

**What this script does:**
- Installs XFCE desktop environment
- Installs TigerVNC server
- Installs noVNC and websockify
- Downloads SpotiFLAC AppImage
- Creates systemd service for noVNC
- Sets up proper file permissions

**⏱️ This takes 5-10 minutes** depending on your internet connection.

### Step 5: Configure VNC Server

Set up your VNC password (this is what you'll use to access the desktop):

```bash
# Start VNC for the first time
vncserver
```

**You'll be prompted for:**
- **Password**: Choose a secure password (6-8 characters minimum)
- **View-only password**: Type `n` (not needed for this use case)

The VNC server will start, then we'll stop it to ensure proper configuration:

```bash
# Stop the VNC session
vncserver -kill :1
```

**Verify the startup script exists:**

```bash
# Check if xstartup file exists and is executable
ls -la ~/.vnc/xstartup

# If it doesn't exist or isn't executable, create it:
cat > ~/.vnc/xstartup << 'EOF'
#!/bin/bash
xrdb $HOME/.Xresources
startxfce4 &
EOF

chmod +x ~/.vnc/xstartup
```

### Step 6: Configure Your Domain

Edit the Caddyfile to use your actual domain:

```bash
nano Caddyfile
```

**Replace** `paidguy.duckdns.org` with your domain in **both places**:

**Before:**
```
paidguy.duckdns.org {
    reverse_proxy navidrome:4533
}

paidguy.duckdns.org:8443 {
    reverse_proxy host.docker.internal:6080
}
```

**After (example with your domain):**
```
your-domain.duckdns.org {
    reverse_proxy navidrome:4533
}

your-domain.duckdns.org:8443 {
    reverse_proxy host.docker.internal:6080
}
```

**Save and exit**: Press `Ctrl+X`, then `Y`, then `Enter`

### Step 7: Create Required Directories

The music and data folders store your library and application data:

```bash
# Create directories if they don't exist
mkdir -p ~/music-stack/music
mkdir -p ~/music-stack/data

# Set proper permissions
chmod 755 ~/music-stack/music
chmod 755 ~/music-stack/data
```

### Step 8: Start the Services

**Start the noVNC service** (makes desktop accessible via browser):

```bash
# Enable it to start on boot
sudo systemctl enable novnc

# Start it now
sudo systemctl start novnc

# Check status
sudo systemctl status novnc
```

You should see "active (running)" in green.

**Start the Docker containers:**

```bash
# Make sure you're in the project directory
cd ~/music-stack

# Start Navidrome and Caddy
docker compose up -d

# Check that they're running
docker compose ps
```

Both containers should show "Up" status.

**View logs if needed:**

```bash
# Watch all logs
docker compose logs -f

# Or specific service
docker compose logs -f navidrome
docker compose logs -f caddy
```

Press `Ctrl+C` to exit logs.

### Step 9: Start Your Virtual Desktop

Launch the VNC server with your preferred resolution:

```bash
# Standard 1080p desktop
vncserver -geometry 1920x1080 -depth 24

# Or for lower bandwidth/smaller screens
vncserver -geometry 1280x720 -depth 24

# Or for high-DPI displays
vncserver -geometry 2560x1440 -depth 24
```

**Verify it's running:**

```bash
ps aux | grep vnc
```

You should see a `Xtightvnc` process running.

### Step 10: Access Your Installation

**Test your virtual desktop:**

Open a browser and go to:
```
https://your-domain.com:8443/vnc.html
```

Enter your VNC password. You should see the XFCE desktop.

**Test your music player:**

Go to:
```
https://your-domain.com
```

Create your admin account on first visit.

---

## ⚙️ Configuration

### Understanding docker-compose.yml

The `docker-compose.yml` file defines your services. Here are the key sections:

```yaml
services:
  navidrome:
    image: deluan/navidrome:latest
    ports:
      - "4533:4533"
    environment:
      ND_SCANSCHEDULE: "@every 15m"  # How often to scan for new music
      ND_LOGLEVEL: "info"            # Logging verbosity
      ND_SESSIONTIMEOUT: "24h"       # How long you stay logged in
      ND_ENABLETRANSCODINGCONFIG: "true"  # Allow format conversion
    volumes:
      - "./music:/music"             # Your music library
      - "./data:/data"               # Database and cache
    user: "1000:1000"                # Run as your user (prevents permission issues)
```

### Common Customizations

**Change scan frequency:**
```yaml
ND_SCANSCHEDULE: "@every 1h"   # Scan hourly
ND_SCANSCHEDULE: "@every 30m"  # Scan every 30 minutes
```

**Adjust session timeout:**
```yaml
ND_SESSIONTIMEOUT: "168h"  # Stay logged in for 1 week
```

**Change logging level:**
```yaml
ND_LOGLEVEL: "debug"  # More detailed logs
ND_LOGLEVEL: "error"  # Only show errors
```

**After making changes:**
```bash
docker compose down
docker compose up -d
```

### Understanding the Caddyfile

Caddy handles routing and SSL. The configuration is simple:

```
# Route traffic to music player
your-domain.com {
    reverse_proxy navidrome:4533
}

# Route traffic to virtual desktop
your-domain.com:8443 {
    reverse_proxy host.docker.internal:6080
}
```

**Key point:** `host.docker.internal` allows containers to access services running on the host machine.

### Memory Optimization for Low-End Systems

If you're running on a system with limited RAM (like 1GB):

**Create swap space:**
```bash
# Create 4GB swap file
sudo fallocate -l 4G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

# Make it permanent
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
```

**Add memory limits to docker-compose.yml:**
```yaml
services:
  navidrome:
    deploy:
      resources:
        limits:
          memory: 512M
        reservations:
          memory: 256M
```

---

## 💡 Usage Guide

### The Virtual Studio (Downloading Music)

The virtual desktop is your music management workspace. Here's how to use it:

#### Accessing the Desktop

1. **Open your browser** and navigate to:
   ```
   https://your-domain.com:8443/vnc.html
   ```

2. **Click "Connect"** on the noVNC landing page

3. **Enter your VNC password** (the one you set during installation)

4. **You're in!** You should see the XFCE desktop

#### Using SpotiFLAC

**Launch the application:**

1. **Right-click** on the desktop
2. Select **"Open Terminal"**
3. Run these commands:

```bash
cd ~/music-stack
./SpotiFLAC.AppImage --no-sandbox
```

**⚠️ CRITICAL: Configure the download path**

Before downloading anything:

1. In SpotiFLAC, go to **Settings**
2. Set **Download Location** to:
   ```
   /home/YOUR_USERNAME/music-stack/music
   ```
   Replace `YOUR_USERNAME` with your actual username (usually `ubuntu` or your chosen name)

3. **Why this matters**: Only files in this exact location will appear in Navidrome!

**Download your music:**

1. Search for albums or playlists
2. Select quality settings (FLAC recommended)
3. Click download
4. Files appear immediately in Navidrome (scans every 15 minutes by default)

#### Alternative: Upload Files Directly

If you have music on your computer, you can upload it:

**From Linux/Mac:**
```bash
scp -r /path/to/your/music/* username@your-server:~/music-stack/music/
```

**From Windows:**
- Use [WinSCP](https://winscp.net/) or [FileZilla](https://filezilla-project.org/)
- Connect via SFTP
- Upload to `/home/username/music-stack/music/`

#### Organizing Your Library

**Best practices for folder structure:**

```
music/
├── Artist Name/
│   ├── Album Name (Year)/
│   │   ├── 01 - Track Name.flac
│   │   ├── 02 - Track Name.flac
│   │   └── cover.jpg
│   └── Another Album (Year)/
└── Another Artist/
```

Navidrome automatically reads metadata from your FLAC files and organizes everything.

### Streaming Your Music

#### Web Player

**Access:** Simply visit `https://your-domain.com`

**First-time setup:**
1. Click **"Create Admin User"**
2. Choose username and password
3. Log in

**Features:**
- Browse by artist, album, genre
- Create playlists
- Search across your library
- Control playback quality
- View album artwork
- Scrobble to Last.fm (optional)

#### Mobile Apps

CMS uses the Subsonic API, which means it works with dozens of apps.

**iOS Apps (Recommended):**

| App | Price | Best For |
|-----|-------|----------|
| **Amperfy** | Free | Open-source, feature-rich |
| **Play:Sub** | $4.99 | Premium experience, offline mode |
| **iSub** | $2.99 | Classic, reliable |

**Android Apps (Recommended):**

| App | Price | Best For |
|-----|-------|----------|
| **Symfonium** | $4.99 | 🏆 Best overall, tons of features |
| **DSub** | Free | Feature-rich, stable |
| **Ultrasonic** | Free | Open-source |
| **SubStreamer** | $3.99 | Clean interface |

#### Connecting Your Mobile App

**Configuration (same for all apps):**

```
Server URL: https://your-domain.com
Port: (leave empty or enter 443)
Username: (your Navidrome username)
Password: (your Navidrome password)
```

**Tips:**
- Most apps will auto-detect the correct port
- Enable "Use HTTPS" if it's a separate option
- Some apps call it "Server Address" instead of URL
- Test the connection before enabling offline mode

**Troubleshooting connection:**
1. Try without the port first
2. If that fails, explicitly set port to `443`
3. Make sure you're using `https://` not `http://`
4. Verify credentials work in the web player first

---

## 🔧 Troubleshooting

### Common Issues and Solutions

#### 1. Gray Screen in VNC Desktop

**Symptom:** You connect to the desktop but only see a gray screen with an X cursor.

**Cause:** The XFCE startup script is missing or not executable.

**Fix:**
```bash
# Stop VNC
vncserver -kill :1

# Recreate the startup script
cat > ~/.vnc/xstartup << 'EOF'
#!/bin/bash
xrdb $HOME/.Xresources
startxfce4 &
EOF

# Make it executable
chmod +x ~/.vnc/xstartup

# Restart VNC
vncserver -geometry 1920x1080 -depth 24
```

#### 2. Can't Access Web Player

**Symptom:** Browser shows "This site can't be reached" at `https://your-domain.com`

**Diagnose:**
```bash
# Check if containers are running
docker compose ps

# Check Caddy logs for SSL errors
docker compose logs caddy

# Verify domain resolves correctly
nslookup your-domain.com

# Test locally on the server
curl -I http://localhost:4533
```

**Common fixes:**

**If Caddy isn't getting SSL:**
- Verify ports 80 and 443 are open in your firewall
- Check that your domain actually points to your server's IP
- Wait a few minutes - Let's Encrypt can be slow

**If Navidrome isn't running:**
```bash
docker compose restart navidrome
docker compose logs -f navidrome
```

#### 3. SpotiFLAC Won't Launch

**Symptom:** Double-clicking SpotiFLAC does nothing, or shows permission error.

**Fix:**
```bash
# Make it executable
chmod +x ~/music-stack/SpotiFLAC.AppImage

# Install FUSE library (required for AppImages)
sudo apt install -y libfuse2

# Launch from terminal with sandbox disabled
cd ~/music-stack
./SpotiFLAC.AppImage --no-sandbox
```

#### 4. Music Not Appearing in Navidrome

**Symptom:** You downloaded music but it doesn't show up in the web player.

**Check download location:**
```bash
# List files in music directory
ls -la ~/music-stack/music

# Verify files are actually there
find ~/music-stack/music -name "*.flac"
```

**Fix permissions:**
```bash
# Ensure Navidrome can read the files
sudo chown -R $USER:$USER ~/music-stack/music
chmod -R 755 ~/music-stack/music
```

**Force a scan:**
1. Go to Navidrome web UI
2. Click the **Activity icon** (top right)
3. Select **"Full Scan"**

**Or restart Navidrome:**
```bash
docker compose restart navidrome
```

#### 5. Virtual Desktop Is Laggy

**Cause:** High resolution or slow network connection.

**Solutions:**

**Reduce resolution:**
```bash
vncserver -kill :1
vncserver -geometry 1280x720 -depth 16
```

**Reduce color depth:**
```bash
vncserver -geometry 1920x1080 -depth 16
```

**Adjust noVNC compression** (in the noVNC interface):
- Click the sidebar
- Lower "Quality" slider
- Lower "Compression Level" slider

#### 6. noVNC Service Won't Start

**Check status:**
```bash
sudo systemctl status novnc
```

**View logs:**
```bash
sudo journalctl -u novnc -n 50
```

**Common fix - recreate the service:**
```bash
sudo tee /etc/systemd/system/novnc.service > /dev/null << EOF
[Unit]
Description=noVNC Web Gateway
After=network.target

[Service]
Type=simple
User=$USER
ExecStart=/usr/share/novnc/utils/launch.sh --vnc localhost:5901 --listen 6080
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable novnc
sudo systemctl start novnc
```

#### 7. Port Already in Use

**Symptom:** Docker fails to start with "port already in use" error.

**Find what's using the port:**
```bash
sudo netstat -tulpn | grep :4533
sudo netstat -tulpn | grep :6080
```

**Kill the process or change ports in docker-compose.yml**

#### 8. High CPU/Memory Usage

**Check resource usage:**
```bash
docker stats
```

**Reduce Navidrome's resource usage:**

Edit `docker-compose.yml`:
```yaml
services:
  navidrome:
    environment:
      ND_SCANSCHEDULE: "@every 1h"  # Scan less frequently
      ND_IMAGECACHESIZE: "100MB"    # Reduce cache
```

Add memory limits:
```yaml
    deploy:
      resources:
        limits:
          memory: 512M
```

---

## 📂 File Structure

```
music-stack/
│
├── 📄 Caddyfile                      # Reverse proxy configuration
│                                     # Handles domain routing and SSL
│
├── 📄 docker-compose.yml             # Docker services definition
│                                     # Defines Navidrome and Caddy containers
│
├── 📄 .gitignore                     # Git exclusion rules
│                                     # Prevents music/data from being committed
│
├── 📄 README.md                      # This file
│
├── 📂 music/                         # 🎵 YOUR MUSIC LIBRARY
│   │                                 # Downloaded files go here
│   ├── Artist/                       # Organized by artist
│   │   └── Album/
│   │       ├── track01.flac
│   │       └── cover.jpg
│   └── ...
│
├── 📂 data/                          # Application persistent data
│   │                                 # Auto-generated by Navidrome
│   ├── navidrome.db                  # Database (playlists, user data)
│   └── cache/                        # Transcoded files, thumbnails
│
└── 📂 scripts/                       # Installation scripts
    ├── setup.sh                      # Main installer
    └── novnc.service                 # systemd service definition
```

### Important Paths

| Path | Purpose | Mount |
|------|---------|-------|
| `~/music-stack/music` | Your music library | → `/music` in Navidrome |
| `~/music-stack/data` | Navidrome database | → `/data` in Navidrome |
| `~/.vnc/` | VNC server config | Host only |
| `/usr/share/novnc/` | noVNC application | Host only |

---

## 🔐 Advanced Topics

### Automatic Startup on Boot

**Make VNC start automatically:**
```bash
crontab -e

# Add this line:
@reboot sleep 30 && /usr/bin/vncserver -geometry 1920x1080 -depth 24
```

**Ensure Docker services start:**
```bash
# Docker should already auto-start, but verify:
sudo systemctl enable docker

# Make Docker Compose services restart automatically
cd ~/music-stack
docker compose up -d --restart always
```

### Backup Your Setup

**Backup script** (`~/backup-cms.sh`):
```bash
#!/bin/bash
BACKUP_DIR=~/backups/cms
DATE=$(date +%Y%m%d-%H%M%S)
mkdir -p $BACKUP_DIR

# Backup music library
tar -czf $BACKUP_DIR/music-$DATE.tar.gz ~/music-stack/music/

# Backup Navidrome database
tar -czf $BACKUP_DIR/data-$DATE.tar.gz ~/music-stack/data/

# Backup configuration
cp ~/music-stack/docker-compose.yml $BACKUP_DIR/docker-compose-$DATE.yml
cp ~/music-stack/Caddyfile $BACKUP_DIR/Caddyfile-$DATE

# Keep only last 7 days
find $BACKUP_DIR -name "*.tar.gz" -mtime +7 -delete
find $BACKUP_DIR -name "*.yml" -mtime +7 -delete

echo "Backup completed: $DATE"
```

**Make it executable and run weekly:**
```bash
chmod +x ~/backup-cms.sh

crontab -e
# Add: 0 3 * * 0 ~/backup-cms.sh
```

### Updating the Stack

**Update Docker images:**
```bash
cd ~/music-stack
docker compose pull
docker compose up -d
```

**Update system packages:**
```bash
sudo apt update && sudo apt upgrade -y
```

**Update SpotiFLAC:**
- Download latest release manually from GitHub
- Replace old AppImage with new one

### Security Hardening

**Use SSH keys only:**
```bash
# On your local machine:
ssh-keygen -t ed25519 -C "your_email@example.com"
ssh-copy-id username@your-server

# On server, disable password auth:
sudo nano /etc/ssh/sshd_config
# Set: PasswordAuthentication no
sudo systemctl restart sshd
```

**Set up UFW firewall:**
```bash
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow 8443/tcp
sudo ufw enable
```

**Strong VNC password:**
```bash
vncpasswd
# Enter a complex password (12+ characters)
```

### Multi-User Setup

**Create additional Navidrome users:**
1. Log in as admin
2. Go to **Settings** → **Users**
3. Click **Create User**
4. Each user gets separate playlists and preferences

**Note:** All users share the same music library.

### Custom Domain with Cloudflare

**Benefits:** DDoS protection, caching, analytics

1. **Add your domain to Cloudflare**
2. **Update nameservers** with your domain registrar
3. **Create A record** pointing to your server IP
4. **Set SSL/TLS mode** to "Full (strict)"
5. **No changes needed** in Caddyfile - it handles Cloudflare automatically

---

## 📚 Quick Reference

### Essential Commands

#### 🟢 How to Start the Site

Run these two commands to turn everything on:

**Start the Desktop (VNC):**
```bash
vncserver -geometry 1280x720
```

**Start the Website Bridge:**
```bash
sudo systemctl start novnc
```

You can now go to `https://your-domain.com:8443/vnc.html` and connect.

---

#### 🔴 How to Stop the Site

Run these to turn it off (saves RAM when you aren't downloading music):

**Stop the Desktop:**
```bash
vncserver -kill :1
```

**Stop the Website Bridge:**
```bash
sudo systemctl stop novnc
```

---

#### 🔄 How to Restart (If it freezes)

If the screen is gray or stuck, run this full cycle to reset it:

```bash
# 1. Kill the Desktop
vncserver -kill :1

# 2. Restart the Bridge
sudo systemctl restart novnc

# 3. Start the Desktop again
vncserver -geometry 1280x720
```

---

#### 📊 Command Summary Table

| Action | Command |
|--------|---------|
| **Start Desktop** | `vncserver -geometry 1280x720` |
| **Kill Desktop** | `vncserver -kill :1` |
| **Start Web Bridge** | `sudo systemctl start novnc` |
| **Stop Web Bridge** | `sudo systemctl stop novnc` |
| **Restart Web Bridge** | `sudo systemctl restart novnc` |
| **Check Status** | `sudo systemctl status novnc` |
| **Start Docker Services** | `cd ~/music-stack && docker compose up -d` |
| **Stop Docker Services** | `docker compose down` |
| **Restart Navidrome** | `docker compose restart navidrome` |
| **View Logs** | `docker compose logs -f` |
| **Check Container Status** | `docker compose ps` |

### Essential URLs

- **Music Player**: `https://your-domain.com`
- **Virtual Desktop**: `https://your-domain.com:8443/vnc.html`
- **Admin Panel**: `https://your-domain.com` → Settings → Administration

### Essential Paths

- **Music Library**: `~/music-stack/music`
- **App Data**: `~/music-stack/data`
- **Config Files**: `~/music-stack/Caddyfile`, `~/music-stack/docker-compose.yml`
- **VNC Config**: `~/.vnc/xstartup`

---

## 👤 Credits

<div align="center">

### Created & Maintained by **@paidguy**

[![GitHub](https://img.shields.io/badge/GitHub-@Paidguy-181717?logo=github)](https://github.com/Paidguy)
[![Twitter](https://img.shields.io/badge/Twitter-@imhqt-1DA1F2?logo=twitter&logoColor=white)](https://twitter.com/imhqt)
[![Telegram](https://img.shields.io/badge/Telegram-@paidguy-26A5E4?logo=telegram&logoColor=white)](https://t.me/paidguy)
[![Email](https://img.shields.io/badge/Email-imhqt@proton.me-6D4AFF?logo=protonmail&logoColor=white)](mailto:imhqt@proton.me)

---

**Built with ❤️ and powered by open-source technology**

</div>

### Built With

This project stands on the shoulders of excellent open-source software:

- **[Navidrome](https://www.navidrome.org/)** - Modern music server and streamer
- **[Caddy](https://caddyserver.com/)** - Fast web server with automatic HTTPS
- **[noVNC](https://novnc.com/)** - Browser-based VNC client
- **[TigerVNC](https://tigervnc.org/)** - High-performance VNC server
- **[XFCE](https://xfce.org/)** - Lightweight desktop environment
- **[Docker](https://www.docker.com/)** - Container platform

---

## 📄 License & Disclaimer

### Legal Notice

⚖️ **Copyright Compliance**: This project is designed for **personal use with legally obtained music**. You are responsible for ensuring you have the rights to download, store, and stream any content.

🎵 **Support Artists**: Please purchase music through legitimate channels. This tool is meant to enhance your music experience, not replace fair compensation for creators.

📜 **License**: This project is provided as-is for educational and personal use. The authors are not responsible for misuse.

---

## 🤝 Contributing & Support

### Get Help

- 🐛 **Bug Reports**: [GitHub Issues](https://github.com/Paidguy/music-stack/issues)
- 💬 **Questions**: [GitHub Discussions](https://github.com/Paidguy/music-stack/discussions)
- 📖 **Navidrome Docs**: [navidrome.org/docs](https://www.navidrome.org/docs/)

### Contribute

Found a bug? Have an improvement? Pull requests are welcome!

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

<div align="center">

## 🎉 You're Ready to Stream!

**Your personal music empire awaits.**

🎵 Access from anywhere • 🎼 Stream in lossless quality • 💾 Own your library

---

⭐ **Star this repo** if you found it helpful!  
🐛 **Found an issue?** Open a GitHub issue  
💬 **Have questions?** Start a discussion

---

*Made with ❤️ for music lovers who value ownership, quality, and privacy*

**[⬆ Back to Top](#-cloud-music-stack-cms)**

</div>
