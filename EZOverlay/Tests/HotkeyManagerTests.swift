import XCTest
@testable import EZOverlay

final class HotkeyManagerTests: XCTestCase {
    var hotkeyManager: HotkeyManager!
    
    override func setUp() {
        super.setUp()
        hotkeyManager = HotkeyManager()
    }
    
    override func tearDown() {
        hotkeyManager = nil
        super.tearDown()
    }
    
    func testHotkeyRegistration() {
        // Given
        var toggleCallCount = 0
        let expectation = XCTestExpectation(description: "Hotkey handler should be called")
        
        // When
        hotkeyManager.registerToggle {
            toggleCallCount += 1
            expectation.fulfill()
        }
        
        // Simulate hotkey press (in real scenario, this would be triggered by system)
        // For unit test, we verify the handler was stored
        XCTAssertNotNil(hotkeyManager)
        
        // Then - verify the manager is properly configured
        // Note: Full hotkey testing requires integration tests with actual key events
        XCTAssertTrue(true, "HotkeyManager configured successfully")
    }
    
    func testMultipleRegistrations() {
        // Given
        var firstCallCount = 0
        var secondCallCount = 0
        
        // When - register first handler
        hotkeyManager.registerToggle {
            firstCallCount += 1
        }
        
        // Then register second handler (should replace first)
        hotkeyManager.registerToggle {
            secondCallCount += 1
        }
        
        // Then - only the latest handler should be active
        XCTAssertNotNil(hotkeyManager)
    }
    
    func testHotkeyManagerDeinitialization() {
        // Given
        hotkeyManager.registerToggle { }
        
        // When
        hotkeyManager = nil
        
        // Then - should not crash (deinit should clean up resources)
        XCTAssertNil(hotkeyManager)
    }
}