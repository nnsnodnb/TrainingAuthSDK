// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TrainingAuthSDK",
    platforms: [
        .iOS(.v11)
    ],
    products: [
        .library(
            name: "TrainingAuthSDK",
            targets: ["TrainingAuthSDK"]),
    ],
    dependencies: [
        .package(
            name: "APIKit",
            url: "https://github.com/ishkawa/APIKit.git",
            .upToNextMajor(from: "5.3.0")),
        .package(
            name: "KeychainAccess",
            url: "https://github.com/kishikawakatsumi/KeychainAccess.git",
            .upToNextMajor(from: "4.2.2"))
    ],
    targets: [
        .target(
            name: "TrainingAuthSDK",
            dependencies: [
                .product(name: "APIKit", package: "APIKit"),
                .product(name: "KeychainAccess", package: "KeychainAccess")
            ]),
        .testTarget(
            name: "TrainingAuthSDKTests",
            dependencies: ["TrainingAuthSDK"]),
    ]
)
