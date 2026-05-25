// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AppSync_Shared",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "AppSync_Shared",
            targets: ["AppSync_Shared"]
        ),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "AppSync_Shared"
        ),
        .testTarget(
            name: "AppSync_SharedTests",
            dependencies: ["AppSync_Shared"]
        ),
    ]
)
