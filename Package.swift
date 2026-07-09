// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "DictionaryApp",
    platforms: [
        .iOS(.v26)
    ],
    products: [
        .iOSApplication(
            name: "DictionaryApp",
            targets: ["DictionaryApp"],
            bundleIdentifier: "com.dictionary.liquidglass",
            displayName: "词典",
            appIcon: "AppIcon",
            accentColor: "AccentColor",
            supportedDestinations: [.iPhone]
        )
    ],
    targets: [
        .executableTarget(
            name: "DictionaryApp",
            path: "DictionaryApp",
            exclude: [
                "Info.plist.swift"
            ],
            resources: [
                .process("Assets.xcassets"),
                .process("Resources")
            ]
        )
    ]
)
