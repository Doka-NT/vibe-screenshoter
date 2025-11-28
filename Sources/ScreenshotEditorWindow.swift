import Cocoa

class ScreenshotEditorWindow: NSWindowController, EditorCanvasDelegate {
    private var canvasView: EditorCanvasView!
    private var toolPaletteView: ToolPaletteView!
    private var saveHandler: ((NSImage) -> Void)?
    private var cancelHandler: (() -> Void)?
    private var localEventMonitor: Any?
    
    convenience init(image: NSImage, saveHandler: @escaping (NSImage) -> Void, cancelHandler: @escaping () -> Void) {
        // Adjust image size for Retina displays if needed
        // screencapture returns an image where size == pixels (72 DPI), but on Retina we want size == pixels / scale
        var displayImage = image
        if let screen = NSScreen.main {
            let scale = screen.backingScaleFactor
            if scale > 1.0 {
                let newSize = NSSize(width: CGFloat(image.representations[0].pixelsWide) / scale,
                                   height: CGFloat(image.representations[0].pixelsHigh) / scale)
                displayImage.size = newSize
            }
        }

        // Create window without title bar for cleaner look
        let window = EditorWindow(
            contentRect: NSRect(x: 0, y: 0, width: displayImage.size.width, height: displayImage.size.height),
            styleMask: [.borderless, .closable],
            backing: .buffered,
            defer: false
        )
        window.isMovableByWindowBackground = false
        window.center()
        
        self.init(window: window)
        
        self.saveHandler = saveHandler
        self.cancelHandler = cancelHandler
        
        setupCanvasView(with: displayImage)
        setupToolPalette()
        
        // Set window delegate to handle close button
        window.delegate = self
        
        // Setup keyboard shortcut monitor
        localEventMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            // Don't intercept events if a text view is first responder (user is typing)
            if let firstResponder = self?.window?.firstResponder as? NSTextView {
                print("DEBUG: Text view is first responder, allowing event through")
                return event
            }
            
            if event.modifierFlags.contains(.command) && event.keyCode == 36 { // 36 is Enter
                self?.saveImage()
                return nil
            }
            return event
        }
    }
    
    private func setupCanvasView(with image: NSImage) {
        canvasView = EditorCanvasView(frame: NSRect(origin: .zero, size: image.size))
        canvasView.screenshotImage = image
        canvasView.delegate = self
        
        // Set canvas directly as content view (no scrollbars)
        window!.contentView = canvasView
    }
    
    private func setupToolPalette() {
        // Create floating tool palette
        toolPaletteView = ToolPaletteView(frame: .zero)
        toolPaletteView.onToolSelected = { [weak self] tool in
            self?.canvasView.currentTool = tool
        }
        toolPaletteView.onSave = { [weak self] in
            self?.saveImage()
        }
        toolPaletteView.onCancel = { [weak self] in
            self?.cancelEditing()
        }
        
        // Set initial tool to text (must be done after callbacks are set)
        canvasView.currentTool = .text
        
        canvasView.addSubview(toolPaletteView)
        
        // Position palette at top center
        toolPaletteView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            toolPaletteView.topAnchor.constraint(equalTo: canvasView.topAnchor, constant: 12),
            toolPaletteView.centerXAnchor.constraint(equalTo: canvasView.centerXAnchor)
        ])
    }
    
    // MARK: - EditorCanvasDelegate
    
    // No longer needed for text input as it's handled inline
    
    // MARK: - Actions
    
    @objc private func saveImage() {
        if let finalImage = canvasView.renderFinalImage() {
            // Save to clipboard
            let pasteboard = NSPasteboard.general
            pasteboard.clearContents()
            pasteboard.writeObjects([finalImage])
            
            saveHandler?(finalImage)
            // Prevent double-calling handlers in windowWillClose
            saveHandler = nil
            cancelHandler = nil
            window?.close()
        }
    }
    
    @objc private func cancelEditing() {
        cancelHandler?()
        // Prevent double-calling handlers in windowWillClose
        saveHandler = nil
        cancelHandler = nil
        window?.close()
    }
    
}

// MARK: - NSWindowDelegate

extension ScreenshotEditorWindow: NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        if let monitor = localEventMonitor {
            NSEvent.removeMonitor(monitor)
            localEventMonitor = nil
        }
        cancelHandler?()
    }
}

// Custom window subclass to allow borderless window to become key
private class EditorWindow: NSWindow {
    override var canBecomeKey: Bool {
        return true
    }
}
