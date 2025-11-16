import Cocoa

class CaptureWindow: NSWindow {
    private var startPoint: NSPoint?
    private var currentPoint: NSPoint?
    private var selectionView: SelectionView?
    private var onCapture: ((NSImage?, NSRect) -> Void)?
    private var onCancel: (() -> Void)?
    
    init(onCapture: @escaping (NSImage?, NSRect) -> Void, onCancel: @escaping () -> Void) {
        self.onCapture = onCapture
        self.onCancel = onCancel
        
        // Create full-screen window
        let screenRect = NSScreen.main?.frame ?? .zero
        
        super.init(
            contentRect: screenRect,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        
        self.level = .screenSaver
        self.backgroundColor = NSColor.black.withAlphaComponent(0.3)
        self.isOpaque = false
        self.ignoresMouseEvents = false
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        
        // Create selection view
        selectionView = SelectionView(frame: screenRect)
        self.contentView = selectionView
        
        // Setup mouse tracking
        setupMouseTracking()
        
        // Setup keyboard monitoring
        setupKeyboardMonitoring()
    }
    
    private func setupMouseTracking() {
        guard let contentView = contentView else { return }
        
        let trackingArea = NSTrackingArea(
            rect: contentView.bounds,
            options: [.mouseEnteredAndExited, .mouseMoved, .activeAlways],
            owner: self,
            userInfo: nil
        )
        contentView.addTrackingArea(trackingArea)
    }
    
    private func setupKeyboardMonitoring() {
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            if event.keyCode == 53 { // ESC key
                self?.cancel()
                return nil
            }
            return event
        }
    }
    
    override func mouseDown(with event: NSEvent) {
        startPoint = event.locationInWindow
        currentPoint = startPoint
        selectionView?.startPoint = startPoint
    }
    
    override func mouseDragged(with event: NSEvent) {
        currentPoint = event.locationInWindow
        selectionView?.currentPoint = currentPoint
        selectionView?.needsDisplay = true
    }
    
    override func mouseUp(with event: NSEvent) {
        guard let start = startPoint, let end = currentPoint else {
            cancel()
            return
        }
        
        let rect = NSRect(
            x: min(start.x, end.x),
            y: min(start.y, end.y),
            width: abs(end.x - start.x),
            height: abs(end.y - start.y)
        )
        
        if rect.width > 10 && rect.height > 10 {
            captureScreenshot(rect: rect)
        } else {
            cancel()
        }
    }
    
    override func rightMouseDown(with event: NSEvent) {
        cancel()
    }
    
    private func captureScreenshot(rect: NSRect) {
        // Capture the screen area
        guard let screen = NSScreen.main else {
            cancel()
            return
        }
        
        let screenRect = screen.frame
        
        // Convert coordinates (AppKit uses bottom-left origin)
        let captureRect = NSRect(
            x: rect.origin.x,
            y: screenRect.height - rect.origin.y - rect.height,
            width: rect.width,
            height: rect.height
        )
        
        // Capture screenshot using CGImage
        let displayID = CGMainDisplayID()
        guard let cgImage = CGDisplayCreateImage(displayID, rect: CGRect(
            x: captureRect.origin.x,
            y: captureRect.origin.y,
            width: captureRect.width,
            height: captureRect.height
        )) else {
            cancel()
            return
        }
        
        let image = NSImage(cgImage: cgImage, size: NSSize(width: captureRect.width, height: captureRect.height))
        
        onCapture?(image, rect)
    }
    
    private func cancel() {
        onCancel?()
    }
}

class SelectionView: NSView {
    var startPoint: NSPoint?
    var currentPoint: NSPoint?
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        guard let start = startPoint, let current = currentPoint else { return }
        
        let rect = NSRect(
            x: min(start.x, current.x),
            y: min(start.y, current.y),
            width: abs(current.x - start.x),
            height: abs(current.y - start.y)
        )
        
        // Draw selection rectangle
        NSColor.white.withAlphaComponent(0.3).setFill()
        NSBezierPath(rect: rect).fill()
        
        NSColor.systemBlue.setStroke()
        let border = NSBezierPath(rect: rect)
        border.lineWidth = 2
        border.stroke()
        
        // Draw dimensions
        let dimensions = String(format: "%.0f × %.0f", rect.width, rect.height)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 12),
            .foregroundColor: NSColor.white
        ]
        dimensions.draw(at: NSPoint(x: rect.midX - 30, y: rect.midY), withAttributes: attributes)
    }
}
