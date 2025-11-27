import Cocoa

enum EditorTool {
    case none
    case text
    case rectangle
    case arrow
    case redaction
}

protocol EditorCanvasDelegate: AnyObject {
    // No longer needed for text input, but keeping for potential future use or cleanup
}

class EditorCanvasView: NSView, NSTextViewDelegate {
    weak var delegate: EditorCanvasDelegate?
    
    var screenshotImage: NSImage?
    var annotations: [Annotation] = []
    var currentTool: EditorTool = .none
    
    // Temporary drawing state
    private var drawingStartPoint: NSPoint?
    private var drawingCurrentPoint: NSPoint?
    
    // Text editing state
    private var activeTextView: NSTextView?
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
        if let textView = activeTextView {
            endTextEditing()
            // If we clicked outside the text view, we might want to process this click for a new tool
            // But usually committing text absorbs the click. Let's see.
            // For now, let's just commit and return to avoid accidental new drawing immediately.
            return
        }
        
        let point = convert(event.locationInWindow, from: nil)
        
        switch currentTool {
        case .text:
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
        let textView = NSTextView(frame: NSRect(x: point.x, y: point.y, width: 200, height: 30))
        setupTextView(textView)
        self.addSubview(textView)
        self.activeTextView = textView
        textView.window?.makeFirstResponder(textView)
    }
    
    private func startEditing(annotation: TextAnnotation) {
        editingAnnotation = annotation
        
        // Create text view at annotation position
        let attributes: [NSAttributedString.Key: Any] = [
            .font: annotation.font
        ]
        let size = annotation.text.size(withAttributes: attributes)
        let rect = NSRect(origin: annotation.position, size: NSSize(width: max(size.width + 20, 100), height: max(size.height, 30)))
        
        let textView = NSTextView(frame: rect)
        textView.string = annotation.text
        setupTextView(textView, font: annotation.font, color: annotation.color)
        
        self.addSubview(textView)
        self.activeTextView = textView
        textView.window?.makeFirstResponder(textView)
        
        // Trigger redraw to hide the annotation being edited
        needsDisplay = true
    }
    
    private func setupTextView(_ textView: NSTextView, font: NSFont = .systemFont(ofSize: 24, weight: .bold), color: NSColor = .red) {
        textView.font = font
        textView.textColor = color
        textView.drawsBackground = false
        textView.backgroundColor = .clear
        textView.delegate = self
        textView.isRichText = false
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = true
        textView.textContainer?.widthTracksTextView = true
        textView.textContainer?.containerSize = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
    }
    
    private func endTextEditing() {
        guard let textView = activeTextView else { return }
        
        let text = textView.string
        let origin = textView.frame.origin
        
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
        
        textView.removeFromSuperview()
        activeTextView = nil
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
        if activeTextView != nil {
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
