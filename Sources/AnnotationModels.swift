import Cocoa

// MARK: - Annotation Protocol
protocol Annotation {
    var id: UUID { get }
    func draw()
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
}

// MARK: - Blur Annotation
class BlurAnnotation: Annotation {
    let id = UUID()
    var rect: NSRect
    var blurRadius: CGFloat
    var image: NSImage?
    
    init(rect: NSRect, blurRadius: CGFloat = 50.0) {
        self.rect = rect
        self.blurRadius = blurRadius
    }
    
    func draw() {
        guard let image = image else { return }
        
        // Create a blurred version of the area
        let ciImage = CIImage(data: image.tiffRepresentation!)
        let filter = CIFilter(name: "CIGaussianBlur")
        filter?.setValue(ciImage, forKey: kCIInputImageKey)
        filter?.setValue(blurRadius, forKey: kCIInputRadiusKey)
        
        if let outputImage = filter?.outputImage {
            let rep = NSCIImageRep(ciImage: outputImage)
            let blurredImage = NSImage(size: rep.size)
            blurredImage.addRepresentation(rep)
            
            // Draw the blurred image in the rect
            blurredImage.draw(in: rect)
        }
    }
    
    func setImageFromRect(sourceImage: NSImage, sourceRect: NSRect) {
        // Extract the portion of the image that needs to be blurred
        let croppedImage = NSImage(size: sourceRect.size)
        croppedImage.lockFocus()
        
        let destRect = NSRect(origin: .zero, size: sourceRect.size)
        sourceImage.draw(in: destRect, from: sourceRect, operation: .copy, fraction: 1.0)
        
        croppedImage.unlockFocus()
        self.image = croppedImage
    }
}
