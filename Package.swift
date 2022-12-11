// swift-tools-version:5.4

import PackageDescription

let package = Package(
    name: "Bulkony",
    platforms: [
          .macOS(.v10_15)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(name: "Bulkony", targets: ["Bulkony"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
         .package(url: "https://github.com/swiftcsv/SwiftCSV", from: "0.8.1"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "Bulkony",
            dependencies: [
                .product(name: "SwiftCSV", package: "SwiftCSV")
            ]
        ),
        .testTarget(
            name: "BulkonyTests",
            dependencies: ["Bulkony"]
        ),
    ]
)
