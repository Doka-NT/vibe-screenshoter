import Cocoa

enum ShortcutType {
    case screen
    case selection
}

class SettingsViewController: NSViewController {
    
    private let pathLabel = NSTextField(labelWithString: "")
    private let screenShortcutField = NSTextField()
    private let selectionShortcutField = NSTextField()
    private var isRecording = false
    private var recordingType: ShortcutType?
    private var eventMonitor: Any?
    
    override func loadView() {
        self.view = NSView(frame: NSRect(x: 0, y: 0, width: 450, height: 280))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateUI()
    }
    
    private func setupUI() {
        let stackView = NSStackView()
        stackView.orientation = .vertical
        stackView.alignment = .leading
        stackView.spacing = 20
        stackView.edgeInsets = NSEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Save Location Section
        let locationBox = NSBox()
        locationBox.title = "Save Location"
        locationBox.boxType = .primary
        
        let locationStack = NSStackView()
        locationStack.orientation = .vertical
        locationStack.alignment = .leading
        locationStack.spacing = 10
        
        pathLabel.lineBreakMode = .byTruncatingMiddle
        pathLabel.maximumNumberOfLines = 1
        
        let changeButton = NSButton(title: "Change...", target: self, action: #selector(changeLocation))
        
        locationStack.addArrangedSubview(pathLabel)
        locationStack.addArrangedSubview(changeButton)
        
        locationBox.contentView = locationStack
        locationStack.frame = NSRect(x: 10, y: 10, width: 390, height: 50) 
        
        // Shortcuts Section
        let shortcutsBox = NSBox()
        shortcutsBox.title = "Global Shortcuts"
        shortcutsBox.boxType = .primary
        
        let shortcutsStack = NSStackView()
        shortcutsStack.orientation = .vertical
        shortcutsStack.alignment = .leading
        shortcutsStack.spacing = 15
        
        // Screen shortcut
        let screenLabel = NSTextField(labelWithString: "Screen Capture:")
        screenLabel.font = NSFont.systemFont(ofSize: 13, weight: .medium)
        
        screenShortcutField.placeholderString = "Click to record shortcut"
        screenShortcutField.isEditable = false
        screenShortcutField.isSelectable = true
        screenShortcutField.wantsLayer = true
        screenShortcutField.widthAnchor.constraint(equalToConstant: 200).isActive = true
        
        let screenClickGesture = NSClickGestureRecognizer(target: self, action: #selector(screenShortcutClicked))
        screenShortcutField.addGestureRecognizer(screenClickGesture)
        
        let screenContainer = NSStackView()
        screenContainer.orientation = .horizontal
        screenContainer.spacing = 10
        screenContainer.addArrangedSubview(screenLabel)
        screenContainer.addArrangedSubview(screenShortcutField)
        
        // Selection shortcut
        let selectionLabel = NSTextField(labelWithString: "Selection Capture:")
        selectionLabel.font = NSFont.systemFont(ofSize: 13, weight: .medium)
        
        selectionShortcutField.placeholderString = "Click to record shortcut"
        selectionShortcutField.isEditable = false
        selectionShortcutField.isSelectable = true
        selectionShortcutField.wantsLayer = true
        selectionShortcutField.widthAnchor.constraint(equalToConstant: 200).isActive = true
        
        let selectionClickGesture = NSClickGestureRecognizer(target: self, action: #selector(selectionShortcutClicked))
        selectionShortcutField.addGestureRecognizer(selectionClickGesture)
        
        let selectionContainer = NSStackView()
        selectionContainer.orientation = .horizontal
        selectionContainer.spacing = 10
        selectionContainer.addArrangedSubview(selectionLabel)
        selectionContainer.addArrangedSubview(selectionShortcutField)
        
        let infoLabel = NSTextField(labelWithString: "Press Esc to cancel recording")
        infoLabel.textColor = .secondaryLabelColor
        infoLabel.font = NSFont.systemFont(ofSize: 11)
        
        shortcutsStack.addArrangedSubview(screenContainer)
        shortcutsStack.addArrangedSubview(selectionContainer)
        shortcutsStack.addArrangedSubview(infoLabel)
        
        shortcutsBox.contentView = shortcutsStack
        shortcutsStack.frame = NSRect(x: 10, y: 10, width: 390, height: 100)

        stackView.addArrangedSubview(locationBox)
        stackView.addArrangedSubview(shortcutsBox)
        
        // Constraints for boxes
        locationBox.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
        locationBox.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        shortcutsBox.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
        shortcutsBox.heightAnchor.constraint(equalToConstant: 150).isActive = true
    }
    
    private func updateUI() {
        pathLabel.stringValue = SettingsManager.shared.saveLocation.path
        
        // Update screen shortcut
        if let code = SettingsManager.shared.screenShortcutKeyCode,
           let mods = SettingsManager.shared.screenShortcutModifiers {
            screenShortcutField.stringValue = stringFor(keyCode: code, modifiers: mods)
        } else {
            screenShortcutField.stringValue = "None"
        }
        
        // Update selection shortcut
        if let code = SettingsManager.shared.selectionShortcutKeyCode,
           let mods = SettingsManager.shared.selectionShortcutModifiers {
            selectionShortcutField.stringValue = stringFor(keyCode: code, modifiers: mods)
        } else {
            selectionShortcutField.stringValue = "None"
        }
    }
    
    @objc func changeLocation() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.canCreateDirectories = true
        panel.allowsMultipleSelection = false
        
        panel.begin { response in
            if response == .OK, let url = panel.url {
                SettingsManager.shared.saveLocation = url
                self.updateUI()
            }
        }
    }
    
    @objc func screenShortcutClicked() {
        startRecording(type: .screen)
    }
    
    @objc func selectionShortcutClicked() {
        startRecording(type: .selection)
    }
    
    func startRecording(type: ShortcutType) {
        isRecording = true
        recordingType = type
        
        let field = type == .screen ? screenShortcutField : selectionShortcutField
        field.stringValue = "Recording... Press keys"
        field.layer?.borderColor = NSColor.systemBlue.cgColor
        field.layer?.borderWidth = 2.0
        
        // Install event monitor to capture key events
        eventMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            self?.handleKeyEvent(event)
            return nil // Consume the event
        }
    }
    
    func endRecording() {
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
            eventMonitor = nil
        }
        
        if let type = recordingType {
            let field = type == .screen ? screenShortcutField : selectionShortcutField
            field.layer?.borderWidth = 0.0
        }
        isRecording = false
        recordingType = nil
        updateUI()
        view.window?.makeFirstResponder(nil)
    }
    
