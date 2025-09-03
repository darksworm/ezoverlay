import XCTest
@testable import EZOverlay

final class LayoutRepositoryTests: XCTestCase {
    var repository: LayoutRepository!
    
    override func setUp() {
        super.setUp()
        repository = LayoutRepository()
    }
    
    override func tearDown() {
        repository = nil
        super.tearDown()
    }
    
    func testLoadExistingLayer() {
        // Given
        let layerID = "base"
        
        // When
        let layer = repository.loadLayer(id: layerID)
        
        // Then
        XCTAssertNotNil(layer)
        XCTAssertEqual(layer?.id, layerID)
        XCTAssertEqual(layer?.title, "Base Layer")
    }
    
    func testLoadNonExistentLayer() {
        // Given
        let nonExistentID = "nonexistent"
        
        // When
        let layer = repository.loadLayer(id: nonExistentID)
        
        // Then
        XCTAssertNil(layer)
    }
    
    func testDefaultLayersLoaded() {
        // Given & When - repository initialized in setUp
        
        // Then
        XCTAssertGreaterThan(repository.availableLayers.count, 0)
        XCTAssertNotNil(repository.currentLayer)
        
        let expectedLayers = ["base", "symbols", "numbers", "function", "navigation"]
        let actualLayerIDs = repository.availableLayers.map { $0.id }
        
        for expectedID in expectedLayers {
            XCTAssertTrue(actualLayerIDs.contains(expectedID), "Missing expected layer: \(expectedID)")
        }
    }
    
    func testSetCurrentLayer() {
        // Given
        let symbolsLayer = Layer(id: "test", title: "Test Layer", imageName: nil, layout: nil)
        
        // When
        repository.setCurrentLayer(symbolsLayer)
        
        // Then
        XCTAssertEqual(repository.currentLayer?.id, "test")
        XCTAssertEqual(repository.currentLayer?.title, "Test Layer")
    }
    
    func testSwitchToLayerByIndex() {
        // Given
        let validIndex = 1
        let originalLayer = repository.currentLayer
        
        // When
        repository.switchToLayer(at: validIndex)
        
        // Then
        XCTAssertNotEqual(repository.currentLayer?.id, originalLayer?.id)
        XCTAssertEqual(repository.currentLayer?.id, repository.availableLayers[validIndex].id)
    }
    
    func testSwitchToInvalidIndex() {
        // Given
        let invalidIndex = 999
        let originalLayer = repository.currentLayer
        
        // When
        repository.switchToLayer(at: invalidIndex)
        
        // Then - should not change current layer
        XCTAssertEqual(repository.currentLayer?.id, originalLayer?.id)
    }
    
    func testJSONSerialization() {
        // Given
        let testLayer = Layer(
            id: "test",
            title: "Test Layer",
            imageName: "test_image",
            layout: [
                KeyLabel(row: 0, column: 0, text: "A"),
                KeyLabel(row: 0, column: 1, text: "B")
            ]
        )
        
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("test_layer.json")
        
        // When - save to JSON
        let saveSuccess = repository.saveLayerToJSON(testLayer, to: tempURL)
        
        // Then
        XCTAssertTrue(saveSuccess)
        XCTAssertTrue(FileManager.default.fileExists(atPath: tempURL.path))
        
        // When - load from JSON
        let loadedLayer = repository.loadLayerFromJSON(url: tempURL)
        
        // Then
        XCTAssertNotNil(loadedLayer)
        XCTAssertEqual(loadedLayer?.id, testLayer.id)
        XCTAssertEqual(loadedLayer?.title, testLayer.title)
        XCTAssertEqual(loadedLayer?.layout?.count, 2)
        XCTAssertEqual(loadedLayer?.layout?[0].text, "A")
        XCTAssertEqual(loadedLayer?.layout?[1].text, "B")
        
        // Cleanup
        try? FileManager.default.removeItem(at: tempURL)
    }
    
    func testLoadInvalidJSON() {
        // Given
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("invalid.json")
        try? "invalid json content".write(to: tempURL, atomically: true, encoding: .utf8)
        
        // When
        let loadedLayer = repository.loadLayerFromJSON(url: tempURL)
        
        // Then
        XCTAssertNil(loadedLayer)
        
        // Cleanup
        try? FileManager.default.removeItem(at: tempURL)
    }
}