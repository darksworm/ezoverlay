import SwiftUI

struct OverlayView: View {
    @StateObject private var layoutRepository = LayoutRepository()
    @AppStorage("opacity") private var opacity: Double = 0.85
    @State private var layerChangeHighlight: Bool = false
    
    var body: some View {
        Group {
            if let layer = layoutRepository.currentLayer, let imageName = layer.imageName {
                // Try to load the image, fall back to placeholder if not found
                Group {
                    if Bundle.main.url(forResource: imageName, withExtension: "png") != nil {
                        Image(imageName)
                            .resizable()
                            .scaledToFit()
                    } else {
                        createPlaceholder(for: layer)
                    }
                }
                .opacity(opacity)
            } else {
                // Fallback placeholder for testing
                createPlaceholder(for: layoutRepository.currentLayer)
                    .opacity(opacity)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.clear)
        .onReceive(NotificationCenter.default.publisher(for: .layerChanged)) { notification in
            if let layer = notification.object as? Layer {
                layoutRepository.setCurrentLayer(layer)
                
                // Brief highlight animation for layer change
                withAnimation(.easeInOut(duration: 0.3)) {
                    layerChangeHighlight = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        layerChangeHighlight = false
                    }
                }
            }
        }
    }
    
    private func createPlaceholder(for layer: Layer?) -> some View {
        // Create actual Ergodox EZ layout visualization
        if let layer = layer, let keyLayout = layer.layout {
            return AnyView(createKeyboardLayoutView(from: keyLayout, layerTitle: layer.title))
        } else {
            return AnyView(createDefaultErgodoxLayout(layerTitle: layer?.title ?? "Base Layer"))
        }
    }
    
    private func createDefaultErgodoxLayout(layerTitle: String) -> some View {
        VStack(spacing: 8) {
            // Title and layer indicator
            HStack {
                // Layer navigation arrows
                Button(action: { previousLayer() }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.white.opacity(0.7))
                        .font(.title2)
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.leading, 8)
                
                Spacer()
                
                VStack(spacing: 4) {
                    Text(layerTitle)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Layer \(getCurrentLayerIndex() + 1)/\(layoutRepository.availableLayers.count)")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(Color.black.opacity(0.8))
                .cornerRadius(15)
                
                Spacer()
                
                // Next layer button
                Button(action: { nextLayer() }) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.white.opacity(0.7))
                        .font(.title2)
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.trailing, 8)
            }
            .padding(.bottom, 8)
            
