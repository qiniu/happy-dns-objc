// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "HappyDNS",
    platforms: [
        .macOS(.v10_10),
        .iOS(.v9)
    ],
    products: [
        .library(
            name: "HappyDNS",
            targets: ["HappyDNS"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "HappyDNS",
            path: "HappyDNS",
            sources: ["Common", "Dns", "Http", "Local", "Util"],
            cSettings: [
                .headerSearchPath("Common"),
                .headerSearchPath("Dns"),
                .headerSearchPath("Http"),
                .headerSearchPath("Local"),
                .headerSearchPath("Util"),
            ],
            linkerSettings:[
                .linkedLibrary("resolv", nil)
            ]),
    ]
)
