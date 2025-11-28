import Cocoa

enum EditorTool: Int {
    case none = 0
    case text = 1
    case rectangle = 2
    case arrow = 3
    case redaction = 4
}

protocol EditorCanvasDelegate: AnyObject {
    // No longer needed for text input, but keeping for potential future use or cleanup
}

class EditorCanvasView: NSView, NSTextViewDelegate {
    weak var delegate: EditorCanvasDelegate?
    
    var screenshotImage: NSImage?
    var annotations: [Annotation] = []
    var currentTool: EditorTool = .none {
        didSet {
            print("DEBUG: currentTool changed from \(oldValue) to \(currentTool)")
        }
    }
    
    // Temporary drawing state
    private var drawingStartPoint: NSPoint?
    private var drawingCurrentPoint: NSPoint?
    
    // Text editing state
    private var activeTextScrollView: NSScrollView?
    private var editingAnnotation: TextAnnotation?
    
    override var isFlipped: Bool {
        return true // Use top-left as origin for easier coordinate management
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        // Draw the screenshot as background
        if let image = screenshotImage {
            image.draw(in: bounds)
        }
        
        // Draw all annotations
        for annotation in annotations {
            // Don't draw the annotation currently being edited
            if let editing = editingAnnotation, editing.id == annotation.id {
                continue
            }
            annotation.draw()
        }
        
        // Draw temporary shape during dragging
        if let start = drawingStartPoint, let current = drawingCurrentPoint {
            drawTemporaryShape(from: start, to: current)
        }
    }
    
    override func mouseDown(with event: NSEvent) {
        // Commit any active text editing first
        if activeTextScrollView != nil {
            endTextEditing()
            // If we clicked outside the text view, we might want to process this click for a new tool
            // But usually committing text absorbs the click. Let's see.
            // For now, let's just commit and return to avoid accidental new drawing immediately.
            return
        }
        
        let point = convert(event.locationInWindow, from: nil)
        
        print("DEBUG: mouseDown with currentTool = \(currentTool)")
        
        switch currentTool {
        case .text:
            print("DEBUG: Starting text annotation at \(point)")
            // Check if we clicked an existing text annotation
            if let existingText = annotations.compactMap({ $0 as? TextAnnotation }).first(where: { $0.hitTest(point: point) }) {
                startEditing(annotation: existingText)
            } else {
                // Start new text annotation
                startNewText(at: point)
            }
            
        case .rectangle, .arrow, .redaction:
            // Start drawing
            drawingStartPoint = point
            drawingCurrentPoint = point
            
        case .none:
            print("DEBUG: Tool is .none, doing nothing")
            break
        }
    }
    
    override func mouseDragged(with event: NSEvent) {
        guard drawingStartPoint != nil else { return }
        
        let point = convert(event.locationInWindow, from: nil)
        drawingCurrentPoint = point
        needsDisplay = true
    }
    
    override func mouseUp(with event: NSEvent) {
        guard let start = drawingStartPoint else { return }
        
        let end = convert(event.locationInWindow, from: nil)
        
        switch currentTool {
        case .rectangle:
            let rect = NSRect(
                x: min(start.x, end.x),
                y: min(start.y, end.y),
                width: abs(end.x - start.x),
                height: abs(end.y - start.y)
            )
            // Prevent zero-size
            if rect.width > 0 && rect.height > 0 {
                let annotation = RectangleAnnotation(rect: rect)
                annotations.append(annotation)
            }
            
        case .arrow:
            let annotation = ArrowAnnotation(startPoint: start, endPoint: end)
            annotations.append(annotation)
            
        case .redaction:
            let rect = NSRect(
                x: min(start.x, end.x),
                y: min(start.y, end.y),
                width: abs(end.x - start.x),
                height: abs(end.y - start.y)
            )
            if rect.width > 0 && rect.height > 0 {
                let annotation = RedactionAnnotation(rect: rect)
                annotations.append(annotation)
            }
            
        default:
            break
        }
        
        // Clear temporary drawing state
        drawingStartPoint = nil
        drawingCurrentPoint = nil
        needsDisplay = true
    }
    
    private func drawTemporaryShape(from start: NSPoint, to end: NSPoint) {
        NSColor.red.setStroke()
        
        let path: NSBezierPath
        
        switch currentTool {
        case .rectangle:
            let rect = NSRect(
                x: min(start.x, end.x),
                y: min(start.y, end.y),
                width: abs(end.x - start.x),
                height: abs(end.y - start.y)
            )
            path = NSBezierPath(rect: rect)
            NSColor.red.withAlphaComponent(0.1).setFill()
            path.fill()
            path.lineWidth = 3.0
            path.stroke()
            
        case .redaction:
            let rect = NSRect(
                x: min(start.x, end.x),
                y: min(start.y, end.y),
                width: abs(end.x - start.x),
                height: abs(end.y - start.y)
            )
            NSColor.black.withAlphaComponent(0.5).setFill()
            path = NSBezierPath(rect: rect)
            path.fill()
            
        case .arrow:
            path = NSBezierPath()
            path.move(to: start)
            path.line(to: end)
            path.lineWidth = 3.0
            path.stroke()
            
        default:
            return
        }
    }
    
    // MARK: - Text Editing
    
