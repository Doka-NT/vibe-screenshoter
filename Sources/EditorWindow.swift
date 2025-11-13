import Cocoa

class EditorWindow: NSWindow {
    private var screenshot: NSImage
    private var settingsManager: SettingsManager
    private var onSave: ((NSImage) -> Void)?
    
    private var canvasView: CanvasView!
    private var toolbar: NSView!
    private var currentTool: DrawingTool = .none
    private var currentColor: NSColor = .red
    private var currentLineWidth: CGFloat = 3.0
    
    init(screenshot: NSImage, settingsManager: SettingsManager, onSave: @escaping (NSImage) -> Void) {
        self.screenshot = screenshot
        self.settingsManager = settingsManager
        self.onSave = onSave
        
        let windowSize = NSSize(
            width: min(screenshot.size.width + 100, 1200),
            height: min(screenshot.size.height + 150, 800)
        )
        
        let rect = NSRect(
            x: 0,
            y: 0,
            width: windowSize.width,
            height: windowSize.height
        )
        
        super.init(
            contentRect: rect,
            styleMask: [.titled, .closable, .resizable],
            backing: .buffered,
            defer: false
        )
        
        self.title = "Редактор скриншота"
        self.center()
        
        setupUI()
    }
    
    private func setupUI() {
        let contentView = NSView(frame: self.contentRect(forFrameRect: frame))
        self.contentView = contentView
        
        // Create toolbar
        toolbar = createToolbar()
        toolbar.frame = NSRect(x: 0, y: contentView.bounds.height - 60, width: contentView.bounds.width, height: 60)
        toolbar.autoresizingMask = [.width, .minYMargin]
        contentView.addSubview(toolbar)
        
        // Create canvas
        let canvasRect = NSRect(
            x: 0,
            y: 0,
            width: contentView.bounds.width,
            height: contentView.bounds.height - 60
        )
        canvasView = CanvasView(frame: canvasRect, screenshot: screenshot)
        canvasView.autoresizingMask = [.width, .height]
        contentView.addSubview(canvasView)
    }
    
