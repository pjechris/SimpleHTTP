// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SimpleHTTP",
    platforms: [.iOS(.v13), .macOS(.v10_15)],
    products: [
        .library(name: "SimpleHTTPFoundation", targets: ["SimpleHTTPFoundation"]),
        .library(name: "SimpleHTTP", targets: ["SimpleHTTP"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-format", branch: "main")
    ],
    targets: [
        .target(name: "SimpleHTTPFoundation", dependencies: []),
        .target(name: "SimpleHTTP", dependencies: ["SimpleHTTPFoundation"]),
        .testTarget(name: "SimpleHTTPFoundationTests", dependencies: ["SimpleHTTPFoundation"]),
        .testTarget(
            name: "SimpleHTTPTests",
            dependencies: ["SimpleHTTP"],
            resources:  [
                .copy("Ressources/Images/swift.png"),
                .copy("Ressources/Images/swiftUI.png")
            ]
        )
    ]
)
