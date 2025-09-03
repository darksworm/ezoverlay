import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    private let windowController = OverlayWindowController()
    private let hotkeys = HotkeyManager()
    private let layoutRepository = LayoutRepository()
    private let eventTapManager = EventTapManager()
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Setup hotkey for overlay toggle
        hotkeys.registerToggle { [weak self] in
            self?.windowController.toggle()
        }
        
        // Setup event tap for layer switching (F13-F20)
        eventTapManager.start { [weak self] layerIndex in
            guard let self = self else { return }
            self.layoutRepository.switchToLayer(at: layerIndex)
            
            // Broadcast layer change to UI
            if let currentLayer = self.layoutRepository.currentLayer {
                NotificationCenter.default.post(
                    name: .layerChanged,
                    object: currentLayer
                )
            }
        }
        
        // Observe settings changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(preferencesChanged),
            name: UserDefaults.didChangeNotification,
            object: nil
        )
    }
    
    @objc private func preferencesChanged() {
        let clickThrough = UserDefaults.standard.bool(forKey: "clickThrough")
        windowController.setClickThrough(clickThrough)
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false // Keep app running even when preferences window is closed
    }
}