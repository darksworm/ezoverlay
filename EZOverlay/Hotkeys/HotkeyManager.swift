import Carbon

final class HotkeyManager {
    private var hotKeyRef: EventHotKeyRef?
    private var eventHandler: EventHandlerRef?
    private var toggleHandler: (() -> Void)?
    
    deinit {
        unregisterHotkey()
    }
    
    func registerToggle(_ handler: @escaping () -> Void) {
        self.toggleHandler = handler
        
        // Create event handler
        let callback: EventHandlerUPP = { (nextHandler, theEvent, userData) in
            let manager = Unmanaged<HotkeyManager>.fromOpaque(userData!).takeUnretainedValue()
            manager.toggleHandler?()
            return noErr
        }
        
        let eventType = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: UInt32(kEventHotKeyPressed)
        )
        
        let status = InstallEventHandler(
            GetApplicationEventTarget(),
            callback,
            1,
            [eventType],
            Unmanaged.passUnretained(self).toOpaque(),
            &eventHandler
        )
        
        guard status == noErr else {
            print("Failed to install event handler: \(status)")
            return
        }
        
        // Register hotkey: Cmd+Option+Ctrl+L
        let hotkeyID = EventHotKeyID(signature: fourCharCodeFrom("ezol"), id: 1)
        let registerStatus = RegisterEventHotKey(
            UInt32(kVK_ANSI_L),
            UInt32(controlKey | optionKey | cmdKey),
            hotkeyID,
            GetApplicationEventTarget(),
            0,
            &hotKeyRef
        )
        
        if registerStatus != noErr {
            print("Failed to register hotkey: \(registerStatus)")
        } else {
            print("Successfully registered hotkey: Cmd+Option+Ctrl+L")
        }
    }
    
    private func unregisterHotkey() {
        if let hotKeyRef = hotKeyRef {
            UnregisterEventHotKey(hotKeyRef)
            self.hotKeyRef = nil
        }
        
        if let eventHandler = eventHandler {
            RemoveEventHandler(eventHandler)
            self.eventHandler = nil
        }
    }
}

// Helper to convert string to FourCharCode
private func fourCharCodeFrom(_ string: String) -> FourCharCode {
    assert(string.count == 4)
    var result: FourCharCode = 0
    for char in string.unicodeScalars {
        result = (result << 8) | FourCharCode(char.value)
    }
    return result
}