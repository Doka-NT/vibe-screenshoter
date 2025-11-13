# Frequently Asked Questions (FAQ)

## General Questions

### What is Vibe Screenshoter?

Vibe Screenshoter is a lightweight macOS application that allows you to take screenshots of selected screen areas and annotate them with arrows, text, and rectangles. It's designed to be fast, efficient, and easy to use.

### Is it free?

Yes! Vibe Screenshoter is open-source and free to use under the MIT License.

### What macOS version do I need?

Vibe Screenshoter requires macOS 13.0 (Ventura) or later. It works on both Apple Silicon and Intel Macs.

### How much disk space does it need?

The application is very lightweight, requiring less than 10 MB of disk space.

### Does it work on Windows or Linux?

No, Vibe Screenshoter is specifically designed for macOS and uses macOS-specific APIs. It will not run on Windows or Linux.

## Installation & Setup

### How do I install Vibe Screenshoter?

1. Download the latest release from GitHub
2. Or build from source using Swift Package Manager
3. See BUILDING.md for detailed instructions

### Why do I need to grant Screen Recording permission?

macOS requires explicit permission to capture screen content. This is a security feature to protect your privacy. The permission is needed to take screenshots.

### Why do I need to grant Accessibility permission?

The Accessibility permission is required for the global keyboard shortcut (⌘⇧S) to work system-wide. Without it, the shortcut won't function.

### How do I enable launch at login?

Open Settings from the menu bar icon and check "Запускать при входе в систему". Note that this feature requires a properly bundled application.

## Usage Questions

### How do I take a screenshot?

There are two ways:
1. Press the keyboard shortcut (default: ⌘⇧S)
2. Click the menu bar icon and select "Запустить скриншот"

### Can I change the keyboard shortcut?

Yes, the shortcut is configurable in Settings. The default is Command + Shift + S (⌘⇧S).

### How do I cancel a screenshot?

You can cancel in two ways:
1. Press the ESC key
2. Right-click with the mouse

### What's the minimum selection size?

The selected area must be at least 10×10 pixels. Smaller selections will be canceled automatically.

### Where are screenshots saved?

Screenshots are:
1. Automatically copied to the clipboard
2. Saved to your configured folder (default: Desktop)

You can change the save location in Settings.

### Can I choose the file format?

Yes! Go to Settings and choose between:
- PNG (default, lossless)
- JPEG (lossy, smaller file size)

### What's the naming format for saved files?

Files are automatically named as: `Screenshot-YYYY-MM-DD-HH-mm-ss.ext`

Example: `Screenshot-2024-11-13-14-30-45.png`

### Can I rename files before saving?

Currently, files are automatically named. Custom naming is planned for a future release.

## Annotation Questions

### What drawing tools are available?

Three tools are currently available:
1. **Arrow**: Directional arrow with arrowhead
2. **Text**: Text label with custom input
3. **Rectangle**: Rectangular outline

### How do I change annotation colors?

Click the color well (🎨) in the toolbar to open the color picker. Select any color you want.

### How do I change line thickness?

Use the slider in the toolbar to adjust line width from 1 to 10.

### Can I delete an annotation?

Yes! Click the "Удалить" (Delete) button, then click on the annotation you want to remove.

### Can I undo an annotation?

Currently, there is no undo feature. You must use the delete tool to remove unwanted annotations. Undo/Redo is planned for version 1.1.0.

### How many annotations can I add?

There's no hard limit, but performance may degrade with hundreds of annotations.

### Can I edit an existing annotation?

No, annotations cannot be edited after creation. You must delete and recreate them.

### Can I move annotations after placing them?

Not currently. This feature is planned for a future release.

## Technical Questions

### Does it work on multiple monitors?

The application currently works best on the primary display. Full multi-monitor support is planned for a future release.

### Is my data sent to the cloud?

No! The application has no network access. All data stays on your device.

### Does it collect analytics or telemetry?

No, absolutely not. We don't collect any usage data or analytics.

### Can I use it in full-screen apps?

The screenshot overlay should work over most full-screen applications, but some apps may have restrictions.

### Does it affect system performance?

No. When idle, the app uses minimal resources (~20-30 MB RAM, near-zero CPU). During screenshot capture and editing, CPU usage remains under 5%.

### Is it compatible with other screenshot tools?

Yes, it can coexist with the built-in macOS screenshot tool (⌘⇧5) and other third-party tools.

