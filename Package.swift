// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "VibeScreenshoter",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "VibeScreenshoter",
            targets: ["VibeScreenshoter"]
        )
    ],
    targets: [
        .executableTarget(
            name: "VibeScreenshoter",
            dependencies: [],
            path: "Sources"
        ),
        .testTarget(
            name: "VibeScreenshoterTests",
            dependencies: ["VibeScreenshoter"],
            path: "Tests"
        )
    ]
)
