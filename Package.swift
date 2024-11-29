// swift-tools-version:5.10

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
            resources: [.copy("PrivacyInfo.xcprivacy")]
        ),
        .testTarget(
            name: "CacheTests",
            dependencies: ["Cache"],
            path: "Tests"),
    ],
    swiftLanguageVersions: [.v5]
)
