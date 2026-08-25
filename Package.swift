// swift-tools-version:6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let approachableConcurrency: [SwiftSetting] = [
    .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
    .enableUpcomingFeature("InferIsolatedConformances")
]

let package = Package(
    name: "SimpleHTTP",
    platforms: [.iOS(.v13), .macOS(.v13)],
    products: [
        .library(name: "SimpleHTTPFoundation", targets: ["SimpleHTTPFoundation"]),
        .library(name: "SimpleHTTP", targets: ["SimpleHTTP"])
    ],
    dependencies: [
    ],
    targets: [
        .target(name: "SimpleHTTPFoundation", dependencies: [], swiftSettings: approachableConcurrency),
        .target(name: "SimpleHTTP", dependencies: ["SimpleHTTPFoundation"], swiftSettings: approachableConcurrency),
        .testTarget(
            name: "SimpleHTTPFoundationTests",
            dependencies: ["SimpleHTTPFoundation"],
            swiftSettings: approachableConcurrency
        ),
        .testTarget(
            name: "SimpleHTTPTests",
            dependencies: ["SimpleHTTP"],
            resources:  [
                .copy("Ressources/Images/swift.png"),
                .copy("Ressources/Images/swiftUI.png")
            ],
            swiftSettings: approachableConcurrency
        )
    ]
)
