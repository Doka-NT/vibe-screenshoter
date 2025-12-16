# Диаграмма потока работы Vibe Screenshoter (Mermaid)

```mermaid
flowchart TD
    A[main.swift: main] --> B[AppDelegate.applicationDidFinishLaunching]
    B --> C[AppDelegate.createStatusItemMenu]
    C --> D{Пользовательское действие}
    D -->|Скриншот всего экрана| E[AppDelegate.captureScreen]
    D -->|Скриншот области| F[AppDelegate.captureSelection]
    D -->|Настройки| G[AppDelegate.openPreferences]
    D -->|Выйти| H[NSApp.terminate]

    E --> I[AppDelegate.generateTempScreenshotPath]
    F --> I
    I --> J[AppDelegate.runScreencapture]
    J --> K[AppDelegate.openEditor]
    K --> L[ScreenshotEditorWindow.init]
    L --> M[ScreenshotEditorWindow.show]
    M --> N[EditorCanvasView.startEditing]
    N --> O{Пользователь аннотирует}
    O --> P[ScreenshotEditorWindow.saveHandler]
    P --> Q[EditorCanvasView.renderFinalImage]
    Q --> R[ScreenshotEditorWindow.saveToDiskAndClipboard]
    R --> S[ScreenshotEditorWindow.cleanupTempFile]
    S --> T[Закрытие окна редактора]
    T --> C

    G --> U[SettingsViewController.show]
    U --> V[SettingsViewController.recordShortcut]
    V --> W[SettingsManager.saveShortcut]
    W --> X[HotKeyManager.registerHotKey]
    X --> C
```

## Легенда
- Каждый блок — это конкретный метод или функция из кода.
- Ветка E/F — полный и частичный скриншот, далее логика схожа.
- Ветка настроек отражает работу с хоткеями и настройками.
```
