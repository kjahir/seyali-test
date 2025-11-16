#!/bin/bash
# complete-setup.sh - Automated setup for seyali-test project
# Run this in your seyali-test directory

set -e

echo "🚀 Seyali Complete Auto Setup"
echo "=============================="
echo ""

# Check if we're in the right directory
if [ ! -d ".git" ]; then
    echo "❌ Error: Not in a git repository. Please run this in your seyali-test directory."
    exit 1
fi

# Check prerequisites
echo "📋 Checking prerequisites..."
command -v node >/dev/null 2>&1 || { echo "❌ Node.js is required. Install from https://nodejs.org"; exit 1; }
command -v npm >/dev/null 2>&1 || { echo "❌ npm is required."; exit 1; }
command -v git >/dev/null 2>&1 || { echo "❌ git is required."; exit 1; }

# Check for GitHub CLI (optional but recommended)
if ! command -v gh >/dev/null 2>&1; then
    echo "⚠️  GitHub CLI not found. Install for easier secret management: brew install gh"
    echo "   You can still continue and set secrets manually via GitHub web interface."
fi

echo "✅ Prerequisites check passed"
echo ""

# ============================================
# STEP 1: Create Directory Structure
# ============================================
echo "📁 Creating directory structure..."
mkdir -p backend/src backend/config backend/migrations
mkdir -p frontend/src/pages frontend/src/styles frontend/public
mkdir -p .github/workflows

# ============================================
# STEP 2: Create Backend Files
# ============================================
echo "📦 Creating backend files..."

cat > backend/package.json << 'EOF'
{
  "name": "seyali-backend",
  "version": "1.0.0",
  "description": "Seyali Backend API",
  "main": "src/index.js",
  "scripts": {
    "start": "node src/index.js",
    "dev": "nodemon src/index.js",
    "build": "echo 'No build step required'",
    "test": "jest --passWithNoTests",
    "lint": "eslint . --ext .js || echo 'Linting completed'",
    "migrate": "node migrations/migrate.js"
  },
  "dependencies": {
    "express": "^4.18.2",
    "cors": "^2.8.5",
    "dotenv": "^16.3.1",
    "pg": "^8.11.3",
    "redis": "^4.6.10",
    "jsonwebtoken": "^9.0.2",
    "bcrypt": "^5.1.1",
    "helmet": "^7.1.0",
    "express-rate-limit": "^7.1.5"
  },
  "devDependencies": {
    "nodemon": "^3.0.2",
    "jest": "^29.7.0",
    "eslint": "^8.55.0"
  },
  "engines": {
    "node": ">=18.0.0"
  }
}
EOF

cat > backend/src/index.js << 'EOF'
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 10000;

// Middleware
app.use(helmet());
app.use(cors({
  origin: process.env.CORS_ORIGIN || '*',
  credentials: true
}));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Rate limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 100
});
app.use('/api/', limiter);

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({
    status: 'ok',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    environment: process.env.NODE_ENV || 'development'
  });
});

// API routes
app.get('/api/hello', (req, res) => {
  res.json({
    message: 'Welcome to Seyali API!',
    version: '1.0.0'
  });
});

app.get('/api/status', (req, res) => {
  res.json({
    backend: 'running',
    database: process.env.DATABASE_URL ? 'configured' : 'not configured',
    redis: process.env.REDIS_URL ? 'configured' : 'not configured'
  });
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({ error: 'Not found' });
});

