# ContentPilot AI 🚀

Enterprise-grade autonomous YouTube operations platform powered by multi-agent orchestration, strict human governance, deterministic media rendering, and closed-loop algorithmic learning.

---

## 1. What It Is

**ContentPilot AI** is an end-to-end autonomous content operations engine and review dashboard for YouTube channels. It orchestrates a 20-stage pipeline: market research, competitive analysis, strategic ideation, script synthesis, thumbnail concept generation, voice narration, rendering, audio loudness normalization (EBU R128), state-machine safety checks, mandatory human editorial review, and scheduled YouTube Data API v3 publishing.

---

## 2. Features

- **Autonomous Multi-Agent Pipeline**: Research, Strategy, Scripting, SEO, Thumbnails, Video Assembly, and Quality Control.
- **Mandatory Human Editorial Gate**: AI cannot publish content autonomously. Every project halts at the Human Approval Gate until explicitly signed off in Review Studio.
- **Zero-Config Demo Mode**: Start, browse, test, and deploy without entering any API keys or credentials.
- **Resilient Fallback Provider Architecture**: Seamlessly switches between live Google Gemini API and offline deterministic demo data.
- **YouTube OAuth 2.0 Integration**: Real Google Cloud OAuth 2.0 connectivity with resumable video uploading, playlist selection, and scheduled release.
- **Real-Time Pipeline Telemetry**: Live status updates across jobs, render progress, and background worker queues.
- **Closed-Loop Learning Agent**: Ingests lifetime performance snapshots to iteratively refine title hooks and content retention strategies.
- **A/B Experimentation Engine**: Systematic split-testing for titles, thumbnails, and publishing schedules.
- **Auto-Fix Self-Healing**: Automated recovery from transient quota limits, LLM output anomalies, and audio loudness drifts.
- **19 Dedicated Operations Consoles**: Complete management across research, scripts, production, review, distribution, analytics, scheduler, and system health.

---

## 3. Project Structure

```
contentpilot-ai/
├── client/                     # Frontend Single Page Application (React 18, Vite, TypeScript)
│   ├── src/
│   │   ├── components/         # Header, Sidebar, VideoPlayer, EmptyState
│   │   ├── pages/              # 19 Operations Consoles (Overview, Review, Scripts, etc.)
│   │   ├── services/           # API Client with seamless offline Demo Mode fallback
│   │   └── types/              # TypeScript models and domain definitions
│   ├── package.json
│   ├── vercel.json             # Vercel SPA rewrite configuration (prevents 404s)
│   └── vite.config.ts          # Vite build & local dev proxy configuration
├── backend/                    # Backend API & Pipeline Runtime (Node.js, Express, TypeScript)
│   ├── src/
│   │   ├── api/                # 19 Modular REST API routes
│   │   ├── config/             # Zod environment schema & validation
│   │   ├── core/               # Pipeline state machine & state types
│   │   ├── database/           # Prisma SQLite client & WAL pragma configuration
│   │   ├── jobs/               # Background persistent queue & worker manager
│   │   ├── services/           # AI providers, YouTube OAuth, scheduler, auto-fix engine
│   │   └── worker.ts           # Standalone worker runtime
│   ├── prisma/
│   │   └── schema.prisma       # Prisma SQLite database schema
│   ├── tests/                  # Vitest unit and end-to-end integration test suites
│   ├── package.json
│   └── tsconfig.json
├── package.json                # Root npm workspaces configuration
├── vercel.json                 # Root Vercel deployment configuration
├── .gitignore                  # GitHub exclusion rules (secrets, databases, media cache)
├── .env.example                # Safe environment variable names template
└── README.md                   # Project documentation
```

---

## 4. Local Development

### Prerequisites
- Node.js v20.x or v22.x LTS
- npm v10+

### Installation & First Run
```bash
# 1. Install all dependencies across workspaces
npm install

# 2. Run backend and frontend concurrently
npm run dev:all
```

- **Frontend UI**: `http://localhost:5173`
- **Backend API**: `http://localhost:3001`
- **Health Check**: `http://localhost:3001/health`

---

## 5. Zero-Config Demo Mode

> **Demo mode requires no API keys.**

You can install, build, run, and explore the entire platform without configuring any credentials.

- If `GEMINI_API_KEY` is not provided: The application automatically activates the **Local Demo Provider**, generating deterministic, realistic sample artifacts clearly labeled `[Demo / Local]`.
- If `YOUTUBE_CLIENT_ID` and `YOUTUBE_CLIENT_SECRET` are not provided: The application clearly displays `"YouTube connection is not configured yet."` and safely disables upload triggers without crashing or fabricating fake upload successes.
- If the backend is not running: The frontend automatically activates client-side offline demo mode with sample data for all 19 consoles, displaying a non-blocking `"Backend not connected — Demo Mode"` badge in the header.

---

## 6. GitHub Upload

To push the project to a new GitHub repository:

```bash
# Initialize git repository (if not already initialized)
git init

# Add all files (respecting .gitignore rules)
git add .

# Verify that no .env, credentials, or build artifacts are staged
git status

# Commit
git commit -m "feat: initial commit ContentPilot AI"

# Push to your GitHub repository
git remote add origin https://github.com/<your-username>/contentpilot-ai.git
git branch -M main
git push -u origin main
```

---

## 7. Vercel Deployment

Deploy the frontend dashboard to Vercel in seconds with zero configuration required.

