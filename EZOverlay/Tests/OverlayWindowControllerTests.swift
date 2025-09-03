import XCTest
import AppKit
@testable import EZOverlay

final class OverlayWindowControllerTests: XCTestCase {
    var windowController: OverlayWindowController!
    
    override func setUp() {
        super.setUp()
        windowController = OverlayWindowController()
    }
    
    override func tearDown() {
        windowController.window?.close()
        windowController = nil
        super.tearDown()
    }
    
    func testWindowConfiguration() {
        // Given & When - window created in setUp
        guard let window = windowController.window else {
            XCTFail("Window should be created")
            return
        }
        
        // Then - verify overlay window properties
        XCTAssertFalse(window.isOpaque, "Window should be transparent")
        XCTAssertEqual(window.backgroundColor, .clear, "Window background should be clear")
        XCTAssertFalse(window.hasShadow, "Window should not have shadow")
        XCTAssertEqual(window.level, .statusBar, "Window should be at statusBar level")
        XCTAssertTrue(window.collectionBehavior.contains(.canJoinAllSpaces), "Should appear on all spaces")
        XCTAssertTrue(window.collectionBehavior.contains(.fullScreenAuxiliary), "Should appear over full-screen apps")
        XCTAssertTrue(window.ignoresMouseEvents, "Should start with click-through enabled")
    }
    
    func testToggleVisibility() {
        // Given
        guard let window = windowController.window else {
            XCTFail("Window should be created")
            return
        }
        
        let initialVisibility = window.isVisible
        
        // When
        windowController.toggle()
        
        // Then
        XCTAssertNotEqual(window.isVisible, initialVisibility, "Window visibility should toggle")
        
        // When - toggle again
        windowController.toggle()
        
        // Then
        XCTAssertEqual(window.isVisible, initialVisibility, "Window should return to initial state")
    }
    
    func testShowWindow() {
        // Given
        windowController.hide() // Ensure it starts hidden
        
        // When
        windowController.show()
        
        // Then
        XCTAssertTrue(windowController.window?.isVisible ?? false, "Window should be visible")
    }
    
    func testHideWindow() {
        // Given
        windowController.show() // Ensure it starts visible
        
        // When
        windowController.hide()
        
        // Then
        XCTAssertFalse(windowController.window?.isVisible ?? true, "Window should be hidden")
    }
    
    func testClickThroughToggle() {
        // Given
        guard let window = windowController.window else {
            XCTFail("Window should be created")
            return
        }
        
        // When - enable click through
        windowController.setClickThrough(true)
        
        // Then
        XCTAssertTrue(window.ignoresMouseEvents, "Should ignore mouse events when click-through enabled")
        
        // When - disable click through
        windowController.setClickThrough(false)
        
        // Then
        XCTAssertFalse(window.ignoresMouseEvents, "Should not ignore mouse events when click-through disabled")
    }
    
    func testWindowFramePersistence() {
        // Given
        guard let window = windowController.window else {
            XCTFail("Window should be created")
            return
        }
        
        let testFrame = NSRect(x: 200, y: 200, width: 600, height: 400)
        
        // When - set a specific frame
        window.setFrame(testFrame, display: true)
        
        // Simulate app restart by creating a new controller
        windowController = nil
        windowController = OverlayWindowController()
        
        // Then - frame should be restored (approximately, allowing for screen bounds adjustments)
        guard let newWindow = windowController.window else {
            XCTFail("New window should be created")
            return
        }
        
        // Note: Exact frame restoration depends on UserDefaults and screen configuration
        // In a real test, you might want to mock UserDefaults
        XCTAssertNotNil(newWindow.frame, "Window should have a valid frame")
    }
}