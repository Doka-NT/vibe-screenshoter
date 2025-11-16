# Copilot Instructions for Vibe Screenshoter

## Project Overview

Vibe Screenshoter is a native macOS screenshot application built with Swift and AppKit. It runs as a menu bar agent (no Dock icon) and provides screenshot capture with annotation capabilities.

### Key Features
- Menu bar-only application (LSUIElement = YES)
- Global keyboard shortcuts (default: ⌘⇧S)
- Area selection with visual feedback
- Screenshot editor with annotation tools (arrow, text, rectangle)
- Saves to clipboard and file system
- Supports PNG and JPEG formats
- Lightweight and privacy-focused (no network access)

### Target Platform
- **Minimum**: macOS 13.0 (Ventura)
- **Swift**: 5.9 or later
- **Xcode**: 15.0 or later
- **Architecture**: Universal binary (Apple Silicon and Intel)

## Architecture

The application follows a modular architecture with clear separation of concerns:

### Core Components

1. **AppDelegate** (`Sources/VibeScreenshoterLib/AppDelegate.swift`)
   - Application lifecycle management
   - Menu bar status item creation and management
   - Coordinates between managers

2. **ScreenshotManager** (`Sources/VibeScreenshoterLib/ScreenshotManager.swift`)
   - Orchestrates capture-edit-save workflow
   - Manages global keyboard shortcuts
   - Handles window lifecycle
   - Clipboard and file system operations

3. **CaptureWindow** (`Sources/VibeScreenshoterLib/CaptureWindow.swift`)
   - Full-screen overlay for area selection
   - Mouse event handling
   - Real-time selection visualization
   - Screen capture using Core Graphics

4. **EditorWindow** (`Sources/VibeScreenshoterLib/EditorWindow.swift`)
   - Annotation editor interface
   - Drawing tools implementation
   - Protocol-based annotation system
   - Image rendering and export

5. **SettingsManager** (`Sources/VibeScreenshoterLib/SettingsManager.swift`)
   - UserDefaults-based settings persistence
   - Property accessors for all settings

6. **SettingsWindowController** (`Sources/VibeScreenshoterLib/SettingsWindowController.swift`)
   - Settings UI implementation
   - Form handling and validation

### Data Flow

```
User triggers shortcut → ScreenshotManager → CaptureWindow (selection) →
→ Screen capture → EditorWindow (annotations) → Save to clipboard & file
```

## Coding Standards

### Swift Style Guide

Follow the [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/).

**Naming Conventions:**
- **Variables/Functions**: camelCase (e.g., `userName`, `calculateTotalPrice()`)
- **Types**: PascalCase (e.g., `ScreenshotManager`, `CaptureWindow`)
- **Private members**: Prefix with `private` access control

**Formatting:**
- Indentation: 4 spaces (no tabs)
- Line length: Prefer under 120 characters
- Consistent spacing and alignment

**Memory Management:**
- Always use `[weak self]` in closures that reference `self` to prevent retain cycles
- Use ARC (Automatic Reference Counting)
- Explicit cleanup in `ScreenshotManager.cleanup()` for event monitors

**Comments:**
- Explain "why", not "what"
- Use Swift documentation comments (`///`) for public APIs
- Keep comments up-to-date with code changes

### Example

```swift
// Good
class ScreenshotManager {
    private var captureWindow: CaptureWindow?
    private var settingsManager: SettingsManager
    
    /// Starts the screenshot capture process
    /// - Returns: True if capture was initiated successfully
    public func startCapture() -> Bool {
        // Using weak self to prevent retain cycle
        someHandler = { [weak self] in
            self?.process()
        }
    }
}
```

## Build & Test

### Building the Application

This project uses Swift Package Manager.

```bash
# Build in release mode
swift build -c release

# Build in debug mode (for development)
swift build

# The executable will be at:
# .build/release/VibeScreenshoter (release)
# .build/debug/VibeScreenshoter (debug)
```

**Note**: The application requires macOS to build and run. It will not build on Linux or Windows.

### Running Tests

```bash
# Run all tests
swift test

# Run tests with verbose output
swift test --verbose
```

**Test Location**: `Tests/VibeScreenshoterTests.swift`

### What to Test

- **Unit Tests**: Settings persistence, annotation logic, format conversion
- **Integration Tests**: Capture workflow, settings save/load
- **Manual Testing Required**: Global shortcuts, screen capture, UI interactions (requires permissions)

## Linting

The project uses SwiftLint for code quality enforcement.

### Running SwiftLint

```bash
# Install SwiftLint (if not already installed)
brew install swiftlint

# Run linter
swiftlint lint

# Auto-fix issues where possible
swiftlint lint --fix
```

### SwiftLint Configuration

Configuration file: `.swiftlint.yml`

**Key Rules:**
- Line length: Warning at 120 chars, error at 150
- Function body length: Warning at 60 lines, error at 100
- File length: Warning at 500 lines, error at 1000
- Indentation: 4 spaces
- No print statements (use proper logging)
- Sorted imports

**Paths:**
- Included: `Sources/`
- Excluded: `.build`, `Tests`, `.swiftpm`

## Development Workflow

### Making Changes

1. **Create a feature branch**:
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make changes** following coding standards

3. **Build and test**:
   ```bash
   swift build
   swift test
   ```

4. **Run linter**:
   ```bash
   swiftlint lint
   ```

5. **Commit changes**:
   ```bash
   git add .
   git commit -m "Brief description of changes"
   ```

### Branch Naming
- Feature: `feature/description-of-feature`
- Bug fix: `fix/description-of-bug`
- Documentation: `docs/description-of-change`
- Refactoring: `refactor/description-of-change`

