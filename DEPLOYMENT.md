# ContentPilot AI — Production Deployment Guide

## 1. Production Architecture Overview

In production, ContentPilot AI runs as:
1. **Node.js Express API Server**: Manages REST API endpoints, security gates, and OAuth callbacks.
2. **Persistent Job Worker Daemon**: Consumes and processes background tasks from SQLite job queue.
3. **Cron Scheduler Loop**: Wakes periodically to evaluate `scheduled_tasks` and release windows.
4. **Static Single Page Application (SPA)**: Built with Vite and served via Nginx, Express, or **Vercel** (see [VERCEL_DEPLOYMENT.md](VERCEL_DEPLOYMENT.md)).

---

## 2. Production Environment Checks

Before starting the server in `NODE_ENV=production`:
1. Ensure `APP_SECRET_KEY` is a minimum 32-character high-entropy secret.
2. Confirm `AUTO_PUBLISH=false` and `REQUIRE_HUMAN_APPROVAL=true` remain active.
3. Validate that `STORAGE_DIR` is on a persistent volume with write permissions.
4. Verify FFmpeg and FFprobe binaries are accessible.

---

## 3. Building for Production

```bash
# 1. Build Backend
cd backend
npm run build
# Outputs compiled JS to backend/dist/

# 2. Build Frontend Dashboard
cd ../client
npm run build
# Outputs production bundle to client/dist/
```

---

## 4. Process Management with PM2

Install PM2 globally:
```bash
npm install -g pm2
```

Create `ecosystem.config.cjs`:
```javascript
module.exports = {
  apps: [
    {
      name: 'contentpilot-backend',
      cwd: './backend',
      script: './dist/index.js',
      instances: 1, // Single instance recommended for SQLite WAL coordination
      autorestart: true,
      watch: false,
      max_memory_restart: '1G',
      env: {
        NODE_ENV: 'production',
        PORT: 3001,
      },
    },
  ],
};
```

Start the service:
```bash
pm2 start ecosystem.config.cjs
pm2 save
pm2 startup
```

---

## 5. Nginx Reverse Proxy Configuration

Sample Nginx configuration for SSL termination and static asset serving:

```nginx
server {
    listen 80;
    server_name studio.yourdomain.com;
    return 301 https://$host$request_uri;
}

server {
    listen 443 ssl http2;
    server_name studio.yourdomain.com;

    ssl_certificate /etc/letsencrypt/live/studio.yourdomain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/studio.yourdomain.com/privkey.pem;

    client_max_body_size 500M;

    # Frontend SPA
    location / {
        root /var/www/contentpilot/client/dist;
        try_files $uri $uri/ /index.html;
    }

    # Backend API
    location /api/ {
        proxy_pass http://127.0.0.1:3001;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # Health Check
    location /health {
        proxy_pass http://127.0.0.1:3001;
    }
}
```

---

## 6. Storage & Database Backups

Schedule automated daily backups of the SQLite database and rendered media:

```bash
#!/bin/bash
BACKUP_DIR="/backups/contentpilot/$(date +%Y-%m-%d)"
mkdir -p "$BACKUP_DIR"

# 1. Hot SQLite Backup
sqlite3 /var/www/contentpilot/backend/prisma/dev.db ".backup '$BACKUP_DIR/contentpilot.db'"

# 2. Archive Media Assets (Keep 30 days)
rsync -avz /var/www/contentpilot/backend/storage/ "$BACKUP_DIR/storage/"

# 3. Prune backups older than 30 days
find /backups/contentpilot/* -maxdepth 0 -type d -mtime +30 -exec rm -rf {} +
```
