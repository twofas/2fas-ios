// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Content",
    platforms: [.iOS(.v16)],
    products: [
        .library(
            name: "Content",
            type: .dynamic,
            targets: ["Content"])
    ],
    dependencies: [
        .package(path: "../Common")
    ],
    targets: [
        .target(
            name: "Content",
            dependencies: [
                "Common"
            ],
            path: ".",
            sources: ["Sources"],
            resources: [.process("Assets")]
        )
    ]
)
