// swift-tools-version:4.2

import PackageDescription

let package = Package(
    name: "Cache",
    products: [
        .library(
            name: "Cache",
            targets: ["Cache"]),
    ],
    dependencies: [
        .package(url: "https://github.com/antitypical/Result.git", from: "4.1.0"),
    ],
    targets: [
        .target(
            name: "Cache",
            path: "Source/Shared",
            exclude: ["Library/ImageWrapper.swift"]), // relative to the target path
        .testTarget(
            name: "CacheTests",
            dependencies: ["Cache"],
            path: "Tests"),
    ]
)
