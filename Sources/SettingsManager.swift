import Foundation

class SettingsManager {
    static let shared = SettingsManager()
    
    private let defaults = UserDefaults.standard
    private let saveLocationKey = "saveLocation"
    private let screenShortcutKeyCodeKey = "screenShortcutKeyCode"
    private let screenShortcutModifiersKey = "screenShortcutModifiers"
    private let selectionShortcutKeyCodeKey = "selectionShortcutKeyCode"
    private let selectionShortcutModifiersKey = "selectionShortcutModifiers"
    
    private init() {}
    
    var saveLocation: URL {
        get {
            if let path = defaults.string(forKey: saveLocationKey) {
                return URL(fileURLWithPath: path)
            }
            // Default to Desktop
            return FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask).first ?? URL(fileURLWithPath: "/tmp")
        }
        set {
            defaults.set(newValue.path, forKey: saveLocationKey)
        }
    }
    
    // Screen capture shortcut
    var screenShortcutKeyCode: UInt16? {
        get {
            if defaults.object(forKey: screenShortcutKeyCodeKey) == nil { return nil }
            return UInt16(defaults.integer(forKey: screenShortcutKeyCodeKey))
        }
        set {
            if let value = newValue {
                defaults.set(Int(value), forKey: screenShortcutKeyCodeKey)
            } else {
                defaults.removeObject(forKey: screenShortcutKeyCodeKey)
            }
        }
    }
    
    var screenShortcutModifiers: UInt? {
        get {
            if defaults.object(forKey: screenShortcutModifiersKey) == nil { return nil }
            return UInt(defaults.integer(forKey: screenShortcutModifiersKey))
        }
        set {
            if let value = newValue {
                defaults.set(Int(value), forKey: screenShortcutModifiersKey)
            } else {
                defaults.removeObject(forKey: screenShortcutModifiersKey)
            }
        }
    }
    
    // Selection capture shortcut
    var selectionShortcutKeyCode: UInt16? {
        get {
            if defaults.object(forKey: selectionShortcutKeyCodeKey) == nil { return nil }
            return UInt16(defaults.integer(forKey: selectionShortcutKeyCodeKey))
        }
        set {
            if let value = newValue {
                defaults.set(Int(value), forKey: selectionShortcutKeyCodeKey)
            } else {
                defaults.removeObject(forKey: selectionShortcutKeyCodeKey)
            }
        }
    }
    
    var selectionShortcutModifiers: UInt? {
        get {
            if defaults.object(forKey: selectionShortcutModifiersKey) == nil { return nil }
            return UInt(defaults.integer(forKey: selectionShortcutModifiersKey))
        }
        set {
            if let value = newValue {
                defaults.set(Int(value), forKey: selectionShortcutModifiersKey)
            } else {
                defaults.removeObject(forKey: selectionShortcutModifiersKey)
            }
        }
    }
}
