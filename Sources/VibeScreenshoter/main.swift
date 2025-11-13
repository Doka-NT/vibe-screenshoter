import Cocoa
import VibeScreenshoterLib

// Main entry point
let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate

// Make app an agent (LSUIElement = YES) - runs without dock icon
app.setActivationPolicy(.accessory)

_ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
