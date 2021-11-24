// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "HappyDns",
    platforms: [
        .macOS(.v10_10),
        .iOS(.v8)
    ],
    products: [
        .library(
            name: "HappyDns",
            targets: ["HappyDns"]),
    ],
    targets: [
        .target(
            name: "HappyDns",
            path: "HappyDns",
            sources: ["Common", "Dns", "Http", "Local", "Util"],
            cSettings: [
                .headerSearchPath("Util"),
                .headerSearchPath("Common"),
                .headerSearchPath("Dns"),
                .headerSearchPath("Http"),
                .headerSearchPath("Local"),
            ]),
    ]
)
