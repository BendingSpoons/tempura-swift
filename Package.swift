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
    .package(name: "Katana", url: "https://github.com/BendingSpoons/katana-swift.git", from: "5.0.0"),
    .package(url: "https://github.com/Quick/Quick.git", from: "2.2.0"),
    .package(url: "https://github.com/Quick/Nimble.git", from: "8.0.0"),
  ],
  targets: [
    .target(
      name: "Tempura",
      dependencies: ["Katana"],
      path: "Tempura",
      exclude: ["SupportingFiles"]
    ),
    .testTarget(
      name: "TempuraTests",
      dependencies: ["Tempura", "Quick", "Nimble"],
      path: "TempuraTests",
      exclude: ["Info.plist"]
    ),
    .target(
      name: "TempuraTesting",
      dependencies: ["Katana", "Tempura"],
      path: "TempuraTesting"
    ),
  ],
  swiftLanguageVersions: [.v5]
)
