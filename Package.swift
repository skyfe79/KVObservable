// swift-tools-version: 5.7.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "KVObservable",
    platforms: [.iOS(.v13), .macOS(.v10_15), .watchOS(.v8), .tvOS(.v13), .macCatalyst(.v13)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "KVObservable",
            targets: ["KVObservable"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "KVObservable"),
        .testTarget(
            name: "KVObservableTests",
            dependencies: ["KVObservable"]),
    ]
)

