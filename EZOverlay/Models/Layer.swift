import Foundation

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