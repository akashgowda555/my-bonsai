// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "MyBonsai",
    platforms: [
        .macOS(.v13)
    ],
    targets: [
        .executableTarget(
            name: "MyBonsai",
            path: "Sources/MyBonsai"
        )
    ]
)