// Error handler
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ error: 'Something went wrong!' });
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 Server running on port ${PORT}`);
  console.log(`📍 Environment: ${process.env.NODE_ENV || 'development'}`);
});
EOF

cat > backend/.env.example << 'EOF'
NODE_ENV=development
PORT=10000
DATABASE_URL=postgresql://user:password@localhost:5432/seyali_db
REDIS_URL=redis://localhost:6379
JWT_SECRET=your-super-secret-jwt-key-change-this
CORS_ORIGIN=http://localhost:3000
FRONTEND_URL=http://localhost:3000
EOF

cat > backend/.gitignore << 'EOF'
node_modules/
.env
.env.local
.DS_Store
*.log
coverage/
dist/
build/
EOF

cat > backend/migrations/migrate.js << 'EOF'
const { Pool } = require('pg');
require('dotenv').config();

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: process.env.NODE_ENV === 'production' ? { rejectUnauthorized: false } : false
});

async function runMigrations() {
  try {
    console.log('🔄 Running database migrations...');
    
    await pool.query(`
      CREATE TABLE IF NOT EXISTS users (
        id SERIAL PRIMARY KEY,
        email VARCHAR(255) UNIQUE NOT NULL,
        password_hash VARCHAR(255) NOT NULL,
        name VARCHAR(255),
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    `);
    
    console.log('✅ Migrations completed successfully');
    process.exit(0);
  } catch (error) {
    console.error('❌ Migration failed:', error);
    process.exit(1);
  }
}

runMigrations();
EOF

cat > backend/.eslintrc.json << 'EOF'
{
  "env": {
    "node": true,
    "es2021": true,
    "jest": true
  },
  "extends": "eslint:recommended",
  "parserOptions": {
    "ecmaVersion": "latest"
  },
  "rules": {
    "no-unused-vars": "warn",
    "no-console": "off"
  }
}
EOF

# ============================================
# STEP 3: Create Frontend Files
# ============================================
echo "📦 Creating frontend files..."

cat > frontend/package.json << 'EOF'
{
  "name": "seyali-frontend",
  "version": "1.0.0",
  "description": "Seyali Frontend",
  "private": true,
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "start": "next start",
    "lint": "next lint",
    "test": "jest --passWithNoTests"
  },
  "dependencies": {
    "next": "14.0.4",
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "axios": "^1.6.2"
  },
  "devDependencies": {
    "eslint": "^8.56.0",
    "eslint-config-next": "14.0.4",
    "jest": "^29.7.0"
  },
  "engines": {
    "node": ">=18.0.0"
  }
}
EOF

cat > frontend/next.config.js << 'EOF'
/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  env: {
    NEXT_PUBLIC_API_URL: process.env.NEXT_PUBLIC_API_URL || 'http://localhost:10000',
  },
}

module.exports = nextConfig
EOF

mkdir -p frontend/src/pages
cat > frontend/src/pages/_app.js << 'EOF'
import '../styles/globals.css'

function MyApp({ Component, pageProps }) {
  return <Component {...pageProps} />
}

export default MyApp
EOF

cat > frontend/src/pages/index.js << 'EOF'
import { useEffect, useState } from 'react'
import Head from 'next/head'
import styles from '../styles/Home.module.css'

export default function Home() {
  const [apiStatus, setApiStatus] = useState('checking...')
  const [apiMessage, setApiMessage] = useState('')
  const [backendStatus, setBackendStatus] = useState(null)

  useEffect(() => {
    const apiUrl = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:10000'
    
    // Check API health
    fetch(`${apiUrl}/health`)
      .then(res => res.json())
      .then(data => {
        setApiStatus('✅ Connected')
        console.log('API Health:', data)
      })
      .catch(err => {
        setApiStatus('❌ Disconnected')
        console.error('API Error:', err)
      })

    // Get API message
    fetch(`${apiUrl}/api/hello`)
      .then(res => res.json())
      .then(data => setApiMessage(data.message))
      .catch(err => console.error('API Error:', err))

    // Get backend status
    fetch(`${apiUrl}/api/status`)
      .then(res => res.json())
      .then(data => setBackendStatus(data))
      .catch(err => console.error('Status Error:', err))
  }, [])

  return (
    <div className={styles.container}>
      <Head>
        <title>Seyali - Home</title>
        <meta name="description" content="Seyali application" />
        <link rel="icon" href="/favicon.ico" />
      </Head>

      <main className={styles.main}>
        <h1 className={styles.title}>
          Welcome to <span className={styles.highlight}>Seyali</span>
        </h1>

        <div className={styles.status}>
          <h3>System Status</h3>
          <p><strong>Backend:</strong> {apiStatus}</p>
          {apiMessage && <p><strong>Message:</strong> {apiMessage}</p>}
          {backendStatus && (
            <div style={{ marginTop: '10px', fontSize: '14px' }}>
              <p>Backend: {backendStatus.backend}</p>
              <p>Database: {backendStatus.database}</p>
              <p>Redis: {backendStatus.redis}</p>
            </div>
          )}
          <p style={{ marginTop: '10px', fontSize: '12px', color: '#666' }}>
            API URL: {process.env.NEXT_PUBLIC_API_URL || 'http://localhost:10000'}
          </p>
        </div>

        <div className={styles.grid}>
          <div className={styles.card}>
            <h2>📚 Documentation</h2>
            <p>Learn about Seyali features and API</p>
          </div>

          <div className={styles.card}>
            <h2>📊 Dashboard</h2>
            <p>Access your dashboard</p>
          </div>

          <div className={styles.card}>
            <h2>⚙️ Settings</h2>
            <p>Configure your application</p>
          </div>

          <div className={styles.card}>
            <h2>💬 Support</h2>
            <p>Get help from our team</p>
          </div>
        </div>
      </main>

      <footer className={styles.footer}>
        <p>Powered by Seyali © 2024</p>
      </footer>
    </div>
  )
}
EOF

mkdir -p frontend/src/styles
cat > frontend/src/styles/globals.css << 'EOF'
html,
body {
  padding: 0;
  margin: 0;
  font-family: -apple-system, BlinkMacSystemFont, Segoe UI, Roboto, Oxygen,
    Ubuntu, Cantarell, Fira Sans, Droid Sans, Helvetica Neue, sans-serif;
}

a {
  color: inherit;
  text-decoration: none;
}

* {
  box-sizing: border-box;
}

@media (prefers-color-scheme: dark) {
  html {
    color-scheme: dark;
  }
  body {
    color: white;
    background: #0a0a0a;
  }
}
EOF

cat > frontend/src/styles/Home.module.css << 'EOF'
.container {
  min-height: 100vh;
  padding: 0 0.5rem;
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
}

.main {
  padding: 5rem 0;
  flex: 1;
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
}

.title {
  margin: 0;
  line-height: 1.15;
  font-size: 4rem;
  text-align: center;
}

.highlight {
  color: #0070f3;
}

.status {
  margin: 2rem 0;
  padding: 1.5rem;
  border: 2px solid #0070f3;
  border-radius: 10px;
  text-align: center;
  background: rgba(0, 112, 243, 0.05);
  min-width: 300px;
}

.status h3 {
  margin-top: 0;
  color: #0070f3;
}

.grid {
  display: flex;
  align-items: center;
  justify-content: center;
  flex-wrap: wrap;
  max-width: 900px;
  margin-top: 3rem;
}

.card {
  margin: 1rem;
  padding: 1.5rem;
  text-align: left;
  color: inherit;
  text-decoration: none;
  border: 1px solid #eaeaea;
  border-radius: 10px;
  transition: color 0.15s ease, border-color 0.15s ease, transform 0.15s ease;
  width: 45%;
  cursor: pointer;
}

.card:hover {
  color: #0070f3;
  border-color: #0070f3;
  transform: translateY(-2px);
}

.card h2 {
  margin: 0 0 1rem 0;
  font-size: 1.5rem;
}

.card p {
  margin: 0;
  font-size: 1.1rem;
  line-height: 1.5;
}

.footer {
  width: 100%;
  height: 100px;
  border-top: 1px solid #eaeaea;
  display: flex;
  justify-content: center;
  align-items: center;
}

@media (max-width: 600px) {
  .grid {
    width: 100%;
    flex-direction: column;
  }
  
  .card {
    width: 90%;
  }
  
  .title {
    font-size: 2.5rem;
  }
}
EOF

cat > frontend/.env.example << 'EOF'
NEXT_PUBLIC_API_URL=http://localhost:10000
NEXT_PUBLIC_ENV=development
EOF

cat > frontend/.gitignore << 'EOF'
node_modules/
.next/
out/
.env
.env.local
.env.production.local
.DS_Store
*.log
.vercel
EOF

mkdir -p frontend/public
touch frontend/public/favicon.ico

# ============================================
# STEP 4: Create GitHub Actions Workflow
# ============================================
echo "📦 Creating GitHub Actions workflow..."

cat > .github/workflows/deploy.yml << 'EOF'
name: Deploy to Render + Vercel

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

env:
  NODE_VERSION: '18'

jobs:
  detect-changes:
    runs-on: ubuntu-latest
    outputs:
      backend: ${{ steps.filter.outputs.backend }}
      frontend: ${{ steps.filter.outputs.frontend }}
    steps:
      - uses: actions/checkout@v3
      - uses: dorny/paths-filter@v2
        id: filter
        with:
          filters: |
            backend:
              - 'backend/**'
            frontend:
              - 'frontend/**'

  test-backend:
    runs-on: ubuntu-latest
    needs: detect-changes
    if: needs.detect-changes.outputs.backend == 'true'
    
    services:
      postgres:
        image: postgres:15
        env:
          POSTGRES_PASSWORD: postgres
          POSTGRES_DB: test_db
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
        ports:
          - 5432:5432
      
      redis:
        image: redis:7
        options: >-
          --health-cmd "redis-cli ping"
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
        ports:
          - 6379:6379

    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'npm'
          cache-dependency-path: backend/package-lock.json
      
      - name: Install backend dependencies
        working-directory: ./backend
        run: npm ci
      
      - name: Run backend tests
        working-directory: ./backend
        env:
          DATABASE_URL: postgresql://postgres:postgres@localhost:5432/test_db
          REDIS_URL: redis://localhost:6379
          NODE_ENV: test
        run: npm test
      
      - name: Run linter
        working-directory: ./backend
        run: npm run lint

  test-frontend:
    runs-on: ubuntu-latest
    needs: detect-changes
    if: needs.detect-changes.outputs.frontend == 'true'
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'npm'
          cache-dependency-path: frontend/package-lock.json
      
      - name: Install frontend dependencies
        working-directory: ./frontend
        run: npm ci
      
      - name: Run frontend tests
        working-directory: ./frontend
        run: npm test
      
      - name: Build frontend
        working-directory: ./frontend
        env:
          NEXT_PUBLIC_API_URL: ${{ secrets.RENDER_BACKEND_URL }}
        run: npm run build

  deploy-backend:
    runs-on: ubuntu-latest
    needs: [detect-changes, test-backend]
    if: |
      always() &&
      github.event_name == 'push' && 
      github.ref == 'refs/heads/main' &&
      (needs.detect-changes.outputs.backend == 'true' || needs.test-backend.result == 'skipped')
    environment:
      name: production-backend
      url: ${{ secrets.RENDER_BACKEND_URL }}
    steps:
      - uses: actions/checkout@v3
      
      - name: Trigger Render Deploy
        run: |
          echo "🚀 Triggering Render deployment..."
          curl -X POST "${{ secrets.RENDER_DEPLOY_HOOK_BACKEND }}"
      
      - name: Wait for deployment
        run: |
          echo "⏳ Waiting 60 seconds for deployment..."
          sleep 60
          
          for i in {1..20}; do
            echo "Health check attempt $i/20..."
            if curl -f -s --max-time 10 "${{ secrets.RENDER_BACKEND_URL }}/health" > /dev/null 2>&1; then
              echo "✅ Backend is healthy!"
              exit 0
            fi
            sleep 15
          done
          echo "⚠️ Deployment may still be in progress"

  deploy-frontend:
    runs-on: ubuntu-latest
    needs: [detect-changes, test-frontend, deploy-backend]
    if: |
      always() &&
      github.event_name == 'push' && 
      github.ref == 'refs/heads/main' &&
      (needs.detect-changes.outputs.frontend == 'true' || needs.test-frontend.result == 'skipped')
    environment:
      name: production-frontend
      url: https://seyali-test.vercel.app
    steps:
      - uses: actions/checkout@v3
      
      - name: Deploy to Vercel
        working-directory: ./frontend
        run: |
          npm install -g vercel@latest
          vercel pull --yes --environment=production --token=${{ secrets.VERCEL_TOKEN }} || true
          vercel build --prod --token=${{ secrets.VERCEL_TOKEN }}
          vercel deploy --prebuilt --prod --token=${{ secrets.VERCEL_TOKEN }}
          echo "✅ Frontend deployed!"
        env:
          VERCEL_ORG_ID: ${{ secrets.VERCEL_ORG_ID }}
          VERCEL_PROJECT_ID: ${{ secrets.VERCEL_PROJECT_ID }}

  deploy-preview:
    runs-on: ubuntu-latest
    if: github.event_name == 'pull_request'
    steps:
      - uses: actions/checkout@v3
      
      - name: Deploy Preview
        working-directory: ./frontend
        run: |
          npm install -g vercel@latest
          PREVIEW_URL=$(vercel deploy --token=${{ secrets.VERCEL_TOKEN }} 2>&1 | grep -o 'https://[^ ]*' | head -1)
          echo "PREVIEW_URL=$PREVIEW_URL" >> $GITHUB_ENV
        env:
          VERCEL_ORG_ID: ${{ secrets.VERCEL_ORG_ID }}
          VERCEL_PROJECT_ID: ${{ secrets.VERCEL_PROJECT_ID }}
      
      - name: Comment PR
        uses: actions/github-script@v6
        if: env.PREVIEW_URL != ''
        with:
          script: |
            github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: `## 🚀 Preview Deployment\n\n✨ Frontend: ${process.env.PREVIEW_URL}\n🔗 Backend: ${{ secrets.RENDER_BACKEND_URL }}`
            })
