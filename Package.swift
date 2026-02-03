// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "iOS_MetricsTVAzteca",
    platforms: [
            .iOS(.v15)
        ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "iOS_MetricsTVAzteca",
            targets: ["iOS_MetricsTVAzteca"]),
    ],
    dependencies: [
            .package(
                url: "https://github.com/firebase/firebase-ios-sdk.git",
                from: "10.0.0"
            ),
            .package(
                url: "https://github.com/permutive-engineering/permutive-ios-spm.git",
                from: "2.3.0"
            )
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "iOS_MetricsTVAzteca",
            dependencies: [
                .product(
                    name: "FirebaseAnalytics",
                    package: "firebase-ios-sdk"
                ),
                .product(
                    name: "Permutive_iOS",
                    package: "permutive-ios-spm"
                )
            ]
        )
    ]
)