### Commit Messages
- Use present tense ("Add feature" not "Added feature")
- Use imperative mood ("Move cursor to..." not "Moves cursor to...")
- Limit first line to 72 characters
- Reference issues when relevant (e.g., "Fixes #123")

## Key Technologies

### AppKit Components
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

## Required Permissions

The application requires these macOS permissions:

1. **Screen Recording**: System Settings → Privacy & Security → Screen Recording
2. **Accessibility**: System Settings → Privacy & Security → Accessibility

These are needed for screen capture and global keyboard shortcuts respectively.

## Common Tasks

### Adding a New Drawing Tool

1. Add enum case to `DrawingTool` in `EditorWindow.swift`
2. Create a new annotation class conforming to `Annotation` protocol
3. Implement `draw()` and `containsPoint()` methods
4. Add UI button and handler in `createToolbar()` method
5. Update `CanvasView` mouse event handlers

### Adding a New Setting

1. Add property to `SettingsManager` class
2. Add UserDefaults key constant
3. Add UI control in `SettingsWindowController`
4. Implement save/load logic

### Supporting a New Image Format

1. Add case to `SaveFormat` enum in `SettingsManager.swift`
2. Update `ScreenshotManager.saveToFile()` method
3. Add option to settings UI in `SettingsWindowController`

## File Structure

```
vibe-screenshoter/
├── .github/
│   ├── workflows/
│   │   └── build.yml              # CI/CD pipeline (linting)
│   └── copilot-instructions.md    # This file
├── Sources/
│   ├── VibeScreenshoter/
│   │   └── main.swift             # Application entry point
│   └── VibeScreenshoterLib/
│       ├── AppDelegate.swift      # Main application lifecycle
│       ├── ScreenshotManager.swift # Capture orchestration
│       ├── CaptureWindow.swift    # Area selection overlay
│       ├── EditorWindow.swift     # Annotation editor
│       ├── SettingsManager.swift  # Settings persistence
│       └── SettingsWindowController.swift # Settings UI
├── Tests/
│   └── VibeScreenshoterTests.swift # Test suite
├── Package.swift                   # Swift Package Manager manifest
├── .swiftlint.yml                 # Linting configuration
├── Info.plist                     # Application bundle info
├── README.md                      # User documentation
├── ARCHITECTURE.md                # Technical design
├── BUILDING.md                    # Build instructions
└── CONTRIBUTING.md                # Contribution guidelines
```

## Project-Specific Terminology

- **Menu Bar Agent**: Application that runs only in the menu bar without a Dock icon
- **Status Item**: The icon displayed in the macOS menu bar
- **Capture Window**: Full-screen overlay for selecting screenshot area
- **Editor Window**: Interface for annotating captured screenshots
- **Annotation**: Drawing element (arrow, text, rectangle) added to a screenshot
- **LSUIElement**: macOS property that prevents app from showing in Dock

## CI/CD Pipeline

**Workflow**: `.github/workflows/build.yml`

The GitHub Actions workflow runs on:
- Push to `main` or `develop` branches
- Pull requests to `main` or `develop` branches

**Steps**:
1. Checkout code
2. Install SwiftLint
3. Run SwiftLint (non-blocking, continues on errors)

**Note**: The workflow uses `|| true` to allow continuation even if linting finds issues, as this is a quality check rather than a build blocker.

## Performance Considerations

### Resource Usage
- **Memory**: ~20-30 MB when idle, <100 MB during editing
- **CPU**: <1% idle, <5% during capture/edit
- **Startup**: <1 second launch time

### Optimization Strategies
1. Lazy window creation (windows created only when needed)
2. Immediate resource cleanup (windows deallocated after use)
3. Efficient AppKit rendering
4. Image format compression (PNG/JPEG)

## Security & Privacy

### Privacy Features
- No network access (completely offline)
- No telemetry or analytics
- All data stored locally
- User controls save location
- No external dependencies

### Security Measures
- Minimal permissions requested
- Open source (auditable code)
- No credential storage
- Sandboxed environment

## Testing Strategy

### Unit Tests
Focus on:
- SettingsManager: Default values and persistence
- Annotation classes: Drawing and hit detection
- Format conversion: Image format conversion

### Integration Tests
Focus on:
- Capture workflow: Full capture-to-save pipeline
- Settings persistence: Save and load operations

### Manual Testing
Required for:
- Global keyboard shortcuts (requires system permissions)
- Screen capture (requires display access)
- UI interactions (mouse and keyboard events)
- Multi-monitor scenarios

## Common Issues & Solutions

### Build Fails with "no such module 'Cocoa'"
**Solution**: This is expected on non-macOS systems. The project requires macOS to build.

### Global Keyboard Shortcut Not Working
**Solution**: Add the application to Accessibility permissions in System Settings.

### Screen Capture Permission Denied
**Solution**: Add the application to Screen Recording permissions in System Settings.

### Launch at Login Not Working
**Solution**: Ensure the application is built as a proper app bundle (see BUILDING.md).

## Documentation References

For more detailed information, see:
- **README.md**: User guide and features
- **ARCHITECTURE.md**: Detailed technical architecture
- **BUILDING.md**: Comprehensive build instructions
- **CONTRIBUTING.md**: Contribution guidelines and standards
- **SECURITY.md**: Security policy
- **FAQ.md**: Frequently asked questions
- **UI_GUIDE.md**: Visual interface guide

## Future Enhancements

Planned features (do not implement unless explicitly requested):
- Undo/Redo functionality
- Additional drawing tools (Circle, Line, Freehand)
- Multi-monitor support
- Custom shortcut recording UI
- Screenshot history/library
- Video recording capability
- OCR text recognition

When implementing new features, always:
1. Follow the existing architecture patterns
2. Add appropriate tests
3. Update documentation
4. Run linter before committing
5. Consider performance impact
6. Maintain privacy and security standards
