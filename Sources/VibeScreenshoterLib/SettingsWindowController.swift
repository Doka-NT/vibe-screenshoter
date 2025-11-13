import Cocoa

class SettingsWindowController: NSWindowController {
    private var settingsManager: SettingsManager
    
    private var launchAtLoginCheckbox: NSButton!
    private var savePathTextField: NSTextField!
    private var saveFormatPopup: NSPopUpButton!
    private var shortcutRecorder: NSTextField!
    
    init(settingsManager: SettingsManager) {
        self.settingsManager = settingsManager
        
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 500, height: 400),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.title = "Настройки"
        window.center()
        
        super.init(window: window)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        guard let window = window, let contentView = window.contentView else { return }
        
        var yOffset: CGFloat = contentView.bounds.height - 40
        
        // Launch at login
        let launchLabel = NSTextField(labelWithString: "Запускать при входе в систему:")
        launchLabel.frame = NSRect(x: 20, y: yOffset, width: 250, height: 20)
        contentView.addSubview(launchLabel)
        
        launchAtLoginCheckbox = NSButton(checkboxWithTitle: "", target: self, action: #selector(launchAtLoginChanged))
        launchAtLoginCheckbox.frame = NSRect(x: 280, y: yOffset, width: 200, height: 20)
        launchAtLoginCheckbox.state = settingsManager.launchAtLogin ? .on : .off
        contentView.addSubview(launchAtLoginCheckbox)
        
        yOffset -= 40
        
        // Shortcut
        let shortcutLabel = NSTextField(labelWithString: "Горячая клавиша:")
        shortcutLabel.frame = NSRect(x: 20, y: yOffset, width: 250, height: 20)
        contentView.addSubview(shortcutLabel)
        
        shortcutRecorder = NSTextField(string: "⌘⇧S")
        shortcutRecorder.frame = NSRect(x: 280, y: yOffset, width: 200, height: 24)
        shortcutRecorder.isEditable = false
        contentView.addSubview(shortcutRecorder)
        
        yOffset -= 40
        
        // Save path
        let savePathLabel = NSTextField(labelWithString: "Путь для сохранения:")
        savePathLabel.frame = NSRect(x: 20, y: yOffset, width: 250, height: 20)
        contentView.addSubview(savePathLabel)
        
        savePathTextField = NSTextField(string: settingsManager.savePath ?? "")
        savePathTextField.frame = NSRect(x: 20, y: yOffset - 25, width: 360, height: 24)
        contentView.addSubview(savePathTextField)
        
        let browseButton = NSButton(title: "Обзор...", target: self, action: #selector(browseSavePath))
        browseButton.frame = NSRect(x: 390, y: yOffset - 25, width: 90, height: 24)
        browseButton.bezelStyle = .rounded
        contentView.addSubview(browseButton)
        
        yOffset -= 70
        
        // Save format
        let formatLabel = NSTextField(labelWithString: "Формат сохранения:")
        formatLabel.frame = NSRect(x: 20, y: yOffset, width: 250, height: 20)
        contentView.addSubview(formatLabel)
        
        saveFormatPopup = NSPopUpButton(frame: NSRect(x: 280, y: yOffset - 5, width: 200, height: 26), pullsDown: false)
        saveFormatPopup.addItems(withTitles: ["PNG", "JPEG"])
        saveFormatPopup.selectItem(at: settingsManager.saveFormat == .png ? 0 : 1)
        saveFormatPopup.target = self
        saveFormatPopup.action = #selector(saveFormatChanged)
        contentView.addSubview(saveFormatPopup)
        
        yOffset -= 60
        
        // Save button
        let saveButton = NSButton(title: "Сохранить", target: self, action: #selector(saveSettings))
        saveButton.frame = NSRect(x: contentView.bounds.width - 120, y: 20, width: 100, height: 30)
        saveButton.bezelStyle = .rounded
        contentView.addSubview(saveButton)
        
        // Cancel button
        let cancelButton = NSButton(title: "Отмена", target: self, action: #selector(cancel))
        cancelButton.frame = NSRect(x: contentView.bounds.width - 230, y: 20, width: 100, height: 30)
        cancelButton.bezelStyle = .rounded
        contentView.addSubview(cancelButton)
    }
    
    @objc private func launchAtLoginChanged() {
        // Will be saved when user clicks Save
    }
    
    @objc private func browseSavePath() {
        let openPanel = NSOpenPanel()
        openPanel.canChooseFiles = false
        openPanel.canChooseDirectories = true
        openPanel.allowsMultipleSelection = false
        
        if openPanel.runModal() == .OK {
            if let url = openPanel.url {
                savePathTextField.stringValue = url.path
            }
        }
    }
    
    @objc private func saveFormatChanged() {
        // Will be saved when user clicks Save
    }
    
    @objc private func saveSettings() {
        settingsManager.launchAtLogin = launchAtLoginCheckbox.state == .on
        settingsManager.savePath = savePathTextField.stringValue
        settingsManager.saveFormat = saveFormatPopup.indexOfSelectedItem == 0 ? .png : .jpeg
        
        close()
    }
    
    @objc private func cancel() {
        close()
    }
}
