# Technical Architecture

## Overview

Vibe Screenshoter is a native macOS application built with Swift and AppKit. It follows a modular architecture with clear separation of concerns.

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                      AppDelegate                            │
│  (Application Lifecycle & Menu Bar Management)              │
└───────────────────┬─────────────────────────────────────────┘
                    │
        ┌───────────┴───────────┬──────────────────┐
        │                       │                  │
        ▼                       ▼                  ▼
┌──────────────┐    ┌──────────────────┐   ┌────────────┐
│   Settings   │    │  Screenshot      │   │  Settings  │
│   Manager    │◄───│  Manager         │   │  Window    │
└──────────────┘    └──────┬───────────┘   └────────────┘
                           │
                ┌──────────┴──────────┐
                │                     │
                ▼                     ▼
        ┌──────────────┐      ┌──────────────┐
        │   Capture    │      │   Editor     │
        │   Window     │      │   Window     │
        └──────────────┘      └──────────────┘
```

## Components

### 1. AppDelegate

**Responsibility**: Main application entry point and lifecycle management

**Key Features**:
- Initializes application on launch
- Creates and manages the menu bar status item
- Registers global keyboard shortcuts
- Coordinates between different managers
- Handles application termination

**Dependencies**:
- ScreenshotManager
- SettingsManager

### 2. ScreenshotManager

**Responsibility**: Orchestrates the screenshot capture workflow

**Key Features**:
- Manages the capture-edit-save pipeline
- Registers and handles global keyboard shortcuts
- Creates and manages CaptureWindow and EditorWindow instances
- Handles clipboard and file system operations
- Manages window lifecycle and visibility

**Methods**:
- `registerShortcut(keyCode:modifiers:)`: Register global hotkey
- `startScreenshotCapture()`: Initiate screenshot process
- `handleCapturedScreenshot(image:rect:)`: Process captured image
- `saveScreenshot(image:)`: Save to clipboard and file system

### 3. CaptureWindow

**Responsibility**: Full-screen overlay for area selection

**Key Features**:
- Full-screen borderless window
- Darkened overlay with 30% opacity
- Real-time selection rectangle visualization
- Display of selection dimensions
- Mouse event handling for area selection
- Keyboard monitoring for ESC key
- Screen capture using Core Graphics

**Event Handling**:
- `mouseDown`: Start selection
- `mouseDragged`: Update selection rectangle
- `mouseUp`: Complete selection and capture
- `rightMouseDown`: Cancel operation

### 4. EditorWindow

**Responsibility**: Annotation editor interface

**Key Features**:
- Toolbar with drawing tools
- Canvas for displaying and annotating screenshot
- Support for multiple annotation types
- Color and size customization
- Element deletion capability
- Final image rendering

**Sub-components**:
- **CanvasView**: Custom NSView for drawing and interaction
- **Drawing Tools**: Arrow, Text, Rectangle
- **Annotations**: Protocol-based annotation system

**Annotation Types**:
1. **ArrowAnnotation**: Directed arrow with customizable color and width
2. **RectangleAnnotation**: Rectangle outline
3. **TextAnnotation**: Text label with font customization

### 5. SettingsManager

**Responsibility**: Persistent storage and retrieval of user preferences

**Stored Settings**:
- `launchAtLogin`: Boolean for auto-start
- `shortcutKeyCode`: Key code for global shortcut
- `shortcutModifiers`: Modifier keys for shortcut
- `savePath`: File system path for saving screenshots
- `saveFormat`: PNG or JPEG format selection

**Storage**: Uses UserDefaults for persistence

### 6. SettingsWindowController

**Responsibility**: User interface for application settings

**UI Components**:
- Launch at login checkbox
- Shortcut display (currently read-only)
- Save path text field with browse button
- Format popup menu (PNG/JPEG)
- Save and Cancel buttons

## Data Flow

### Screenshot Capture Flow

```
1. User triggers shortcut (Cmd+Shift+S)
   ↓
2. ScreenshotManager.startScreenshotCapture()
   ↓
3. CaptureWindow appears (full-screen overlay)
   ↓
