#!/bin/bash

# Hotel Booking Automation V3 - Extended Version
# Extended 30-minute deep browsing with advanced patterns
# Usage: ./booking-automation-v3.sh <device_id> <city>

# Check if both parameters are provided
if [ $# -lt 2 ]; then
    echo "❌ Error: Missing parameters"
    echo ""
    echo "Usage: ./booking-automation-v3.sh <device_id> <city>"
    echo ""
    echo "Examples:"
    echo "  ./booking-automation-v3.sh 98.98.125.9:24142 Paris"
    echo "  ./booking-automation-v3.sh 192.168.1.100:5555 London"
    echo "  ./booking-automation-v3.sh ABC123DEF456 Tokyo"
    echo "  ./booking-automation-v3.sh 98.98.125.9:24142 \"New York\""
    echo ""
    echo "🔥 V3 Extended Features:"
    echo "  - Extended 30-minute deep browsing"
    echo "  - Advanced hotel exploration patterns"
    echo "  - Multiple search refinements"
    echo "  - Enhanced human-like behavior"
    echo "  - Comprehensive hotel analysis"
    echo ""
    exit 1
fi

DEVICE_ID="$1"
CITY="$2"
YAML_FILE="booking-v3-${DEVICE_ID//[^a-zA-Z0-9]/-}-${CITY// /-}.yaml"

echo "🔥 Hotel Booking Automation V3 (Extended)"
echo "📱 Device: $DEVICE_ID"
echo "🏙️  City: $CITY"
echo "📄 Generated file: $YAML_FILE"
echo "🔥 Extended features: 30min deep browsing, Advanced patterns, Multiple refinements"
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

# Function to generate dynamic image count (8-25 images for V3)
random_image_count() {
    echo $((8 + RANDOM % 18))  # Random between 8-25 (higher than V2)
}

# Function to generate extended exploration count (3-6 explorations per hotel)
random_exploration_count() {
    echo $((3 + RANDOM % 4))  # Random between 3-6
}

# Create the extended V3 YAML file
echo "📝 Generating extended V3 automation script..."
cat > "$YAML_FILE" << EOF
android:
  deviceId: "$DEVICE_ID"

tasks:
  - name: "V3 Deep Hotel Browsing 1 - Premium Results"
    flow:
      # Advanced scrolling pattern - start with premium results
      - ai: "scroll down slowly to see premium hotel options"
      - sleep: $(random_sleep 2500)
      - ai: "tap on the first luxury or highly-rated hotel"
      - sleep: $(random_sleep 3500)
      # Extended image browsing (higher count for V3)
EOF

# Generate extended image browsing for hotel 1
IMAGE_COUNT_1=$(random_image_count)
EXPLORATION_COUNT_1=$(random_exploration_count)
echo "      # Browse $IMAGE_COUNT_1 hotel images extensively" >> "$YAML_FILE"
for ((i=1; i<=IMAGE_COUNT_1; i++)); do
    echo "      - ai: \"tap right arrow to view next hotel image\"" >> "$YAML_FILE"
    echo "      - sleep: $(random_sleep 1800 400)" >> "$YAML_FILE"
done

echo "      # Extended room exploration ($EXPLORATION_COUNT_1 sections)" >> "$YAML_FILE"
for ((j=1; j<=EXPLORATION_COUNT_1; j++)); do
    echo "      - ai: \"scroll down to explore room details section $j\"" >> "$YAML_FILE"
    echo "      - sleep: $(random_sleep 2500 500)" >> "$YAML_FILE"
done

cat >> "$YAML_FILE" << EOF
      # Advanced amenities exploration
      - ai: "scroll down to see hotel amenities and facilities"
      - sleep: $(random_sleep 2500 500)
      - ai: "scroll down to see guest reviews and ratings"
      - sleep: $(random_sleep 2500 500)
      - ai: "scroll down to see location and nearby attractions"
      - sleep: $(random_sleep 2500 500)
      # Return to search results
      - ai: "tap back button to return to hotel search"
      - sleep: $(random_sleep 4000 600)

  - name: "V3 Deep Hotel Browsing 2 - Mid-Tier Analysis"
    flow:
      # Strategic scrolling - mid-tier options
      - ai: "scroll down to explore mid-tier hotel options"
      - sleep: $(random_sleep 2500)
      - ai: "scroll down again to find good value hotels"
      - sleep: $(random_sleep 2500)
      - ai: "tap on a hotel with good ratings and reasonable price"
      - sleep: $(random_sleep 3500)
      # Extended image browsing
EOF

# Generate extended image browsing for hotel 2
IMAGE_COUNT_2=$(random_image_count)
EXPLORATION_COUNT_2=$(random_exploration_count)
echo "      # Browse $IMAGE_COUNT_2 hotel images thoroughly" >> "$YAML_FILE"
for ((i=1; i<=IMAGE_COUNT_2; i++)); do
    echo "      - ai: \"tap right arrow to view next image\"" >> "$YAML_FILE"
    echo "      - sleep: $(random_sleep 1800 500)" >> "$YAML_FILE"
done

echo "      # Deep room analysis ($EXPLORATION_COUNT_2 sections)" >> "$YAML_FILE"
for ((j=1; j<=EXPLORATION_COUNT_2; j++)); do
    echo "      - ai: \"scroll down to analyze room features section $j\"" >> "$YAML_FILE"
    echo "      - sleep: $(random_sleep 2500 600)" >> "$YAML_FILE"
done

cat >> "$YAML_FILE" << EOF
      # Comprehensive details exploration
      - ai: "scroll down to see detailed room specifications"
      - sleep: $(random_sleep 2500 600)
      - ai: "scroll down to see pricing breakdown and policies"
      - sleep: $(random_sleep 2500 600)
      - ai: "scroll down to see guest reviews and feedback"
      - sleep: $(random_sleep 2500 600)
      # Navigate back
      - ai: "tap back button to return to search results"
      - sleep: $(random_sleep 4000 700)

  - name: "V3 Deep Hotel Browsing 3 - Budget-Friendly Options"
    flow:
      # Extended scrolling pattern
      - ai: "scroll down to explore budget-friendly options"
      - sleep: $(random_sleep 2500)
      - ai: "scroll down more to see affordable hotels"
      - sleep: $(random_sleep 2500)
      - ai: "tap on a budget hotel with good value proposition"
      - sleep: $(random_sleep 3500)
      # Extended image browsing
EOF

# Generate extended image browsing for hotel 3
IMAGE_COUNT_3=$(random_image_count)
EXPLORATION_COUNT_3=$(random_exploration_count)
echo "      # Browse $IMAGE_COUNT_3 hotel images comprehensively" >> "$YAML_FILE"
for ((i=1; i<=IMAGE_COUNT_3; i++)); do
    echo "      - ai: \"tap right arrow to see another image\"" >> "$YAML_FILE"
    echo "      - sleep: $(random_sleep 1800 600)" >> "$YAML_FILE"
done

echo "      # Detailed room inspection ($EXPLORATION_COUNT_3 sections)" >> "$YAML_FILE"
for ((j=1; j<=EXPLORATION_COUNT_3; j++)); do
    echo "      - ai: \"scroll down to inspect room details section $j\"" >> "$YAML_FILE"
    echo "      - sleep: $(random_sleep 2500 700)" >> "$YAML_FILE"
done

cat >> "$YAML_FILE" << EOF
      # Budget analysis
      - ai: "scroll down to see what's included in the price"
      - sleep: $(random_sleep 2500 700)
      - ai: "scroll down to see additional fees and charges"
      - sleep: $(random_sleep 2500 700)
      - ai: "scroll down to see cancellation policy"
      - sleep: $(random_sleep 2500 700)
      # Return navigation
      - ai: "tap back button to return to hotel listings"
      - sleep: $(random_sleep 4000 800)

  - name: "V3 Deep Hotel Browsing 4 - Boutique Properties"
    flow:
      # Advanced scrolling to find unique properties
      - ai: "scroll down to find boutique or unique hotels"
      - sleep: $(random_sleep 2500)
      - ai: "scroll down more to see specialty accommodations"
      - sleep: $(random_sleep 2500)
      - ai: "tap on a boutique hotel or unique property"
      - sleep: $(random_sleep 3500)
      # Extended image browsing
EOF

# Generate extended image browsing for hotel 4
IMAGE_COUNT_4=$(random_image_count)
EXPLORATION_COUNT_4=$(random_exploration_count)
echo "      # Browse $IMAGE_COUNT_4 hotel images extensively" >> "$YAML_FILE"
for ((i=1; i<=IMAGE_COUNT_4; i++)); do
    echo "      - ai: \"tap right arrow to explore more images\"" >> "$YAML_FILE"
    echo "      - sleep: $(random_sleep 1800 700)" >> "$YAML_FILE"
done

echo "      # Boutique property analysis ($EXPLORATION_COUNT_4 sections)" >> "$YAML_FILE"
for ((j=1; j<=EXPLORATION_COUNT_4; j++)); do
    echo "      - ai: \"scroll down to explore unique features section $j\"" >> "$YAML_FILE"
    echo "      - sleep: $(random_sleep 2500 800)" >> "$YAML_FILE"
done

cat >> "$YAML_FILE" << EOF
      # Specialty features exploration
      - ai: "scroll down to see unique amenities and services"
      - sleep: $(random_sleep 2500 800)
      - ai: "scroll down to see special packages and offers"
      - sleep: $(random_sleep 2500 800)
      - ai: "scroll down to see location advantages"
      - sleep: $(random_sleep 2500 800)
      # Navigate back
      - ai: "tap back button to return to search"
      - sleep: $(random_sleep 4000 900)

  - name: "V3 Deep Hotel Browsing 5 - Business Hotels"
    flow:
      # Business-focused scrolling
      - ai: "scroll down to find business or conference hotels"
      - sleep: $(random_sleep 2500)
      - ai: "scroll down to see hotels with business facilities"
      - sleep: $(random_sleep 2500)
      - ai: "tap on a business hotel or conference center"
      - sleep: $(random_sleep 3500)
      # Extended image browsing
EOF

# Generate extended image browsing for hotel 5
IMAGE_COUNT_5=$(random_image_count)
EXPLORATION_COUNT_5=$(random_exploration_count)
echo "      # Browse $IMAGE_COUNT_5 hotel images thoroughly" >> "$YAML_FILE"
for ((i=1; i<=IMAGE_COUNT_5; i++)); do
    echo "      - ai: \"tap right arrow to see business facility images\"" >> "$YAML_FILE"
    echo "      - sleep: $(random_sleep 1800 800)" >> "$YAML_FILE"
done

echo "      # Business facilities analysis ($EXPLORATION_COUNT_5 sections)" >> "$YAML_FILE"
for ((j=1; j<=EXPLORATION_COUNT_5; j++)); do
    echo "      - ai: \"scroll down to explore business facilities section $j\"" >> "$YAML_FILE"
    echo "      - sleep: $(random_sleep 2500 900)" >> "$YAML_FILE"
done

cat >> "$YAML_FILE" << EOF
      # Business amenities exploration
      - ai: "scroll down to see meeting rooms and conference facilities"
      - sleep: $(random_sleep 2500 900)
      - ai: "scroll down to see business center services"
      - sleep: $(random_sleep 2500 900)
      - ai: "scroll down to see corporate rates and packages"
      - sleep: $(random_sleep 2500 900)
      # Navigate back
      - ai: "tap back button to continue exploration"
      - sleep: $(random_sleep 4000 1000)

  - name: "V3 Deep Hotel Browsing 6 - Resort Properties"
    flow:
      # Resort-focused exploration
      - ai: "scroll down to find resort or spa hotels"
      - sleep: $(random_sleep 2500)
      - ai: "scroll down to see leisure and resort properties"
      - sleep: $(random_sleep 2500)
      - ai: "tap on a resort or spa hotel"
      - sleep: $(random_sleep 3500)
      # Extended image browsing
EOF

# Generate extended image browsing for hotel 6
IMAGE_COUNT_6=$(random_image_count)
EXPLORATION_COUNT_6=$(random_exploration_count)
echo "      # Browse $IMAGE_COUNT_6 resort images extensively" >> "$YAML_FILE"
for ((i=1; i<=IMAGE_COUNT_6; i++)); do
    echo "      - ai: \"tap right arrow to see resort facility images\"" >> "$YAML_FILE"
    echo "      - sleep: $(random_sleep 1800 900)" >> "$YAML_FILE"
done

echo "      # Resort facilities analysis ($EXPLORATION_COUNT_6 sections)" >> "$YAML_FILE"
for ((j=1; j<=EXPLORATION_COUNT_6; j++)); do
    echo "      - ai: \"scroll down to explore resort amenities section $j\"" >> "$YAML_FILE"
    echo "      - sleep: $(random_sleep 2500 1000)" >> "$YAML_FILE"
done

cat >> "$YAML_FILE" << EOF
      # Resort amenities exploration
      - ai: "scroll down to see spa and wellness facilities"
      - sleep: $(random_sleep 2500 1000)
      - ai: "scroll down to see recreational activities"
      - sleep: $(random_sleep 2500 1000)
      - ai: "scroll down to see dining and entertainment options"
      - sleep: $(random_sleep 2500 1000)
      # Navigate back
      - ai: "tap back button to continue browsing"
      - sleep: $(random_sleep 4000 1100)

  - name: "V3 Deep Hotel Browsing 7 - Final Comprehensive Review"
    flow:
      # Final comprehensive exploration
      - ai: "scroll down to see remaining hotel options"
      - sleep: $(random_sleep 2500)
      - ai: "scroll down to explore the last set of hotels"
      - sleep: $(random_sleep 2500)
      - ai: "tap on the final hotel for comprehensive review"
      - sleep: $(random_sleep 3500)
      # Extended final image browsing
EOF

# Generate extended image browsing for hotel 7
IMAGE_COUNT_7=$(random_image_count)
EXPLORATION_COUNT_7=$(random_exploration_count)
echo "      # Browse $IMAGE_COUNT_7 final hotel images comprehensively" >> "$YAML_FILE"
for ((i=1; i<=IMAGE_COUNT_7; i++)); do
    echo "      - ai: \"tap right arrow to see comprehensive image set\"" >> "$YAML_FILE"
    echo "      - sleep: $(random_sleep 1800 1000)" >> "$YAML_FILE"
done

echo "      # Final comprehensive analysis ($EXPLORATION_COUNT_7 sections)" >> "$YAML_FILE"
for ((j=1; j<=EXPLORATION_COUNT_7; j++)); do
    echo "      - ai: \"scroll down to complete final analysis section $j\"" >> "$YAML_FILE"
    echo "      - sleep: $(random_sleep 2500 1100)" >> "$YAML_FILE"
done

cat >> "$YAML_FILE" << EOF
      # Comprehensive final review
      - ai: "scroll down to see complete hotel information"
      - sleep: $(random_sleep 2500 1100)
      - ai: "scroll down to see all available room types"
      - sleep: $(random_sleep 2500 1100)
      - ai: "scroll down to see complete pricing structure"
      - sleep: $(random_sleep 2500 1100)
      - ai: "scroll down to see all guest reviews and ratings"
      - sleep: $(random_sleep 2500 1100)
      # Session completion
      - ai: "tap back button to complete the extended browsing session"
      - sleep: $(random_sleep 4000 1200)
EOF

echo "✅ Extended V3 script generated successfully!"
echo ""
echo "🔥 V3 Extended Features Applied:"
echo "  📊 Hotel 1 (Premium): $IMAGE_COUNT_1 images, $EXPLORATION_COUNT_1 explorations"
echo "  📊 Hotel 2 (Mid-tier): $IMAGE_COUNT_2 images, $EXPLORATION_COUNT_2 explorations"
echo "  📊 Hotel 3 (Budget): $IMAGE_COUNT_3 images, $EXPLORATION_COUNT_3 explorations"
echo "  📊 Hotel 4 (Boutique): $IMAGE_COUNT_4 images, $EXPLORATION_COUNT_4 explorations"
echo "  📊 Hotel 5 (Business): $IMAGE_COUNT_5 images, $EXPLORATION_COUNT_5 explorations"
echo "  📊 Hotel 6 (Resort): $IMAGE_COUNT_6 images, $EXPLORATION_COUNT_6 explorations"
echo "  📊 Hotel 7 (Final): $IMAGE_COUNT_7 images, $EXPLORATION_COUNT_7 explorations"
echo "  ⏱️  Extended timing variation: ±400-1200ms"
echo "  🎯 Advanced hotel categorization"
echo "  🔄 Comprehensive exploration patterns"
echo ""
echo "🚀 Starting extended V3 hotel booking automation..."
echo "⏱️  Estimated time: ~30 minutes (extended deep browsing)"
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

echo "🔑 Using OpenRouter API with Qwen VL model (V3 Extended)"
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
echo "✅ Device ready for extended automation: $DEVICE_ID"

# Run the Midscene CLI with extended timeout for V3
echo "🔧 Running Midscene CLI (Extended V3)..."
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

# Run Midscene CLI with extended timeout for V3 (45 minutes)
echo "🚀 Executing Extended Midscene CLI (V3)..."
timeout 2700 npx --yes @midscene/cli "$YAML_FILE" 2>&1
CLI_EXIT_CODE=$?

# Check the exit code
if [ $CLI_EXIT_CODE -eq 124 ]; then
    echo "⏰ Midscene CLI timed out after 45 minutes"
    echo "💡 This might be normal for extended V3 automation sessions"
elif [ $CLI_EXIT_CODE -ne 0 ]; then
    echo "❌ Midscene CLI failed with exit code: $CLI_EXIT_CODE"
    echo "💡 Check the logs above for error details"
    exit $CLI_EXIT_CODE
else
    echo "✅ Midscene CLI completed successfully"
fi

echo ""
echo "🎉 V3 Extended Automation completed!"
echo "📄 Generated file: $YAML_FILE"
echo "📊 Report: midscene_run/report/"
echo ""
echo "🔥 V3 Extended Features Used:"
echo "  ✅ Extended 30-minute deep browsing"
echo "  ✅ Advanced hotel categorization (Premium, Mid-tier, Budget, Boutique, Business, Resort)"
echo "  ✅ Enhanced image counts (8-25 per hotel)"
echo "  ✅ Multiple exploration sections (3-6 per hotel)"
echo "  ✅ Comprehensive analysis patterns"
echo "  ✅ Extended timing variations for maximum human-like behavior" 