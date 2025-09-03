**1. Short summary**
- Overlay app shows Ergodox EZ layout as a translucent, click-through NSWindow spanning all Spaces, toggled by a global hotkey.
- Architecture divides UI, windowing, hotkeys, event-tap, layout data, and persistence into micro‑modules for clarity and future portability.
- JSON/asset-based layer model enables fast static rendering now and data-driven layouts later.
- TDD-first build: start with window + hotkey MVP; incrementally add auto-layer switching, preferences, and fade animations.
- Packaging targets a small notarized binary without unnecessary entitlements.

---

**2. Architecture**

```
+-------------------------- macOS ---------------------------+
|  SwiftUI App (EZOverlayApp)                                |
|  ├─ AppDelegate                                            |
|  ├─ WindowManager (OverlayWindowController)                |
|  │   └─ OverlayView (SwiftUI)                              |
|  ├─ HotkeyManager (Carbon)                                 |
|  ├─ EventTapManager (optional)                             |
|  ├─ LayoutRepository (assets/JSON)                         |
|  └─ PreferencesDomain (UserDefaults)                       |
+------------------------------------------------------------+
```

*Explanation*

- **EZOverlayApp**: SwiftUI entry; wires managers via environment.
- **WindowManager**: creates borderless, transparent, always‑on‑top NSWindow; hosts `OverlayView`.
- **OverlayView**: SwiftUI view displaying the current layer image or JSON-rendered grid.
- **HotkeyManager**: registers global hotkey; posts toggle notifications.
- **EventTapManager** (optional): listens for F13–F20; requires Input Monitoring permission; emits layer change events.
- **LayoutRepository**: loads layer assets or JSON from user-selected folder; caches and serves to OverlayView.
- **PreferencesDomain**: simple wrapper around `UserDefaults` + Codable settings.
- Clear boundaries allow replacing window/hotkey implementations for Linux later.

*Data model*

```swift
struct Layer: Identifiable, Codable {
    var id: String          // "base", "symbols", ...
    var title: String
    var imageName: String?  // v1: PNG/SVG asset
    var layout: [KeyLabel]? // v1.1: JSON grid
}

struct KeyLabel: Codable {
    var row: Int
    var column: Int
    var text: String
}
```

*Window behavior*

- `level = .statusBar` keeps overlay above most windows.
- `collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]` ensures presence on all Spaces and atop full‑screen apps.
- `isOpaque = false`, `backgroundColor = .clear`, `hasShadow = false` create borderless transparent window.
- `ignoresMouseEvents` toggles click‑through.
- `orderFrontRegardless()` to display without stealing focus.

---

**3. Implementation plan**

| Milestone | Tasks & Estimate | Risks / Rollback |
|-----------|-----------------|------------------|
| **M0 – Project skeleton (0.5d)** | Create Xcode project, Swift Packages, minimal App/Window/Hotkey stubs. | Low risk. |
| **M1 – Overlay MVP (1.5d)** | Borderless window, static PNG overlay, hotkey toggle, size/position persistence. | Window layering over full-screen may fail → adjust `level` & `collectionBehavior`. |
| **M2 – Preferences (1d)** | SwiftUI sheet for opacity, hotkey picker, click-through toggle, save to `UserDefaults`. | If hotkey change fails, revert to default. |
| **M3 – LayoutRepository (1d)** | Load PNGs by layer name, switch layers manually via UI tabs. | Asset path errors → show placeholder. |
| **M4 – Auto layer switching (1.5d)** | EventTap for F13–F20, permission request, link to repository. | Permission denied → fall back to manual switching. |
| **M5 – Animations & polish (0.5d)** | Fade in/out, “hide after N sec” option. | If animation stutters, allow disable. |
| **M6 – Tests & packaging (1d)** | Unit tests, UI toggle test, archive, codesign, notarize. | Notarization fails → verify entitlements/signing. |

Enhancements after MVP: JSON-based rendering, layer mapping UI, advanced prefs.

---

**4. File tree + code skeletons**

```
EZOverlay/
├─ EZOverlayApp.swift
├─ AppDelegate.swift
├─ Window/
│  ├─ OverlayWindowController.swift
│  └─ OverlayView.swift
├─ Hotkeys/
│  └─ HotkeyManager.swift
├─ EventTap/
│  └─ EventTapManager.swift
├─ Layout/
│  ├─ LayoutRepository.swift
│  └─ SampleLayout.json
├─ Preferences/
│  └─ PreferencesView.swift
├─ Models/
│  └─ Layer.swift
└─ Tests/
   ├─ HotkeyManagerTests.swift
   └─ LayoutRepositoryTests.swift
```

