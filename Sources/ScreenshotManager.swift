import Cocoa
import Carbon

class ScreenshotManager {
    private var settingsManager: SettingsManager
    private var captureWindow: CaptureWindow?
    private var editorWindow: EditorWindow?
    private var eventMonitor: Any?
    
    init(settingsManager: SettingsManager) {
        self.settingsManager = settingsManager
    }
    
    func registerShortcut(keyCode: UInt16, modifiers: UInt32) {
        // Register global keyboard shortcut
        let hotKeyID = EventHotKeyID(signature: OSType(0x56494245), id: 1) // 'VIBE'
        var hotKeyRef: EventHotKeyRef?
        
        let status = RegisterEventHotKey(
            keyCode,
            modifiers,
            hotKeyID,
            GetApplicationEventTarget(),
            0,
            &hotKeyRef
        )
        
        if status != noErr {
            print("Failed to register hotkey")
        }
        
        // Setup event handler
        setupEventHandler()
    }
    
    private func setupEventHandler() {
        eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
            // Check if it's our shortcut
            if event.modifierFlags.contains([.command, .shift]) && event.keyCode == 1 { // 's' key
                self?.startScreenshotCapture()
            }
        }
    }
    
    func startScreenshotCapture() {
        // Hide menu bar temporarily
        NSApp.presentationOptions = [.autoHideMenuBar, .autoHideDock]
        
        // Create and show capture window
        captureWindow = CaptureWindow { [weak self] capturedImage, rect in
            self?.handleCapturedScreenshot(image: capturedImage, rect: rect)
        } onCancel: { [weak self] in
            self?.cancelCapture()
        }
        
        captureWindow?.makeKeyAndOrderFront(nil)
    }
    
    private func handleCapturedScreenshot(image: NSImage?, rect: NSRect) {
        // Restore menu bar
        NSApp.presentationOptions = []
        
        // Close capture window
        captureWindow?.close()
        captureWindow = nil
        
        guard let image = image else { return }
        
        // Open editor with captured screenshot
        editorWindow = EditorWindow(
            screenshot: image,
            settingsManager: settingsManager
        ) { [weak self] editedImage in
            self?.saveScreenshot(image: editedImage)
        }
        
        editorWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    private func cancelCapture() {
        // Restore menu bar
        NSApp.presentationOptions = []
        
        // Close capture window
        captureWindow?.close()
        captureWindow = nil
    }
    
    private func saveScreenshot(image: NSImage) {
        // Save to clipboard
        saveToClipboard(image: image)
        
        // Save to file system if configured
        if let savePath = settingsManager.savePath {
            saveToFile(image: image, path: savePath)
        }
        
        // Close editor window
        editorWindow?.close()
        editorWindow = nil
    }
    
    private func saveToClipboard(image: NSImage) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.writeObjects([image])
    }
    
    private func saveToFile(image: NSImage, path: String) {
        guard let tiffData = image.tiffRepresentation,
              let bitmapImage = NSBitmapImageRep(data: tiffData) else {
            return
        }
        
        let format = settingsManager.saveFormat
        let imageData: Data?
        let fileExtension: String
        
        switch format {
        case .png:
            imageData = bitmapImage.representation(using: .png, properties: [:])
            fileExtension = "png"
        case .jpeg:
            imageData = bitmapImage.representation(using: .jpeg, properties: [.compressionFactor: 0.9])
            fileExtension = "jpg"
        }
        
        guard let data = imageData else { return }
        
        // Generate filename
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd-HH-mm-ss"
        let timestamp = dateFormatter.string(from: Date())
        let filename = "Screenshot-\(timestamp).\(fileExtension)"
        
        let fileURL = URL(fileURLWithPath: path).appendingPathComponent(filename)
        
        do {
            try data.write(to: fileURL)
            print("Screenshot saved to: \(fileURL.path)")
        } catch {
            print("Failed to save screenshot: \(error)")
        }
    }
    
    func cleanup() {
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
        }
    }
}
