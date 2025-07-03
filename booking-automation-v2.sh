#!/bin/bash

# Hotel Booking Automation V2 - Enhanced Version
# Starts from hotel browsing phase with smart improvements
# Usage: ./booking-automation-v2.sh <device_id> <city>

# Check if both parameters are provided
if [ $# -lt 2 ]; then
    echo "❌ Error: Missing parameters"
    echo ""
    echo "Usage: ./booking-automation-v2.sh <device_id> <city>"
    echo ""
    echo "Examples:"
    echo "  ./booking-automation-v2.sh 98.98.125.9:24142 Paris"
    echo "  ./booking-automation-v2.sh 192.168.1.100:5555 London"
    echo "  ./booking-automation-v2.sh ABC123DEF456 Tokyo"
    echo "  ./booking-automation-v2.sh 98.98.125.9:24142 \"New York\""
    echo ""
    echo "🆕 V2 Features:"
    echo "  - Random timing variation (more human-like)"
    echo "  - Smart hotel selection (avoids duplicates)"
    echo "  - Dynamic image count (5-20 images per hotel)"
    echo "  - Intelligent scrolling patterns"
    echo ""
    exit 1
fi

DEVICE_ID="$1"
CITY="$2"
YAML_FILE="booking-v2-${DEVICE_ID//[^a-zA-Z0-9]/-}-${CITY// /-}.yaml"

echo "🏨 Hotel Booking Automation V2 (Enhanced)"
echo "📱 Device: $DEVICE_ID"
echo "🏙️  City: $CITY"
echo "📄 Generated file: $YAML_FILE"
echo "🆕 Enhanced features: Random timing, Smart selection, Dynamic browsing"
echo ""

# Define persistent Android SDK path
PERSISTENT_ANDROID_SDK="/opt/android-sdk"
ADB_INSTALLED_FLAG="/opt/android-sdk/.adb_installed"

# Check if ADB is already installed persistently
if [ -f "$ADB_INSTALLED_FLAG" ] && [ -x "$PERSISTENT_ANDROID_SDK/platform-tools/adb" ]; then
    echo "✅ ADB already installed, using existing installation"
    export PATH="$PERSISTENT_ANDROID_SDK/platform-tools:$PATH"
    export ANDROID_SDK_ROOT="$PERSISTENT_ANDROID_SDK"
elif ! command -v adb >/dev/null 2>&1; then
    echo "❌ ADB not found. Installing Android SDK tools permanently..."
    
    # Install required system packages once
    echo "📦 Installing system dependencies..."
    if command -v apt-get >/dev/null 2>&1; then
        apt-get update -qq && apt-get install -y unzip wget curl android-tools-adb || true
    elif command -v yum >/dev/null 2>&1; then
        yum install -y unzip wget curl || true
    elif command -v apk >/dev/null 2>&1; then
        apk add --no-cache unzip wget curl android-tools || true
    fi
    
    # Try system ADB first
    if command -v adb >/dev/null 2>&1; then
        echo "✅ Using system ADB installation"
        mkdir -p "$(dirname "$ADB_INSTALLED_FLAG")"
        touch "$ADB_INSTALLED_FLAG"
    else
        echo "📥 System ADB not available, installing Android SDK..."
        
        # Create persistent Android SDK directory
        mkdir -p "$PERSISTENT_ANDROID_SDK/platform-tools"
        
        # Download and install ADB to persistent location
        cd /tmp
        echo "📥 Downloading Android platform tools..."
        if ! wget -q https://dl.google.com/android/repository/platform-tools-latest-linux.zip -O platform-tools.zip; then
            echo "❌ Failed to download platform tools"
            exit 1
        fi
        
        echo "📦 Extracting platform tools to $PERSISTENT_ANDROID_SDK..."
        if ! unzip -q platform-tools.zip -d "$PERSISTENT_ANDROID_SDK/"; then
            echo "❌ Failed to extract platform tools"
            exit 1
        fi
        
        # Clean up
        rm -f platform-tools.zip
        
        # Make ADB executable
        chmod +x "$PERSISTENT_ANDROID_SDK/platform-tools/adb"
        
        # Add to PATH
        export PATH="$PERSISTENT_ANDROID_SDK/platform-tools:$PATH"
        export ANDROID_SDK_ROOT="$PERSISTENT_ANDROID_SDK"
        
        # Create installation flag
        touch "$ADB_INSTALLED_FLAG"
        echo "$(date): ADB installed to $PERSISTENT_ANDROID_SDK" > "$ADB_INSTALLED_FLAG"
        
        # Verify installation
        if ! command -v adb >/dev/null 2>&1; then
            echo "❌ Failed to install ADB. Please install Android SDK manually."
            echo "💡 Try: apt-get install android-tools-adb"
            exit 1
        fi
        
        echo "✅ ADB installed successfully to $PERSISTENT_ANDROID_SDK!"
    fi
else
    echo "✅ ADB found in system PATH"
fi

# Test ADB connection
echo "🔍 Testing ADB connection..."
if ! adb devices | grep -q "$DEVICE_ID.*device"; then
    echo "⚠️  Device not found. Attempting to connect..."
    
    # Try to connect if it looks like a network address
    if [[ "$DEVICE_ID" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+:[0-9]+$ ]]; then
        echo "🔗 Connecting to wireless device: $DEVICE_ID"
        adb connect "$DEVICE_ID"
        sleep 2
        
        # Check again
        if ! adb devices | grep -q "$DEVICE_ID.*device"; then
            echo "❌ Failed to connect to device: $DEVICE_ID"
            echo "💡 Make sure:"
            echo "   - Device has wireless ADB enabled"
            echo "   - Device is on the same network"
            echo "   - IP address and port are correct"
            exit 1
        fi
    else
        echo "❌ Device not found: $DEVICE_ID"
        echo "💡 Available devices:"
        adb devices
        exit 1
    fi
fi

echo "✅ Device connected: $DEVICE_ID"
echo ""

# Function to generate random timing (human-like variation)
random_sleep() {
    local base_time=$1
    local variation=${2:-500}  # Default ±500ms variation
    local min_time=$((base_time - variation))
    local max_time=$((base_time + variation))
    local random_time=$((min_time + RANDOM % (max_time - min_time + 1)))
    echo $random_time
}

# Function to generate dynamic image count (5-20 images)
random_image_count() {
    echo $((5 + RANDOM % 16))  # Random between 5-20
}

# Create the enhanced YAML file
echo "📝 Generating enhanced automation script..."
cat > "$YAML_FILE" << EOF
android:
  deviceId: "$DEVICE_ID"

tasks:
  - name: "Smart Hotel Browsing 1 - Top Results"
    flow:
      # Intelligent scrolling - start with top results
      - ai: "scroll down once to see available hotels"
      - sleep: $(random_sleep 2000)
      - ai: "tap on the first highly-rated hotel you see"
      - sleep: $(random_sleep 3000)
      # Dynamic image browsing (random count)
EOF

# Generate dynamic image browsing for hotel 1
IMAGE_COUNT_1=$(random_image_count)
echo "      # Browse $IMAGE_COUNT_1 hotel images dynamically" >> "$YAML_FILE"
for ((i=1; i<=IMAGE_COUNT_1; i++)); do
    echo "      - ai: \"tap right arrow to see next hotel image\"" >> "$YAML_FILE"
    echo "      - sleep: $(random_sleep 1500 300)" >> "$YAML_FILE"
done

cat >> "$YAML_FILE" << EOF
      # Explore room details with varied timing
      - ai: "scroll down to see room details and amenities"
      - sleep: $(random_sleep 2000 400)
      - ai: "scroll down to see more room options"
      - sleep: $(random_sleep 2000 400)
      - ai: "scroll down to see pricing information"
      - sleep: $(random_sleep 2000 400)
      # Return to search results
      - ai: "tap back button to return to hotel search"
      - sleep: $(random_sleep 3000 500)

  - name: "Smart Hotel Browsing 2 - Mid-Range Results"
    flow:
      # Smart scrolling - avoid previously viewed area
      - ai: "scroll down twice to see different hotels"
      - sleep: $(random_sleep 2000)
      - ai: "scroll down once more to find mid-range options"
      - sleep: $(random_sleep 2000)
      - ai: "tap on a hotel that looks different from the previous one"
      - sleep: $(random_sleep 3000)
      # Dynamic image browsing
EOF

# Generate dynamic image browsing for hotel 2
IMAGE_COUNT_2=$(random_image_count)
echo "      # Browse $IMAGE_COUNT_2 hotel images dynamically" >> "$YAML_FILE"
for ((i=1; i<=IMAGE_COUNT_2; i++)); do
    echo "      - ai: \"tap right arrow to view next image\"" >> "$YAML_FILE"
    echo "      - sleep: $(random_sleep 1500 400)" >> "$YAML_FILE"
done

cat >> "$YAML_FILE" << EOF
      # Detailed room exploration
      - ai: "scroll down to explore room types and features"
      - sleep: $(random_sleep 2000 500)
      - ai: "scroll down to see additional room details"
      - sleep: $(random_sleep 2000 500)
      - ai: "scroll down to check room availability and prices"
      - sleep: $(random_sleep 2000 500)
      # Navigate back
      - ai: "tap back button to return to search results"
      - sleep: $(random_sleep 3000 600)

  - name: "Smart Hotel Browsing 3 - Lower Results"
    flow:
      # Intelligent scrolling pattern
      - ai: "scroll down to explore hotels further down the list"
      - sleep: $(random_sleep 2000)
      - ai: "scroll down again to see more options"
      - sleep: $(random_sleep 2000)
      - ai: "tap on a hotel with good photos or ratings"
      - sleep: $(random_sleep 3000)
      # Dynamic image browsing
EOF

# Generate dynamic image browsing for hotel 3
IMAGE_COUNT_3=$(random_image_count)
echo "      # Browse $IMAGE_COUNT_3 hotel images dynamically" >> "$YAML_FILE"
for ((i=1; i<=IMAGE_COUNT_3; i++)); do
    echo "      - ai: \"tap right arrow to see another image\"" >> "$YAML_FILE"
    echo "      - sleep: $(random_sleep 1500 500)" >> "$YAML_FILE"
done

cat >> "$YAML_FILE" << EOF
      # Room details exploration
      - ai: "scroll down to see room information"
      - sleep: $(random_sleep 2000 600)
      - ai: "scroll down to see room amenities"
      - sleep: $(random_sleep 2000 600)
      - ai: "scroll down to see pricing and availability"
      - sleep: $(random_sleep 2000 600)
      # Return navigation
      - ai: "tap back button to return to hotel listings"
      - sleep: $(random_sleep 3000 700)

  - name: "Smart Hotel Browsing 4 - Alternative Options"
    flow:
      # Smart scrolling to find unique hotels
      - ai: "scroll down to find alternative hotel options"
      - sleep: $(random_sleep 2000)
      - ai: "scroll down more to see different price ranges"
      - sleep: $(random_sleep 2000)
      - ai: "tap on a hotel that offers something unique"
      - sleep: $(random_sleep 3000)
      # Dynamic image browsing
EOF

# Generate dynamic image browsing for hotel 4
IMAGE_COUNT_4=$(random_image_count)
echo "      # Browse $IMAGE_COUNT_4 hotel images dynamically" >> "$YAML_FILE"
for ((i=1; i<=IMAGE_COUNT_4; i++)); do
    echo "      - ai: \"tap right arrow to explore more images\"" >> "$YAML_FILE"
    echo "      - sleep: $(random_sleep 1500 600)" >> "$YAML_FILE"
done

cat >> "$YAML_FILE" << EOF
      # Comprehensive room review
      - ai: "scroll down to review room specifications"
      - sleep: $(random_sleep 2000 700)
      - ai: "scroll down to see room facilities"
      - sleep: $(random_sleep 2000 700)
      - ai: "scroll down to compare room prices"
      - sleep: $(random_sleep 2000 700)
      # Navigate back
      - ai: "tap back button to return to search"
      - sleep: $(random_sleep 3000 800)

  - name: "Smart Hotel Browsing 5 - Final Exploration"
    flow:
      # Final intelligent scrolling
      - ai: "scroll down to explore remaining hotel options"
      - sleep: $(random_sleep 2000)
      - ai: "scroll down to see the last set of hotels"
      - sleep: $(random_sleep 2000)
      - ai: "tap on the final hotel to complete the browsing session"
      - sleep: $(random_sleep 3000)
      # Dynamic image browsing
EOF

# Generate dynamic image browsing for hotel 5
IMAGE_COUNT_5=$(random_image_count)
echo "      # Browse $IMAGE_COUNT_5 hotel images dynamically" >> "$YAML_FILE"
for ((i=1; i<=IMAGE_COUNT_5; i++)); do
    echo "      - ai: \"tap right arrow to see final set of images\"" >> "$YAML_FILE"
    echo "      - sleep: $(random_sleep 1500 700)" >> "$YAML_FILE"
done

cat >> "$YAML_FILE" << EOF
      # Final room details review
      - ai: "scroll down to see final room details"
      - sleep: $(random_sleep 2000 800)
      - ai: "scroll down to see complete room information"
      - sleep: $(random_sleep 2000 800)
      - ai: "scroll down to see final pricing details"
      - sleep: $(random_sleep 2000 800)
      # Session completion
      - ai: "tap back button to complete the browsing session"
      - sleep: $(random_sleep 3000 1000)
EOF

echo "✅ Enhanced script generated successfully!"
echo ""
echo "🆕 V2 Enhancements Applied:"
echo "  📊 Hotel 1: $IMAGE_COUNT_1 images (top results)"
echo "  📊 Hotel 2: $IMAGE_COUNT_2 images (mid-range)"
echo "  📊 Hotel 3: $IMAGE_COUNT_3 images (lower results)"
echo "  📊 Hotel 4: $IMAGE_COUNT_4 images (alternatives)"
echo "  📊 Hotel 5: $IMAGE_COUNT_5 images (final exploration)"
echo "  ⏱️  Random timing variation: ±300-1000ms"
echo "  🎯 Smart hotel selection prompts"
echo "  🔄 Intelligent scrolling patterns"
echo ""
echo "🚀 Starting enhanced hotel booking automation..."
echo "⏱️  Estimated time: ~12-25 minutes (dynamic based on image counts)"
echo "📊 Monitor progress: tail -f midscene_run/log/ai-call.log"
echo ""

# Set Android SDK path (use persistent installation if available)
if [ -d "$PERSISTENT_ANDROID_SDK" ]; then
    export ANDROID_SDK_ROOT="$PERSISTENT_ANDROID_SDK"
    export PATH="$PERSISTENT_ANDROID_SDK/platform-tools:$PATH"
elif [ -d "/opt/homebrew/Caskroom/android-platform-tools/36.0.0" ]; then
    export ANDROID_SDK_ROOT="/opt/homebrew/Caskroom/android-platform-tools/36.0.0"
elif [ -d "/tmp/android-sdk" ]; then
    export ANDROID_SDK_ROOT="/tmp/android-sdk"
    export PATH="/tmp/android-sdk/platform-tools:$PATH"
else
    export ANDROID_SDK_ROOT="$PERSISTENT_ANDROID_SDK"
fi

# Check if required environment variables are set
if [ -z "$OPENAI_API_KEY" ]; then
    echo "❌ Error: OPENAI_API_KEY environment variable not set"
    echo "💡 Please set this in your Coolify environment variables"
    exit 1
fi

# Use environment variables from Coolify (no hardcoded fallbacks for security)
export OPENAI_BASE_URL="${OPENAI_BASE_URL:-https://openrouter.ai/api/v1}"
export MIDSCENE_MODEL_NAME="${MIDSCENE_MODEL_NAME:-qwen/qwen2.5-vl-72b-instruct}"
export MIDSCENE_USE_QWEN_VL="${MIDSCENE_USE_QWEN_VL:-1}"

echo "🔑 Using OpenRouter API with Qwen VL model (V2 Enhanced)"
echo "🔧 Android SDK: $ANDROID_SDK_ROOT"
echo "🔐 API Key: ${OPENAI_API_KEY:0:10}...${OPENAI_API_KEY: -6} (from environment)"

# Final device connection check before running automation
echo ""
echo "🔍 Final device check before automation..."
if ! adb devices | grep -q "$DEVICE_ID.*device"; then
    echo "❌ Device lost connection: $DEVICE_ID"
    echo "🔄 Attempting to reconnect..."
    if [[ "$DEVICE_ID" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+:[0-9]+$ ]]; then
        adb connect "$DEVICE_ID"
        sleep 2
        if ! adb devices | grep -q "$DEVICE_ID.*device"; then
            echo "❌ Failed to reconnect to device"
            exit 1
        fi
    else
        echo "❌ Device not available"
        exit 1
    fi
fi
echo "✅ Device ready for automation: $DEVICE_ID"

# Run the Midscene CLI with enhanced error handling
echo "🔧 Running Midscene CLI..."
echo "📝 YAML file: $YAML_FILE"
echo "🔍 File exists: $([ -f "$YAML_FILE" ] && echo "✅ Yes" || echo "❌ No")"
echo "📏 File size: $(wc -l < "$YAML_FILE" 2>/dev/null || echo "0") lines"
echo ""

# Check if YAML file was created successfully
if [ ! -f "$YAML_FILE" ]; then
    echo "❌ Error: YAML file was not created: $YAML_FILE"
    exit 1
fi

# Verify YAML file has content
if [ ! -s "$YAML_FILE" ]; then
    echo "❌ Error: YAML file is empty: $YAML_FILE"
    exit 1
fi

# Show first few lines of YAML for debugging
echo "📄 YAML file preview (first 10 lines):"
head -10 "$YAML_FILE"
echo "..."
echo ""

# Run Midscene CLI with timeout and error handling
echo "🚀 Executing Midscene CLI..."
timeout 1800 npx --yes @midscene/cli "$YAML_FILE" 2>&1
CLI_EXIT_CODE=$?

# Check the exit code
if [ $CLI_EXIT_CODE -eq 124 ]; then
    echo "⏰ Midscene CLI timed out after 30 minutes"
    echo "💡 This might be normal for long automation sessions"
elif [ $CLI_EXIT_CODE -ne 0 ]; then
    echo "❌ Midscene CLI failed with exit code: $CLI_EXIT_CODE"
    echo "💡 Check the logs above for error details"
    exit $CLI_EXIT_CODE
else
    echo "✅ Midscene CLI completed successfully"
fi

echo ""
echo "🎉 V2 Automation completed!"
echo "📄 Generated file: $YAML_FILE"
echo "📊 Report: midscene_run/report/"
echo ""
echo "🆕 V2 Features Used:"
echo "  ✅ Random timing variation for human-like behavior"
echo "  ✅ Dynamic image counts (5-20 per hotel)"
echo "  ✅ Smart hotel selection prompts"
echo "  ✅ Intelligent scrolling patterns" 