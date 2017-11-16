import PackageDescription

var package = Package(
    name: "Cache",
    products: [
      .library(
        name: "Cache",
        targets: ["Cache"]
      )
    ],
    dependencies: [
       .package(url: "https://github.com/onmyway133/SwiftHash.git", .upToNextMinor(from: "2.0.0")),
    ],
    targets: [
      .target(
        name: "Cache",
        dependencies: ["Cache"]
        )
    ]
)
