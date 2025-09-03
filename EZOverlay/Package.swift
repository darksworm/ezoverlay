// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "EZOverlay",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "EZOverlay", targets: ["EZOverlay"])
    ],
    targets: [
        .executableTarget(
            name: "EZOverlay",
            dependencies: [],
            path: ".",
            exclude: [
                "Tests", 
                "Package.swift", 
                "build.sh", 
                "test_with_screenshots.sh",
                "Info.plist"
            ],
            sources: [
                "EZOverlayApp.swift",
                "AppDelegate.swift",
                "Window/OverlayView.swift",
                "Window/OverlayWindowController.swift",
                "Hotkeys/HotkeyManager.swift",
                "EventTap/EventTapManager.swift",
                "Layout/LayoutRepository.swift",
                "Layout/OryxParser.swift",
                "Preferences/PreferencesView.swift",
                "Models/Layer.swift"
            ],
            resources: [
                .copy("Layout/SampleLayout.json")
            ]
        ),
        .testTarget(
            name: "EZOverlayTests",
            dependencies: ["EZOverlay"],
            path: "Tests"
        )
    ]
)