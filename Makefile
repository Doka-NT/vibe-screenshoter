APP_NAME = MenuBarScreenshotApp
SOURCES = Sources/main.swift Sources/AppDelegate.swift Sources/SettingsManager.swift Sources/HotKeyManager.swift Sources/SettingsViewController.swift Sources/AnnotationModels.swift Sources/EditorCanvasView.swift Sources/ScreenshotEditorWindow.swift Sources/ToolPaletteView.swift
BUILD_DIR = build
APP_BUNDLE = $(BUILD_DIR)/$(APP_NAME).app
CONTENTS_DIR = $(APP_BUNDLE)/Contents
MACOS_DIR = $(CONTENTS_DIR)/MacOS
RESOURCES_DIR = $(CONTENTS_DIR)/Resources

all: $(APP_BUNDLE)

$(APP_BUNDLE): $(SOURCES) Info.plist
	@mkdir -p $(MACOS_DIR)
	@mkdir -p $(RESOURCES_DIR)
	swiftc $(SOURCES) -o $(MACOS_DIR)/$(APP_NAME)
	cp Info.plist $(CONTENTS_DIR)/
	@echo "Built $(APP_NAME).app in $(BUILD_DIR)"

clean:
	rm -rf $(BUILD_DIR)

run: $(APP_BUNDLE)
	open $(APP_BUNDLE)

debug: $(APP_BUNDLE)
	$(MACOS_DIR)/$(APP_NAME)
