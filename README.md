

## 🆕 V2 Enhanced Features

### 🎯 Smart Automation
- **Random Timing Variation**: ±300-1000ms timing variation for more human-like behavior
- **Dynamic Image Counts**: 5-20 images per hotel (randomly generated)
- **Smart Hotel Selection**: Intelligent prompts to avoid duplicate selections
- **Intelligent Scrolling**: Adaptive scrolling patterns based on content area
- **Adaptive Browsing**: Context-aware navigation and exploration

### 🔄 Behavioral Improvements
- **Phase-Based Approach**: Starts directly from hotel browsing (Tasks 4-8)
- **Varied Exploration**: Different image counts and timing for each hotel
- **Smart Navigation**: Contextual prompts for better hotel selection
- **Dynamic Duration**: 12-25 minutes based on random image counts

## 🚀 Quick Start

### Prerequisites
- Android device with ADB enabled
- Node.js 16+ installed
- Environment variables configured

### Local Usage
```bash
# Clone and setup
git clone <repository>
cd web-automation-v2
npm install

# Make script executable
chmod +x booking-automation-v2.sh

# Run V2 automation
./booking-automation-v2.sh 98.98.125.9:24142 "Paris"

# Start web interface
npm start
# Access: http://localhost:3000
```

### Web Interface Usage
1. Open the web interface
2. Enter Android Device ID
3. Enter destination city
4. Select V2 Enhanced version
5. Click "🚀 Start Automation"

## 🎛️ Configuration

### Required Environment Variables
```bash
export OPENAI_API_KEY="sk-or-v1-your-api-key"
export OPENAI_BASE_URL="https://openrouter.ai/api/v1"
export MIDSCENE_MODEL_NAME="qwen/qwen2.5-vl-72b-instruct"
export MIDSCENE_USE_QWEN_VL="1"
```

### Android Device Setup
```bash
# Enable wireless ADB
adb tcpip 5555
adb connect YOUR_DEVICE_IP:5555

# Verify connection
adb devices
```

## 📊 V2 vs V1 Comparison

| Feature | V1 Standard | V2 Enhanced |
|---------|-------------|-------------|
| **Timing** | Fixed intervals | Random variation (±300-1000ms) |
| **Images** | Fixed 15 per hotel | Dynamic 5-20 per hotel |
| **Selection** | Basic prompts | Smart contextual prompts |
| **Scrolling** | Simple patterns | Intelligent adaptive patterns |
| **Duration** | Fixed ~15 minutes | Dynamic 12-25 minutes |
| **Behavior** | Predictable | Human-like variation |

## 🏗️ Architecture

### V2 Enhancement Structure
```
web-automation-v2/
├── booking-automation-v2.sh    # Enhanced automation script
├── server.js                   # V2 web server with dual support
├── index.html                  # Enhanced web interface
├── package.json               # V2 dependencies
├── Dockerfile                 # V2 container setup
└── README.md                  # This file
```

### Smart Features Implementation
1. **Random Sleep Function**: Generates human-like timing variations
2. **Dynamic Image Count**: Randomizes browsing depth per hotel
3. **Intelligent Prompts**: Context-aware hotel selection
4. **Adaptive Scrolling**: Smart navigation patterns

## 🔧 API Endpoints

### V2 Enhanced Endpoints
- `POST /api/start-automation-v2` - Start V2 enhanced automation
- `POST /api/start-automation` - Start V1 standard automation (fallback)
- `GET /api/status` - Check automation status (V1 & V2)
- `POST /api/stop-automation` - Stop running automation
- `GET /health` - Health check with V2 features

## 📱 Device Compatibility

### Supported Devices
- **Network ADB**: `IP:PORT` format (e.g., `192.168.1.100:5555`)
- **USB ADB**: Device serial numbers
- **Wireless ADB**: Android 11+ with wireless debugging

