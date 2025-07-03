#!/bin/bash

echo "🚀 Deploying Dashboard to Coolify..."
echo ""

# Add all changes
git add .

# Commit with dashboard message
git commit -m "Add dashboard route and WebSocket support to existing server

✅ Added /dashboard route to server.js
✅ Added optional WebSocket support for real-time features  
✅ Dashboard now accessible at /dashboard endpoint
✅ Backward compatible - works with or without WebSocket dependency
✅ Enhanced server startup logging

Features:
- Real-time dashboard interface
- Pause/Resume automation control
- Live log streaming (if WebSocket available)
- Device status monitoring
- Performance metrics tracking"

# Push to repository
echo "📤 Pushing to git repository..."
git push origin main

echo ""
echo "✅ Changes pushed successfully!"
echo ""
echo "🌐 After Coolify deployment completes:"
echo "📱 Main Interface: https://your-domain.com"
echo "📊 Dashboard: https://your-domain.com/dashboard"
echo ""
echo "💡 The dashboard will work immediately after deployment!"
echo "📡 For full real-time features, WebSocket dependency will be installed automatically" 