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
