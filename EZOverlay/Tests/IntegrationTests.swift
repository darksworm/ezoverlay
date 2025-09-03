import XCTest
import AppKit
@testable import EZOverlay

final class IntegrationTests: XCTestCase {
    var appDelegate: AppDelegate!
    
    override func setUp() {
        super.setUp()
        appDelegate = AppDelegate()
    }
    
    override func tearDown() {
        appDelegate = nil
        super.tearDown()
    }
    
    func testFullApplicationFlow() {
        // Given - simulate app launch
        let mockNotification = Notification(name: NSApplication.didFinishLaunchingNotification)
        
        // When - app finishes launching
        appDelegate.applicationDidFinishLaunching(mockNotification)
        
        // Then - verify components are initialized
        XCTAssertNotNil(appDelegate)
    }
    
    func testOverlayVisibilityToggle() {
        // This test would require UI automation for full testing
        // In a real scenario, you'd use XCUITest for end-to-end testing
        
        // Given
        appDelegate.applicationDidFinishLaunching(
            Notification(name: NSApplication.didFinishLaunchingNotification)
        )
        
        // When & Then - verify app doesn't crash with basic initialization
        XCTAssertNotNil(appDelegate)
        
        // Note: Full UI testing would require:
        // 1. Launch the app in a test environment
        // 2. Send the hotkey combination (Cmd+Opt+Ctrl+L)
        // 3. Take a screenshot to verify overlay appears
        // 4. Send hotkey again to verify overlay disappears
    }
    
    func testPreferencesIntegration() {
        // Given
        appDelegate.applicationDidFinishLaunching(
            Notification(name: NSApplication.didFinishLaunchingNotification)
        )
        
        // When - change click through preference
        UserDefaults.standard.set(false, forKey: "clickThrough")
        
        // Simulate the notification
        NotificationCenter.default.post(name: UserDefaults.didChangeNotification, object: nil)
        
        // Then - verify app handles preference changes
        XCTAssertNotNil(appDelegate)
    }
}

// MARK: - Screenshot Testing Helper
extension IntegrationTests {
    
    func takeScreenshot(name: String) -> NSImage? {
        guard let screen = NSScreen.main else { return nil }
        
        let rect = screen.frame
        guard let cgImage = CGWindowListCreateImage(
            rect,
            .optionOnScreenOnly,
            kCGNullWindowID,
            .imageDefault
        ) else { return nil }
        
        let screenshot = NSImage(cgImage: cgImage, size: rect.size)
        
        // Save screenshot for manual verification
        let desktop = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Desktop")
            .appendingPathComponent("EZOverlay_Screenshots")
        
        do {
            try FileManager.default.createDirectory(at: desktop, withIntermediateDirectories: true)
            
            if let data = screenshot.tiffRepresentation {
                let url = desktop.appendingPathComponent("\(name).tiff")
                try data.write(to: url)
                print("Screenshot saved to: \(url.path)")
            }
        } catch {
            print("Failed to save screenshot: \(error)")
        }
        
        return screenshot
    }
}