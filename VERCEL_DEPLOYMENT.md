# Deploying ContentPilot AI to Vercel

This guide explains how to deploy **ContentPilot AI** to [Vercel](https://vercel.com).

---

## 1. Architecture Overview for Vercel

ContentPilot AI consists of two components:
1. **Frontend Studio (`client/`)**: A fast React + Vite Single Page Application (SPA). This is **100% compatible with Vercel** and can be deployed with zero extra setup. It includes a standalone **Interactive Demo Mode** (with full UI navigation, review workflows, safety gates, and analytics) so it works out of the box even before your backend is deployed.
2. **Backend Engine (`backend/`)**: Node.js + Express API + SQLite database + FFmpeg video rendering engine + persistent background workers.
   - *Note on Serverless*: Vercel is designed for static assets and ephemeral serverless functions. Because video rendering with FFmpeg, background task loops, and local SQLite files require persistent compute and storage, the **backend should be hosted on a persistent server/VPS** (Render, Railway, Fly.io, or VPS with Docker/PM2).
   - Once your backend is deployed, simply set `VITE_API_URL` in Vercel to connect the frontend to your backend!

---

## 2. Method 1: Deploy via Vercel Web Dashboard (Recommended)

### Step 1: Push Project to GitHub / GitLab / Bitbucket
Ensure your project repository is uploaded to your Git provider.

### Step 2: Import into Vercel
1. Log into your account at [vercel.com](https://vercel.com).
2. Click **Add New...** > **Project**.
3. Import your repository.

### Step 3: Configure Project Settings
The repository already includes a pre-configured `vercel.json` at the root.

- **Option A (Monorepo Root - Default)**:
  - **Framework Preset**: Other
  - **Root Directory**: `./` (leave default)
  - Vercel will automatically read the root `vercel.json`:
    - Build Command: `npm run build --workspace=client`
    - Output Directory: `client/dist`

- **Option B (Root Directory set to Client)**:
  - If you prefer, set **Root Directory** to `client` in the Vercel dashboard.
  - **Framework Preset**: Vite
  - Build Command: `npm run build`
  - Output Directory: `dist`

### Step 4: Configure Environment Variables (Optional)
In Vercel's **Environment Variables** section:
- If you have deployed the backend:
  - Set `VITE_API_URL` to your backend URL (e.g., `https://api.yourdomain.com`).
- If you have NOT deployed the backend yet:
  - Leave `VITE_API_URL` empty. ContentPilot AI will automatically run in **Interactive Demo Mode** allowing you to preview the entire dashboard.

### Step 5: Click Deploy
Click **Deploy**. Vercel will build the frontend and provide you with a live `https://*.vercel.app` URL.

---

## 3. Method 2: Deploy via Vercel CLI

You can deploy directly from your local terminal using the Vercel CLI:

### Step 1: Log in to Vercel
Run in your terminal:
```bash
npx vercel login
```
Follow the browser prompt to authenticate.

### Step 2: Deploy to Preview
Run from the project root:
```bash
npx vercel
```
Accept the prompts:
- Link to existing project? **No**
- What's your project's name? **contentpilot-ai** (or press Enter)
- In which directory is your code located? **./** (press Enter)
- Want to modify these settings? **No** (the settings from `vercel.json` are automatically detected)

### Step 3: Deploy to Production
To promote your deployment to production:
```bash
npx vercel --prod
```

---

## 4. Connecting Vercel Frontend to Production Backend

When you host your backend on a VPS or cloud container (Render, Railway, Fly.io, etc.):

1. **Update Backend CORS**:
   Add your Vercel URL to your backend `.env`:
   ```env
   CORS_ORIGIN=https://your-project.vercel.app,http://localhost:5173
   ```
2. **Update Vercel Environment Variables**:
   In your Vercel Project Dashboard (`Settings` > `Environment Variables`):
   - Key: `VITE_API_URL`
   - Value: `https://your-backend-api.com`
3. **Redeploy**:
   Trigger a redeploy in Vercel to apply the updated environment variable.
