import Cocoa

class ScreenshotEditorWindow: NSWindowController, EditorCanvasDelegate {
    private var canvasView: EditorCanvasView!
    private var toolbar: NSToolbar!
    private var saveHandler: ((NSImage) -> Void)?
    private var cancelHandler: (() -> Void)?
    
    // Toolbar buttons
    private var textButton: NSToolbarItem!
    private var rectangleButton: NSToolbarItem!
    private var arrowButton: NSToolbarItem!
    private var blurButton: NSToolbarItem!
    
    convenience init(image: NSImage, saveHandler: @escaping (NSImage) -> Void, cancelHandler: @escaping () -> Void) {
        // Create window
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: image.size.width, height: image.size.height),
            styleMask: [.titled, .closable, .miniaturizable], // Removed .resizable
            backing: .buffered,
            defer: false
        )
        window.title = "Редактирование скриншота"
        window.center()
        
        self.init(window: window)
        
        self.saveHandler = saveHandler
        self.cancelHandler = cancelHandler
        
        setupCanvasView(with: image)
        setupToolbar()
        
        // Set window delegate to handle close button
        window.delegate = self
    }
    
    private func setupCanvasView(with image: NSImage) {
        canvasView = EditorCanvasView(frame: NSRect(origin: .zero, size: image.size))
        canvasView.screenshotImage = image
        canvasView.delegate = self
        
        // Set canvas directly as content view (no scrollbars)
        window!.contentView = canvasView
    }
    
    private func setupToolbar() {
        toolbar = NSToolbar(identifier: "EditorToolbar")
        toolbar.delegate = self
        toolbar.displayMode = .iconAndLabel
        window?.toolbar = toolbar
    }
    
    // MARK: - EditorCanvasDelegate
    
    func canvasNeedsTextInput(at point: NSPoint) {
        let alert = NSAlert()
        alert.messageText = "Добавить текст"
        alert.informativeText = "Введите текст для аннотации:"
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Отмена")
        
        let textField = NSTextField(frame: NSRect(x: 0, y: 0, width: 300, height: 24))
        textField.placeholderString = "Текст..."
        alert.accessoryView = textField
        
        alert.beginSheetModal(for: window!) { response in
            if response == .alertFirstButtonReturn {
                let text = textField.stringValue
                if !text.isEmpty {
                    self.canvasView.addTextAnnotation(text: text, at: point)
                }
            }
        }
        
        // Focus the text field
        DispatchQueue.main.async {
            textField.becomeFirstResponder()
        }
    }
    
    // MARK: - Toolbar Actions
    
    @objc private func selectTextTool() {
        canvasView.currentTool = .text
        updateToolbarSelection()
    }
    
    @objc private func selectRectangleTool() {
        canvasView.currentTool = .rectangle
        updateToolbarSelection()
    }
    
    @objc private func selectArrowTool() {
        canvasView.currentTool = .arrow
        updateToolbarSelection()
    }
    
    @objc private func selectBlurTool() {
        canvasView.currentTool = .blur
        updateToolbarSelection()
    }
    
    @objc private func saveImage() {
        if let finalImage = canvasView.renderFinalImage() {
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
    
    private func updateToolbarSelection() {
        // Visual feedback for selected tool could be added here
        // For now, just update cursor or status
    }
}

// MARK: - NSToolbarDelegate

extension ScreenshotEditorWindow: NSToolbarDelegate {
    func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
        
        switch itemIdentifier.rawValue {
        case "text":
            let item = NSToolbarItem(itemIdentifier: itemIdentifier)
            item.label = "Текст"
            item.paletteLabel = "Текст"
            item.toolTip = "Добавить текст"
            item.image = NSImage(systemSymbolName: "textformat", accessibilityDescription: "Text")
            item.target = self
            item.action = #selector(selectTextTool)
            textButton = item
            return item
            
        case "rectangle":
            let item = NSToolbarItem(itemIdentifier: itemIdentifier)
            item.label = "Прямоугольник"
            item.paletteLabel = "Прямоугольник"
            item.toolTip = "Нарисовать прямоугольник"
            item.image = NSImage(systemSymbolName: "rectangle", accessibilityDescription: "Rectangle")
            item.target = self
            item.action = #selector(selectRectangleTool)
            rectangleButton = item
            return item
            
        case "arrow":
            let item = NSToolbarItem(itemIdentifier: itemIdentifier)
            item.label = "Стрелка"
            item.paletteLabel = "Стрелка"
            item.toolTip = "Нарисовать стрелку"
            item.image = NSImage(systemSymbolName: "arrow.up.right", accessibilityDescription: "Arrow")
            item.target = self
            item.action = #selector(selectArrowTool)
            arrowButton = item
            return item
            
        case "blur":
            let item = NSToolbarItem(itemIdentifier: itemIdentifier)
            item.label = "Размытие"
            item.paletteLabel = "Размытие"
            item.toolTip = "Размыть область"
            item.image = NSImage(systemSymbolName: "eye.slash", accessibilityDescription: "Blur")
            item.target = self
            item.action = #selector(selectBlurTool)
            blurButton = item
            return item
            
        case "save":
            let item = NSToolbarItem(itemIdentifier: itemIdentifier)
            item.label = "Сохранить"
            item.paletteLabel = "Сохранить"
            item.toolTip = "Сохранить скриншот"
            item.image = NSImage(systemSymbolName: "checkmark.circle.fill", accessibilityDescription: "Save")
            item.target = self
            item.action = #selector(saveImage)
            return item
            
        case "cancel":
            let item = NSToolbarItem(itemIdentifier: itemIdentifier)
            item.label = "Отмена"
            item.paletteLabel = "Отмена"
            item.toolTip = "Отменить и закрыть"
            item.image = NSImage(systemSymbolName: "xmark.circle.fill", accessibilityDescription: "Cancel")
            item.target = self
            item.action = #selector(cancelEditing)
            return item
            
        default:
            return nil
        }
    }
    
    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return [
            NSToolbarItem.Identifier("text"),
            NSToolbarItem.Identifier("rectangle"),
            NSToolbarItem.Identifier("arrow"),
            NSToolbarItem.Identifier("blur"),
            .flexibleSpace,
            NSToolbarItem.Identifier("save"),
            NSToolbarItem.Identifier("cancel")
        ]
    }
    
    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return toolbarDefaultItemIdentifiers(toolbar)
    }
}