    private func createToolbar() -> NSView {
        let toolbar = NSView()
        toolbar.wantsLayer = true
        toolbar.layer?.backgroundColor = NSColor.windowBackgroundColor.cgColor
        
        var xOffset: CGFloat = 20
        let buttonSpacing: CGFloat = 10
        
        // Arrow tool button
        let arrowButton = createToolButton(title: "Стрелка", action: #selector(selectArrowTool))
        arrowButton.frame = NSRect(x: xOffset, y: 15, width: 100, height: 30)
        toolbar.addSubview(arrowButton)
        xOffset += 100 + buttonSpacing
        
        // Text tool button
        let textButton = createToolButton(title: "Текст", action: #selector(selectTextTool))
        textButton.frame = NSRect(x: xOffset, y: 15, width: 100, height: 30)
        toolbar.addSubview(textButton)
        xOffset += 100 + buttonSpacing
        
        // Rectangle tool button
        let rectButton = createToolButton(title: "Прямоугольник", action: #selector(selectRectangleTool))
        rectButton.frame = NSRect(x: xOffset, y: 15, width: 130, height: 30)
        toolbar.addSubview(rectButton)
        xOffset += 130 + buttonSpacing
        
        // Delete tool button
        let deleteButton = createToolButton(title: "Удалить", action: #selector(selectDeleteTool))
        deleteButton.frame = NSRect(x: xOffset, y: 15, width: 100, height: 30)
        toolbar.addSubview(deleteButton)
        xOffset += 100 + buttonSpacing + 20
        
        // Color picker
        let colorPicker = NSColorWell()
        colorPicker.color = currentColor
        colorPicker.frame = NSRect(x: xOffset, y: 15, width: 50, height: 30)
        colorPicker.target = self
        colorPicker.action = #selector(colorChanged(_:))
        toolbar.addSubview(colorPicker)
        xOffset += 50 + buttonSpacing
        
        // Line width slider
        let slider = NSSlider(value: Double(currentLineWidth), minValue: 1, maxValue: 10, target: self, action: #selector(lineWidthChanged(_:)))
        slider.frame = NSRect(x: xOffset, y: 15, width: 100, height: 30)
        toolbar.addSubview(slider)
        xOffset += 100 + buttonSpacing + 20
        
        // Save button
        let saveButton = NSButton(title: "Сохранить", target: self, action: #selector(saveScreenshot))
        saveButton.frame = NSRect(x: toolbar.bounds.width - 120, y: 15, width: 100, height: 30)
        saveButton.autoresizingMask = [.minXMargin]
        saveButton.bezelStyle = .rounded
        toolbar.addSubview(saveButton)
        
        return toolbar
    }
    
    private func createToolButton(title: String, action: Selector) -> NSButton {
        let button = NSButton(title: title, target: self, action: action)
        button.bezelStyle = .rounded
        return button
    }
    
    @objc private func selectArrowTool() {
        currentTool = .arrow
        canvasView.setTool(.arrow, color: currentColor, lineWidth: currentLineWidth)
    }
    
    @objc private func selectTextTool() {
        currentTool = .text
        canvasView.setTool(.text, color: currentColor, lineWidth: currentLineWidth)
    }
    
    @objc private func selectRectangleTool() {
        currentTool = .rectangle
        canvasView.setTool(.rectangle, color: currentColor, lineWidth: currentLineWidth)
    }
    
    @objc private func selectDeleteTool() {
        currentTool = .delete
        canvasView.setTool(.delete, color: currentColor, lineWidth: currentLineWidth)
    }
    
    @objc private func colorChanged(_ sender: NSColorWell) {
        currentColor = sender.color
        canvasView.setTool(currentTool, color: currentColor, lineWidth: currentLineWidth)
    }
    
    @objc private func lineWidthChanged(_ sender: NSSlider) {
        currentLineWidth = CGFloat(sender.doubleValue)
        canvasView.setTool(currentTool, color: currentColor, lineWidth: currentLineWidth)
    }
    
    @objc private func saveScreenshot() {
        let finalImage = canvasView.renderToImage()
        onSave?(finalImage)
    }
}

enum DrawingTool {
    case none
    case arrow
    case text
    case rectangle
    case delete
}

class CanvasView: NSView {
    private var screenshot: NSImage
    private var annotations: [Annotation] = []
    private var currentTool: DrawingTool = .none
    private var currentColor: NSColor = .red
    private var currentLineWidth: CGFloat = 3.0
    
    private var startPoint: NSPoint?
    private var currentPoint: NSPoint?
    private var temporaryAnnotation: Annotation?
    
    init(frame: NSRect, screenshot: NSImage) {
        self.screenshot = screenshot
        super.init(frame: frame)
        self.wantsLayer = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setTool(_ tool: DrawingTool, color: NSColor, lineWidth: CGFloat) {
        currentTool = tool
        currentColor = color
        currentLineWidth = lineWidth
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        // Draw screenshot
        screenshot.draw(in: calculateImageRect())
        
        // Draw all annotations
        for annotation in annotations {
            annotation.draw()
        }
        
        // Draw temporary annotation
        temporaryAnnotation?.draw()
    }
    
    private func calculateImageRect() -> NSRect {
        let imageSize = screenshot.size
        let viewSize = bounds.size
        
        let scale = min(viewSize.width / imageSize.width, viewSize.height / imageSize.height)
        let scaledWidth = imageSize.width * scale
        let scaledHeight = imageSize.height * scale
        
        let x = (viewSize.width - scaledWidth) / 2
        let y = (viewSize.height - scaledHeight) / 2
        
        return NSRect(x: x, y: y, width: scaledWidth, height: scaledHeight)
    }
    
    override func mouseDown(with event: NSEvent) {
        let point = convert(event.locationInWindow, from: nil)
        startPoint = point
        
        if currentTool == .delete {
            // Find and delete annotation at point
            if let index = annotations.firstIndex(where: { $0.containsPoint(point) }) {
                annotations.remove(at: index)
                needsDisplay = true
            }
        }
    }
    
    override func mouseDragged(with event: NSEvent) {
        guard let start = startPoint else { return }
        let point = convert(event.locationInWindow, from: nil)
        currentPoint = point
        
        // Create temporary annotation for preview
        switch currentTool {
        case .arrow:
            temporaryAnnotation = ArrowAnnotation(start: start, end: point, color: currentColor, lineWidth: currentLineWidth)
        case .rectangle:
            temporaryAnnotation = RectangleAnnotation(start: start, end: point, color: currentColor, lineWidth: currentLineWidth)
        default:
            break
        }
        
        needsDisplay = true
    }
    
    override func mouseUp(with event: NSEvent) {
        guard let start = startPoint else { return }
        let point = convert(event.locationInWindow, from: nil)
        
        switch currentTool {
        case .arrow:
            annotations.append(ArrowAnnotation(start: start, end: point, color: currentColor, lineWidth: currentLineWidth))
        case .rectangle:
            annotations.append(RectangleAnnotation(start: start, end: point, color: currentColor, lineWidth: currentLineWidth))
        case .text:
            let text = promptForText()
            if !text.isEmpty {
                annotations.append(TextAnnotation(point: point, text: text, color: currentColor, fontSize: currentLineWidth * 5))
            }
        default:
            break
        }
        
        temporaryAnnotation = nil
        startPoint = nil
        currentPoint = nil
        needsDisplay = true
    }
    
    private func promptForText() -> String {
        let alert = NSAlert()
        alert.messageText = "Введите текст"
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Отмена")
        
        let textField = NSTextField(frame: NSRect(x: 0, y: 0, width: 200, height: 24))
        alert.accessoryView = textField
        
        alert.window.initialFirstResponder = textField
        
        let response = alert.runModal()
        if response == .alertFirstButtonReturn {
            return textField.stringValue
        }
        return ""
    }
    
    func renderToImage() -> NSImage {
        let imageRect = calculateImageRect()
        let image = NSImage(size: screenshot.size)
        
        image.lockFocus()
        
        // Draw screenshot
        screenshot.draw(in: NSRect(origin: .zero, size: screenshot.size))
        
        // Draw annotations (scaled to original image size)
        let scale = screenshot.size.width / imageRect.width
        
        let context = NSGraphicsContext.current?.cgContext
        context?.saveGState()
        context?.translateBy(x: -imageRect.origin.x * scale, y: -imageRect.origin.y * scale)
        context?.scaleBy(x: scale, y: scale)
        
        for annotation in annotations {
            annotation.draw()
        }
        
        context?.restoreGState()
        
        image.unlockFocus()
        
        return image
    }
}

// Annotation protocol
protocol Annotation {
    func draw()
    func containsPoint(_ point: NSPoint) -> Bool
}

class ArrowAnnotation: Annotation {
    let start: NSPoint
    let end: NSPoint
    let color: NSColor
    let lineWidth: CGFloat
    
    init(start: NSPoint, end: NSPoint, color: NSColor, lineWidth: CGFloat) {
        self.start = start
        self.end = end
        self.color = color
        self.lineWidth = lineWidth
    }
    
    func draw() {
        color.setStroke()
        
        let path = NSBezierPath()
        path.move(to: start)
        path.line(to: end)
        path.lineWidth = lineWidth
        path.stroke()
        
        // Draw arrowhead
        let angle = atan2(end.y - start.y, end.x - start.x)
        let arrowLength: CGFloat = 15
        let arrowAngle: CGFloat = .pi / 6
        
        let arrowPath = NSBezierPath()
        arrowPath.move(to: end)
        arrowPath.line(to: NSPoint(
            x: end.x - arrowLength * cos(angle - arrowAngle),
            y: end.y - arrowLength * sin(angle - arrowAngle)
        ))
        arrowPath.move(to: end)
        arrowPath.line(to: NSPoint(
            x: end.x - arrowLength * cos(angle + arrowAngle),
            y: end.y - arrowLength * sin(angle + arrowAngle)
        ))
        arrowPath.lineWidth = lineWidth
        arrowPath.stroke()
    }
    
    func containsPoint(_ point: NSPoint) -> Bool {
        let distance = distanceToLine(point: point, lineStart: start, lineEnd: end)
        return distance < lineWidth * 2
    }
    
    private func distanceToLine(point: NSPoint, lineStart: NSPoint, lineEnd: NSPoint) -> CGFloat {
        let dx = lineEnd.x - lineStart.x
        let dy = lineEnd.y - lineStart.y
        let lenSquared = dx * dx + dy * dy
        
        if lenSquared == 0 {
            return hypot(point.x - lineStart.x, point.y - lineStart.y)
        }
        
        let t = max(0, min(1, ((point.x - lineStart.x) * dx + (point.y - lineStart.y) * dy) / lenSquared))
        let projectionX = lineStart.x + t * dx
        let projectionY = lineStart.y + t * dy
        
        return hypot(point.x - projectionX, point.y - projectionY)
    }
}

class RectangleAnnotation: Annotation {
    let start: NSPoint
    let end: NSPoint
    let color: NSColor
    let lineWidth: CGFloat
    
    init(start: NSPoint, end: NSPoint, color: NSColor, lineWidth: CGFloat) {
        self.start = start
        self.end = end
        self.color = color
        self.lineWidth = lineWidth
    }
    
    func draw() {
        color.setStroke()
        
        let rect = NSRect(
            x: min(start.x, end.x),
            y: min(start.y, end.y),
            width: abs(end.x - start.x),
            height: abs(end.y - start.y)
        )
        
        let path = NSBezierPath(rect: rect)
        path.lineWidth = lineWidth
        path.stroke()
    }
    
    func containsPoint(_ point: NSPoint) -> Bool {
        let rect = NSRect(
            x: min(start.x, end.x),
            y: min(start.y, end.y),
            width: abs(end.x - start.x),
            height: abs(end.y - start.y)
        )
        return rect.contains(point)
    }
}

class TextAnnotation: Annotation {
    let point: NSPoint
    let text: String
    let color: NSColor
    let fontSize: CGFloat
    
    init(point: NSPoint, text: String, color: NSColor, fontSize: CGFloat) {
        self.point = point
        self.text = text
        self.color = color
        self.fontSize = fontSize
    }
    
    func draw() {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: fontSize),
            .foregroundColor: color
        ]
        text.draw(at: point, withAttributes: attributes)
    }
    
    func containsPoint(_ point: NSPoint) -> Bool {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: fontSize)
        ]
        let size = text.size(withAttributes: attributes)
        let rect = NSRect(origin: self.point, size: size)
        return rect.contains(point)
    }
}
