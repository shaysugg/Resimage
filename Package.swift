// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Resimage",
    products: [
      .executable(name: "Resimage", targets: ["imageResizer"])
    ],
    dependencies: [
         .package(url: "https://github.com/apple/swift-argument-parser" , from: "0.0.1")
    ],
    targets: [
        .target(
            name: "imageResizer",
            dependencies: [
            .product(name: "ArgumentParser", package: "swift-argument-parser"),]),
        .testTarget(
            name: "imageResizerTests",
            dependencies: ["imageResizer"]),
    ]
)
