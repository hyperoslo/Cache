// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "Cache",
    products: [
        .library(
            name: "Cache",
            targets: ["Cache"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Cache",
            path: "Source",
            exclude: ["Library/ImageWrapper.swift"]),
        .testTarget(
            name: "CacheTests",
            dependencies: ["Cache"],
            path: "Tests"),
    ],
    swiftLanguageVersions: [.v5]
)
