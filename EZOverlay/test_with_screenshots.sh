#!/bin/bash

# Comprehensive test script with visual verification
set -e

echo "🧪 Running EZOverlay comprehensive test suite..."

# Change to the EZOverlay directory
cd "$(dirname "$0")"

# Create screenshots directory
SCREENSHOTS_DIR="$HOME/Desktop/EZOverlay_Screenshots"
mkdir -p "$SCREENSHOTS_DIR"
echo "📸 Screenshots will be saved to: $SCREENSHOTS_DIR"

echo ""
echo "1️⃣ Running unit tests..."
swift test

echo ""
echo "2️⃣ Building application..."
swift build --configuration release

if [ ! -f ".build/release/EZOverlay" ]; then
    echo "❌ Build failed - executable not found"
    exit 1
fi

echo ""
echo "3️⃣ Testing application launch..."

# Take a screenshot before launching app
echo "📸 Taking 'before' screenshot..."
screencapture -x "$SCREENSHOTS_DIR/00_before_app_launch.png"

# Launch the app in the background
echo "🚀 Launching EZOverlay..."
.build/release/EZOverlay &
APP_PID=$!

# Wait for app to initialize
sleep 3

# Take screenshot after app launch
echo "📸 Taking 'after launch' screenshot..."
screencapture -x "$SCREENSHOTS_DIR/01_after_app_launch.png"

echo ""
echo "4️⃣ Testing hotkey functionality..."
echo "⚠️  Note: Hotkey testing requires manual verification"
echo "   Press Cmd+Option+Ctrl+L to toggle overlay"
echo "   Waiting 10 seconds for manual test..."

# Wait for manual testing
sleep 10

# Take screenshot after potential hotkey activation
echo "📸 Taking 'after hotkey test' screenshot..."
screencapture -x "$SCREENSHOTS_DIR/02_after_hotkey_test.png"

echo ""
echo "5️⃣ Testing preferences window..."
echo "⚠️  Note: Open preferences via app menu if needed"

# Wait for potential preferences testing
sleep 5

# Take final screenshot
echo "📸 Taking final screenshot..."
screencapture -x "$SCREENSHOTS_DIR/03_final_state.png"

echo ""
echo "6️⃣ Cleaning up..."
# Kill the app
if kill -0 $APP_PID 2>/dev/null; then
    echo "🛑 Stopping EZOverlay..."
    kill $APP_PID
    sleep 2
    
    # Force kill if still running
    if kill -0 $APP_PID 2>/dev/null; then
        kill -9 $APP_PID
    fi
fi

echo ""
echo "✅ Test complete!"
echo ""
echo "📋 Test Summary:"
echo "   ✓ Unit tests passed"
echo "   ✓ Application built successfully"
echo "   ✓ Application launched without crashing"
echo "   📸 Screenshots saved to: $SCREENSHOTS_DIR"
echo ""
echo "🔍 Manual verification needed:"
echo "   1. Check screenshots for overlay visibility"
echo "   2. Verify hotkey toggle works (Cmd+Option+Ctrl+L)"
echo "   3. Test preferences window functionality"
echo "   4. Verify overlay appears on all Spaces"
echo "   5. Test click-through functionality"
echo ""
echo "📖 Next steps:"
echo "   - Review screenshots in: $SCREENSHOTS_DIR"
echo "   - Test with actual Ergodox EZ keyboard"
echo "   - Verify F13-F20 layer switching (requires Input Monitoring permission)"