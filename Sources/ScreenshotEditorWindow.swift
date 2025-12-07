import Cocoa

class ScreenshotEditorWindow: NSWindowController, EditorCanvasDelegate {
    private var canvasView: EditorCanvasView!
    private var toolPaletteView: ToolPaletteView!
    private var saveHandler: ((NSImage) -> Void)?
    private var cancelHandler: (() -> Void)?
    private var localEventMonitor: Any?
    private var paletteTopConstraint: NSLayoutConstraint?
    private var paletteLeadingConstraint: NSLayoutConstraint?
    private let paletteMargin: CGFloat = 12
    private let frameCornerRadius: CGFloat = 10
    private let frameBorderWidth: CGFloat = 2
    
    convenience init(image: NSImage, saveHandler: @escaping (NSImage) -> Void, cancelHandler: @escaping () -> Void) {
        // Adjust image size for Retina displays if needed
        // screencapture returns an image where size == pixels (72 DPI), but on Retina we want size == pixels / scale
        let displayImage = image
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
        window.isOpaque = false
        window.backgroundColor = .clear
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
            guard let self else { return event }
            let isTextEditing = (self.window?.firstResponder?.isKind(of: NSTextView.self) == true)
            if self.handleKey(event: event, isTextEditing: isTextEditing) {
                return nil
            }
            return event
        }
    }

    private func centerPalette() {
        guard let leading = paletteLeadingConstraint, let canvas = canvasView else { return }
        let paletteWidth = toolPaletteView.fittingSize.width
        let centeredX = (canvas.bounds.width - paletteWidth) / 2
        let minX = paletteMargin
        let maxX = max(paletteMargin, canvas.bounds.width - paletteWidth - paletteMargin)
        leading.constant = min(max(centeredX, minX), maxX)
    }

    private func movePalette(by delta: NSPoint) {
        guard let leading = paletteLeadingConstraint, let top = paletteTopConstraint else { return }
        let paletteSize = toolPaletteView.fittingSize
        let maxX = max(paletteMargin, canvasView.bounds.width - paletteSize.width - paletteMargin)
        let maxY = max(paletteMargin, canvasView.bounds.height - paletteSize.height - paletteMargin)
        let nextX = min(max(paletteMargin, leading.constant + delta.x), maxX)
        let nextY = min(max(paletteMargin, top.constant + delta.y), maxY)
        leading.constant = nextX
        top.constant = nextY
        canvasView.layoutSubtreeIfNeeded()
    }
    
    private func setupCanvasView(with image: NSImage) {
        let containerView = NSView(frame: NSRect(origin: .zero, size: image.size))
        containerView.wantsLayer = true
        containerView.layer?.cornerRadius = frameCornerRadius
        containerView.layer?.borderWidth = frameBorderWidth
        containerView.layer?.borderColor = NSColor.black.withAlphaComponent(0.22).cgColor
        containerView.layer?.backgroundColor = NSColor.black.withAlphaComponent(0.06).cgColor
        containerView.layer?.shadowColor = NSColor.black.cgColor
        containerView.layer?.shadowOpacity = 0.25
        containerView.layer?.shadowRadius = 12
        containerView.layer?.shadowOffset = CGSize(width: 0, height: -1)

        canvasView = EditorCanvasView(frame: NSRect(origin: .zero, size: image.size))
        canvasView.translatesAutoresizingMaskIntoConstraints = false
        canvasView.screenshotImage = image
        canvasView.delegate = self
        canvasView.wantsLayer = true
        canvasView.layer?.cornerRadius = frameCornerRadius
        canvasView.layer?.masksToBounds = true

        containerView.addSubview(canvasView)
        NSLayoutConstraint.activate([
            canvasView.topAnchor.constraint(equalTo: containerView.topAnchor),
            canvasView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            canvasView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            canvasView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])

        window!.contentView = containerView
    }
    
    private func setupToolPalette() {
        // Create floating tool palette
        toolPaletteView = ToolPaletteView(frame: .zero)
        // Синхронизируем выбор инструмента между палитрой и канвасом
        toolPaletteView.onToolSelected = { [weak self] tool in
            self?.applyToolSelection(tool)
        }
        toolPaletteView.onSave = { [weak self] in
            self?.saveImage()
        }
        toolPaletteView.onCancel = { [weak self] in
            self?.cancelEditing()
        }
        toolPaletteView.onDrag = { [weak self] delta in
            self?.movePalette(by: delta)
        }

        // Установить начальный инструмент и синхронизировать палитру
        let initialTool: EditorTool = .text
        applyToolSelection(initialTool)

        canvasView.addSubview(toolPaletteView)

        // Position palette at top center
        toolPaletteView.translatesAutoresizingMaskIntoConstraints = false
        paletteTopConstraint = toolPaletteView.topAnchor.constraint(equalTo: canvasView.topAnchor, constant: paletteMargin)
        paletteLeadingConstraint = toolPaletteView.leadingAnchor.constraint(equalTo: canvasView.leadingAnchor, constant: paletteMargin)
        NSLayoutConstraint.activate([paletteTopConstraint, paletteLeadingConstraint].compactMap { $0 })

        // Center after layout to account for intrinsic size
        canvasView.layoutSubtreeIfNeeded()
        centerPalette()
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
    
    private func handleKey(event: NSEvent, isTextEditing: Bool) -> Bool {
        let modifiers = event.modifierFlags.intersection(.deviceIndependentFlagsMask)

        if modifiers.contains(.command) && event.keyCode == 36 { // ⌘Enter
            saveImage()
            return true
        }
        
        if event.keyCode == 53 { // Esc
            cancelEditing()
            return true
        }

        // Only switch tools when not typing
        if !isTextEditing && modifiers.isEmpty {
            if let tool = toolForKey(event) {
                applyToolSelection(tool)
                return true
            }
        }
        
        return false
    }
    
    private func toolForKey(_ event: NSEvent) -> EditorTool? {
        // Prefer keyCode for reliability, fall back to character
        switch event.keyCode {
        case 17: return .text      // T
        case 15: return .rectangle // R
        case 0:  return .arrow     // A
        case 11: return .redaction // B
        default:
            break
        }
        if let character = event.charactersIgnoringModifiers?.lowercased() {
            switch character {
            case "t": return .text
            case "r": return .rectangle
            case "a": return .arrow
            case "b": return .redaction
            default:
                break
            }
        }
        return nil
    }
    
    private func applyToolSelection(_ tool: EditorTool) {
        canvasView.currentTool = tool
        toolPaletteView.setSelectedTool(tool)
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
