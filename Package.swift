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
        .target(
            name: "VibeScreenshoterLib",
            dependencies: [],
            path: "Sources/VibeScreenshoterLib"
        ),
        .executableTarget(
            name: "VibeScreenshoter",
            dependencies: ["VibeScreenshoterLib"],
            path: "Sources/VibeScreenshoter"
        ),
        .testTarget(
            name: "VibeScreenshoterTests",
            dependencies: ["VibeScreenshoterLib"],
            path: "Tests"
        )
    ]
)
