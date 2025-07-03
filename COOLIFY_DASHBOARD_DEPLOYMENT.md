# 🚀 Coolify Dashboard Deployment Guide

## 📊 Deploy Enhanced Dashboard to Coolify

### 🎯 Quick Deployment Steps

1. **Push to Git Repository**
2. **Update Coolify Service**
3. **Access Enhanced Dashboard**

## 📝 Step-by-Step Instructions

### 1. Commit and Push Changes
```bash
# In your local web-automation-v2 directory
git add .
git commit -m "Add real-time dashboard with pause/resume functionality"
git push origin main
```

### 2. Coolify Deployment Options

#### Option A: Automatic Deployment (if auto-deploy enabled)
- Coolify will automatically detect the changes
- Wait for the build to complete
- Dashboard will be available automatically

#### Option B: Manual Deployment
1. Go to your Coolify dashboard
2. Navigate to your hotel automation service
3. Click "Deploy" or "Redeploy"
4. Wait for the build to complete

### 3. Environment Variables (Already Set)
Your existing environment variables will work:
```env
OPENAI_API_KEY=sk-or-v1-your-key
OPENAI_BASE_URL=https://openrouter.ai/api/v1
MIDSCENE_MODEL_NAME=qwen/qwen2.5-vl-72b-instruct
MIDSCENE_USE_QWEN_VL=1
```

## 🌐 Access Points

After deployment, you'll have these URLs:

### Main Interfaces
- **Original Interface**: `https://your-coolify-domain.com`
- **Enhanced Dashboard**: `https://your-coolify-domain.com/dashboard`

### API Endpoints
- **Health Check**: `https://your-coolify-domain.com/health`
- **System Status**: `https://your-coolify-domain.com/api/status`
- **Device List**: `https://your-coolify-domain.com/api/devices`

## 📊 Dashboard Features Available

### 🎮 Real-Time Controls
- **Quick Start**: Launch automations directly from dashboard
- **Pause/Resume**: Control running automations
- **Stop**: Emergency stop functionality
- **Bulk Operations**: Control all automations at once

### 📡 Live Monitoring
- **WebSocket Connection**: Real-time updates
- **Live Logs**: Streaming log entries
- **Performance Metrics**: Hotels viewed, images processed
- **Device Status**: Online/offline monitoring

### 📱 Mobile-Friendly
- **Responsive Design**: Works on all devices
- **Touch Controls**: Mobile-optimized buttons
- **Real-time Updates**: Live status on mobile

## 🔧 Technical Details

### Enhanced Server Features
```javascript
// New capabilities added
- WebSocket support for real-time updates
- Pause/Resume functionality (SIGSTOP/SIGCONT)
- Live log streaming from Midscene CLI
- Enhanced process management
- Real-time performance metrics
```

### Docker Configuration
```dockerfile
# Updated Dockerfile includes:
- WebSocket dependency (ws)
- Enhanced server startup
- Dashboard script permissions
- Health check for enhanced features
```

## 🎯 Usage Examples

### Start Automation from Dashboard
1. Open `https://your-domain.com/dashboard`
2. Click "🚀 Quick Start"
3. Enter device ID: `98.98.125.9:24142`
4. Enter city: `Paris`
5. Watch real-time progress

### Pause/Resume Control
1. View active automations in the dashboard
2. Click "⏸️ Pause" to pause specific automation
3. Click "▶️ Resume" to resume paused automation
4. Use "Pause All" / "Resume All" for bulk operations

### Live Log Monitoring
1. Dashboard automatically shows live logs
2. Color-coded entries (error/warning/info/success)
3. Auto-scroll to latest entries
4. Download logs as text file

## 🔍 Monitoring Capabilities

### Real-Time Metrics
- **Active Automations**: Live count of running processes
- **V2 Enhanced**: Count of V2 automations
- **Success Rate**: Overall automation success percentage
- **API Calls**: Real-time API request counter
- **Response Times**: Average API response times

### Device Management
- **Connection Status**: Online/offline indicators
- **Device List**: All connected devices
- **Status Updates**: Real-time device state changes
- **Add Devices**: Dynamic device management

## 🚨 Troubleshooting

### If Dashboard Doesn't Load
1. Check Coolify build logs for errors
2. Verify WebSocket dependency installed
3. Ensure port 3000 is accessible
4. Check environment variables are set

### If WebSocket Connection Fails
1. Verify HTTPS/WSS protocol compatibility
2. Check firewall settings
3. Ensure WebSocket support enabled
4. Try refreshing the page

### Build Issues
```bash
# Common solutions:
1. Clear Coolify build cache
2. Check package.json dependencies
3. Verify Dockerfile syntax
4. Review build logs for specific errors
```

## 📈 Performance Benefits

### Real-Time Responsiveness
- **Instant Updates**: Sub-second status changes
- **Live Feedback**: Immediate command acknowledgment
- **WebSocket Efficiency**: Better than polling
- **Optimized UI**: Smooth real-time updates

### Enhanced Control
- **Process Management**: Full control over automations
- **Bulk Operations**: Manage multiple automations
- **Error Handling**: Graceful failure recovery
- **State Persistence**: Maintains state across connections

## 🎉 What's New in Enhanced Version

### Compared to V1/V2 Basic
```diff
+ Real-time WebSocket dashboard
+ Pause/Resume functionality
+ Live log streaming
+ Device status monitoring
+ Performance metrics tracking
+ Modern UI with glass morphism
+ Mobile-responsive design
+ Bulk automation control
+ Enhanced error handling
+ Auto-reconnection
```

## 🔒 Security & Reliability

### Production-Ready Features
- **Input Validation**: Sanitized WebSocket messages
- **Process Isolation**: Safe signal handling
- **Auto-reconnection**: Resilient connections
- **Error Boundaries**: Contained failure handling
- **Resource Management**: Efficient memory usage

### Coolify Integration
- **Environment Variables**: Secure API key handling
- **Health Checks**: Automatic service monitoring
- **Auto-scaling**: Coolify's built-in scaling
- **SSL/TLS**: Secure WebSocket connections (WSS)

## 📞 Support

### If You Need Help
1. **Check Build Logs**: Coolify deployment logs
2. **Test Locally**: Run `./start-dashboard.sh` locally first
3. **Verify Environment**: Ensure all env vars are set
4. **WebSocket Test**: Check browser developer console

### Debug Commands (if you have shell access)
```bash
# Check if enhanced server is running
ps aux | grep server-enhanced

# Test WebSocket connection
curl -i -N -H "Connection: Upgrade" -H "Upgrade: websocket" https://your-domain.com

# Check logs
tail -f logs/application.log
```

---

**🎯 Your enhanced dashboard with real-time monitoring and pause/resume functionality is now ready for Coolify deployment!** 📊✨

**Access your new dashboard at**: `https://your-coolify-domain.com/dashboard` 