4. User selects area with mouse
   ↓
5. CaptureWindow captures selected region
   ↓
6. ScreenshotManager.handleCapturedScreenshot()
   ↓
7. EditorWindow opens with captured image
   ↓
8. User adds annotations
   ↓
9. User clicks "Save"
   ↓
10. ScreenshotManager.saveScreenshot()
    ├─→ Save to clipboard
    └─→ Save to file system
```

### Settings Flow

```
1. User opens Settings from menu bar
   ↓
2. SettingsWindowController displays current settings
   ↓
3. User modifies settings
   ↓
4. User clicks "Save"
   ↓
5. SettingsManager persists changes to UserDefaults
   ↓
6. Changes take effect immediately or on next app launch
```

## Key Technologies

### AppKit Components Used

- **NSStatusBar**: Menu bar integration
- **NSMenu**: Context menu
- **NSWindow**: Windows and overlays
- **NSView**: Custom drawing and UI
- **NSEvent**: Mouse and keyboard event handling
- **NSImage**: Image manipulation
- **NSBezierPath**: Vector drawing
- **NSUserDefaults**: Settings persistence

### Core Graphics

- **CGDisplayCreateImage**: Screen capture
- **CGImage**: Image representation
- **CGContext**: Graphics rendering

### Carbon (Legacy)

- **RegisterEventHotKey**: Global keyboard shortcuts
- Used for backward compatibility and reliability

## Thread Safety

- Main thread: All UI operations
- Background thread: Not currently used (consider for large screenshot processing)
- Event loop: AppKit handles all event processing

## Memory Management

- ARC (Automatic Reference Counting): All objects
- Weak references: Used in closures to prevent retain cycles
- Explicit cleanup: `ScreenshotManager.cleanup()` removes event monitors

## Security Considerations

### Required Permissions

1. **Screen Recording**: Required for capturing screen content
2. **Accessibility**: Required for global keyboard shortcuts

### Privacy

- No network access required
- All data stays local
- No telemetry or analytics
- User controls save location

## Performance Characteristics

### Resource Usage

- **Memory**: ~20-30 MB when idle
- **CPU**: Near zero when idle, <5% during capture/edit
- **Disk**: Minimal (screenshots only)

### Optimization Strategies

1. **Lazy Loading**: Windows created only when needed
2. **Resource Cleanup**: Windows deallocated after use
3. **Efficient Drawing**: Uses AppKit's optimized rendering
4. **Image Format**: PNG compression, JPEG quality configurable

## Extension Points

### Adding New Drawing Tools

1. Add enum case to `DrawingTool`
2. Create class conforming to `Annotation` protocol
3. Implement `draw()` and `containsPoint()` methods
4. Add UI button and handler in `EditorWindow`
5. Update `CanvasView` mouse event handlers

### Adding New Settings

1. Add property to `SettingsManager`
2. Add UserDefaults key constant
3. Add UI control in `SettingsWindowController`
4. Implement save/load logic

### Supporting Additional Image Formats

1. Add case to `SaveFormat` enum
2. Update `ScreenshotManager.saveToFile()` method
3. Add option to settings UI

## Testing Strategy

### Unit Tests

- SettingsManager: Test default values and persistence
- Annotation classes: Test drawing and hit detection
- Format conversion: Test image format conversion

### Integration Tests

- Capture workflow: Test full capture-to-save pipeline
- Settings persistence: Test settings save and load

### Manual Testing Required

- Global keyboard shortcuts (requires system permissions)
- Screen capture (requires display access)
- UI interactions (mouse and keyboard events)

## Future Enhancements

### Planned Features

1. More drawing tools (Circle, Line, Pen/Freehand)
2. Undo/Redo functionality
3. Custom shortcut recording
4. Multiple monitor support
5. Cloud storage integration
6. Screenshot history/library
7. OCR text recognition
8. Video recording capability

### Technical Debt

1. Replace Carbon EventHotKey with modern API
2. Add proper error handling and user feedback
3. Implement async image processing
4. Add comprehensive logging
5. Improve accessibility support
