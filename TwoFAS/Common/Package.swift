// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Common",
    platforms: [.iOS(.v16)],
    products: [
        .library(
            name: "Common",
            type: .dynamic,
            targets: ["Common"])
    ],
    targets: [
        .target(
            name: "Common",
            path: ".",
            sources: ["Sources"],
            resources: [.process("Assets")]
        )
    ]
)