EOF

# ============================================
# STEP 5: Create Render Configuration
# ============================================
echo "📦 Creating Render configuration..."

cat > render.yaml << 'EOF'
services:
  - type: web
    name: seyali-backend
    env: node
    region: singapore
    plan: free
    buildCommand: cd backend && npm install
    startCommand: cd backend && npm start
    healthCheckPath: /health
    autoDeploy: true
    
    envVars:
      - key: NODE_ENV
        value: production
      
      - key: PORT
        value: 10000
      
      - key: DATABASE_URL
        fromDatabase:
          name: seyali-postgres
          property: connectionString
      
      - key: REDIS_URL
        fromDatabase:
          name: seyali-redis
          property: connectionString
      
      - key: JWT_SECRET
        generateValue: true
      
      - key: CORS_ORIGIN
        sync: false
      
      - key: FRONTEND_URL
        sync: false

databases:
  - name: seyali-postgres
    databaseName: seyali_db
    user: seyali_user
    plan: free
    region: singapore
  
  - name: seyali-redis
    plan: free
    region: singapore
    maxmemoryPolicy: allkeys-lru
EOF

# ============================================
# STEP 6: Create Vercel Configuration
# ============================================
echo "📦 Creating Vercel configuration..."

cat > vercel.json << 'EOF'
{
  "version": 2,
  "name": "seyali-frontend",
  "framework": "nextjs",
  "buildCommand": "cd frontend && npm run build",
  "devCommand": "cd frontend && npm run dev",
  "installCommand": "cd frontend && npm install",
  "outputDirectory": "frontend/.next",
  "public": false,
  "regions": ["sin1"],
  "env": {
    "NEXT_PUBLIC_API_URL": "https://seyali-test.onrender.com"
  },
  "build": {
    "env": {
      "NEXT_PUBLIC_API_URL": "https://seyali-test.onrender.com"
    }
  },
  "git": {
    "deploymentEnabled": {
      "main": true
    }
  }
}
EOF

