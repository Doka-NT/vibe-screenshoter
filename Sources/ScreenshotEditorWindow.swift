import Cocoa

class ScreenshotEditorWindow: NSWindowController, EditorCanvasDelegate {
    private var canvasView: EditorCanvasView!
    private var paletteWindow: NSWindow!
    private var toolPaletteView: ToolPaletteView!
    private var saveHandler: ((NSImage) -> Void)?
    private var cancelHandler: (() -> Void)?
    private var localEventMonitor: Any?
    private let frameCornerRadius: CGFloat = 10
    private let frameBorderWidth: CGFloat = 2
    private let palettePadding: CGFloat = 16
    
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

        // Создаем стандартное окно с заголовком, чтобы рамка была видимой
        let borderWidth: CGFloat = 15
        let contentPadding: CGFloat = 8
        let windowRect = NSRect(x: 0, y: 0, width: displayImage.size.width + borderWidth * 2 + contentPadding * 2, height: displayImage.size.height + borderWidth * 2 + contentPadding * 2)
        let window = EditorWindow(
            contentRect: windowRect,
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.title = "Редактор скриншота"
        window.titleVisibility = .visible
        window.titlebarAppearsTransparent = false
        window.setContentSize(windowRect.size)
        window.backgroundColor = .windowBackgroundColor
        window.isMovableByWindowBackground = false
        window.center()
        // Добавим толстую рамку вокруг окна
        window.contentView?.wantsLayer = true
        window.contentView?.layer?.borderWidth = borderWidth
        window.contentView?.layer?.borderColor = NSColor.windowFrameColor.cgColor
        window.contentView?.layer?.cornerRadius = 0
        
        self.init(window: window)
        
        self.saveHandler = saveHandler
        self.cancelHandler = cancelHandler
        
        setupCanvasView(with: displayImage)
        setupToolPalette()
        positionPaletteWindow()
        
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

    private func positionPaletteWindow() {
        guard let editorWindow = window, let palette = paletteWindow else { return }
        
        // Calculate position below the editor window, centered horizontally
        let editorFrame = editorWindow.frame
        let paletteSize = palette.frame.size
        
        let xPos = editorFrame.origin.x + (editorFrame.width - paletteSize.width) / 2
        let yPos = editorFrame.origin.y - paletteSize.height - palettePadding
        
        palette.setFrameOrigin(NSPoint(x: xPos, y: yPos))
    }
    
    private func setupCanvasView(with image: NSImage) {
        // Контейнер с паддингом вокруг canvasView
        let contentPadding: CGFloat = 3
        let containerSize = NSSize(width: image.size.width + contentPadding * 2, height: image.size.height + contentPadding * 2)
        let containerView = NSView(frame: NSRect(origin: .zero, size: containerSize))

        canvasView = EditorCanvasView(frame: NSRect(origin: .zero, size: image.size))
        canvasView.translatesAutoresizingMaskIntoConstraints = false
        canvasView.screenshotImage = image
        canvasView.delegate = self
        canvasView.wantsLayer = true
        canvasView.layer?.cornerRadius = 0 // убираем скругление у скриншота
        canvasView.layer?.masksToBounds = true

        containerView.addSubview(canvasView)
        // Используем автолейаут для равных паддингов
        NSLayoutConstraint.activate([
            canvasView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: contentPadding),
            canvasView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: contentPadding),
            canvasView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -contentPadding),
            canvasView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -contentPadding)
        ])

        window!.contentView = containerView
    }
    
    private func setupToolPalette() {
        // Create tool palette view
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
        toolPaletteView.onFontSizeChanged = { [weak self] size in
            self?.canvasView.setTextFontSize(size, notifyDelegate: false)
        }

        // Create separate floating window for palette
        let paletteSize = toolPaletteView.fittingSize
        paletteWindow = FloatingPaletteWindow(
            contentRect: NSRect(origin: .zero, size: paletteSize),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        paletteWindow.isOpaque = false
        paletteWindow.backgroundColor = .clear
        paletteWindow.level = .floating
        paletteWindow.isMovableByWindowBackground = true
        paletteWindow.contentView = toolPaletteView
        paletteWindow.orderFront(nil)

        // Установить начальный инструмент и синхронизировать палитру
        let initialTool: EditorTool = .text
        applyToolSelection(initialTool)
        toolPaletteView.setFontSize(canvasView.textFontSize)
    }
    
    // MARK: - EditorCanvasDelegate
    
    func editorCanvasView(_ canvas: EditorCanvasView, didChangeTextFontSize size: CGFloat) {
        toolPaletteView.setFontSize(size)
    }
    
    // MARK: - Actions
    
    @objc private func saveImage() {
        if let finalImage = canvasView.renderFinalImage() {
            // Save to clipboard
            let pasteboard = NSPasteboard.general
            pasteboard.clearContents()
            pasteboard.writeObjects([finalImage])
            
            saveHandler?(finalImage)
            window?.close()
        }
    }
    
    @objc private func cancelEditing() {
        cancelHandler?()
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
        paletteWindow?.close()
        cancelHandler?()
    }
}

// Custom window subclass to allow borderless window to become key
private class EditorWindow: NSWindow {
    override var canBecomeKey: Bool {
        return true
    }
}

// Custom window for palette with drag cursor
private class FloatingPaletteWindow: NSWindow {
    override func resetCursorRects() {
        super.resetCursorRects()
        if let contentView = contentView {
            contentView.discardCursorRects()
            contentView.addCursorRect(contentView.bounds, cursor: .openHand)
        }
    }
}
