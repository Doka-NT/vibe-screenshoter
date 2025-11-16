import Cocoa
import VibeScreenshoterLib

// Main entry point
// Keep delegate as a global variable to prevent deallocation
// NSApplication.delegate is weak, so we need a strong reference
var appDelegate: AppDelegate? = nil

let app = NSApplication.shared
appDelegate = AppDelegate()
app.delegate = appDelegate

// Make app an agent (LSUIElement = YES) - runs without dock icon
app.setActivationPolicy(.accessory)

app.run()