### Option A: Via Vercel Web Dashboard (Recommended)
1. Import your GitHub repository into Vercel.
2. In the deployment settings:
   - **Framework Preset**: Vite
   - **Root Directory**: `client` (or leave as root; both root and client include `vercel.json`)
   - **Build Command**: `npm run build`
   - **Output Directory**: `dist` (or `client/dist` if root)
3. Deploy!
4. Direct navigation to client-side routes (e.g. `/`, `/dashboard`, `/operator`, `/research`, `/ideas`, `/scripts`, `/analytics`, `/settings`) is handled by `vercel.json` rewrites and will **never return a 404 NOT_FOUND error**.

### Option B: Via Vercel CLI
```bash
cd client
npx vercel
```

---

## 8. Backend Deployment

The backend can be hosted on any persistent server (VPS, Railway, Render, Fly.io, or Hostinger Cloud).

### Deploying on a Persistent Server (Ubuntu / Debian VPS)
```bash
# 1. Clone your repository
git clone https://github.com/<your-username>/contentpilot-ai.git
cd contentpilot-ai

# 2. Install dependencies
npm install

# 3. Synchronize database schema
npx prisma db push --schema=./backend/prisma/schema.prisma

# 4. Build backend
npm run build:backend

# 5. Start with PM2
pm2 start backend/dist/index.js --name "contentpilot-backend"
```

### Connecting Frontend to Backend
Set `VITE_API_URL` in your Vercel project environment settings:
```
VITE_API_URL=https://api.yourdomain.com
```

---

## 9. Optional Gemini Configuration

> **Real Gemini and YouTube functionality requires the corresponding credentials.**

To enable live multimodal AI generation (dynamic research, script synthesis, and thumbnail prompts via Google Gemini):

1. Obtain a free or paid API key at [Google AI Studio](https://aistudio.google.com/).
2. Add the key to your backend `.env` file:
   ```env
   GEMINI_API_KEY=your_actual_gemini_api_key
   GEMINI_MODEL=gemini-2.5-flash
   ```
3. Restart the backend. The platform will automatically switch from the Local Demo Provider to the live Google Gemini Provider.

---

## 10. Optional YouTube Configuration

To enable live YouTube OAuth 2.0 authentication and automated channel video uploads:

1. Create a project in [Google Cloud Console](https://console.cloud.google.com/).
2. Enable the **YouTube Data API v3**.
3. Create **OAuth 2.0 Client IDs** (Web application):
   - **Authorized redirect URI**: `https://api.yourdomain.com/api/auth/youtube/callback` (or `http://localhost:3001/api/auth/youtube/callback` for local development).
4. Add credentials to your backend `.env` file:
   ```env
   YOUTUBE_CLIENT_ID=your_oauth_client_id.apps.googleusercontent.com
   YOUTUBE_CLIENT_SECRET=your_oauth_client_secret
   YOUTUBE_REDIRECT_URI=https://api.yourdomain.com/api/auth/youtube/callback
   ```
5. In the dashboard, navigate to **YouTube Channel** and click **Connect YouTube OAuth**.

---

## 11. Environment Variables

Reference template available in `.env.example`:

| Variable | Required For | Description | Default |
| :--- | :--- | :--- | :--- |
| `NODE_ENV` | Optional | Runtime environment (`development` / `production`) | `development` |
| `PORT` | Optional | API server port | `3001` |
| `CORS_ORIGIN` | Optional | Allowed frontend origins (comma-separated) | `http://localhost:5173` |
| `DATABASE_URL` | Optional | SQLite connection string | `file:./dev.db` |
| `AUTO_PUBLISH` | Optional | Publishing safety toggle (`true` / `false`) | `false` |
| `REQUIRE_HUMAN_APPROVAL` | Optional | Human approval gate enforcement | `true` |
| `GEMINI_API_KEY` | Real AI Mode | Google Gemini API key (Leave empty for Demo Mode) | None |
| `YOUTUBE_CLIENT_ID` | Real YouTube Mode | Google Cloud OAuth Client ID | None |
| `YOUTUBE_CLIENT_SECRET` | Real YouTube Mode | Google Cloud OAuth Client Secret | None |
| `YOUTUBE_REDIRECT_URI` | Real YouTube Mode | Authorized OAuth callback redirect URL | `http://localhost:3001/api/auth/youtube/callback` |
| `VITE_API_URL` | Frontend | Backend API endpoint for production | None (Relative / Demo Fallback) |

---

## 12. Security

- **Zero Secret Exposure**: Server credentials (`GEMINI_API_KEY`, `YOUTUBE_CLIENT_SECRET`) never leave the backend environment.
- **Frontend Bundle Cleanliness**: No private keys or OAuth secrets are compiled into the client distribution.
- **Encrypted Token Storage**: YouTube OAuth refresh tokens are encrypted at rest using AES-256-GCM.
- **Non-Bypassable Governance**: Pre-upload safety guards enforce `status === 'APPROVED'` and QC verification before any network request to YouTube is dispatched.
- **Strict CORS Policy**: Whitelists only explicitly configured frontend domains.

---

## 13. Production Requirements

For full video rendering in a production Linux VPS environment:
- **FFmpeg & FFprobe**: Required on the backend host for compiling MP4 video streams and normalizing audio loudness.
  ```bash
  sudo apt-get update && sudo apt-get install -y ffmpeg
  ```
- **Persistent Disk Volume**: Ensure the `storage/` directory and SQLite database file are mounted on persistent storage.

---

## 📄 License

MIT License. Designed and built for autonomous, governed YouTube production.
