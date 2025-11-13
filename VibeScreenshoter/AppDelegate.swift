import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var menu: NSMenu?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Create the status bar item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        // Set the icon for the status bar
        if let button = statusItem?.button {
            // Create a screenshot icon using SF Symbols
            if let image = NSImage(systemSymbolName: "camera.viewfinder", accessibilityDescription: "Screenshot") {
                image.isTemplate = true // Makes it adapt to dark/light mode
                button.image = image
            }
            button.toolTip = "Vibe Screenshoter"
        }
        
        // Create the menu
        setupMenu()
        
        // Activate the app
        NSApp.setActivationPolicy(.accessory)
    }
    
    func setupMenu() {
        menu = NSMenu()
        
        // Add menu items
        menu?.addItem(NSMenuItem(title: "Сделать снимок экрана", action: #selector(takeScreenshot), keyEquivalent: "s"))
        menu?.addItem(NSMenuItem(title: "Сделать снимок области", action: #selector(takeAreaScreenshot), keyEquivalent: "a"))
        menu?.addItem(NSMenuItem.separator())
        menu?.addItem(NSMenuItem(title: "О приложении", action: #selector(showAbout), keyEquivalent: ""))
        menu?.addItem(NSMenuItem.separator())
        menu?.addItem(NSMenuItem(title: "Выход", action: #selector(quitApp), keyEquivalent: "q"))
        
        statusItem?.menu = menu
    }
    
    @objc func takeScreenshot() {
        print("Захват полного экрана")
        // TODO: Implement full screen capture
    }
    
    @objc func takeAreaScreenshot() {
        print("Захват выбранной области")
        // TODO: Implement area screenshot capture
    }
    
    @objc func showAbout() {
        let alert = NSAlert()
        alert.messageText = "Vibe Screenshoter"
        alert.informativeText = "Простое приложение для создания скриншотов\nВерсия 1.0"
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
    
    @objc func quitApp() {
        NSApplication.shared.terminate(nil)
    }
}
