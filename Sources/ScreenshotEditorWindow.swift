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
    private var redactionButton: NSToolbarItem!
    
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
    
    // No longer needed for text input as it's handled inline
    
    // MARK: - Toolbar Actions
    
    @objc private func selectTextTool() {
        canvasView.currentTool = .text
        updateToolbarSelection(identifier: NSToolbarItem.Identifier("text"))
    }
    
    @objc private func selectRectangleTool() {
        canvasView.currentTool = .rectangle
        updateToolbarSelection(identifier: NSToolbarItem.Identifier("rectangle"))
    }
    
    @objc private func selectArrowTool() {
        canvasView.currentTool = .arrow
        updateToolbarSelection(identifier: NSToolbarItem.Identifier("arrow"))
    }
    
    @objc private func selectRedactionTool() {
        canvasView.currentTool = .redaction
        updateToolbarSelection(identifier: NSToolbarItem.Identifier("redaction"))
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
    
    private func updateToolbarSelection(identifier: NSToolbarItem.Identifier) {
        toolbar.selectedItemIdentifier = identifier
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
            
        case "redaction":
            let item = NSToolbarItem(itemIdentifier: itemIdentifier)
            item.label = "Скрыть"
            item.paletteLabel = "Скрыть область"
            item.toolTip = "Скрыть выбранную область"
            item.image = NSImage(systemSymbolName: "eye.slash.fill", accessibilityDescription: "Redaction")
            item.target = self
            item.action = #selector(selectRedactionTool)
            redactionButton = item
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
            NSToolbarItem.Identifier("redaction"),
            .flexibleSpace,
            NSToolbarItem.Identifier("save"),
            NSToolbarItem.Identifier("cancel")
        ]
    }
    
    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return toolbarDefaultItemIdentifiers(toolbar)
    }
    
    func toolbarSelectableItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return [
            NSToolbarItem.Identifier("text"),
            NSToolbarItem.Identifier("rectangle"),
            NSToolbarItem.Identifier("arrow"),
            NSToolbarItem.Identifier("redaction")
        ]
    }
}

// MARK: - NSToolbarItemValidation

extension ScreenshotEditorWindow: NSToolbarItemValidation {
    func validateToolbarItem(_ item: NSToolbarItem) -> Bool {
        return true
    }
}

// MARK: - NSWindowDelegate

extension ScreenshotEditorWindow: NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        cancelHandler?()
    }
}
