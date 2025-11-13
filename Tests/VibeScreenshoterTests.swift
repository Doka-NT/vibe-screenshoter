import XCTest
@testable import VibeScreenshoter

final class VibeScreenshoterTests: XCTestCase {
    
    func testSettingsManagerDefaults() {
        let settings = SettingsManager()
        
        // Test default shortcut key code
        XCTAssertEqual(settings.shortcutKeyCode, 1, "Default shortcut should be 's' key")
        
        // Test default save format
        XCTAssertEqual(settings.saveFormat, .png, "Default format should be PNG")
        
        // Test save path is not nil
        XCTAssertNotNil(settings.savePath, "Save path should have a default value")
    }
    
    func testSettingsManagerPersistence() {
        let settings = SettingsManager()
        
        // Set values
        settings.launchAtLogin = true
        settings.saveFormat = .jpeg
        
        // Verify values
        XCTAssertTrue(settings.launchAtLogin, "Launch at login should be true")
        XCTAssertEqual(settings.saveFormat, .jpeg, "Format should be JPEG")
    }
    
    func testSaveFormatEnum() {
        XCTAssertNotEqual(SaveFormat.png, SaveFormat.jpeg, "PNG and JPEG should be different")
    }
}