*Starter code snippets*

`EZOverlayApp.swift`
```swift
import SwiftUI

@main
struct EZOverlayApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        Settings { PreferencesView() }
    }
}
```

`AppDelegate.swift`
```swift
import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    private let windowController = OverlayWindowController()
    private let hotkeys = HotkeyManager()
    func applicationDidFinishLaunching(_ notification: Notification) {
        hotkeys.registerToggle { self.windowController.toggle() }
    }
}
```

`OverlayWindowController.swift`
```swift
import AppKit
import SwiftUI

final class OverlayWindowController: NSWindowController {
    init() {
        let view = OverlayView()
        let window = NSWindow(
            contentRect: .init(x: 100, y: 100, width: 800, height: 300),
            styleMask: [.borderless, .resizable],
            backing: .buffered, defer: false)
        window.isOpaque = false
        window.backgroundColor = .clear
        window.hasShadow = false
        window.level = .statusBar
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        window.contentView = NSHostingView(rootView: view)
        super.init(window: window)
    }
    required init?(coder: NSCoder) { fatalError() }
    func toggle() { window?.isVisible.toggle() }
}
```

`OverlayView.swift`
```swift
import SwiftUI

struct OverlayView: View {
    var body: some View {
        Image("layer_base")
            .resizable()
            .scaledToFit()
            .background(Color.black.opacity(0.5))
    }
}
```

`HotkeyManager.swift`
```swift
import Carbon

final class HotkeyManager {
    private var hotKeyRef: EventHotKeyRef?
    func registerToggle(_ handler: @escaping () -> Void) {
        var eventHandler: EventHandlerRef?
        let callback: EventHandlerUPP = { _, event, _ in
            handler()
            return noErr
        }
        let eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard),
                                      eventKind: UInt32(kEventHotKeyPressed))
        InstallEventHandler(GetApplicationEventTarget(), callback, 1, [eventType], nil, &eventHandler)
        RegisterEventHotKey(UInt32(kVK_ANSI_L), UInt32(controlKey|optionKey|cmdKey),
                            eventType, GetApplicationEventTarget(), 0, &hotKeyRef)
    }
}
```

`EventTapManager.swift`
```swift
import Quartz

final class EventTapManager {
    private var tap: CFMachPort?
    func start(onLayerChange: @escaping (Int) -> Void) {
        tap = CGEvent.tapCreate(tap: .cgSessionEventTap,
                                place: .headInsertEventTap,
                                options: .defaultTap,
                                eventsOfInterest: CGEventMask(1 << CGEventType.keyDown.rawValue),
                                callback: { _, type, event, refcon in
            let key = event.getIntegerValueField(.keyboardEventKeycode)
            if (105...112).contains(key) { // F13–F20
                onLayerChange(Int(key - 105))
            }
            return Unmanaged.passUnretained(event)
        }, userInfo: nil)
        if let tap = tap {
            let runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
            CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
            CGEvent.tapEnable(tap: tap, enable: true)
        }
    }
}
```

`PreferencesView.swift`
```swift
import SwiftUI

struct PreferencesView: View {
    @AppStorage("opacity") private var opacity: Double = 0.5
    @AppStorage("clickThrough") private var clickThrough = false
    var body: some View {
        Form {
            Slider(value: $opacity, in: 0.2...1.0, label: { Text("Opacity") })
            Toggle("Click through", isOn: $clickThrough)
        }.padding()
    }
}
```

`LayoutRepository.swift`
```swift
import Foundation

final class LayoutRepository {
    func loadLayer(id: String) -> Layer? {
        // v1: load from bundled images; stub for future JSON support.
        Layer(id: id, title: id.capitalized, imageName: "layer_\(id)", layout: nil)
    }
}
```

`SampleLayout.json`
```json
{
  "id": "symbols",
  "title": "Symbols",
  "layout": [
    { "row": 0, "column": 0, "text": "!" },
    { "row": 0, "column": 1, "text": "@" }
  ]
}
```

PNG naming: `layer_base.png`, `layer_symbols.png`, etc., stored in app bundle or user-selected folder.

---

**5. Key code snippets**

*Transparent always-on-top window*
```swift
let window = NSWindow(contentRect: rect, styleMask: [.borderless, .resizable], backing: .buffered, defer: false)
window.isOpaque = false
window.backgroundColor = .clear
window.level = .statusBar
window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
window.ignoresMouseEvents = clickThrough
window.orderFrontRegardless()
```

