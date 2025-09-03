# EZOverlay

A macOS application that displays an Ergodox EZ keyboard layout as a translucent, click-through overlay window.

## Features

- **Global Hotkey Toggle**: Press `Cmd+Option+Ctrl+L` to show/hide overlay
- **Transparent Overlay**: Borderless, transparent window that appears on all Spaces
- **Auto Layer Switching**: F13-F20 keys automatically switch overlay layers (requires Input Monitoring permission)
- **Click-through Support**: Configurable click-through behavior
- **Multi-Space Support**: Overlay appears on all desktop Spaces and over full-screen apps
- **Customizable Opacity**: Adjust overlay transparency via preferences

## Quick Start

### Building

```bash
# Build the application
./build.sh

# Or manually:
swift build --configuration release
```

### Running

```bash
# Run the built executable
.build/release/EZOverlay
```

### Testing

```bash
# Run comprehensive tests with screenshots
./test_with_screenshots.sh

# The test will:
# 1. Run unit tests
# 2. Build the application
# 3. Launch and test basic functionality
# 4. Take screenshots for manual verification
# 5. Save screenshots to ~/Desktop/EZOverlay_Screenshots/
```

## Architecture

The application follows a modular architecture:

- **EZOverlayApp**: SwiftUI app entry point
- **AppDelegate**: Coordinates all managers and handles app lifecycle
- **OverlayWindowController**: Manages the transparent overlay window
- **HotkeyManager**: Handles global hotkey registration (Carbon APIs)
- **EventTapManager**: Monitors F13-F20 keys for layer switching
- **LayoutRepository**: Manages keyboard layout data (JSON/PNG assets)
- **PreferencesView**: SwiftUI settings interface

## Permissions

The app requires **Input Monitoring** permission for automatic layer switching via F13-F20 keys. This permission is requested when you first enable the feature and can be granted in:

System Settings > Privacy & Security > Input Monitoring

## Development

### Project Structure

```
EZOverlay/
├── EZOverlayApp.swift          # Main app entry point
├── AppDelegate.swift           # App coordinator
├── Window/                     # Window management
│   ├── OverlayWindowController.swift
│   └── OverlayView.swift
├── Hotkeys/                    # Global hotkey handling
│   └── HotkeyManager.swift
├── EventTap/                   # Keyboard monitoring
│   └── EventTapManager.swift
├── Layout/                     # Layout management
│   ├── LayoutRepository.swift
│   └── SampleLayout.json
├── Preferences/                # Settings UI
│   └── PreferencesView.swift
├── Models/                     # Data models
│   └── Layer.swift
└── Tests/                      # Test suite
    ├── HotkeyManagerTests.swift
    ├── LayoutRepositoryTests.swift
    ├── OverlayWindowControllerTests.swift
    ├── EventTapManagerTests.swift
    └── IntegrationTests.swift
```

### Key Technologies

- **SwiftUI** for UI components
- **AppKit** for window management and system integration
- **Carbon APIs** for global hotkey registration
- **Quartz** for low-level keyboard monitoring
- **UserDefaults** for settings persistence

### Testing

The project includes comprehensive unit tests and integration tests. Screenshots are automatically captured during testing for manual verification of UI behavior.

## Configuration

### Default Hotkey
- Toggle overlay: `Cmd+Option+Ctrl+L`

### Layer Switching (F13-F20)
- F13 → Layer 0 (Base)
- F14 → Layer 1 (Symbols)
- F15 → Layer 2 (Numbers)
- F16 → Layer 3 (Function)
- F17 → Layer 4 (Navigation)
- F18-F20 → Additional layers

### Settings
- Opacity: 20% to 100%
- Click-through: Enable/disable mouse event passthrough
- Window position and size are automatically saved

## Known Limitations

1. **Accessibility Permission**: Required for F13-F20 layer switching
2. **PNG Assets**: Current version uses placeholder graphics (add your own layout PNGs)
3. **Keyboard Layout**: Optimized for Ergodox EZ keyboard layouts

## Future Enhancements

- Oryx/QMK configuration import
- Custom layout editor
- Per-application overlay rules
- Menu bar mode
- Advanced animations
- Linux/Windows port