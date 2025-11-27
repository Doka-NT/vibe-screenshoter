import Cocoa

enum EditorTool {
    case none
    case text
    case rectangle
    case arrow
    case blur
}

protocol EditorCanvasDelegate: AnyObject {
    func canvasNeedsTextInput(at point: NSPoint)
}

class EditorCanvasView: NSView {
    weak var delegate: EditorCanvasDelegate?
    
    var screenshotImage: NSImage?
    var annotations: [Annotation] = []
    var currentTool: EditorTool = .none
    
    // Temporary drawing state
    private var drawingStartPoint: NSPoint?
    private var drawingCurrentPoint: NSPoint?
    
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
            annotation.draw()
        }
        
        // Draw temporary shape during dragging
        if let start = drawingStartPoint, let current = drawingCurrentPoint {
            drawTemporaryShape(from: start, to: current)
        }
    }
    
    override func mouseDown(with event: NSEvent) {
        let point = convert(event.locationInWindow, from: nil)
        
        switch currentTool {
        case .text:
            // Request text input from delegate
            delegate?.canvasNeedsTextInput(at: point)
        case .rectangle, .arrow, .blur:
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
            let annotation = RectangleAnnotation(rect: rect)
            annotations.append(annotation)
            
        case .arrow:
            let annotation = ArrowAnnotation(startPoint: start, endPoint: end)
            annotations.append(annotation)
            
        case .blur:
            let rect = NSRect(
                x: min(start.x, end.x),
                y: min(start.y, end.y),
                width: abs(end.x - start.x),
                height: abs(end.y - start.y)
            )
            let blurAnnotation = BlurAnnotation(rect: rect, blurRadius: 50.0)
            
            // Extract the image portion to blur
            if let image = screenshotImage {
                blurAnnotation.setImageFromRect(sourceImage: image, sourceRect: rect)
            }
            
            annotations.append(blurAnnotation)
            
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
        NSColor.red.withAlphaComponent(0.2).setFill()
        
        let path: NSBezierPath
        
        switch currentTool {
        case .rectangle, .blur:
            let rect = NSRect(
                x: min(start.x, end.x),
                y: min(start.y, end.y),
                width: abs(end.x - start.x),
                height: abs(end.y - start.y)
            )
            path = NSBezierPath(rect: rect)
            path.fill()
            
        case .arrow:
            path = NSBezierPath()
            path.move(to: start)
            path.line(to: end)
            
        default:
            return
        }
        
        path.lineWidth = 2.0
        path.stroke()
    }
    
    func addTextAnnotation(text: String, at point: NSPoint) {
        let annotation = TextAnnotation(text: text, position: point)
        annotations.append(annotation)
        needsDisplay = true
    }
    
    // Render the final image with all annotations
    func renderFinalImage() -> NSImage? {
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
