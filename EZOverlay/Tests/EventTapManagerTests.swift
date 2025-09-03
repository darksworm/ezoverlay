import XCTest
@testable import EZOverlay

final class EventTapManagerTests: XCTestCase {
    var eventTapManager: EventTapManager!
    
    override func setUp() {
        super.setUp()
        eventTapManager = EventTapManager()
    }
    
    override func tearDown() {
        eventTapManager?.stop()
        eventTapManager = nil
        super.tearDown()
    }
    
    func testEventTapManagerInitialization() {
        // Given & When - created in setUp
        
        // Then
        XCTAssertNotNil(eventTapManager)
    }
    
    func testStartEventTap() {
        // Given
        var layerChanges: [Int] = []
        let expectation = XCTestExpectation(description: "Layer change callback")
        expectation.isInverted = true // We don't expect this to be fulfilled in unit tests
        
        // When
        eventTapManager.start { layerIndex in
            layerChanges.append(layerIndex)
            expectation.fulfill()
        }
        
        // Then - should not crash (actual functionality requires accessibility permissions)
        wait(for: [expectation], timeout: 0.1)
        XCTAssertTrue(layerChanges.isEmpty, "No layer changes expected in unit test environment")
    }
    
    func testStopEventTap() {
        // Given
        eventTapManager.start { _ in }
        
        // When
        eventTapManager.stop()
        
        // Then - should not crash
        XCTAssertNotNil(eventTapManager)
    }
    
    func testAccessibilityPermissionCheck() {
        // Given & When
        let hasPermission = eventTapManager.checkAccessibilityPermission()
        
        // Then - in test environment, likely false unless specifically granted
        XCTAssertNotNil(hasPermission, "Should return a boolean value")
    }
    
    func testEventTapManagerDeinitialization() {
        // Given
        eventTapManager.start { _ in }
        
        // When
        eventTapManager = nil
        
        // Then - should not crash (deinit should clean up resources)
        XCTAssertNil(eventTapManager)
    }
    
    func testMultipleStartCalls() {
        // Given
        var firstCallCount = 0
        var secondCallCount = 0
        
        // When - start first event tap
        eventTapManager.start { _ in firstCallCount += 1 }
        
        // Then start second event tap (should replace first)
        eventTapManager.start { _ in secondCallCount += 1 }
        
        // Then - should not crash
        XCTAssertNotNil(eventTapManager)
    }
}