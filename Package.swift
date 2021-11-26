// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "HappyDNS",
    platforms: [
        .macOS(.v10_10),
        .iOS(.v8)
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
            cSettings: [
                .headerSearchPath("."),
            ],
            linkerSettings:[
                .linkedLibrary("resolv", nil)
            ]),
    ]
)
