// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "Tempura",
  platforms: [
    .iOS(.v11)
  ],
  products: [
    .library(name: "Tempura", targets: ["Tempura"]),
    .library(name: "TempuraTesting", targets: ["TempuraTesting"])
  ],
  dependencies: [
    .package(name: "Katana", url: "https://github.com/BendingSpoons/katana-swift.git", from: "6.0.2"),
  ],
  targets: [
    .target(
      name: "Tempura",
      dependencies: ["Katana"],
      path: "Tempura/Sources"
    ),
    .target(
      name: "TempuraTesting",
      dependencies: ["Katana", "Tempura"],
      path: "TempuraTesting/Sources"
    ),
    .testTarget(
      name: "TempuraTests",
      dependencies: ["Tempura"],
      path: "Tempura/Tests"
    ),
  ],
  swiftLanguageVersions: [.v5]
)