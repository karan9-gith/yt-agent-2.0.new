# ContentPilot AI — Production Cloud VPS Deployment Guide

Complete step-by-step instructions to deploy ContentPilot AI on a Cloud Virtual Private Server (Ubuntu 22.04 / 24.04 LTS or Debian 12) with Nginx reverse proxy, PM2 process management, FFmpeg rendering, and Let's Encrypt SSL.

---

## 1. Recommended Server Specifications

| Component | Minimum | Recommended (Multi-video pipeline) |
| :--- | :--- | :--- |
| **CPU** | 2 vCPU | 4+ vCPU (Faster FFmpeg encoding) |
| **RAM** | 4 GB | 8 GB |
| **Disk** | 40 GB NVMe SSD | 100+ GB NVMe (For video & cache storage) |
| **OS** | Ubuntu 22.04 / 24.04 LTS | Ubuntu 24.04 LTS or Debian 12 |
| **Providers** | DigitalOcean, Hetzner, Linode, AWS EC2, Contabo, Vultr |

---

## 2. Fast Automated One-Command Installation

### Step A: Connect to your VPS
```bash
ssh root@YOUR_SERVER_IP
```

### Step B: Transfer or Clone the Code to `/var/www/contentpilot-ai`

```bash
mkdir -p /var/www/contentpilot-ai
cd /var/www/contentpilot-ai

# If cloning from Git:
git clone https://github.com/your-username/contentpilot-ai.git .

# Or if copying files via SCP/rsync from your local PC:
# rsync -avz --exclude 'node_modules' --exclude '.git' ./ root@YOUR_SERVER_IP:/var/www/contentpilot-ai/
```

### Step C: Execute the Automated Setup Script

```bash
chmod +x scripts/*.sh
sudo bash scripts/setup-vps.sh
```

The script will automatically:
1. Update system packages and install `ffmpeg`, `sqlite3`, `nginx`, `certbot`, `build-essential`.
2. Install Node.js LTS v20 and global `pm2`.
3. Set up directories (`storage`, `prisma`, `logs`, `/backups/contentpilot`).
4. Generate a secure 256-bit `APP_SECRET_KEY` in `.env`.
5. Run Prisma generation and schema sync on SQLite.
6. Compile the TypeScript backend and Vite React frontend bundle.
7. Configure and start PM2 with automatic systemd startup on reboot.
8. Configure Nginx reverse proxy and firewall (UFW).

---

## 3. Configure Production Environment Variables

Edit the `.env` file on your server:

```bash
nano /var/www/contentpilot-ai/.env
```

Ensure the following are set:
```env
NODE_ENV=production
PORT=3001
CORS_ORIGIN=https://yourdomain.com
APP_SECRET_KEY=YOUR_GENERATED_32_BYTE_SECRET

# AI & APIs
GEMINI_API_KEY=your_gemini_api_key
GEMINI_MODEL=gemini-2.5-flash

# YouTube OAuth credentials
YOUTUBE_CLIENT_ID=your_client_id.apps.googleusercontent.com
YOUTUBE_CLIENT_SECRET=your_client_secret
YOUTUBE_REDIRECT_URI=https://yourdomain.com/api/auth/youtube/callback

# Operational Safety
AUTO_PUBLISH=false
REQUIRE_HUMAN_APPROVAL=true
STORAGE_DIR=/var/www/contentpilot-ai/backend/storage
```

After modifying `.env`, reload the application:
```bash
pm2 restart contentpilot-api --update-env
```

---

## 4. Domain & Free SSL (Let's Encrypt) Setup

### Step A: Set your DNS Records
In your DNS provider (Cloudflare, Namecheap, GoDaddy, etc.):
- **Type**: `A`
- **Name**: `@` or `studio` (e.g. `studio.yourdomain.com`)
- **Value**: `YOUR_SERVER_IP`

### Step B: Update Domain in Nginx
```bash
sudo nano /etc/nginx/sites-available/contentpilot.conf
```
Replace `api.yourdomain.com` with your actual domain name (e.g. `studio.yourdomain.com`).

Test and reload Nginx:
```bash
sudo nginx -t
sudo systemctl reload nginx
```

### Step C: Generate Free SSL Certificate
```bash
sudo certbot --nginx -d studio.yourdomain.com
```
Certbot will configure HTTPS automatic renewal.

---

## 5. Daily Maintenance & Operations

### Monitoring Services
```bash
# Check PM2 process health & memory usage
pm2 status

# Real-time application logs
pm2 logs contentpilot-api

# Check system health endpoint
curl -i http://localhost:3001/health
```

### Zero-Downtime Updates
Whenever you push updates or new code:
```bash
cd /var/www/contentpilot-ai
sudo bash scripts/update-vps.sh
```

### Automated Daily Backups
Add a cron job to take daily hot snapshots of the SQLite database and media files:
```bash
crontab -e
```
Add this line:
```cron
0 3 * * * /var/www/contentpilot-ai/scripts/backup-vps.sh >> /var/log/contentpilot-backup.log 2>&1
```
Backups will be archived under `/backups/contentpilot/` with automated 30-day retention pruning.
