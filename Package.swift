// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "Cache",
    products: [
        .library(
            name: "Cache",
            targets: ["Cache"]),
    ],
    dependencies: [
        .package(url: "https://github.com/onmyway133/SwiftHash.git", from: "2.0.0")
    ],
    targets: [
        .target(
            name: "Cache",
            dependencies: ["SwiftHash"]),
            .testTarget(
                name: "MacTests",
                dependencies: ["Cache"]),
    ]
)
