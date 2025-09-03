# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview
EZOverlay is a macOS application that displays an Ergodox EZ keyboard layout as a translucent, click-through overlay window. The app shows the current layer of a programmable keyboard layout across all Spaces and can be toggled with a global hotkey.

## Architecture
The application follows a modular architecture with clear separation of concerns:

```
SwiftUI App (EZOverlayApp)
├─ AppDelegate                          # Main app lifecycle and coordinator
├─ WindowManager (OverlayWindowController)  # Manages overlay window properties
│   └─ OverlayView (SwiftUI)           # UI layer displaying keyboard layout
├─ HotkeyManager (Carbon)              # Global hotkey registration
├─ EventTapManager (optional)          # F13-F20 key detection for layer switching
├─ LayoutRepository (assets/JSON)      # Loads and manages keyboard layout data
└─ PreferencesDomain (UserDefaults)   # Settings persistence
```

### Key Components
- **WindowManager**: Creates borderless, transparent, always-on-top NSWindow that spans all Spaces
- **HotkeyManager**: Uses Carbon APIs to register global hotkeys (default: Cmd+Opt+Ctrl+L)
- **EventTapManager**: Requires Input Monitoring permission; listens for F13-F20 function keys
- **LayoutRepository**: Handles both PNG assets and JSON-based layout definitions

### Window Behavior
The overlay window uses specific NSWindow configurations:
- `level = .statusBar` for above-app positioning
- `collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]` for all Spaces
- `isOpaque = false`, `backgroundColor = .clear` for transparency
- `ignoresMouseEvents` for click-through functionality

## Development Commands

Since this is currently a planning repository with no actual Swift code yet, standard Xcode commands will apply once implementation begins:

### Building
```bash
# Build the project
xcodebuild -scheme EZOverlay -configuration Release

# For development builds
xcodebuild -scheme EZOverlay -configuration Debug
```

### Testing
```bash
# Run unit tests
xcodebuild test -scheme EZOverlay

# Run specific test
xcodebuild test -scheme EZOverlay -only-testing:EZOverlayTests/HotkeyManagerTests
```

### Code Signing & Distribution
```bash
# Sign the application
codesign --deep --force --options runtime --sign "Developer ID Application: Your Name" EZOverlay.app

# Notarize for distribution
zip -r EZOverlay.zip EZOverlay.app
xcrun notarytool submit EZOverlay.zip --keychain-profile "AC_PROFILE" --wait
xcrun stapler staple EZOverlay.app
```

## Implementation Milestones

The project follows a TDD approach with these milestones:
1. **M0**: Project skeleton (0.5d)
2. **M1**: Overlay MVP with hotkey toggle (1.5d)
3. **M2**: Preferences UI (1d)
4. **M3**: LayoutRepository with PNG support (1d)
5. **M4**: Auto layer switching via EventTap (1.5d)
6. **M5**: Animations and polish (0.5d)
7. **M6**: Tests and packaging (1d)

## File Structure
Expected project structure once implementation begins:
```
EZOverlay/
├─ EZOverlayApp.swift               # SwiftUI app entry point
├─ AppDelegate.swift                # App lifecycle coordinator
├─ Window/
│  ├─ OverlayWindowController.swift # Window management
│  └─ OverlayView.swift            # SwiftUI overlay content
├─ Hotkeys/
│  └─ HotkeyManager.swift          # Global hotkey handling
├─ EventTap/
│  └─ EventTapManager.swift        # F13-F20 key detection
├─ Layout/
│  ├─ LayoutRepository.swift       # Layout data management
│  └─ SampleLayout.json           # JSON layout example
├─ Preferences/
│  └─ PreferencesView.swift        # Settings UI
├─ Models/
│  └─ Layer.swift                  # Data models
└─ Tests/
   ├─ HotkeyManagerTests.swift
   └─ LayoutRepositoryTests.swift
```

## Security & Permissions
The app requires Input Monitoring permission for automatic layer switching via EventTapManager. This permission is requested on first use of the event tap feature and can be granted in System Settings > Privacy & Security > Input Monitoring.

## Data Models
```swift
struct Layer: Identifiable, Codable {
    var id: String          // "base", "symbols", etc.
    var title: String
    var imageName: String?  # v1: PNG asset reference
    var layout: [KeyLabel]? # v1.1: JSON grid data
}

struct KeyLabel: Codable {
    var row: Int
    var column: Int
    var text: String
}
```

## Key Technical Patterns
- Uses SwiftUI for UI with NSHostingView for embedding in AppKit window
- Carbon APIs for global hotkey registration
- CGEventTap for low-level keyboard monitoring
- UserDefaults with Codable for settings persistence
- Asset-based and JSON-based layout loading