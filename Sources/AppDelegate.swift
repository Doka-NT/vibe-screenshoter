import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var screenshotManager: ScreenshotManager?
    var settingsManager: SettingsManager?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Initialize managers
        settingsManager = SettingsManager()
        screenshotManager = ScreenshotManager(settingsManager: settingsManager!)
        
        // Setup menu bar icon
        setupMenuBar()
        
        // Register global shortcut
        registerGlobalShortcut()
        
        // Setup launch at login if enabled
        setupLaunchAtLogin()
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        // Cleanup
        screenshotManager?.cleanup()
    }
    
    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
    
    private func setupMenuBar() {
        // Create status item in menu bar
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        
        if let button = statusItem?.button {
            // Set icon for menu bar
            let image = NSImage(systemSymbolName: "camera.fill", accessibilityDescription: "Screenshot")
            image?.isTemplate = true
            button.image = image
        }
        
        // Create menu
        let menu = NSMenu()
        
        menu.addItem(NSMenuItem(title: "Запустить скриншот", action: #selector(takeScreenshot), keyEquivalent: "s"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Настройки...", action: #selector(openSettings), keyEquivalent: ","))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Выход", action: #selector(quitApp), keyEquivalent: "q"))
        
        statusItem?.menu = menu
    }
    
    private func registerGlobalShortcut() {
        // Register global keyboard shortcut (Command + Shift + S)
        guard let settingsManager = settingsManager else { return }
        
        let keyCode = settingsManager.shortcutKeyCode
        let modifiers = settingsManager.shortcutModifiers
        
        screenshotManager?.registerShortcut(keyCode: keyCode, modifiers: modifiers)
    }
    
    private func setupLaunchAtLogin() {
        guard let settingsManager = settingsManager else { return }
        
        if settingsManager.launchAtLogin {
            // Enable launch at login
            enableLaunchAtLogin()
        }
    }
    
    private func enableLaunchAtLogin() {
        // This would use LaunchServices or SMLoginItemSetEnabled
        // For now, we'll add placeholder
        print("Launch at login enabled")
    }
    
    @objc func takeScreenshot() {
        screenshotManager?.startScreenshotCapture()
    }
    
    @objc func openSettings() {
        let settingsWindow = SettingsWindowController(settingsManager: settingsManager!)
        settingsWindow.showWindow(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    @objc func quitApp() {
        NSApplication.shared.terminate(nil)
    }
}
