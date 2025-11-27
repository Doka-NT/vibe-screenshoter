import Cocoa

// MARK: - Annotation Protocol
protocol Annotation {
    var id: UUID { get }
    func draw()
    func hitTest(point: NSPoint) -> Bool
}

// MARK: - Text Annotation
class TextAnnotation: Annotation {
    let id = UUID()
    var text: String
    var position: NSPoint
    var font: NSFont
    var color: NSColor
    
    init(text: String, position: NSPoint, font: NSFont = .systemFont(ofSize: 24, weight: .bold), color: NSColor = .red) {
        self.text = text
        self.position = position
        self.font = font
        self.color = color
    }
    
    func draw() {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: color
        ]
        text.draw(at: position, withAttributes: attributes)
    }
    
    func hitTest(point: NSPoint) -> Bool {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font
        ]
        let size = text.size(withAttributes: attributes)
        let rect = NSRect(origin: position, size: size)
        return rect.contains(point)
    }
}

// MARK: - Rectangle Annotation
class RectangleAnnotation: Annotation {
    let id = UUID()
    var rect: NSRect
    var strokeColor: NSColor
    var lineWidth: CGFloat
    var fillColor: NSColor?
    
    init(rect: NSRect, strokeColor: NSColor = .red, lineWidth: CGFloat = 3.0, fillColor: NSColor? = nil) {
        self.rect = rect
        self.strokeColor = strokeColor
        self.lineWidth = lineWidth
        self.fillColor = fillColor
    }
    
    func draw() {
        let path = NSBezierPath(rect: rect)
        
        if let fill = fillColor {
            fill.setFill()
            path.fill()
        }
        
        strokeColor.setStroke()
        path.lineWidth = lineWidth
        path.stroke()
    }
    
    func hitTest(point: NSPoint) -> Bool {
        // Simple bounding box check for now
        // For hollow rectangles, we might want to check the border, but for simplicity:
        return rect.contains(point)
    }
}

// MARK: - Arrow Annotation
class ArrowAnnotation: Annotation {
    let id = UUID()
    var startPoint: NSPoint
    var endPoint: NSPoint
    var strokeColor: NSColor
    var lineWidth: CGFloat
    
    init(startPoint: NSPoint, endPoint: NSPoint, strokeColor: NSColor = .red, lineWidth: CGFloat = 3.0) {
        self.startPoint = startPoint
        self.endPoint = endPoint
        self.strokeColor = strokeColor
        self.lineWidth = lineWidth
    }
    
    func draw() {
        strokeColor.setStroke()
        
        // Draw the main line
        let linePath = NSBezierPath()
        linePath.move(to: startPoint)
        linePath.line(to: endPoint)
        linePath.lineWidth = lineWidth
        linePath.stroke()
        
        // Draw arrowhead at end point
        let arrowLength: CGFloat = 15.0
        let arrowAngle: CGFloat = 0.4 // radians (~23 degrees)
        
        // Calculate angle of the line
        let dx = endPoint.x - startPoint.x
        let dy = endPoint.y - startPoint.y
        let angle = atan2(dy, dx)
        
        // Calculate arrowhead points
        let arrowPoint1 = NSPoint(
            x: endPoint.x - arrowLength * cos(angle - arrowAngle),
            y: endPoint.y - arrowLength * sin(angle - arrowAngle)
        )
        let arrowPoint2 = NSPoint(
            x: endPoint.x - arrowLength * cos(angle + arrowAngle),
            y: endPoint.y - arrowLength * sin(angle + arrowAngle)
        )
        
        // Draw arrowhead
        let arrowPath = NSBezierPath()
        arrowPath.move(to: arrowPoint1)
        arrowPath.line(to: endPoint)
        arrowPath.line(to: arrowPoint2)
        arrowPath.lineWidth = lineWidth
        arrowPath.stroke()
    }
    
    func hitTest(point: NSPoint) -> Bool {
        // Hit testing a line is a bit more complex, using a simple bounding box for now
        let minX = min(startPoint.x, endPoint.x) - 10
        let minY = min(startPoint.y, endPoint.y) - 10
        let width = abs(endPoint.x - startPoint.x) + 20
        let height = abs(endPoint.y - startPoint.y) + 20
        let rect = NSRect(x: minX, y: minY, width: width, height: height)
        return rect.contains(point)
    }
}

// MARK: - Redaction Annotation
class RedactionAnnotation: Annotation {
    let id = UUID()
    var rect: NSRect
    
    init(rect: NSRect) {
        self.rect = rect
    }
    
    func draw() {
        NSColor.black.setFill()
        let path = NSBezierPath(rect: rect)
        path.fill()
    }
    
    func hitTest(point: NSPoint) -> Bool {
        return rect.contains(point)
    }
}

