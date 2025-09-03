import AppKit
import SwiftUI

final class OverlayWindowController: NSWindowController {
    
    init() {
        let view = OverlayView()
        
        // Calculate centered position on main screen
        let screenSize = NSScreen.main?.frame.size ?? NSSize(width: 1920, height: 1080)
        let windowWidth: CGFloat = 1200
        let windowHeight: CGFloat = 500
        let x = (screenSize.width - windowWidth) / 2
        let y = (screenSize.height - windowHeight) / 2
        
        let window = NSWindow(
            contentRect: NSRect(x: x, y: y, width: windowWidth, height: windowHeight),
            styleMask: [.borderless, .resizable],
            backing: .buffered,
            defer: false
        )
        
        // Configure window for overlay behavior
        window.isOpaque = false
        window.backgroundColor = .clear
        window.hasShadow = false
        window.level = .statusBar
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        window.ignoresMouseEvents = true // Start with click-through enabled
        
        // Set up SwiftUI content
        window.contentView = NSHostingView(rootView: view)
        
        super.init(window: window)
        
        // Load saved position and size
        loadWindowFrame()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func toggle() {
        guard let window = window else { return }
        
        if window.isVisible {
            window.orderOut(nil)
        } else {
            window.orderFrontRegardless() // Show without stealing focus
        }
    }
    
    func show() {
        centerWindow()
        window?.orderFrontRegardless()
    }
    
    func centerWindow() {
        guard let window = window else { return }
        
        // Get the screen that contains the mouse cursor
        let mouseLocation = NSEvent.mouseLocation
        let targetScreen = NSScreen.screens.first { screen in
            NSMouseInRect(mouseLocation, screen.frame, false)
        } ?? NSScreen.main ?? NSScreen.screens.first!
        
        let screenFrame = targetScreen.visibleFrame
        let windowSize = window.frame.size
        
        let x = screenFrame.origin.x + (screenFrame.size.width - windowSize.width) / 2
        let y = screenFrame.origin.y + (screenFrame.size.height - windowSize.height) / 2
        
        window.setFrame(NSRect(x: x, y: y, width: windowSize.width, height: windowSize.height), display: true)
    }
    
    func hide() {
        window?.orderOut(nil)
    }
    
    func setClickThrough(_ enabled: Bool) {
        window?.ignoresMouseEvents = enabled
    }
    
    private func loadWindowFrame() {
        guard let window = window else { return }
        
        if let frameString = UserDefaults.standard.string(forKey: "OverlayWindowFrame") {
            let frame = NSRectFromString(frameString)
            if !frame.isEmpty {
                window.setFrame(frame, display: true)
            }
        }
    }
    
    private func saveWindowFrame() {
        guard let window = window else { return }
        let frameString = NSStringFromRect(window.frame)
        UserDefaults.standard.set(frameString, forKey: "OverlayWindowFrame")
    }
    
    deinit {
        saveWindowFrame()
    }
}