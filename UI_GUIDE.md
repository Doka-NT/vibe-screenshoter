# User Interface Guide

This document provides a visual guide to the Vibe Screenshoter user interface.

## Menu Bar Icon

The application appears in the macOS menu bar with a camera icon (📷).

```
┌─────────────────────────────────────┐
│  📷  🔋  🔊  📶  🕐                │  ← Menu Bar
└─────────────────────────────────────┘
     │
     ├─ Click to open menu
     │
     └─> ┌──────────────────────────┐
         │  Запустить скриншот  ⌘⇧S │
         ├──────────────────────────┤
         │  Настройки...         ⌘, │
         ├──────────────────────────┤
         │  Выход                ⌘Q │
         └──────────────────────────┘
```

## Screenshot Capture Flow

### 1. Trigger Screenshot

Press `⌘⇧S` or select "Запустить скриншот" from menu.

### 2. Area Selection

Full-screen overlay appears with darkened background:

```
┌─────────────────────────────────────────────────┐
│                                                 │
│  Dark overlay (30% opacity)                     │
│                                                 │
│          ┌──────────────────┐                   │
│          │                  │                   │
│          │  Selected Area   │  ← Drag to select│
│          │   800 × 600      │                   │
│          │                  │                   │
│          └──────────────────┘                   │
│                                                 │
│  ESC or Right-click to cancel                   │
│                                                 │
└─────────────────────────────────────────────────┘
```

**Features:**
- Blue border around selection
- White semi-transparent fill
- Dimensions displayed in center
- Real-time size updates

### 3. Editor Window

After selecting area, editor window opens:

```
┌─────────────────── Редактор скриншота ───────────────────┐
│                                                           │
│  Toolbar:                                                │
│  ┌─────┬─────┬──────────┬────┬───┬─────┬────────────┐   │
│  │Arrow│Text │Rectangle │Del │🎨 │━━━━ │  Сохранить │   │
│  └─────┴─────┴──────────┴────┴───┴─────┴────────────┘   │
│   Tool  Tool    Tool     Tool Color Width   Save Button │
│                                                           │
├───────────────────────────────────────────────────────────┤
│                                                           │
│                                                           │
│                  ┌─────────────────┐                     │
│                  │                 │                     │
│                  │   Screenshot    │                     │
│                  │    with         │                     │
│                  │  Annotations    │                     │
│                  │                 │                     │
│                  └─────────────────┘                     │
│                                                           │
│   Canvas Area (Click and drag to add annotations)        │
│                                                           │
└───────────────────────────────────────────────────────────┘
```

## Drawing Tools

### Arrow Tool

Click and drag to draw an arrow from start to end point:

```
Start Point ─────────────────────────> End Point
                                       ╱
                                      ╱
```

**Properties:**
- Customizable color
- Adjustable line width (1-10)
- Automatic arrowhead at end point

### Text Tool

Click to place text, then enter text in dialog:

```
┌──── Введите текст ─────┐
│                        │
│  ┌──────────────────┐  │
│  │ Your text here   │  │
│  └──────────────────┘  │
│                        │
│   [ OK ]  [ Отмена ]   │
└────────────────────────┘
```

**Properties:**
- Customizable color
- Font size based on line width (size × 5)
- Click to position

### Rectangle Tool

Click and drag to draw a rectangle:

```
┌───────────────────┐
│                   │
│   Rectangle       │
│   Outline         │
│                   │
└───────────────────┘
```

**Properties:**
- Customizable color
- Adjustable line width (1-10)
- No fill (outline only)

### Delete Tool

Click on any annotation to remove it:

```
Before:
  ─────>  [Box]  Text
     ↑ Click this arrow

After:
  [Box]  Text
```

## Settings Window

Access via menu bar icon → "Настройки...":

```
┌──────────────── Настройки ────────────────┐
│                                           │
│  Запускать при входе в систему:  [✓]      │
│                                           │
│  Горячая клавиша:  [ ⌘⇧S ]                │
│                                           │
│  Путь для сохранения:                     │
│  ┌─────────────────────────┐              │
│  │ /Users/name/Desktop     │  [ Обзор ]   │
│  └─────────────────────────┘              │
│                                           │
│  Формат сохранения:  [ PNG ▼ ]            │
│                      ├─ PNG               │
│                      └─ JPEG              │
│                                           │
│                                           │
│                                           │
│              [ Отмена ]  [ Сохранить ]    │
└───────────────────────────────────────────┘
```