    private func stringFor(keyCode: UInt16, modifiers: UInt) -> String {
        var str = ""
        let flags = NSEvent.ModifierFlags(rawValue: modifiers)
        if flags.contains(.command) { str += "⌘" }
        if flags.contains(.shift) { str += "⇧" }
        if flags.contains(.option) { str += "⌥" }
        if flags.contains(.control) { str += "⌃" }
        
        if let keyChar = keyString(for: keyCode) {
             str += keyChar.uppercased()
        } else {
             str += "[\(keyCode)]"
        }
        
        return str
    }
    
    private func keyString(for keyCode: UInt16) -> String? {
        // Basic mapping for common keys
        switch keyCode {
        case 0: return "A"
        case 1: return "S"
        case 2: return "D"
        case 3: return "F"
        case 4: return "H"
        case 5: return "G"
        case 6: return "Z"
        case 7: return "X"
        case 8: return "C"
        case 9: return "V"
        case 11: return "B"
        case 12: return "Q"
        case 13: return "W"
        case 14: return "E"
        case 15: return "R"
        case 16: return "Y"
        case 17: return "T"
        case 18: return "1"
        case 19: return "2"
        case 20: return "3"
        case 21: return "4"
        case 23: return "5"
        case 22: return "6"
        case 26: return "7"
        case 28: return "8"
        case 25: return "9"
        case 29: return "0"
        case 31: return "O"
        case 32: return "U"
        case 34: return "I"
        case 35: return "P"
        case 37: return "L"
        case 38: return "J"
        case 40: return "K"
        case 45: return "N"
        case 46: return "M"
        default: return nil
        }
    }
    
    private func handleKeyEvent(_ event: NSEvent) {
        guard let type = recordingType else { return }
        
        // Cancel on Escape
        if event.keyCode == 53 {
            endRecording()
            return
        }
        
        let flags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
        
        // Save the shortcut
        switch type {
        case .screen:
            SettingsManager.shared.screenShortcutKeyCode = event.keyCode
            SettingsManager.shared.screenShortcutModifiers = flags.rawValue
            HotKeyManager.shared.register(id: 1, keyCode: event.keyCode, modifiers: flags.rawValue)
        case .selection:
            SettingsManager.shared.selectionShortcutKeyCode = event.keyCode
            SettingsManager.shared.selectionShortcutModifiers = flags.rawValue
            HotKeyManager.shared.register(id: 2, keyCode: event.keyCode, modifiers: flags.rawValue)
        }
        
        // Update the menu bar to show the new shortcuts
        if let appDelegate = NSApplication.shared.delegate as? AppDelegate {
            appDelegate.updateMenuShortcuts()
        }
        
        endRecording()
    }
    
    deinit {
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
        }
    }
}