            HStack(spacing: 60) {
                // Left hand
                createErgodoxHalf(isLeft: true, layerTitle: layerTitle)
                
                // Right hand  
                createErgodoxHalf(isLeft: false, layerTitle: layerTitle)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.black.opacity(0.7))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(layerChangeHighlight ? Color.blue.opacity(0.9) : Color.white.opacity(0.4), 
                               lineWidth: layerChangeHighlight ? 4 : 2)
                        .animation(.easeInOut(duration: 0.3), value: layerChangeHighlight)
                )
        )
    }
    
    private func createErgodoxHalf(isLeft: Bool, layerTitle: String) -> some View {
        let baseKeys = getKeysForLayer(layerTitle, isLeft: isLeft)
        
        return VStack(spacing: 6) {
            // Top row (numbers/symbols)
            createKeyRow(baseKeys.topRow)
            
            // Upper row
            createKeyRow(baseKeys.upperRow)
            
            // Home row
            createKeyRow(baseKeys.homeRow)
            
            // Lower row
            createKeyRow(baseKeys.lowerRow)
            
            // Thumb cluster
            createThumbCluster(baseKeys.thumbKeys, isLeft: isLeft)
        }
    }
    
    private func createKeyRow(_ keys: [String]) -> some View {
        HStack(spacing: 4) {
            ForEach(Array(keys.enumerated()), id: \.offset) { index, key in
                createKeyButton(key)
            }
        }
    }
    
    private func createThumbCluster(_ keys: [String], isLeft: Bool) -> some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                ForEach(Array(keys.prefix(2).enumerated()), id: \.offset) { index, key in
                    createKeyButton(key)
                        .frame(width: 50, height: 35)
                }
            }
            
            HStack(spacing: 4) {
                ForEach(Array(keys.dropFirst(2).enumerated()), id: \.offset) { index, key in
                    createKeyButton(key)
                        .frame(width: 60, height: 45)
                }
            }
        }
    }
    
    private func createKeyButton(_ label: String) -> some View {
        Text(label)
            .font(.system(size: 12, weight: .semibold, design: .monospaced))
            .foregroundColor(.white)
            .frame(width: 40, height: 35)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.gray.opacity(0.8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.white.opacity(0.5), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.3), radius: 2, x: 0, y: 1)
            )
    }
    
    private func createKeyboardLayoutView(from layout: [KeyLabel], layerTitle: String) -> some View {
        // Render from JSON layout data
        VStack {
            Text(layerTitle)
                .font(.headline)
                .foregroundColor(.white)
                .padding()
            
            // Create a grid from the layout data
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 2), count: 14), spacing: 2) {
                ForEach(layout.sorted { $0.row < $1.row || ($0.row == $1.row && $0.column < $1.column) }, id: \.text) { keyLabel in
                    createKeyButton(keyLabel.text)
                }
            }
        }
        .padding()
        .background(Color.black.opacity(0.3))
        .cornerRadius(15)
    }
    
    private func getKeysForLayer(_ layerTitle: String, isLeft: Bool) -> (topRow: [String], upperRow: [String], homeRow: [String], lowerRow: [String], thumbKeys: [String]) {
        switch layerTitle.lowercased() {
        case "base layer", "base":
            if isLeft {
                return (
                    topRow: ["=", "1", "2", "3", "4", "5"],
                    upperRow: ["Del", "Q", "W", "E", "R", "T"],
                    homeRow: ["BkSp", "A", "S", "D", "F", "G"],
                    lowerRow: ["LSft", "Z", "X", "C", "V", "B"],
                    thumbKeys: ["Gui", "Alt", "Ctrl", "Space"]
                )
            } else {
                return (
                    topRow: ["6", "7", "8", "9", "0", "-"],
                    upperRow: ["Y", "U", "I", "O", "P", "\\"],
                    homeRow: ["H", "J", "K", "L", ";", "'"],
                    lowerRow: ["N", "M", ",", ".", "/", "RSft"],
                    thumbKeys: ["Left", "Down", "Up", "Right"]
                )
            }
        case "symbols":
            if isLeft {
                return (
                    topRow: ["+", "!", "@", "#", "$", "%"],
                    upperRow: ["Del", "{", "}", "[", "]", "|"],
                    homeRow: ["BkSp", "<", ">", "(", ")", "&"],
                    lowerRow: ["LSft", "~", "`", "^", "*", "\\"],
                    thumbKeys: ["Gui", "Alt", "Ctrl", "Space"]
                )
            } else {
                return (
                    topRow: ["^", "&", "*", "(", ")", "_"],
                    upperRow: ["|", "\"", ":", "?", "+", "}"],
                    homeRow: ["&", "!", "?", ":", ";", "\""],
                    lowerRow: ["/", "<", ">", "{", "}", "RSft"],
                    thumbKeys: ["Left", "Down", "Up", "Right"]
                )
            }
        case "numbers":
            if isLeft {
                return (
                    topRow: ["F1", "F2", "F3", "F4", "F5", "F6"],
                    upperRow: ["Del", "1", "2", "3", "4", "5"],
                    homeRow: ["BkSp", "6", "7", "8", "9", "0"],
                    lowerRow: ["LSft", "+", "-", "*", "/", "="],
                    thumbKeys: ["Gui", "Alt", "Ctrl", "Space"]
                )
            } else {
                return (
                    topRow: ["F7", "F8", "F9", "F10", "F11", "F12"],
                    upperRow: ["6", "7", "8", "9", "0", "Num"],
                    homeRow: [".", "4", "5", "6", "+", "Ent"],
                    lowerRow: ["0", "1", "2", "3", ".", "RSft"],
                    thumbKeys: ["Left", "Down", "Up", "Right"]
                )
            }
        default:
            if isLeft {
                return (
                    topRow: ["F1", "F2", "F3", "F4", "F5", "F6"],
                    upperRow: ["Tab", "Q", "W", "E", "R", "T"],
                    homeRow: ["Cap", "A", "S", "D", "F", "G"],
                    lowerRow: ["Sft", "Z", "X", "C", "V", "B"],
                    thumbKeys: ["Gui", "Alt", "Ctrl", "Spc"]
                )
            } else {
                return (
                    topRow: ["F7", "F8", "F9", "F10", "F11", "F12"],
                    upperRow: ["Y", "U", "I", "O", "P", "\\"],
                    homeRow: ["H", "J", "K", "L", ";", "'"],
                    lowerRow: ["N", "M", ",", ".", "/", "Sft"],
                    thumbKeys: ["←", "↓", "↑", "→"]
                )
            }
        }
    }
    
    private func previousLayer() {
        let currentIndex = getCurrentLayerIndex()
        let newIndex = currentIndex > 0 ? currentIndex - 1 : layoutRepository.availableLayers.count - 1
        layoutRepository.switchToLayer(at: newIndex)
    }
    
    private func nextLayer() {
        let currentIndex = getCurrentLayerIndex()
        let newIndex = (currentIndex + 1) % layoutRepository.availableLayers.count
        layoutRepository.switchToLayer(at: newIndex)
    }
    
    private func getCurrentLayerIndex() -> Int {
        guard let currentLayer = layoutRepository.currentLayer else { return 0 }
        return layoutRepository.availableLayers.firstIndex { $0.id == currentLayer.id } ?? 0
    }
}

extension Notification.Name {
    static let layerChanged = Notification.Name("layerChanged")
}