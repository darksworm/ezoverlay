#!/bin/bash

echo "🎹 EZOverlay - Enhanced Demo"
echo "============================"
echo ""
echo "✨ New Features Added:"
echo "  • Properly centered overlay on current screen"
echo "  • Real Ergodox EZ keyboard layout visualization"
echo "  • Layer switching with arrow buttons (← →)" 
echo "  • Visual layer change indicators"
echo "  • Multi-screen support (centers on screen with mouse)"
echo "  • Layer counter (Layer X/Y)"
echo ""
echo "🔧 How to Test:"
echo "  1. Launch: cd EZOverlay && ./.build/release/EZOverlay"
echo "  2. Press Cmd+Option+Ctrl+L to show overlay"
echo "  3. Click the arrow buttons to switch layers"
echo "  4. Try F13-F20 keys for auto layer switching (requires Input Monitoring)"
echo "  5. Press hotkey again to hide"
echo "  6. Move mouse to different screen and show overlay (it will center there)"
echo ""
echo "🎨 Layer Types Available:"
echo "  • Base Layer: QWERTY layout with standard modifiers"
echo "  • Symbols: Special characters and symbols"  
echo "  • Numbers: Numeric keypad and F-keys"
echo "  • Function: Additional function keys"
echo "  • Navigation: Arrow keys and navigation"
echo ""
echo "Ready to launch? (press Enter)"
read

echo "🚀 Launching EZOverlay..."
cd EZOverlay
./.build/release/EZOverlay