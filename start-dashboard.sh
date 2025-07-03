#!/bin/bash

echo "🚀 Starting Hotel Automation V2 Enhanced Dashboard..."
echo ""

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "❌ Node.js is not installed. Please install Node.js first."
    exit 1
fi

# Check if npm is installed
if ! command -v npm &> /dev/null; then
    echo "❌ npm is not installed. Please install npm first."
    exit 1
fi

# Install dependencies if needed
if [ ! -d "node_modules" ]; then
    echo "📦 Installing dependencies..."
    npm install
    echo ""
fi

# Check if WebSocket dependency is installed
if ! npm list ws &> /dev/null; then
    echo "📡 Installing WebSocket dependency..."
    npm install ws
    echo ""
fi

# Create midscene directories if they don't exist
mkdir -p midscene_run/log
mkdir -p midscene_run/report

echo "✅ Dependencies ready!"
echo ""
echo "🌐 Starting Enhanced Server with Dashboard..."
echo "📱 Main Interface: http://localhost:3000"
echo "📊 Real-time Dashboard: http://localhost:3000/dashboard"
echo ""
echo "🎮 Dashboard Features:"
echo "  ✅ Real-time WebSocket monitoring"
echo "  ✅ Pause/Resume automation control"
echo "  ✅ Live log streaming"
echo "  ✅ Device status monitoring"
echo "  ✅ Performance metrics tracking"
echo ""
echo "Press Ctrl+C to stop the server"
echo ""

# Start the enhanced server
node server-enhanced.js 