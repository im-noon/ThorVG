// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ThorVG",
    platforms: [
        .iOS(.v11)
    ],
    products: [
        .library(
            name: "ThorVG",
            targets: ["ThorVG"]),
    ],
    targets: [
        .binaryTarget(
            name: "ThorVG",
            path: "./ThorVG.xcframework"
        )
    ]
)
