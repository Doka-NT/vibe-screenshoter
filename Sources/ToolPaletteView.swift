import Cocoa

class ToolPaletteView: NSView {
    // Позволяет внешне установить выбранный инструмент
    func setSelectedTool(_ tool: EditorTool) {
        selectedTool = tool
    }
    var onToolSelected: ((EditorTool) -> Void)?
    var onSave: (() -> Void)?
    var onCancel: (() -> Void)?
    var onFontSizeChanged: ((CGFloat) -> Void)?
    
    private var selectedTool: EditorTool = .text {
        didSet {
            updateSelection(tool: selectedTool)
        }
    }
    private var toolButtons: [EditorTool: NSButton] = [:]
    private var saveButton: NSButton!
    private var cancelButton: NSButton!
    private var fontSlider: NSSlider!
    private var fontValueLabel: NSTextField!
    private var fontSize: CGFloat = 24
    
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
        let separator2 = createSeparator()
        
        // Create action buttons
        saveButton = createActionButton(icon: "checkmark.circle.fill", tooltip: "Сохранить (⌘↩)", action: #selector(saveAction), color: .systemGreen)
        cancelButton = createActionButton(icon: "xmark.circle.fill", tooltip: "Отмена (Esc)", action: #selector(cancelAction), color: .systemRed)

        let fontControl = createFontControl()
        
        // Add all buttons to stack
        stackView.addArrangedSubview(textButton)
        stackView.addArrangedSubview(rectangleButton)
        stackView.addArrangedSubview(arrowButton)
        stackView.addArrangedSubview(redactionButton)
        stackView.addArrangedSubview(separator1)
        stackView.addArrangedSubview(fontControl)
        stackView.addArrangedSubview(separator2)
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
    }
    
    private func createToolButton(tool: EditorTool, icon: String, tooltip: String) -> NSButton {
        let button = NSButton()
        button.bezelStyle = .texturedRounded
        button.isBordered = true
        button.setButtonType(.toggle) // keep state to show selection
        button.focusRingType = .none // avoid persistent system focus outline
        button.image = NSImage(systemSymbolName: icon, accessibilityDescription: tooltip)
        button.imagePosition = .imageOnly
        button.toolTip = tooltip
        button.target = self
        button.action = #selector(toolButtonClicked(_:))
        button.tag = tool.rawValue

        // Enable layer-backed styling for selection background
        button.wantsLayer = true
        button.layer?.cornerRadius = 8
        button.layer?.masksToBounds = true
        
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

    private func createFontControl() -> NSView {
        let container = NSStackView()
        container.orientation = .vertical
        container.alignment = .centerX
        container.spacing = 4

        let label = NSTextField(labelWithString: "Размер текста")
        label.font = .systemFont(ofSize: 11, weight: .medium)
        label.textColor = .white.withAlphaComponent(0.8)

        fontSlider = NSSlider(value: Double(fontSize), minValue: 12, maxValue: 72, target: self, action: #selector(fontSliderChanged(_:)))
        fontSlider.sliderType = .linear
        fontSlider.isContinuous = true
        fontSlider.controlSize = .small
        fontSlider.allowsTickMarkValuesOnly = false
        fontSlider.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            fontSlider.widthAnchor.constraint(equalToConstant: 140)
        ])

        fontValueLabel = NSTextField(labelWithString: formattedFontSize(fontSize))
        fontValueLabel.font = .monospacedDigitSystemFont(ofSize: 12, weight: .medium)
        fontValueLabel.textColor = .white

        let sliderRow = NSStackView(views: [fontSlider, fontValueLabel])
        sliderRow.orientation = .horizontal
        sliderRow.spacing = 8
        sliderRow.alignment = .centerY

        container.addArrangedSubview(label)
        container.addArrangedSubview(sliderRow)
        return container
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

    @objc private func fontSliderChanged(_ sender: NSSlider) {
        fontSize = CGFloat(round(sender.doubleValue))
        fontSlider.doubleValue = Double(fontSize)
        fontValueLabel.stringValue = formattedFontSize(fontSize)
        onFontSizeChanged?(fontSize)
    }
    
    private func updateSelection(tool: EditorTool) {
        // Update visual state of all tool buttons
        for (buttonTool, button) in toolButtons {
            if buttonTool == tool {
                button.state = .on
                button.contentTintColor = .controlAccentColor
                button.layer?.backgroundColor = NSColor.controlAccentColor.withAlphaComponent(0.18).cgColor
                button.layer?.borderColor = NSColor.controlAccentColor.withAlphaComponent(0.45).cgColor
                button.layer?.borderWidth = 1
            } else {
                button.state = .off
                button.contentTintColor = nil
                button.layer?.backgroundColor = NSColor.clear.cgColor
                button.layer?.borderColor = NSColor.clear.cgColor
                button.layer?.borderWidth = 0
            }
        }
    }
    
    override var intrinsicContentSize: NSSize {
        return NSSize(width: NSView.noIntrinsicMetric, height: 52)
    }

    func setFontSize(_ size: CGFloat) {
        let rounded = CGFloat(round(size))
        fontSize = rounded
        fontSlider?.doubleValue = Double(rounded)
        fontValueLabel?.stringValue = formattedFontSize(rounded)
    }
    
    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        NSCursor.closedHand.push()
    }
    
    override func mouseUp(with event: NSEvent) {
        super.mouseUp(with: event)
        NSCursor.pop()
        window?.invalidateCursorRects(for: self)
    }
    
    override func resetCursorRects() {
        discardCursorRects()
        addCursorRect(bounds, cursor: .openHand)
    }
    
    private func formattedFontSize(_ size: CGFloat) -> String {
        return "\(Int(round(size))) pt"
    }
}
