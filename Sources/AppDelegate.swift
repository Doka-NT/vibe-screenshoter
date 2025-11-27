import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate, HotKeyDelegate {
    var statusItem: NSStatusItem!
    var settingsWindowController: NSWindowController?
    var captureScreenMenuItem: NSMenuItem!
    var captureSelectionMenuItem: NSMenuItem!

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
        
        captureScreenMenuItem = NSMenuItem(title: "Снимок экрана", action: #selector(captureScreen), keyEquivalent: "")
        captureSelectionMenuItem = NSMenuItem(title: "Снимок области", action: #selector(captureSelection), keyEquivalent: "")
        let preferencesItem = NSMenuItem(title: "Настройки...", action: #selector(openPreferences), keyEquivalent: ",")
        let quitItem = NSMenuItem(title: "Выход", action: #selector(quit), keyEquivalent: "q")
        
        menu.addItem(captureScreenMenuItem)
        menu.addItem(captureSelectionMenuItem)
        menu.addItem(NSMenuItem.separator())
        menu.addItem(preferencesItem)
        menu.addItem(NSMenuItem.separator())
        menu.addItem(quitItem)
        
        statusItem.menu = menu
        
        // Update menu shortcuts based on current settings
        updateMenuShortcuts()
        
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
            // -t png: Use PNG format for lossless quality
            // -T 0: Disable shadow/border effects
            self.runScreenCapture(arguments: ["-t", "png", "-T", "0", filePath])
        }
    }

    @objc func captureSelection() {
        print("Capture Selection action triggered")
        let filePath = generateScreenshotPath()
        // Run asynchronously
        DispatchQueue.global(qos: .userInitiated).async {
            // -i: Interactive mode (selection)
            // -t png: Use PNG format for lossless quality
            // -T 0: Disable shadow/border effects
            self.runScreenCapture(arguments: ["-i", "-t", "png", "-T", "0", filePath])
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
    
    // Update menu items to show current shortcuts
    func updateMenuShortcuts() {
        // Update Screen Capture menu item
        captureScreenMenuItem.title = "Снимок экрана"
        if let keyCode = SettingsManager.shared.screenShortcutKeyCode,
           let modifiers = SettingsManager.shared.screenShortcutModifiers,
           let keyChar = keyCodeToCharacter(keyCode) {
            
            // Convert to lowercase for keyEquivalent (it expects lowercase)
            captureScreenMenuItem.keyEquivalent = keyChar.lowercased()
            captureScreenMenuItem.keyEquivalentModifierMask = NSEvent.ModifierFlags(rawValue: modifiers)
        } else {
            captureScreenMenuItem.keyEquivalent = ""
            captureScreenMenuItem.keyEquivalentModifierMask = []
        }
        
        // Update Selection Capture menu item
        captureSelectionMenuItem.title = "Снимок области"
        if let keyCode = SettingsManager.shared.selectionShortcutKeyCode,
           let modifiers = SettingsManager.shared.selectionShortcutModifiers,
           let keyChar = keyCodeToCharacter(keyCode) {
            
            captureSelectionMenuItem.keyEquivalent = keyChar.lowercased()
            captureSelectionMenuItem.keyEquivalentModifierMask = NSEvent.ModifierFlags(rawValue: modifiers)
        } else {
            captureSelectionMenuItem.keyEquivalent = ""
            captureSelectionMenuItem.keyEquivalentModifierMask = []
        }
    }
    
    // Convert key code to character representation
    private func keyCodeToCharacter(_ keyCode: UInt16) -> String? {
        // Common key codes mapping
        let keyMap: [UInt16: String] = [
            0: "A", 1: "S", 2: "D", 3: "F", 4: "H", 5: "G", 6: "Z", 7: "X",
            8: "C", 9: "V", 11: "B", 12: "Q", 13: "W", 14: "E", 15: "R",
            16: "Y", 17: "T", 18: "1", 19: "2", 20: "3", 21: "4", 22: "6",
            23: "5", 24: "=", 25: "9", 26: "7", 27: "-", 28: "8", 29: "0",
            30: "]", 31: "O", 32: "U", 33: "[", 34: "I", 35: "P", 37: "L",
            38: "J", 39: "'", 40: "K", 41: ";", 42: "\\", 43: ",", 44: "/",
            45: "N", 46: "M", 47: ".", 50: "`",
            // Function keys
            122: "F1", 120: "F2", 99: "F3", 118: "F4", 96: "F5", 97: "F6",
            98: "F7", 100: "F8", 101: "F9", 109: "F10", 103: "F11", 111: "F12",
            // Special keys
            36: "↩", 48: "⇥", 49: "Space", 51: "⌫", 53: "⎋",
            123: "←", 124: "→", 125: "↓", 126: "↑"
        ]
        
        return keyMap[keyCode]
    }
}
