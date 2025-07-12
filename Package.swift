// swift-tools-version: 6.1.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "FileLogger",
  platforms: [
    .macOS(.v12),
    .iOS(.v16),
    .watchOS(.v8),
    .tvOS(.v16),
  ],
  products: [
    .library(
      name: "FileLogger",
      targets: ["FileLogger"]
    )
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-log.git", from: "1.6.3")
  ],
  targets: [
    .target(
      name: "FileLogger",
      dependencies: [
        .product(name: "Logging", package: "swift-log")
      ]
    ),
    .testTarget(
      name: "FileLoggerTests",
      dependencies: ["FileLogger"]
    ),
  ],
  swiftLanguageModes: [.v6]
)