// MARK: - NSToolbarItemValidation

extension ScreenshotEditorWindow: NSToolbarItemValidation {
    func validateToolbarItem(_ item: NSToolbarItem) -> Bool {
        print("Validating toolbar item: \(item.itemIdentifier.rawValue)")
        return true
    }
}

// MARK: - NSWindowDelegate

extension ScreenshotEditorWindow: NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        // If user closes window via close button, treat as cancel
        // We check if handlers are still set (they might be nilled out if we closed programmatically, 
        // but here we just call cancelHandler which is safe to call multiple times if we designed it that way,
        // or we can rely on the fact that if we saved, we probably closed the window ourselves).
        
        // Actually, to be safe, we should just call cancelHandler here.
        // If we saved, we should have probably nilled out the handlers or set a flag.
        // But for now, let's just assume if the window is closing and we didn't trigger save, it's a cancel.
        
        // A simple way is to check if the window is visible? No, it's closing.
        // Let's just call cancelHandler. The AppDelegate implementation of cancelHandler
        // removes the editor and cleans up temp file.
        // If we already saved, the temp file is gone.
        // But wait, if we saved, we don't want to call cancelHandler because that might imply "user cancelled".
        // Although for cleanup purposes it's fine.
        
        // Better approach:
        // In saveImage/cancelEditing, we can set handlers to nil after calling them.
        // Then here we check if cancelHandler is non-nil.
        
        cancelHandler?()
    }
}
