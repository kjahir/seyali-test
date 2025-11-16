# Seyali Test Project

Full-stack application with automated CI/CD deployment.

## 🏗️ Stack

- **Frontend**: Next.js → Vercel
- **Backend**: Express.js → Render
- **Database**: PostgreSQL → Render
- **Cache**: Redis → Render
- **CI/CD**: GitHub Actions

## 🚀 Quick Start

### Local Development

```bash
# Test locally (installs dependencies and starts both services)
./local-test.sh

# Or manually:
cd backend && npm install && npm run dev
cd frontend && npm install && npm run dev
```

Visit:
- Frontend: http://localhost:3000
- Backend: http://localhost:10000
- Health: http://localhost:10000/health

### Deploy to Production

```bash
# Deploy everything
./deploy-all.sh "Your commit message"

# Deploy backend only
./deploy-backend.sh "Backend changes"

# Deploy frontend only
./deploy-frontend.sh "Frontend changes"

# Check deployment status
./status.sh
```

## 🔧 Setup (One-Time Configuration)

### 1. Setup Render

1. Go to https://dashboard.render.com
2. Click "New" → "Blueprint"
3. Connect your GitHub account
4. Select `kjahir/seyali-test` repository
5. Render will automatically detect `render.yaml` and create:
   - Backend web service
   - PostgreSQL database
   - Redis instance

### 2. Get Render Deploy Hook

1. Go to Render Dashboard
2. Click on "seyali-backend" service
3. Go to Settings → Deploy Hook
4. Click "Create Deploy Hook"
5. Copy the webhook URL

### 3. Setup Vercel

1. Go to https://vercel.com/new
2. Import `kjahir/seyali-test`
3. Configure:
   - Framework Preset: Next.js
   - Root Directory: `frontend`
   - Build Command: `npm run build`
   - Output Directory: `.next`
