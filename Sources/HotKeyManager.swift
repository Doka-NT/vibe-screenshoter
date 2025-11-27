import Cocoa
import Carbon

protocol HotKeyDelegate: AnyObject {
    func hotKeyTriggered(id: UInt32)
}

class HotKeyManager {
    static let shared = HotKeyManager()
    
    weak var delegate: HotKeyDelegate?
    private var eventHotKeyRefs: [UInt32: EventHotKeyRef] = [:]
    private var eventHandlerRef: EventHandlerRef?
    
    private init() {
        installEventHandler()
    }
    
    deinit {
        unregisterAll()
        if let handler = eventHandlerRef {
            RemoveEventHandler(handler)
        }
    }
    
    func register(id: UInt32, keyCode: UInt16, modifiers: UInt) {
        unregister(id: id) // Unregister if exists
        
        var hotKeyID = EventHotKeyID()
        hotKeyID.signature = OSType(0x53534854) // 'SSHT' - unique signature
        hotKeyID.id = id
        
        // Convert Cocoa modifiers to Carbon modifiers
        let carbonModifiers = convertModifiers(modifiers)
        
        var ref: EventHotKeyRef?
        let status = RegisterEventHotKey(UInt32(keyCode),
                                         carbonModifiers,
                                         hotKeyID,
                                         GetApplicationEventTarget(),
                                         0,
                                         &ref)
        
        if status != noErr {
            print("Failed to register hotkey \(id): \(status)")
        } else {
            eventHotKeyRefs[id] = ref
            print("Registered hotkey \(id): code=\(keyCode), mods=\(modifiers)")
        }
    }
    
    func unregister(id: UInt32) {
        if let ref = eventHotKeyRefs[id] {
            UnregisterEventHotKey(ref)
            eventHotKeyRefs.removeValue(forKey: id)
        }
    }
    
    func unregisterAll() {
        for (_, ref) in eventHotKeyRefs {
            UnregisterEventHotKey(ref)
        }
        eventHotKeyRefs.removeAll()
    }
    
    private func installEventHandler() {
        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))
        
        let handler: EventHandlerUPP = { (_, event, _) -> OSStatus in
            var hotKeyID = EventHotKeyID()
            let status = GetEventParameter(event,
                                          EventParamName(kEventParamDirectObject),
                                          EventParamType(typeEventHotKeyID),
                                          nil,
                                          MemoryLayout<EventHotKeyID>.size,
                                          nil,
                                          &hotKeyID)
            
            if status == noErr {
                HotKeyManager.shared.delegate?.hotKeyTriggered(id: hotKeyID.id)
            }
            return noErr
        }
        
        InstallEventHandler(GetApplicationEventTarget(),
                            handler,
                            1,
                            &eventType,
                            nil,
                            &eventHandlerRef)
    }
    
    private func convertModifiers(_ flags: UInt) -> UInt32 {
        var carbonFlags: UInt32 = 0
        
        if (flags & NSEvent.ModifierFlags.command.rawValue) != 0 {
            carbonFlags |= UInt32(cmdKey)
        }
        if (flags & NSEvent.ModifierFlags.option.rawValue) != 0 {
            carbonFlags |= UInt32(optionKey)
        }
        if (flags & NSEvent.ModifierFlags.control.rawValue) != 0 {
            carbonFlags |= UInt32(controlKey)
        }
        if (flags & NSEvent.ModifierFlags.shift.rawValue) != 0 {
            carbonFlags |= UInt32(shiftKey)
        }
        
        return carbonFlags
    }
}
