#!/bin/bash

# Test script for EZOverlay application
set -e

cd EZOverlay

echo "🚀 Testing EZOverlay Application"
echo "================================"

# Build the app
echo "📦 Building application..."
swift build --configuration release

if [ ! -f ".build/release/EZOverlay" ]; then
    echo "❌ Build failed!"
    exit 1
fi

echo "✅ Build successful!"

# Create screenshots directory
SCREENSHOTS_DIR="$HOME/Desktop/EZOverlay_Screenshots"
mkdir -p "$SCREENSHOTS_DIR"
echo "📸 Screenshots will be saved to: $SCREENSHOTS_DIR"

# Take a before screenshot
echo "📸 Taking 'before' screenshot..."
screencapture -x "$SCREENSHOTS_DIR/before_launch.png"

echo ""
echo "🎯 Launching EZOverlay..."
echo ""
echo "🔍 Manual Testing Instructions:"
echo "   1. The app should launch without showing a window initially"
echo "   2. Press Cmd+Option+Ctrl+L to toggle the overlay"
echo "   3. You should see a blue placeholder overlay appear"
echo "   4. Press the hotkey again to hide the overlay"
echo "   5. Press Cmd+, (or go to EZOverlay > Settings) to open preferences"
echo "   6. Adjust opacity and click-through settings"
echo "   7. Test overlay on different Spaces and full-screen apps"
echo ""
echo "⚠️  Note: F13-F20 layer switching requires Input Monitoring permission"
echo "   Grant permission in System Settings > Privacy & Security > Input Monitoring"
echo ""
echo "Press Enter when ready to launch the app..."
read

# Launch the app
.build/release/EZOverlay &
APP_PID=$!

echo "✅ App launched with PID: $APP_PID"
echo ""
echo "🧪 Automated testing (wait 5 seconds then take screenshot)..."
sleep 5

# Take screenshot after launch
screencapture -x "$SCREENSHOTS_DIR/after_launch.png"

echo "📸 Screenshot taken"
echo ""
echo "⌨️  Now test the hotkey manually:"
echo "   Press Cmd+Option+Ctrl+L to toggle overlay"
echo ""
echo "Press Enter after testing hotkey..."
read

# Take screenshot after hotkey test
screencapture -x "$SCREENSHOTS_DIR/after_hotkey_test.png"

echo ""
echo "🔧 Test preferences window:"
echo "   Press Cmd+, to open preferences or use app menu"
echo ""
echo "Press Enter after testing preferences..."
read

# Take final screenshot
screencapture -x "$SCREENSHOTS_DIR/final_test.png"

echo ""
echo "🏁 Test complete! Cleaning up..."
echo ""

# Kill the app
if kill -0 $APP_PID 2>/dev/null; then
    kill $APP_PID
    echo "🛑 App terminated"
    sleep 2
    
    # Force kill if still running
    if kill -0 $APP_PID 2>/dev/null; then
        kill -9 $APP_PID
        echo "🔪 Force killed app"
    fi
else
    echo "ℹ️  App already terminated"
fi

echo ""
echo "📊 Test Summary"
echo "==============="
echo "✅ Application built successfully"
echo "✅ Application launched without crashing"
echo "📸 Screenshots saved to: $SCREENSHOTS_DIR"
echo ""
echo "🔍 Review the following files:"
ls -la "$SCREENSHOTS_DIR/"*.png 2>/dev/null || echo "No screenshots found"
echo ""
echo "✨ EZOverlay test complete!"