## Troubleshooting

### The app won't start

1. Check that you're running macOS 13.0 or later
2. Verify the application has not been quarantined by macOS
3. Try running from Terminal to see error messages

### The keyboard shortcut doesn't work

1. Go to System Settings → Privacy & Security → Accessibility
2. Make sure the application is listed and enabled
3. Try restarting the application

### I can't capture the screen

1. Go to System Settings → Privacy & Security → Screen Recording
2. Make sure the application is listed and enabled
3. Restart the application after granting permission

### The menu bar icon is missing

1. Check if the app is running in Activity Monitor
2. The icon might be hidden if menu bar is full - try making it wider
3. Restart the application

### Screenshots are not being saved

1. Check that the save path exists and is writable
2. Verify you have disk space available
3. Check Settings to confirm save path is correct

### Annotations are not visible

1. Try changing the color - it might match the screenshot
2. Increase the line width
3. Make sure you've selected a tool before drawing

### The delete tool isn't working

1. Make sure the Delete tool is selected (button highlighted)
2. Click directly on the annotation element
3. Some small elements may be hard to click - try zooming (planned feature)

## Performance Questions

### Can I use it on an old Mac?

Yes, if it runs macOS 13.0+. The app is lightweight and should work well on older hardware.

### Does it slow down my system?

No. The app runs in the background with minimal resource usage.

### How much RAM does it use?

Approximately 20-30 MB when idle, up to 100 MB when editing large screenshots.

### Does it work well on Retina displays?

Yes! The app is fully compatible with Retina displays and captures at full resolution.

## Feature Requests

### Can you add [feature X]?

We welcome feature requests! Please:
1. Check if it's already in the roadmap (see CHANGELOG.md)
2. Open a GitHub issue with your suggestion
3. Provide use cases and examples

### When will [planned feature] be released?

Check CHANGELOG.md for the roadmap and planned features for upcoming versions.

### Can I contribute code?

Yes! See CONTRIBUTING.md for guidelines on how to contribute.

## Privacy & Security

### Is it safe to use?

Yes. The application:
- Has no network access
- Stores all data locally
- Uses Apple's secure APIs
- Is open-source (you can review the code)

### What permissions does it need?

Only two:
1. Screen Recording (to capture screenshots)
2. Accessibility (for global keyboard shortcuts)

### Does it access my files?

Only the screenshots it saves to your chosen location. It doesn't access other files.

### Can it record my keystrokes?

No. Despite needing Accessibility permission, it only monitors for the specific shortcut key combination.

## Comparison with Other Tools

### How is it different from macOS built-in screenshots?

Vibe Screenshoter offers:
- Annotation tools (arrow, text, rectangle)
- Customizable save locations
- Menu bar access
- Automatic clipboard copy
- More intuitive interface

### How does it compare to Snagit or Skitch?

Vibe Screenshoter is:
- Free and open-source
- Lighter weight
- More privacy-focused (no cloud, no analytics)
- Simpler feature set (by design)

## Support

### Where can I get help?

1. Check this FAQ
2. Read the documentation (README.md, BUILDING.md, etc.)
3. Search existing GitHub issues
4. Create a new GitHub issue

### How do I report a bug?

1. Go to the GitHub repository
2. Click "Issues" → "New Issue"
3. Provide detailed information:
   - macOS version
   - Steps to reproduce
   - Expected vs actual behavior
   - Screenshots if applicable

### Is there a community forum?

Currently, we use GitHub Discussions for community interaction. Check the repository.

### How can I support the project?

- Star the repository on GitHub
- Report bugs and suggest features
- Contribute code (see CONTRIBUTING.md)
- Share with others who might find it useful

## Roadmap

### What features are planned?

See CHANGELOG.md for the complete roadmap. Highlights include:
- Version 1.1: Undo/Redo, more drawing tools
- Version 1.2: Screenshot history, cloud sync
- Version 2.0: Video recording, OCR

### Can I vote on features?

Yes! React to feature requests on GitHub issues with 👍 to show support.

## Legal

### What license is it under?

MIT License. See LICENSE file for details.

### Can I use it commercially?

Yes, the MIT License allows commercial use.

### Can I modify and redistribute it?

Yes, under the terms of the MIT License.

---

**Still have questions?** Open an issue on GitHub or check the documentation!

**Last Updated**: 2024-11-13
