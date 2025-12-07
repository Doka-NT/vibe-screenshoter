import Cocoa

class ToolPaletteView: NSView {
        // Позволяет внешне установить выбранный инструмент
        public func setSelectedTool(_ tool: EditorTool) {
            selectedTool = tool
        }
    var onToolSelected: ((EditorTool) -> Void)?
    var onSave: (() -> Void)?
    var onCancel: (() -> Void)?
    var onDrag: ((NSPoint) -> Void)?
    
    private var selectedTool: EditorTool = .text {
        didSet {
            updateSelection(tool: selectedTool)
        }
    }
    private var toolButtons: [EditorTool: NSButton] = [:]
    private var saveButton: NSButton!
    private var cancelButton: NSButton!
    private var dragActive = false
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        wantsLayer = true
        
        // Create a modern, compact background with blur effect
        let visualEffect = NSVisualEffectView()
        visualEffect.material = .hudWindow
        visualEffect.state = .active
        visualEffect.blendingMode = .withinWindow
        visualEffect.appearance = NSAppearance(named: .vibrantDark)
        visualEffect.wantsLayer = true
        visualEffect.layer?.cornerRadius = 12
        visualEffect.layer?.backgroundColor = NSColor(calibratedWhite: 0.06, alpha: 0.78).cgColor
        visualEffect.layer?.borderColor = NSColor.white.withAlphaComponent(0.12).cgColor
        visualEffect.layer?.borderWidth = 1
        visualEffect.translatesAutoresizingMaskIntoConstraints = false
        addSubview(visualEffect)
        
        // Create horizontal stack for all buttons
        let stackView = NSStackView()
        stackView.orientation = .horizontal
        stackView.spacing = 10
        stackView.edgeInsets = NSEdgeInsets(top: 8, left: 14, bottom: 8, right: 14)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        visualEffect.addSubview(stackView)
        
        // Create tool buttons
        let textButton = createToolButton(tool: .text, icon: "textformat", tooltip: "Текст (T)")
        let rectangleButton = createToolButton(tool: .rectangle, icon: "rectangle", tooltip: "Прямоугольник (R)")
        let arrowButton = createToolButton(tool: .arrow, icon: "arrow.up.right", tooltip: "Стрелка (A)")
        let redactionButton = createToolButton(tool: .redaction, icon: "eye.slash.fill", tooltip: "Скрыть (B)")
        
        toolButtons[.text] = textButton
        toolButtons[.rectangle] = rectangleButton
        toolButtons[.arrow] = arrowButton
        toolButtons[.redaction] = redactionButton
        
        // Create separator
        let separator1 = createSeparator()
        
        // Create action buttons
        saveButton = createActionButton(icon: "checkmark.circle.fill", tooltip: "Сохранить (⌘↩)", action: #selector(saveAction), color: .systemGreen)
        cancelButton = createActionButton(icon: "xmark.circle.fill", tooltip: "Отмена (Esc)", action: #selector(cancelAction), color: .systemRed)
        
        // Add all buttons to stack
        stackView.addArrangedSubview(textButton)
        stackView.addArrangedSubview(rectangleButton)
        stackView.addArrangedSubview(arrowButton)
        stackView.addArrangedSubview(redactionButton)
        stackView.addArrangedSubview(separator1)
        stackView.addArrangedSubview(saveButton)
        stackView.addArrangedSubview(cancelButton)
        
        // Set constraints
        NSLayoutConstraint.activate([
            visualEffect.topAnchor.constraint(equalTo: topAnchor),
            visualEffect.leadingAnchor.constraint(equalTo: leadingAnchor),
            visualEffect.trailingAnchor.constraint(equalTo: trailingAnchor),
            visualEffect.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            stackView.topAnchor.constraint(equalTo: visualEffect.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: visualEffect.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: visualEffect.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: visualEffect.bottomAnchor)
        ])
        
        // Select text tool by default
        updateSelection(tool: selectedTool)
        // Позволяет внешне установить выбранный инструмент
        func setSelectedTool(_ tool: EditorTool) {
            selectedTool = tool
        }
    }
    
    private func createToolButton(tool: EditorTool, icon: String, tooltip: String) -> NSButton {
        let button = NSButton()
        button.bezelStyle = .texturedRounded
        button.isBordered = true
        button.image = NSImage(systemSymbolName: icon, accessibilityDescription: tooltip)
        button.imagePosition = .imageOnly
        button.toolTip = tooltip
        button.target = self
        button.action = #selector(toolButtonClicked(_:))
        button.tag = tool.rawValue
        
        // Set button size
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: 36),
            button.heightAnchor.constraint(equalToConstant: 36)
        ])
        
        // Configure symbol
        let symbolConfig = NSImage.SymbolConfiguration(pointSize: 18, weight: .regular)
        button.image = button.image?.withSymbolConfiguration(symbolConfig)
        
        return button
    }
    
    private func createActionButton(icon: String, tooltip: String, action: Selector, color: NSColor) -> NSButton {
        let button = NSButton()
        button.bezelStyle = .texturedRounded
        button.isBordered = true
        button.image = NSImage(systemSymbolName: icon, accessibilityDescription: tooltip)
        button.imagePosition = .imageOnly
        button.toolTip = tooltip
        button.target = self
        button.action = action
        button.contentTintColor = color
        
        // Set button size
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: 36),
            button.heightAnchor.constraint(equalToConstant: 36)
        ])
        
        // Configure symbol
        let symbolConfig = NSImage.SymbolConfiguration(pointSize: 18, weight: .medium)
        button.image = button.image?.withSymbolConfiguration(symbolConfig)
        
        return button
    }
    
    private func createSeparator() -> NSBox {
        let separator = NSBox()
        separator.boxType = .separator
        separator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            separator.widthAnchor.constraint(equalToConstant: 1),
            separator.heightAnchor.constraint(equalToConstant: 32)
        ])
        return separator
    }
    
    @objc private func toolButtonClicked(_ sender: NSButton) {
        guard let tool = EditorTool(rawValue: sender.tag) else { return }
        selectedTool = tool
        updateSelection(tool: tool)
        onToolSelected?(tool)
    }
    
    @objc private func saveAction() {
        onSave?()
    }
    
    @objc private func cancelAction() {
        onCancel?()
    }
    
    private func updateSelection(tool: EditorTool) {
        // Update visual state of all tool buttons
        for (buttonTool, button) in toolButtons {
            if buttonTool == tool {
                button.state = .on
                button.contentTintColor = .controlAccentColor
            } else {
                button.state = .off
                button.contentTintColor = nil
            }
        }
    }
    
    override var intrinsicContentSize: NSSize {
        return NSSize(width: NSView.noIntrinsicMetric, height: 52)
    }

    // MARK: - Drag support
    override func mouseDown(with event: NSEvent) {
        dragActive = true
        NSCursor.closedHand.push()
    }

    override func mouseDragged(with event: NSEvent) {
        guard dragActive else { return }
        // Use high-rate delta values for smoother tracking
        let delta = NSPoint(x: event.deltaX, y: event.deltaY)
        onDrag?(delta)
    }

    override func mouseUp(with event: NSEvent) {
        dragActive = false
        NSCursor.pop()
    }

    override func resetCursorRects() {
        discardCursorRects()
        addCursorRect(bounds, cursor: .openHand)
    }
}