    private func startNewText(at point: NSPoint) {
        print("DEBUG: startNewText called at \(point)")
        
        // Create scroll view to contain the text view (required for proper NSTextView operation)
        let scrollView = NSScrollView(frame: NSRect(x: point.x, y: point.y, width: 200, height: 30))
        scrollView.hasVerticalScroller = false
        scrollView.hasHorizontalScroller = false
        scrollView.borderType = .noBorder
        scrollView.drawsBackground = false
        
        // Create text view
        let textView = NSTextView(frame: scrollView.bounds)
        setupTextView(textView)
        
        // Set up the scroll view's document view
        scrollView.documentView = textView
        
        // Add scroll view to canvas
        self.addSubview(scrollView)
        self.activeTextScrollView = scrollView
        
        print("DEBUG: textView.window = \(String(describing: textView.window))")
        print("DEBUG: self.window = \(String(describing: self.window))")
        
        // Use self.window instead of textView.window to ensure we have the right reference
        if let window = self.window {
            window.makeFirstResponder(textView)
            print("DEBUG: Made textView first responder")
        } else {
            print("DEBUG: ERROR - No window found!")
        }
    }
    
    private func startEditing(annotation: TextAnnotation) {
        editingAnnotation = annotation
        
        // Create text view at annotation position
        let attributes: [NSAttributedString.Key: Any] = [
            .font: annotation.font
        ]
        let size = annotation.text.size(withAttributes: attributes)
        let rect = NSRect(origin: annotation.position, size: NSSize(width: max(size.width + 20, 100), height: max(size.height, 30)))
        
        // Create scroll view to contain the text view
        let scrollView = NSScrollView(frame: rect)
        scrollView.hasVerticalScroller = false
        scrollView.hasHorizontalScroller = false
        scrollView.borderType = .noBorder
        scrollView.drawsBackground = false
        
        // Create text view
        let textView = NSTextView(frame: scrollView.bounds)
        textView.string = annotation.text
        setupTextView(textView, font: annotation.font, color: annotation.color)
        
        // Set up the scroll view's document view
        scrollView.documentView = textView
        
        self.addSubview(scrollView)
        self.activeTextScrollView = scrollView
        self.window?.makeFirstResponder(textView)
        
        // Trigger redraw to hide the annotation being edited
        needsDisplay = true
    }
    
    private func setupTextView(_ textView: NSTextView, font: NSFont = .systemFont(ofSize: 24, weight: .bold), color: NSColor = .red) {
        // CRITICAL: Make sure the text view is editable and selectable
        textView.isEditable = true
        textView.isSelectable = true
        
        // Appearance
        textView.font = font
        textView.textColor = color
        textView.drawsBackground = true
        textView.backgroundColor = NSColor.white.withAlphaComponent(0.1)
        textView.insertionPointColor = color
        
        // Behavior
        textView.delegate = self
        textView.isRichText = false
        textView.allowsUndo = true
        textView.usesFontPanel = false
        textView.usesRuler = false
        
        // Make it auto-resize
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = true
        textView.autoresizingMask = [.width, .height]
        
        if let textContainer = textView.textContainer {
            textContainer.containerSize = NSSize(width: 500, height: CGFloat.greatestFiniteMagnitude)
            textContainer.widthTracksTextView = false
        }
        
        textView.maxSize = NSSize(width: 500, height: CGFloat.greatestFiniteMagnitude)
        textView.minSize = NSSize(width: 50, height: 30)
        
        // Add a visible border for debugging
        textView.wantsLayer = true
        textView.layer?.borderColor = NSColor.red.withAlphaComponent(0.5).cgColor
        textView.layer?.borderWidth = 2.0
        
        print("DEBUG: setupTextView - isEditable: \(textView.isEditable), isSelectable: \(textView.isSelectable)")
    }
    
    private func endTextEditing() {
        guard let scrollView = activeTextScrollView,
              let textView = scrollView.documentView as? NSTextView else { return }
        
        let text = textView.string
        let origin = scrollView.frame.origin
        
        if !text.isEmpty {
            if let existing = editingAnnotation {
                // Update existing
                existing.text = text
                existing.position = origin
                // If we changed font/color in setup, update them too. For now they are static.
            } else {
                // Create new
                let annotation = TextAnnotation(text: text, position: origin)
                annotations.append(annotation)
            }
        } else {
            // If text is empty, remove the annotation if we were editing one
            if let existing = editingAnnotation {
                annotations.removeAll(where: { $0.id == existing.id })
            }
        }
        
        scrollView.removeFromSuperview()
        activeTextScrollView = nil
        editingAnnotation = nil
        needsDisplay = true
    }
    
    func textDidEndEditing(_ notification: Notification) {
        // This is called when focus is lost (e.g. tab or click away)
        // We handle click away in mouseDown, but this is good backup
        // However, if we click away, mouseDown fires first?
        // Let's rely on mouseDown or explicit enter key if we want.
        // Actually, textDidEndEditing is standard.
        // But if we click on the canvas, the canvas gets mouseDown.
        // The text view resigns first responder.
        endTextEditing()
    }
    
    // Render the final image with all annotations
    func renderFinalImage() -> NSImage? {
        // Ensure any active editing is committed
        if activeTextScrollView != nil {
            endTextEditing()
        }
        
        guard let screenshot = screenshotImage else { return nil }
        
        let finalImage = NSImage(size: screenshot.size)
        finalImage.lockFocus()
        
        // Draw screenshot
        screenshot.draw(at: .zero, from: NSRect(origin: .zero, size: screenshot.size), operation: .copy, fraction: 1.0)
        
        // Draw all annotations
        for annotation in annotations {
            annotation.draw()
        }
        
        finalImage.unlockFocus()
        return finalImage
    }
}
