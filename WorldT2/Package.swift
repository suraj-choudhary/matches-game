// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "WorldT2",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "WorldT2Core",
            targets: ["WorldT2Core"]
        )
    ],
    targets: [
        .target(
            name: "WorldT2Core",
            path: "WorldT2",
            exclude: [
                "App/WorldT2App.swift"
            ],
            resources: [
                .process("Resources/teams.json")
            ]
        ),
        .testTarget(
            name: "WorldT2Tests",
            dependencies: ["WorldT2Core"],
            path: "WorldT2Tests"
        )
    ]
)