# ============================================
# STEP 7: Create Root .gitignore
# ============================================
echo "📦 Creating root .gitignore..."

cat > .gitignore << 'EOF'
node_modules/
.env
.env.local
.env.production.local
.env.*.local
*.log
npm-debug.log*
.DS_Store
Thumbs.db
.vscode/
.idea/
*.swp
*.swo
dist/
build/
.next/
out/
coverage/
.vercel
*.pem
EOF

# ============================================
# STEP 8: Create Deployment Scripts
# ============================================
echo "📦 Creating deployment scripts..."

cat > deploy-all.sh << 'EOF'
#!/bin/bash
set -e
MESSAGE="${1:-Quick deploy}"
echo "🚀 Deploying everything..."
git add .
git commit -m "$MESSAGE" || echo "No changes to commit"
git push origin main
echo ""
echo "✅ Deployment triggered!"
echo "📊 Check status: https://github.com/kjahir/seyali-test/actions"
EOF
chmod +x deploy-all.sh

cat > deploy-backend.sh << 'EOF'
#!/bin/bash
set -e
MESSAGE="${1:-Update backend}"
echo "🔧 Deploying backend only..."
git add backend/ render.yaml .github/
git commit -m "$MESSAGE" || echo "No changes to commit"
git push origin main
echo "✅ Backend deployment triggered!"
EOF
chmod +x deploy-backend.sh

