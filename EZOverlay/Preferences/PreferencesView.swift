import SwiftUI

struct PreferencesView: View {
    @AppStorage("opacity") private var opacity: Double = 0.85
    @AppStorage("clickThrough") private var clickThrough = true
    @State private var showingHotkeyHelp = false
    @State private var showingOryxHelp = false
    @StateObject private var layoutRepository = LayoutRepository()
    
    var body: some View {
        Form {
            Section("Overlay Settings") {
                VStack(alignment: .leading) {
                    Text("Opacity: \(Int(opacity * 100))%")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Slider(
                        value: $opacity,
                        in: 0.2...1.0,
                        step: 0.1
                    ) {
                        Text("Opacity")
                    }
                }
                
                Toggle("Click through overlay", isOn: $clickThrough)
                    .help("When enabled, clicks pass through the overlay to the app underneath")
            }
            
            Section("Hotkeys") {
                HStack {
                    Text("Toggle overlay:")
                    Spacer()
                    Text("⌘⌥⌃L")
                        .font(.system(.body, design: .monospaced))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.secondary.opacity(0.2))
                        .cornerRadius(4)
                }
                
                Button("Show hotkey help") {
                    showingHotkeyHelp = true
                }
                .buttonStyle(.link)
            }
            
            Section("Layout Import") {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Import from Oryx")
                        .font(.headline)
                    
                    Text("Import your Ergodox EZ layout from ZSA's Oryx configurator")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Button("Import Oryx JSON") {
                            importOryxLayout()
                        }
                        
                        Spacer()
                        
                        Button("How to Export") {
                            showOryxHelp()
                        }
                        .buttonStyle(.link)
                    }
                }
            }
            
            Section("About") {
                HStack {
                    Text("EZOverlay")
                    Spacer()
                    Text("v1.0")
                        .foregroundColor(.secondary)
                }
                Text("Keyboard layout overlay for Ergodox EZ")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .formStyle(.grouped)
        .frame(minWidth: 400, minHeight: 300)
        .alert("Hotkey Help", isPresented: $showingHotkeyHelp) {
            Button("OK") { }
        } message: {
            Text("Press ⌘⌥⌃L (Command + Option + Control + L) to toggle the overlay on/off from anywhere in macOS.")
        }
        .alert("Oryx Export Instructions", isPresented: $showingOryxHelp) {
            Button("Open Oryx") {
                if let url = URL(string: "https://configure.zsa.io/") {
                    NSWorkspace.shared.open(url)
                }
            }
            Button("OK") { }
        } message: {
            Text("""
            To export your Ergodox EZ layout from Oryx:
            
            1. Go to configure.zsa.io
            2. Load or create your keyboard layout
            3. Click "Download source" button
            4. Extract the ZIP file
            5. Find the keymap.json file
            6. Import it here using "Import Oryx JSON"
            """)
        }
    }
    
    private func importOryxLayout() {
        let panel = NSOpenPanel()
        panel.title = "Import Oryx Layout"
        panel.message = "Select the keymap.json file from your Oryx source download"
        panel.allowedContentTypes = [.json]
        panel.allowsMultipleSelection = false
        
        if panel.runModal() == .OK, let url = panel.url {
            if layoutRepository.loadOryxLayout(from: url) {
                // Success - show notification or confirmation
                NSSound.beep()
            } else {
                // Show error alert
                let alert = NSAlert()
                alert.messageText = "Import Failed"
                alert.informativeText = "Could not import the Oryx layout. Please make sure you selected a valid keymap.json file from Oryx."
                alert.alertStyle = .warning
                alert.runModal()
            }
        }
    }
    
    private func showOryxHelp() {
        showingOryxHelp = true
    }
}