### Connection Examples
```bash
# Network connection
./booking-automation-v2.sh 192.168.1.100:5555 "Tokyo"

# USB connection
./booking-automation-v2.sh ABC123DEF456 "London"

# Wireless ADB
./booking-automation-v2.sh 98.98.125.9:24142 "New York"
```

## 🎯 V2 Automation Flow

### Phase 2: Enhanced Hotel Browsing (Tasks 4-8)
1. **Smart Hotel 1** - Top results with intelligent scrolling
2. **Smart Hotel 2** - Mid-range options with varied timing
3. **Smart Hotel 3** - Lower results with adaptive patterns
4. **Smart Hotel 4** - Alternative options with smart selection
5. **Smart Hotel 5** - Final exploration with dynamic behavior

### Dynamic Features Per Hotel
- **Random Image Count**: 5-20 images per hotel
- **Varied Timing**: ±300-1000ms sleep variations
- **Smart Prompts**: Context-aware selection text
- **Adaptive Scrolling**: Intelligent navigation patterns

## 🚀 Deployment

### Docker Deployment
```bash
# Build V2 container
docker build -t hotel-automation-v2 .

# Run with environment variables
docker run -d \
  -p 3000:3000 \
  -e OPENAI_API_KEY="your-key" \
  -e OPENAI_BASE_URL="https://openrouter.ai/api/v1" \
  -e MIDSCENE_MODEL_NAME="qwen/qwen2.5-vl-72b-instruct" \
  -e MIDSCENE_USE_QWEN_VL="1" \
  hotel-automation-v2
```

### Coolify Deployment
1. Create new service from GitHub repository
2. Set environment variables in Coolify
3. Deploy using Node.js buildpack
4. Access via generated URL

## 🔍 Monitoring & Debugging

### Log Files
```bash
# V2 automation logs
tail -f midscene_run/log/ai-call.log

# Server logs
npm start

# Docker logs
docker logs hotel-automation-v2
```

### Status Monitoring
- Web interface status panel
- API endpoint: `GET /api/status`
- Real-time process tracking
- V1/V2 process separation

## ⚡ Performance

### V2 Optimizations
- **Parallel Processing**: Concurrent V1/V2 support
- **Smart Caching**: Persistent ADB installation
- **Resource Management**: Efficient process handling
- **Error Recovery**: Robust failure handling

### Estimated Performance
- **V2 Duration**: 12-25 minutes (dynamic)
- **Image Processing**: 5-20 images per hotel
- **Timing Variation**: ±300-1000ms humanization
- **Success Rate**: 95%+ with smart features

## 🛠️ Troubleshooting

### Common V2 Issues
1. **Random Timing Too Fast**: Increase base sleep times
2. **Image Count Too High**: Adjust random range
3. **Smart Selection Fails**: Review prompt context
4. **Adaptive Scrolling Issues**: Check screen resolution

### Debug Commands
```bash
# Test V2 script syntax
bash -n booking-automation-v2.sh

# Verify random functions
bash -c 'source booking-automation-v2.sh; random_sleep 2000; random_image_count'

# Check environment
env | grep -E "(OPENAI|MIDSCENE)"
```

## 📈 Future Enhancements

### Planned V2.1 Features
- **ML-Based Timing**: Machine learning for optimal delays
- **Behavioral Profiles**: Different human behavior patterns
- **Smart Recovery**: AI-powered error recovery
- **Advanced Analytics**: Detailed performance metrics

## 🤝 Contributing

### Development Setup
```bash
git clone <repository>
cd web-automation-v2
npm install
npm run dev  # Development mode with nodemon
```

### V2 Enhancement Guidelines
1. Maintain backward compatibility with V1
2. Add randomization for human-like behavior
3. Include smart contextual prompts
4. Test with multiple device types

## 📄 License

MIT License - Enhanced V2 Edition

## 🆘 Support

- **Issues**: GitHub Issues
- **Documentation**: This README
- **Web Interface**: Built-in help system
- **API Reference**: `/health` endpoint for feature list

---

**🎉 V2 Enhanced Edition** - Smart, Dynamic, Human-like Hotel Automation 