## Color Picker

Click the color well in toolbar:

```
┌────── Color Picker ──────┐
│                          │
│   ┌──────────────────┐   │
│   │  🌈 Color Wheel  │   │
│   │                  │   │
│   └──────────────────┘   │
│                          │
│   RGB: 255, 0, 0         │
│   Hex: #FF0000           │
│                          │
│        [ Select ]        │
└──────────────────────────┘
```

## Line Width Slider

Adjust thickness of lines and text:

```
Slider Control:
┌─────────────────────────┐
│ ▒▒▒▒▒▒▒▒░░░░░░░░░░░░    │ ← Drag to adjust
└─────────────────────────┘
  1                    10

Examples:
Line Width 1:  ─────
Line Width 3:  ━━━━━
Line Width 5:  ═════
Line Width 10: ▓▓▓▓▓
```

## Keyboard Shortcuts

| Action                  | Shortcut | Context      |
|------------------------|----------|--------------|
| Take Screenshot        | ⌘⇧S      | Global       |
| Cancel Selection       | ESC      | Selection    |
| Cancel Selection       | Right-click | Selection |
| Open Settings          | ⌘,       | Menu         |
| Quit Application       | ⌘Q       | Menu         |

## File Naming Convention

Screenshots are automatically named with timestamp:

```
Format: Screenshot-YYYY-MM-DD-HH-mm-ss.ext

Examples:
- Screenshot-2024-11-13-14-30-45.png
- Screenshot-2024-11-13-14-31-22.jpg
```

## Save Locations

### Default Location
```
/Users/[username]/Desktop/
```

### Custom Location
```
Choose any folder through settings:
- Documents
- Pictures
- Custom folder
```

## Workflow Example

**Complete workflow from start to finish:**

```
1. Press ⌘⇧S
   ↓
2. Drag to select area
   ↓
3. Release to capture
   ↓
4. Editor opens
   ↓
5. Add annotations:
   - Click Arrow tool
   - Draw arrow
   - Click Text tool
   - Add label
   - Click Rectangle tool
   - Highlight area
   ↓
6. Adjust colors/sizes as needed
   ↓
7. Click "Сохранить"
   ↓
8. Screenshot copied to clipboard
   AND saved to file
   ↓
9. Paste anywhere with ⌘V
```

## Tips & Tricks

### Quick Actions
- **Double ESC**: Cancel and close immediately
- **Right-click**: Quick cancel without keyboard
- **Precise selection**: Use corners of screen as anchors

### Annotation Tips
- **Layering**: Later annotations appear on top
- **Precision**: Zoom in (planned feature) for detailed work
- **Color coding**: Use consistent colors for clarity
- **Text placement**: Consider readability on background

### Efficiency Tips
- **Learn the shortcut**: Faster than menu
- **Pre-select area carefully**: Reduces need for editing
- **Use templates**: Common annotation patterns
- **Quick clipboard paste**: Immediate sharing

## Troubleshooting UI Issues

### Menu Bar Icon Not Appearing
1. Check if app is running (Activity Monitor)
2. Restart the application
3. Check menu bar settings (System Settings)

### Selection Not Visible
1. Check screen brightness
2. Try on different monitor
3. Restart the application

### Editor Not Opening
1. Check Screen Recording permissions
2. Try selecting a larger area (minimum 10×10 pixels)
3. Check available memory

### Annotations Not Showing
1. Ensure tool is selected (highlighted button)
2. Check color is not matching background
3. Verify line width is not set to minimum

## Accessibility

The application is designed with accessibility in mind:

- **Keyboard navigation**: Full keyboard support
- **Screen reader**: Compatible with VoiceOver (planned)
- **High contrast**: Visible in all color schemes
- **Clear feedback**: Visual confirmation of actions

## Future UI Enhancements

Planned improvements:
- [ ] Undo/Redo buttons in toolbar
- [ ] Zoom controls for precise editing
- [ ] Grid overlay for alignment
- [ ] Snap to grid feature
- [ ] More visual feedback
- [ ] Customizable toolbar
- [ ] Dark mode support
- [ ] Touch Bar support
