import Foundation

// MARK: - Oryx JSON Data Structures
struct OryxLayout: Codable {
    let keyboard: String
    let keymap: String
    let version: String?
    let author: String?
    let notes: String?
    let layout: String
    let layers: [[String]]
    
    private enum CodingKeys: String, CodingKey {
        case keyboard, keymap, version, author, notes, layout, layers
    }
}

// MARK: - QMK Key Code Mappings
struct QMKKeyCodes {
    // Common key mappings from QMK to display text
    static let keyMappings: [String: String] = [
        // Letters
        "KC_A": "A", "KC_B": "B", "KC_C": "C", "KC_D": "D", "KC_E": "E",
        "KC_F": "F", "KC_G": "G", "KC_H": "H", "KC_I": "I", "KC_J": "J",
        "KC_K": "K", "KC_L": "L", "KC_M": "M", "KC_N": "N", "KC_O": "O",
        "KC_P": "P", "KC_Q": "Q", "KC_R": "R", "KC_S": "S", "KC_T": "T",
        "KC_U": "U", "KC_V": "V", "KC_W": "W", "KC_X": "X", "KC_Y": "Y", "KC_Z": "Z",
        
        // Numbers
        "KC_1": "1", "KC_2": "2", "KC_3": "3", "KC_4": "4", "KC_5": "5",
        "KC_6": "6", "KC_7": "7", "KC_8": "8", "KC_9": "9", "KC_0": "0",
        
        // Symbols
        "KC_MINUS": "-", "KC_EQUAL": "=", "KC_LEFT_BRACKET": "[", "KC_RIGHT_BRACKET": "]",
        "KC_BACKSLASH": "\\", "KC_SEMICOLON": ";", "KC_QUOTE": "'", "KC_GRAVE": "`",
        "KC_COMMA": ",", "KC_DOT": ".", "KC_SLASH": "/",
        
        // Modifiers
        "KC_LSHIFT": "LSft", "KC_RSHIFT": "RSft", "KC_LCTRL": "LCtl", "KC_RCTRL": "RCtl",
        "KC_LALT": "LAlt", "KC_RALT": "RAlt", "KC_LGUI": "LGui", "KC_RGUI": "RGui",
        
        // Function keys
        "KC_F1": "F1", "KC_F2": "F2", "KC_F3": "F3", "KC_F4": "F4", "KC_F5": "F5",
        "KC_F6": "F6", "KC_F7": "F7", "KC_F8": "F8", "KC_F9": "F9", "KC_F10": "F10",
        "KC_F11": "F11", "KC_F12": "F12", "KC_F13": "F13", "KC_F14": "F14", "KC_F15": "F15",
        "KC_F16": "F16", "KC_F17": "F17", "KC_F18": "F18", "KC_F19": "F19", "KC_F20": "F20",
        
        // Special keys
        "KC_SPACE": "Space", "KC_ENTER": "Enter", "KC_ESCAPE": "Esc", "KC_TAB": "Tab",
        "KC_BACKSPACE": "BkSp", "KC_DELETE": "Del", "KC_INSERT": "Ins",
        "KC_HOME": "Home", "KC_END": "End", "KC_PAGE_UP": "PgUp", "KC_PAGE_DOWN": "PgDn",
        
        // Arrow keys
        "KC_LEFT": "←", "KC_DOWN": "↓", "KC_UP": "↑", "KC_RIGHT": "→",
        
        // Layers
        "TO(1)": "→L1", "TO(2)": "→L2", "TO(3)": "→L3", "TO(4)": "→L4",
        "MO(1)": "L1", "MO(2)": "L2", "MO(3)": "L3", "MO(4)": "L4",
        "TG(1)": "⇄L1", "TG(2)": "⇄L2", "TG(3)": "⇄L3", "TG(4)": "⇄L4",
        
        // Empty/transparent
        "KC_TRANSPARENT": "▽", "KC_NO": "✗", "KC_TRNS": "▽",
        
        // Common combinations
        "LCTL(KC_C)": "Ctl+C", "LCTL(KC_V)": "Ctl+V", "LCTL(KC_X)": "Ctl+X", "LCTL(KC_Z)": "Ctl+Z"
    ]
    
