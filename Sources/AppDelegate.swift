import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate, HotKeyDelegate {
    var statusItem: NSStatusItem!
    var settingsWindowController: NSWindowController?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Create the status item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        // Configure the button
        if let button = statusItem.button {
            // Use SF Symbol 'camera.viewfinder'
            // We use a configuration to ensure it scales properly if needed, but default is usually fine.
            if let image = NSImage(systemSymbolName: "camera.viewfinder", accessibilityDescription: "Screenshot") {
                // Set template to true so it adapts to light/dark mode automatically
                image.isTemplate = true 
                button.image = image
            } else {
                // Fallback if symbol not found (shouldn't happen on macOS 11+)
                button.title = "Cam"
            }
        }
        
        // Build the menu
        let menu = NSMenu()
        
        let captureScreenItem = NSMenuItem(title: "Снимок экрана", action: #selector(captureScreen), keyEquivalent: "1")
        let captureSelectionItem = NSMenuItem(title: "Снимок области", action: #selector(captureSelection), keyEquivalent: "2")
        let preferencesItem = NSMenuItem(title: "Настройки...", action: #selector(openPreferences), keyEquivalent: ",")
        let quitItem = NSMenuItem(title: "Выход", action: #selector(quit), keyEquivalent: "q")
        
        menu.addItem(captureScreenItem)
        menu.addItem(captureSelectionItem)
        menu.addItem(NSMenuItem.separator())
        menu.addItem(preferencesItem)
        menu.addItem(NSMenuItem.separator())
        menu.addItem(quitItem)
        
        statusItem.menu = menu
        
        // Initialize HotKey Manager
        HotKeyManager.shared.delegate = self
        
        // Register screen shortcut (ID: 1)
        if let code = SettingsManager.shared.screenShortcutKeyCode,
           let mods = SettingsManager.shared.screenShortcutModifiers {
            HotKeyManager.shared.register(id: 1, keyCode: code, modifiers: mods)
        }
        
        // Register selection shortcut (ID: 2)
        if let code = SettingsManager.shared.selectionShortcutKeyCode,
           let mods = SettingsManager.shared.selectionShortcutModifiers {
            HotKeyManager.shared.register(id: 2, keyCode: code, modifiers: mods)
        }
    }

    @objc func captureScreen() {
        print("Capture Screen action triggered")
        let filePath = generateScreenshotPath()
        // Run asynchronously
        DispatchQueue.global(qos: .userInitiated).async {
            self.runScreenCapture(arguments: [filePath])
        }
    }

    @objc func captureSelection() {
        print("Capture Selection action triggered")
        let filePath = generateScreenshotPath()
        // Run asynchronously
        DispatchQueue.global(qos: .userInitiated).async {
            self.runScreenCapture(arguments: ["-i", filePath])
        }
    }
    
    @objc func openPreferences() {
        if settingsWindowController == nil {
            let settingsVC = SettingsViewController()
            let window = NSWindow(contentViewController: settingsVC)
            window.title = "Preferences"
            window.styleMask = [.titled, .closable]
            window.center()
            settingsWindowController = NSWindowController(window: window)
        }
        
        settingsWindowController?.showWindow(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc func quit() {
        print("Quit action triggered")
        NSApplication.shared.terminate(nil)
    }
    
    func hotKeyTriggered(id: UInt32) {
        print("Global HotKey Triggered! ID: \(id)")
        switch id {
        case 1:
            captureScreen()
        case 2:
            captureSelection()
        default:
            print("Unknown hotkey ID: \(id)")
        }
    }
    
    func generateScreenshotPath() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd 'at' HH.mm.ss"
        let dateString = formatter.string(from: Date())
        
        let saveDir = SettingsManager.shared.saveLocation
        return saveDir.appendingPathComponent("Screenshot \(dateString).png").path
    }
    
    func runScreenCapture(arguments: [String]) {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/sbin/screencapture")
        task.arguments = arguments
        
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe
        
        do {
            print("Launching screencapture with args: \(arguments)")
            try task.run()
            task.waitUntilExit()
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let output = String(data: data, encoding: .utf8), !output.isEmpty {
                print("screencapture output: \(output)")
            }
            print("screencapture finished with status: \(task.terminationStatus)")
        } catch {
            print("Failed to run screencapture: \(error)")
        }
    }
}