*Attach SwiftUI content*
```swift
let hosting = NSHostingView(rootView: OverlayView())
window.contentView = hosting
```

*Global hotkey (Carbon)*
```swift
RegisterEventHotKey(kVK_ANSI_L, UInt32(controlKey|optionKey|cmdKey),
                    EventTypeSpec(eventClass: kEventClassKeyboard, eventKind: kEventHotKeyPressed),
                    GetApplicationEventTarget(), 0, &hotKeyRef)
```

*CGEventTap for F13–F20*
```swift
tap = CGEvent.tapCreate(tap: .cgSessionEventTap, place: .headInsertEventTap, options: .defaultTap,
                        eventsOfInterest: CGEventMask(1 << CGEventType.keyDown.rawValue)) { _, _, event, _ in
    let code = event.getIntegerValueField(.keyboardEventKeycode)
    if (105...112).contains(code) { onLayerChange(Int(code - 105)) }
    return Unmanaged.passUnretained(event)
}
```

*Fade in/out*
```swift
NSAnimationContext.runAnimationGroup { ctx in
    ctx.duration = 0.18
    window.animator().alphaValue = show ? 1 : 0
}
```

---

**6. Test plan**

*Unit tests*
- `HotkeyManagerTests`: register hotkey, simulate callback, ensure toggle closure invoked.
- `LayoutRepositoryTests`: load existing layer, missing layer returns nil.
- `PreferencesTests`: round-trip encode/decode settings.

*Lightweight UI test (XCTest/UIAutomation)*
1. Launch app.
2. Send global hotkey; assert overlay window exists and is visible.
3. Send hotkey again; assert window hidden.

*Manual QA checklist*
- Overlay visible on all Spaces and over full-screen apps.
- Window resizable, position/size persist across launches.
- Click-through mode doesn’t steal focus.
- Opacity slider works; hotkey configurable.
- CPU usage idle ~0%.
- Auto-layer switching: press F13–F20 on keyboard, overlay layer changes.
- Multi-monitor: overlay appears on current space of each screen.

---

**7. Build, codesign, notarize steps**

1. **Build Settings**
   - Deployment target macOS 14.
   - `ENABLE_HARDENED_RUNTIME = YES`.
2. **Entitlements / Plist**
   - None for MVP; add `com.apple.security.automation.apple-events` if needed later.
   - `NSInputMonitoringUsageDescription` in Info.plist for event tap prompt.
3. **Codesign**
   ```bash
   xcodebuild -scheme EZOverlay -configuration Release
   codesign --deep --force --options runtime --sign "Developer ID Application: Your Name" EZOverlay.app
   ```
4. **Notarize**
   ```bash
   zip -r EZOverlay.zip EZOverlay.app
   xcrun notarytool submit EZOverlay.zip --keychain-profile "AC_PROFILE" --wait
   xcrun stapler staple EZOverlay.app
   ```
5. Distribute DMG/ZIP.

Permission prompt: first call to `CGEvent.tapCreate` in auto-layer mode triggers Input Monitoring request; guide user to System Settings > Privacy & Security > Input Monitoring.

---

**8. Risks & mitigations**

| Risk | Mitigation |
|------|------------|
| Event tap requires Input Monitoring; user may decline. | Lazy-load EventTapManager only when feature enabled; show help if permission missing; fall back to manual switching. |
| Full-screen apps ignore overlay. | Use `.statusBar` level + `.fullScreenAuxiliary`; test with common apps. |
| International keyboard layouts may mismatch F13–F20 codes. | Allow user remapping, document requirement. |
| App steals focus or interferes with input. | Enable click-through by default; set `acceptsFirstResponder = false`. |
| High CPU/GPU usage | Avoid timers; use `NSAnimationContext` only on show/hide; no continuous drawing. |

---

**9. Backlog (nice-to-haves)**

- Auto-hide per application; overlay appears only when foreground app is in whitelist.
- Heads-up display timeout (hide after N seconds of inactivity).
- Menu bar mode for quick layer switching and status.
- Editable key labels and import from Oryx/QMK JSON configurations.
- Hold ⌘ to temporarily enable click-through for interacting with underlying apps.
- Fancy backgrounds: gradient, blur via `NSVisualEffectView`.
- Linux port using GTK or similar, leveraging window/hotkey abstractions.

