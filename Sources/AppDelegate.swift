import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!

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
        let quitItem = NSMenuItem(title: "Выход", action: #selector(quit), keyEquivalent: "q")
        
        menu.addItem(captureScreenItem)
        menu.addItem(captureSelectionItem)
        menu.addItem(NSMenuItem.separator())
        menu.addItem(quitItem)
        
        statusItem.menu = menu
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

    @objc func quit() {
        print("Quit action triggered")
        NSApplication.shared.terminate(nil)
    }
    
    func generateScreenshotPath() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd 'at' HH.mm.ss"
        let dateString = formatter.string(from: Date())
        
        let desktopPath = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask).first?.path ?? "/tmp"
        return "\(desktopPath)/Screenshot \(dateString).png"
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
