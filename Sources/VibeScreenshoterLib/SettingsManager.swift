import Foundation

public enum SaveFormat {
    case png
    case jpeg
}

public class SettingsManager {
    private let defaults = UserDefaults.standard
    
    // Keys
    private let launchAtLoginKey = "launchAtLogin"
    private let shortcutKeyCodeKey = "shortcutKeyCode"
    private let shortcutModifiersKey = "shortcutModifiers"
    private let savePathKey = "savePath"
    private let saveFormatKey = "saveFormat"
    
    // Default values
    public var launchAtLogin: Bool {
        get {
            return defaults.bool(forKey: launchAtLoginKey)
        }
        set {
            defaults.set(newValue, forKey: launchAtLoginKey)
        }
    }
    
    public var shortcutKeyCode: UInt16 {
        get {
            let code = defaults.integer(forKey: shortcutKeyCodeKey)
            return code == 0 ? 1 : UInt16(code) // Default: 's' key
        }
        set {
            defaults.set(Int(newValue), forKey: shortcutKeyCodeKey)
        }
    }
    
    public var shortcutModifiers: UInt32 {
        get {
            let modifiers = defaults.integer(forKey: shortcutModifiersKey)
            return modifiers == 0 ? UInt32(cmdKey | shiftKey) : UInt32(modifiers) // Default: Cmd+Shift
        }
        set {
            defaults.set(Int(newValue), forKey: shortcutModifiersKey)
        }
    }
    
    public var savePath: String? {
        get {
            if let path = defaults.string(forKey: savePathKey) {
                return path
            }
            // Default to Desktop
            let desktopPath = NSSearchPathForDirectoriesInDomains(.desktopDirectory, .userDomainMask, true).first
            return desktopPath
        }
        set {
            defaults.set(newValue, forKey: savePathKey)
        }
    }
    
    public var saveFormat: SaveFormat {
        get {
            let format = defaults.string(forKey: saveFormatKey) ?? "png"
            return format == "jpeg" ? .jpeg : .png
        }
        set {
            let formatString = newValue == .jpeg ? "jpeg" : "png"
            defaults.set(formatString, forKey: saveFormatKey)
        }
    }
    
    public init() {
        // Initialize defaults if not set
        if defaults.object(forKey: shortcutKeyCodeKey) == nil {
            shortcutKeyCode = 1 // 's' key
        }
        if defaults.object(forKey: shortcutModifiersKey) == nil {
            shortcutModifiers = UInt32(cmdKey | shiftKey)
        }
        if defaults.object(forKey: saveFormatKey) == nil {
            saveFormat = .png
        }
    }
}
