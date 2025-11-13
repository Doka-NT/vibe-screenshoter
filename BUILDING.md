# Building Vibe Screenshoter

## Prerequisites

- macOS 13.0 or later
- Xcode 15.0 or later
- Swift 5.9 or later

## Build Methods

### Method 1: Swift Package Manager (Command Line)

This is the simplest method for building the application.

```bash
# Navigate to project directory
cd vibe-screenshoter

# Build in release mode
swift build -c release

# The executable will be at:
# .build/release/VibeScreenshoter

# Run the application
.build/release/VibeScreenshoter
```

### Method 2: Xcode

1. Open `Package.swift` in Xcode (double-click the file)
2. Wait for Xcode to resolve dependencies
3. Select the "VibeScreenshoter" scheme
4. Press `⌘R` to run or `⌘B` to build

### Method 3: Creating an App Bundle

To create a proper macOS application bundle:

```bash
# Build the executable
swift build -c release

# Create app bundle structure
mkdir -p "Vibe Screenshoter.app/Contents/MacOS"
mkdir -p "Vibe Screenshoter.app/Contents/Resources"

# Copy executable
cp .build/release/VibeScreenshoter "Vibe Screenshoter.app/Contents/MacOS/"

# Copy Info.plist
cp Info.plist "Vibe Screenshoter.app/Contents/"

# Make executable
chmod +x "Vibe Screenshoter.app/Contents/MacOS/VibeScreenshoter"

# Run the app
open "Vibe Screenshoter.app"
```

## Running Tests

```bash
# Run all tests
swift test

# Run tests with verbose output
swift test --verbose
```

## Troubleshooting

### Permission Issues

If you get permission errors when trying to capture the screen:

1. Open **System Settings** → **Privacy & Security** → **Screen Recording**
2. Add and enable your terminal app (Terminal.app or iTerm2) or the built application

### Global Keyboard Shortcut Not Working

If the global keyboard shortcut isn't working:

1. Open **System Settings** → **Privacy & Security** → **Accessibility**
2. Add and enable your terminal app or the built application

### Launch at Login Not Working

For launch at login functionality to work properly, you need to:

1. Build a proper application bundle (see Method 3 above)
2. The feature uses macOS LaunchServices APIs that require proper app bundling

## Development Tips

### Debug Mode

For development and debugging, run in debug mode:

```bash
swift build
.build/debug/VibeScreenshoter
```

### Code Structure

The application is organized into these main components:

- **AppDelegate.swift**: Main application lifecycle and menu bar setup
- **ScreenshotManager.swift**: Coordinates the screenshot capture process
- **CaptureWindow.swift**: Handles the area selection overlay
- **EditorWindow.swift**: Provides the annotation editor
- **SettingsManager.swift**: Manages user preferences
- **SettingsWindowController.swift**: Settings UI

### Adding New Features

To add new drawing tools:

1. Add a new case to the `DrawingTool` enum in `EditorWindow.swift`
2. Create a new annotation class implementing the `Annotation` protocol
3. Add button and handler in `createToolbar()` method
4. Update `mouseDragged()` and `mouseUp()` in `CanvasView` to handle the new tool

## Distribution

For distributing the application:

1. Build a release version with proper signing
2. Create an app bundle (Method 3)
3. Optionally notarize the app for distribution outside the App Store

```bash
# Example with proper signing
swift build -c release

# Sign the executable
codesign --force --deep --sign "Developer ID Application: Your Name" \
  .build/release/VibeScreenshoter

# Create and sign the bundle
# (follow Method 3 steps, then sign the bundle)
codesign --force --deep --sign "Developer ID Application: Your Name" \
  "Vibe Screenshoter.app"
```

## Performance Optimization

The application is designed to be lightweight:

- Runs as a menu bar agent (no Dock icon)
- Minimal memory footprint when idle
- Screen capture happens on-demand
- No background processes or timers

## Platform Support

- **Minimum**: macOS 13.0 (Ventura)
- **Recommended**: macOS 14.0 (Sonoma) or later
- **Architecture**: Universal (Apple Silicon and Intel)
