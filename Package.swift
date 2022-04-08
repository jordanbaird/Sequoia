// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "Sequoia",
    products: [
        .library(
            name: "Sequoia",
            targets: ["Sequoia"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Sequoia",
            dependencies: []),
        .testTarget(
            name: "SequoiaTests",
            dependencies: ["Sequoia"]),
    ]
)
