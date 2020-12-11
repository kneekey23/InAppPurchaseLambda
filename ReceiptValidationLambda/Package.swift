// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ReceiptValidationLambda",
    products: [
      .executable(name: "ReceiptValidationLambda",
                  targets: ["ReceiptValidationLambda"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/swift-server/swift-aws-lambda-runtime.git", .upToNextMajor(from:"0.3.0")),
        .package(url: "https://github.com/swift-server/async-http-client", .upToNextMajor(from: "1.1.0")),
        .package(url: "https://github.com/apple/swift-nio", .upToNextMajor(from: "2.14.0")),
        .package(url: "https://github.com/fabianfett/swift-app-store-receipt-validation", .upToNextMajor(from: "0.1.0"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "ReceiptValidationLambda",
            dependencies: [
                .product(name: "AWSLambdaRuntime",
                         package: "swift-aws-lambda-runtime"),
                .product(name: "NIO", package: "swift-nio"),
                .product(name: "AsyncHTTPClient", package: "async-http-client"),
                .product(name: "AppStoreReceiptValidation", package: "swift-app-store-receipt-validation"),
            ]),
        .testTarget(
            name: "ReceiptValidationLambdaTests",
            dependencies: ["ReceiptValidationLambda"]),
    ]
)