    static func displayText(for keyCode: String) -> String {
        // Remove any whitespace
        let cleanCode = keyCode.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Check direct mapping
        if let mapped = keyMappings[cleanCode] {
            return mapped
        }
        
        // Handle layer switching patterns
        if cleanCode.starts(with: "TO(") {
            let layer = cleanCode.replacingOccurrences(of: "TO(", with: "").replacingOccurrences(of: ")", with: "")
            return "→L\(layer)"
        }
        
        if cleanCode.starts(with: "MO(") {
            let layer = cleanCode.replacingOccurrences(of: "MO(", with: "").replacingOccurrences(of: ")", with: "")
            return "L\(layer)"
        }
        
        if cleanCode.starts(with: "TG(") {
            let layer = cleanCode.replacingOccurrences(of: "TG(", with: "").replacingOccurrences(of: ")", with: "")
            return "⇄L\(layer)"
        }
        
        // Handle shifted symbols
        if cleanCode.starts(with: "LSFT(") || cleanCode.starts(with: "RSFT(") {
            let inner = cleanCode.replacingOccurrences(of: "LSFT(", with: "").replacingOccurrences(of: "RSFT(", with: "").replacingOccurrences(of: ")", with: "")
            return shiftedSymbol(for: inner)
        }
        
        // Remove KC_ prefix if present
        if cleanCode.starts(with: "KC_") {
            let withoutPrefix = String(cleanCode.dropFirst(3))
            return withoutPrefix.capitalized
        }
        
        // Return as-is if no mapping found, but limit length
        let result = cleanCode.isEmpty ? "?" : cleanCode
        return result.count > 6 ? String(result.prefix(6)) : result
    }
    
    private static func shiftedSymbol(for keyCode: String) -> String {
        let shiftedMappings: [String: String] = [
            "KC_1": "!", "KC_2": "@", "KC_3": "#", "KC_4": "$", "KC_5": "%",
            "KC_6": "^", "KC_7": "&", "KC_8": "*", "KC_9": "(", "KC_0": ")",
            "KC_MINUS": "_", "KC_EQUAL": "+", "KC_LEFT_BRACKET": "{", "KC_RIGHT_BRACKET": "}",
            "KC_BACKSLASH": "|", "KC_SEMICOLON": ":", "KC_QUOTE": "\"", "KC_GRAVE": "~",
            "KC_COMMA": "<", "KC_DOT": ">", "KC_SLASH": "?"
        ]
        
        return shiftedMappings[keyCode] ?? displayText(for: keyCode).uppercased()
    }
}

// MARK: - Oryx Parser
final class OryxParser {
    
