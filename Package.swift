// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Scout",
    platforms: [.macOS("10.13")],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "Scout",
            targets: ["Scout"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(
            url: "https://github.com/tadija/AEXML.git",
            from: "4.5.0"),
        .package(
            url: "https://github.com/apple/swift-argument-parser",
            from: "0.0.1")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "Scout",
            dependencies: ["AEXML"]),
        .target(
            name: "ScoutCLT",
            dependencies: ["Scout", "ArgumentParser"]),
        .testTarget(
            name: "ScoutTests",
            dependencies: ["Scout"]),
    ]
)
