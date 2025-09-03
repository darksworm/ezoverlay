import Quartz
import Foundation

final class EventTapManager {
    private var tap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    private var onLayerChange: ((Int) -> Void)?
    
    deinit {
        stop()
    }
    
    func start(onLayerChange: @escaping (Int) -> Void) {
        // Check if we already have accessibility permission
        guard checkAccessibilityPermission() else {
            print("Input Monitoring permission not granted")
            return
        }
        
        self.onLayerChange = onLayerChange
        
        let eventMask = CGEventMask(1 << CGEventType.keyDown.rawValue)
        
        tap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: eventMask,
            callback: { (proxy, type, event, refcon) in
                let manager = Unmanaged<EventTapManager>.fromOpaque(refcon!).takeUnretainedValue()
                return manager.handleEvent(proxy: proxy, type: type, event: event)
            },
            userInfo: Unmanaged.passUnretained(self).toOpaque()
        )
        
        guard let tap = tap else {
            print("Failed to create event tap")
            return
        }
        
        runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
        guard let runLoopSource = runLoopSource else {
            print("Failed to create run loop source")
            return
        }
        
        CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
        CGEvent.tapEnable(tap: tap, enable: true)
        
        print("EventTapManager started - listening for F13-F20 keys")
    }
    
    func stop() {
        if let tap = tap {
            CGEvent.tapEnable(tap: tap, enable: false)
            CFMachPortInvalidate(tap)
            self.tap = nil
        }
        
        if let runLoopSource = runLoopSource {
            CFRunLoopRemoveSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
            self.runLoopSource = nil
        }
        
        print("EventTapManager stopped")
    }
    
    private func handleEvent(proxy: CGEventTapProxy, type: CGEventType, event: CGEvent) -> Unmanaged<CGEvent>? {
        // Handle event tap being disabled (e.g., due to timeout)
        if type == .tapDisabledByTimeout {
            if let tap = tap {
                CGEvent.tapEnable(tap: tap, enable: true)
            }
            return Unmanaged.passUnretained(event)
        }
        
        if type == .keyDown {
            let keyCode = event.getIntegerValueField(.keyboardEventKeycode)
            
            // F13-F20 key codes: 105-112
            if (105...112).contains(keyCode) {
                let layerIndex = Int(keyCode - 105)
                print("F\(layerIndex + 13) pressed - switching to layer \(layerIndex)")
                onLayerChange?(layerIndex)
            }
        }
        
        return Unmanaged.passUnretained(event)
    }
    
    func checkAccessibilityPermission() -> Bool {
        let trusted = AXIsProcessTrusted()
        if !trusted {
            print("Process is not trusted for accessibility access")
            // In a real app, you might want to prompt the user to grant permission
            requestAccessibilityPermission()
        }
        return trusted
    }
    
    private func requestAccessibilityPermission() {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
        AXIsProcessTrustedWithOptions(options as CFDictionary)
    }
}