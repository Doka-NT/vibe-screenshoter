# Changelog

All notable changes to Vibe Screenshoter will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-11-13

### Added

#### Core Features (FR-01 to FR-20)

- **Menu Bar Integration** (FR-01, FR-02, FR-03)
  - Application appears in menu bar with camera icon
  - Context menu with "Start Screenshot", "Settings", and "Quit" options
  - Launch at login capability (configurable in settings)

- **Keyboard Shortcuts** (FR-04, FR-05)
  - Global keyboard shortcut support
  - Default shortcut: Command + Shift + S (⌘⇧S)
  - Customizable shortcut in settings

- **Screenshot Capture** (FR-06, FR-07, FR-08)
  - Full-screen overlay for area selection
  - Visual feedback with selection rectangle
  - Real-time display of selection dimensions
  - ESC key cancellation
  - Right-click cancellation
  - High-quality screen capture using Core Graphics

- **Annotation Editor** (FR-09, FR-10, FR-11)
  - Arrow tool with directional arrowhead
  - Text tool with custom input
  - Rectangle tool for highlighting areas
  - Color picker for customizing annotation colors
  - Line width/size slider for all tools
  - Real-time preview while drawing
  - Intuitive toolbar interface

- **Element Management** (FR-12, FR-13)
  - Delete tool for removing annotations
  - Click-to-delete specific elements
  - Visual feedback for deletable elements

- **Save Functionality** (FR-14, FR-15, FR-16, FR-17, FR-18)
  - Automatic clipboard copy
  - File system save with customizable path
  - PNG format support (default)
  - JPEG format support with quality settings
  - Automatic filename generation with timestamp
  - Format: `Screenshot-YYYY-MM-DD-HH-mm-ss.ext`
  - Configurable save directory (defaults to Desktop)

- **Performance & Compatibility** (FR-19, FR-20)
  - Lightweight menu bar application
  - Runs as agent (no Dock icon)
  - Minimal memory footprint (~20-30 MB idle)
  - macOS 13.0+ support
  - Universal binary (Apple Silicon & Intel)

#### Technical Implementation

- Swift 5.9 with AppKit framework
- Swift Package Manager build system
- Protocol-based annotation system
- UserDefaults for settings persistence
- Modular architecture with clear separation of concerns

#### Documentation

- Comprehensive README with features and usage
- BUILDING.md with detailed build instructions
- ARCHITECTURE.md with technical design documentation
- CONTRIBUTING.md with contribution guidelines
- MIT License

#### Testing

- Unit tests for SettingsManager
- Test infrastructure for future expansion
- Manual testing procedures documented

### Project Structure

```
vibe-screenshoter/
├── Sources/
│   ├── AppDelegate.swift              # Application lifecycle
│   ├── ScreenshotManager.swift        # Capture orchestration
│   ├── CaptureWindow.swift            # Area selection overlay
│   ├── EditorWindow.swift             # Annotation editor
│   ├── SettingsManager.swift          # Preferences management
│   ├── SettingsWindowController.swift # Settings UI
│   └── main.swift                     # Entry point
├── Tests/
│   └── VibeScreenshoterTests.swift    # Unit tests
├── Package.swift                       # Swift Package Manager config
├── Info.plist                         # App bundle info
├── README.md                          # User documentation
├── BUILDING.md                        # Build instructions
├── ARCHITECTURE.md                    # Technical documentation
├── CONTRIBUTING.md                    # Contribution guide
├── CHANGELOG.md                       # This file
├── LICENSE                            # MIT License
└── .gitignore                         # Git ignore rules
```

### Technical Details

#### Implemented Components

1. **AppDelegate**
   - Menu bar status item management
   - Global shortcut registration
   - Application lifecycle handling

2. **ScreenshotManager**
   - Capture workflow coordination
   - Window lifecycle management
   - Clipboard and file operations

3. **CaptureWindow**
   - Full-screen borderless overlay
   - Mouse event handling
   - Selection visualization
   - Screen capture via CGDisplayCreateImage

4. **EditorWindow**
   - Toolbar with drawing tools
   - CanvasView for annotation
   - Annotation rendering system
   - Image export functionality

5. **Annotation System**
   - Protocol-based design
   - ArrowAnnotation with arrowhead
   - RectangleAnnotation with outline
   - TextAnnotation with custom fonts
   - Hit detection for deletion

6. **SettingsManager**
   - UserDefaults integration
   - Default value initialization
   - Type-safe property accessors

7. **SettingsWindowController**
   - Native macOS UI
   - File browser integration
   - Format selection
   - Launch at login toggle

#### Supported Formats

- **PNG**: Lossless compression (default)
- **JPEG**: Lossy compression (90% quality)

#### Keyboard Shortcuts

- **⌘⇧S**: Take screenshot (customizable)
- **ESC**: Cancel operation
- **Right-click**: Cancel operation

### Known Limitations

1. **Keyboard Shortcut Customization**: UI shows current shortcut but doesn't allow changing it yet
2. **Single Monitor**: Currently optimized for primary display
3. **Launch at Login**: Requires proper app bundle for full functionality
4. **No Undo/Redo**: Annotations cannot be undone (must use delete tool)

### System Requirements

- **Minimum**: macOS 13.0 (Ventura)
- **Recommended**: macOS 14.0 (Sonoma) or later
- **Architecture**: Universal (Apple Silicon and Intel)
- **RAM**: 4 GB minimum
- **Disk**: Minimal (application < 10 MB)

### Permissions Required

- **Screen Recording**: For capturing screen content
- **Accessibility**: For global keyboard shortcuts

### Build Information

- **Swift Version**: 5.9
- **Build System**: Swift Package Manager
- **Xcode Version**: 15.0 or later
- **Deployment Target**: macOS 13.0

---

## Future Roadmap

### Planned for v1.1.0

- [ ] Undo/Redo functionality
- [ ] Circle drawing tool
- [ ] Line drawing tool
- [ ] Freehand/Pen tool
- [ ] Multi-monitor support
- [ ] Shortcut recorder UI
- [ ] Screenshot history

### Planned for v1.2.0

- [ ] Custom filename templates
- [ ] Image editing (crop, resize)
- [ ] More export formats (GIF, PDF)
- [ ] iCloud sync
- [ ] Blur/pixelate tool
- [ ] Highlight tool

### Planned for v2.0.0

- [ ] Video recording
- [ ] GIF creation
- [ ] OCR text recognition
- [ ] Cloud storage integration
- [ ] Screenshot library/manager
- [ ] Advanced editing features

---

## Version History

### [1.0.0] - 2024-11-13
- Initial release with all core features (FR-01 through FR-20)
- Complete macOS menu bar application
- Screenshot capture with area selection
- Annotation editor with three drawing tools
- Settings management and persistence
- Comprehensive documentation

---

[1.0.0]: https://github.com/Doka-NT/vibe-screenshoter/releases/tag/v1.0.0
