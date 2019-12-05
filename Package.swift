// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "Tempura",
  platforms: [
    .iOS(.v9)
  ],
  products: [
    .library(name: "Tempura", targets: ["Tempura"]),
    .library(name: "TempuraTesting", targets: ["TempuraTesting"])
  ],
  dependencies: [
    .package(url: "https://github.com/BendingSpoons/katana-swift", .branch("master")),
    .package(url: "https://github.com/Quick/Quick.git", from: "1.3.0"),
    .package(url: "https://github.com/Quick/Nimble.git", from: "7.3.0")
  ],
  targets: [
    .target(
      name: "Tempura",
      dependencies: ["Katana"],
      path: "Tempura"
    ),
    .target(
      name: "TempuraTesting",
      dependencies: ["Tempura"],
      path: "TempuraTesting"
    ),
    .testTarget(
      name: "TempuraTests",
      dependencies: ["Tempura", "Quick", "Nimble"],
      path: "TempuraTests"
    )
  ]
)