    // Ergodox EZ key layout mapping (Oryx key index to our row/column)
    // Based on the standard Ergodox EZ 76-key layout
    private static let ergodoxKeyMap: [Int: (row: Int, column: Int, hand: String)] = [
        // Left hand
        0: (0, 0, "L"), 1: (0, 1, "L"), 2: (0, 2, "L"), 3: (0, 3, "L"), 4: (0, 4, "L"), 5: (0, 5, "L"), 6: (0, 6, "L"),
        7: (1, 0, "L"), 8: (1, 1, "L"), 9: (1, 2, "L"), 10: (1, 3, "L"), 11: (1, 4, "L"), 12: (1, 5, "L"), 13: (1, 6, "L"),
        14: (2, 0, "L"), 15: (2, 1, "L"), 16: (2, 2, "L"), 17: (2, 3, "L"), 18: (2, 4, "L"), 19: (2, 5, "L"),
        20: (3, 0, "L"), 21: (3, 1, "L"), 22: (3, 2, "L"), 23: (3, 3, "L"), 24: (3, 4, "L"), 25: (3, 5, "L"), 26: (3, 6, "L"),
        27: (4, 0, "L"), 28: (4, 1, "L"), 29: (4, 2, "L"), 30: (4, 3, "L"), 31: (4, 4, "L"),
        32: (5, 0, "L"), 33: (5, 1, "L"), 34: (5, 2, "L"), 35: (5, 3, "L"), 36: (5, 4, "L"), 37: (5, 5, "L"),
        
        // Right hand
        38: (0, 7, "R"), 39: (0, 8, "R"), 40: (0, 9, "R"), 41: (0, 10, "R"), 42: (0, 11, "R"), 43: (0, 12, "R"), 44: (0, 13, "R"),
        45: (1, 7, "R"), 46: (1, 8, "R"), 47: (1, 9, "R"), 48: (1, 10, "R"), 49: (1, 11, "R"), 50: (1, 12, "R"), 51: (1, 13, "R"),
        52: (2, 8, "R"), 53: (2, 9, "R"), 54: (2, 10, "R"), 55: (2, 11, "R"), 56: (2, 12, "R"), 57: (2, 13, "R"),
        58: (3, 7, "R"), 59: (3, 8, "R"), 60: (3, 9, "R"), 61: (3, 10, "R"), 62: (3, 11, "R"), 63: (3, 12, "R"), 64: (3, 13, "R"),
        65: (4, 9, "R"), 66: (4, 10, "R"), 67: (4, 11, "R"), 68: (4, 12, "R"), 69: (4, 13, "R"),
        70: (5, 8, "R"), 71: (5, 9, "R"), 72: (5, 10, "R"), 73: (5, 11, "R"), 74: (5, 12, "R"), 75: (5, 13, "R")
    ]
    
    static func parseOryxJSON(from url: URL) throws -> [Layer] {
        let data = try Data(contentsOf: url)
        let oryxLayout = try JSONDecoder().decode(OryxLayout.self, from: data)
        
        var layers: [Layer] = []
        
        for (layerIndex, layerKeys) in oryxLayout.layers.enumerated() {
            var keyLabels: [KeyLabel] = []
            
            for (keyIndex, keyCode) in layerKeys.enumerated() {
                guard let position = ergodoxKeyMap[keyIndex] else { continue }
                
                let displayText = QMKKeyCodes.displayText(for: keyCode)
                let keyLabel = KeyLabel(
                    row: position.row,
                    column: position.column,
                    text: displayText
                )
                keyLabels.append(keyLabel)
            }
            
            let layer = Layer(
                id: "oryx_layer_\(layerIndex)",
                title: "Layer \(layerIndex)",
                imageName: nil,
                layout: keyLabels
            )
            
            layers.append(layer)
        }
        
        return layers
    }
    
    static func parseOryxJSON(from jsonString: String) throws -> [Layer] {
        guard let data = jsonString.data(using: .utf8) else {
            throw NSError(domain: "OryxParser", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON string"])
        }
        
        let oryxLayout = try JSONDecoder().decode(OryxLayout.self, from: data)
        
        var layers: [Layer] = []
        
        for (layerIndex, layerKeys) in oryxLayout.layers.enumerated() {
            var keyLabels: [KeyLabel] = []
            
            for (keyIndex, keyCode) in layerKeys.enumerated() {
                guard let position = ergodoxKeyMap[keyIndex] else { continue }
                
                let displayText = QMKKeyCodes.displayText(for: keyCode)
                let keyLabel = KeyLabel(
                    row: position.row,
                    column: position.column,
                    text: displayText
                )
                keyLabels.append(keyLabel)
            }
            
            let layer = Layer(
                id: "oryx_layer_\(layerIndex)",
                title: "Layer \(layerIndex)",
                imageName: nil,
                layout: keyLabels
            )
            
            layers.append(layer)
        }
        
        return layers
    }
}