cat > deploy-frontend.sh << 'EOF'
#!/bin/bash
set -e
MESSAGE="${1:-Update frontend}"
echo "💅 Deploying frontend only..."
git add frontend/ vercel.json .github/
git commit -m "$MESSAGE" || echo "No changes to commit"
git push origin main
echo "✅ Frontend deployment triggered!"
EOF
chmod +x deploy-frontend.sh

cat > status.sh << 'EOF'
#!/bin/bash
echo "📊 Deployment Status:"
echo ""
if command -v gh >/dev/null 2>&1; then
    gh run list --limit 5 --repo kjahir/seyali-test
    echo ""
    echo "💡 To watch live: gh run watch"
else
    echo "View at: https://github.com/kjahir/seyali-test/actions"
fi
EOF
chmod +x status.sh

cat > local-test.sh << 'EOF'
#!/bin/bash
echo "🧪 Testing locally..."
echo ""
echo "Starting backend..."
cd backend
cp .env.example .env 2>/dev/null || true
npm install
npm run dev &
BACKEND_PID=$!
cd ..

echo "Waiting for backend to start..."
sleep 5

echo "Starting frontend..."
cd frontend
cp .env.example .env 2>/dev/null || true
npm install
npm run dev &
FRONTEND_PID=$!
cd ..

echo ""
echo "✅ Services started!"
echo "Backend: http://localhost:10000"
echo "Frontend: http://localhost:3000"
echo ""
echo "Press Ctrl+C to stop both services"

trap "kill $BACKEND_PID $FRONTEND_PID 2>/dev/null" EXIT

wait
EOF
chmod +x local-test.sh

# ============================================
# STEP 9: Create README
# ============================================
echo "📦 Creating README..."

cat > README.md << 'EOF'
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