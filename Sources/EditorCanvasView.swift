import Cocoa

enum EditorTool: Int {
    case none = 0
    case text = 1
    case rectangle = 2
    case arrow = 3
    case redaction = 4
}

protocol EditorCanvasDelegate: AnyObject {
    func editorCanvasView(_ canvas: EditorCanvasView, didChangeTextFontSize size: CGFloat)
}

class EditorCanvasView: NSView, NSTextViewDelegate {
    weak var delegate: EditorCanvasDelegate?
    
    var screenshotImage: NSImage?
    var annotations: [Annotation] = []
    var currentTool: EditorTool = .none {
        didSet {
            print("DEBUG: currentTool changed from \(oldValue) to \(currentTool)")
            updateCursorForCurrentTool()
        }
    }
    private var isFontSizeChangeInternal = false
    private(set) var textFontSize: CGFloat = 24 {
        didSet {
            applyFontSizeChange()
        }
    }

    // Обновляет курсор в зависимости от выбранного инструмента
    private func updateCursorForCurrentTool() {
        window?.invalidateCursorRects(for: self)
    }

    override func resetCursorRects() {
        super.resetCursorRects()
        switch currentTool {
        case .text:
            addCursorRect(bounds, cursor: .iBeam)
        case .rectangle, .arrow, .redaction:
            addCursorRect(bounds, cursor: .crosshair)
        default:
            addCursorRect(bounds, cursor: .arrow)
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
        resizeActiveTextViewToFitContent()
        
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
        let bounding = NSString(string: annotation.text).boundingRect(
            with: NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: attributes
        )
        let rect = NSRect(
            origin: annotation.position,
            size: NSSize(width: max(bounding.width + 20, 100), height: max(bounding.height + 10, 30))
        )
        
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
        resizeActiveTextViewToFitContent()
        self.window?.makeFirstResponder(textView)
        setTextFontSize(annotation.font.pointSize)
        
        // Trigger redraw to hide the annotation being edited
        needsDisplay = true
    }
    
    private func setupTextView(_ textView: NSTextView, font: NSFont? = nil, color: NSColor = .red) {
        // CRITICAL: Make sure the text view is editable and selectable
        textView.isEditable = true
        textView.isSelectable = true
        
        // Appearance
        textView.font = font ?? TextAnnotation.font(ofSize: textFontSize)
        textView.textColor = color
        textView.drawsBackground = true
        textView.backgroundColor = NSColor.white.withAlphaComponent(0.08)
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
            textContainer.containerSize = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
            textContainer.widthTracksTextView = false
        }

        textView.maxSize = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        textView.minSize = NSSize(width: 50, height: 30)
        
        textView.wantsLayer = true
    }

    private func resizeActiveTextViewToFitContent() {
        guard let scrollView = activeTextScrollView,
              let textView = scrollView.documentView as? NSTextView,
              let layoutManager = textView.layoutManager,
              let textContainer = textView.textContainer else { return }

        layoutManager.ensureLayout(for: textContainer)
        let usedRect = layoutManager.usedRect(for: textContainer)
        let padding: CGFloat = 10
        let lineHeight = layoutManager.defaultLineHeight(for: textView.font ?? .systemFont(ofSize: 24, weight: .bold))
        var newHeight = ceil(usedRect.height) + padding

        // If the text ends with a newline or is empty, ensure space for the current line
        if textView.string.isEmpty {
            newHeight = lineHeight + padding
        } else if textView.string.hasSuffix("\n") {
            newHeight += lineHeight
        }

        let newSize = NSSize(
            width: max(textView.minSize.width, ceil(usedRect.width) + padding),
            height: max(textView.minSize.height, newHeight)
        )

        textContainer.containerSize = NSSize(width: CGFloat.greatestFiniteMagnitude, height: newSize.height)
        textView.frame.size = newSize

        var frame = scrollView.frame
        frame.size = newSize
        scrollView.frame = frame
    }
    
    private func endTextEditing() {
        guard let scrollView = activeTextScrollView,
              let textView = scrollView.documentView as? NSTextView else { return }

        resizeActiveTextViewToFitContent()
        
        let text = textView.string
        let origin = scrollView.frame.origin
        
        if !text.isEmpty {
            if let existing = editingAnnotation {
                // Update existing
                existing.text = text
                existing.position = origin
                existing.font = TextAnnotation.font(ofSize: textFontSize)
                // If we changed font/color in setup, update them too. For now they are static.
            } else {
                // Create new
                let annotation = TextAnnotation(
                    text: text,
                    position: origin,
                    font: TextAnnotation.font(ofSize: textFontSize)
                )
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
    
    func textDidChange(_ notification: Notification) {
        resizeActiveTextViewToFitContent()
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
    
    func textView(_ textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        if commandSelector == #selector(NSResponder.insertNewline(_:)) {
            if NSApp.currentEvent?.modifierFlags.contains(.shift) == true {
                // Let the newline be inserted normally and resize afterwards
                return false
            } else {
                endTextEditing()
                return true
            }
        }
        return false
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

    func setTextFontSize(_ size: CGFloat, notifyDelegate: Bool = true) {
        let clamped = clampFontSize(size)
        guard textFontSize != clamped else { return }
        isFontSizeChangeInternal = !notifyDelegate
        textFontSize = clamped
        isFontSizeChangeInternal = false
    }
    
    private func clampFontSize(_ size: CGFloat) -> CGFloat {
        return max(12, min(size, 72))
    }
    
    private func applyFontSizeChange() {
        updateActiveTextViewFont()
        if let editing = editingAnnotation {
            editing.font = TextAnnotation.font(ofSize: textFontSize)
        }
        if !isFontSizeChangeInternal {
            delegate?.editorCanvasView(self, didChangeTextFontSize: textFontSize)
        }
    }
    
    private func updateActiveTextViewFont() {
        guard let scrollView = activeTextScrollView,
              let textView = scrollView.documentView as? NSTextView else { return }
        textView.font = TextAnnotation.font(ofSize: textFontSize)
        resizeActiveTextViewToFitContent()
    }
}
