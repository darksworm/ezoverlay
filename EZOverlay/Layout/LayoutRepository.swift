import Foundation

final class LayoutRepository: ObservableObject {
    @Published var currentLayer: Layer?
    @Published var availableLayers: [Layer] = []
    
    private let userDefaults = UserDefaults.standard
    private let currentLayerKey = "CurrentLayerID"
    
    init() {
        if !loadKeymapJSONIfPresent() {
            loadDefaultLayers()
        }
        loadCurrentLayer()
    }
    
    func loadLayer(id: String) -> Layer? {
        return availableLayers.first { $0.id == id }
    }
    
    func setCurrentLayer(_ layer: Layer) {
        currentLayer = layer
        userDefaults.set(layer.id, forKey: currentLayerKey)
    }
    
    func switchToLayer(at index: Int) {
        guard index >= 0 && index < availableLayers.count else { return }
        setCurrentLayer(availableLayers[index])
    }
    
    private func loadKeymapJSONIfPresent() -> Bool {
        let searchPaths = ["keymap.json", "../keymap.json"]
        let fileManager = FileManager.default

        for path in searchPaths {
            let url = URL(fileURLWithPath: path)
            if fileManager.fileExists(atPath: url.path) {
                return loadOryxLayout(from: url)
            }
        }
        return false
    }

    private func loadDefaultLayers() {
        // Default layers for v1 - these would eventually load from PNG assets or JSON
        availableLayers = [
            Layer(id: "base", title: "Base Layer", imageName: "layer_base", layout: nil),
            Layer(id: "symbols", title: "Symbols", imageName: "layer_symbols", layout: nil),
            Layer(id: "numbers", title: "Numbers", imageName: "layer_numbers", layout: nil),
            Layer(id: "function", title: "Function", imageName: "layer_function", layout: nil),
            Layer(id: "navigation", title: "Navigation", imageName: "layer_navigation", layout: nil)
        ]
    }
    
    private func loadCurrentLayer() {
        let savedLayerID = userDefaults.string(forKey: currentLayerKey) ?? "base"
        currentLayer = loadLayer(id: savedLayerID) ?? availableLayers.first
    }
    
    // Load layer from JSON file (for v1.1)
    func loadLayerFromJSON(url: URL) -> Layer? {
        do {
            let data = try Data(contentsOf: url)
            let layer = try JSONDecoder().decode(Layer.self, from: data)
            return layer
        } catch {
            print("Failed to load layer from JSON: \(error)")
            return nil
        }
    }
    
    // Save layer to JSON (for future use)
    func saveLayerToJSON(_ layer: Layer, to url: URL) -> Bool {
        do {
            let data = try JSONEncoder().encode(layer)
            try data.write(to: url)
            return true
        } catch {
            print("Failed to save layer to JSON: \(error)")
            return false
        }
    }
    
    // Load layers from Oryx JSON export
    func loadOryxLayout(from url: URL) -> Bool {
        do {
            let oryxLayers = try OryxParser.parseOryxJSON(from: url)
            
            // Replace current layers with Oryx layers
            availableLayers = oryxLayers
            
            // Set first layer as current
            if let firstLayer = oryxLayers.first {
                setCurrentLayer(firstLayer)
            }
            
            print("Successfully loaded \(oryxLayers.count) layers from Oryx")
            return true
        } catch {
            print("Failed to load Oryx layout: \(error)")
            return false
        }
    }
    
    // Load layers from Oryx JSON string
    func loadOryxLayout(from jsonString: String) -> Bool {
        do {
            let oryxLayers = try OryxParser.parseOryxJSON(from: jsonString)
            
            // Replace current layers with Oryx layers
            availableLayers = oryxLayers
            
            // Set first layer as current
            if let firstLayer = oryxLayers.first {
                setCurrentLayer(firstLayer)
            }
            
            print("Successfully loaded \(oryxLayers.count) layers from Oryx JSON")
            return true
        } catch {
            print("Failed to load Oryx layout from string: \(error)")
            return false
        }
    }
}