//
//  Project.swift
//  Tempura
//
//  Copyright © 2021 Bending Spoons.
//  Distributed under the MIT License.
//  See the LICENSE file for more information.

import ProjectDescription

let iOSTargetVersion = "11.0"

// MARK: - Actions

let actions: [TargetAction] = [
  .pre(
    tool: "swiftlint",
    arguments: ["--lenient"],
    name: "SwiftLint"
  ),
  .pre(
    tool: "swiftformat",
    arguments: ["."],
    name: "SwiftFormat"
  ),
]

// MARK: - Tempura

let tempuraMainTarget = Target(
  name: "Tempura",
  platform: .iOS,
  product: .framework,
  bundleId: "com.bendingspoonsapps.Tempura",
  deploymentTarget: .iOS(targetVersion: iOSTargetVersion, devices: [.iphone, .ipad]),
  infoPlist: .default,
  sources: ["Tempura/Sources/**"],
  actions: actions,
  dependencies: [
    .cocoapods(path: "."),
  ]
)

let tempuraTestsTarget = Target(
  name: "TempuraTests",
  platform: .iOS,
  product: .unitTests,
  bundleId: "com.bendingspoonsapps.Tempura.Tests",
  deploymentTarget: .iOS(targetVersion: iOSTargetVersion, devices: [.iphone, .ipad]),
  infoPlist: .default,
  sources: ["Tempura/Tests/**"],
  actions: actions,
  dependencies: [
    .target(name: tempuraMainTarget.name),
  ]
)

// MARK: - TempuraTesting

let tempuraTestingTarget = Target(
  name: "TempuraTesting",
  platform: .iOS,
  product: .staticLibrary,
  bundleId: "com.bendingspoonsapps.TempuraTesting",
  deploymentTarget: .iOS(targetVersion: iOSTargetVersion, devices: [.iphone, .ipad]),
  infoPlist: .default,
  sources: ["TempuraTesting/Sources/**"],
  actions: actions,
  dependencies: [
    .cocoapods(path: "."),
    .target(name: tempuraMainTarget.name),
  ],
  settings: Settings(base: [
    "ENABLE_TESTING_SEARCH_PATHS": "YES",
    "OTHER_LDFLAGS": "$(inherited)",
  ])
)

// MARK: - Demo

let demoTarget = Target(
  name: "Demo",
  platform: .iOS,
  product: .app,
  bundleId: "com.bendingspoonsapps.Tempura.Demo",
  deploymentTarget: .iOS(targetVersion: iOSTargetVersion, devices: [.iphone, .ipad]),
  infoPlist: .extendingDefault(with: [
    "UI_TEST_DIR": "$(SOURCE_ROOT)/Demo/UITests/Screenshots",
  ]),
  sources: ["Demo/Sources/**"],
  actions: actions,
  dependencies: [
    .cocoapods(path: "."),
    .target(name: tempuraMainTarget.name),
  ]
)

let demoUITestTarget = Target(
  name: "DemoUITests",
  platform: .iOS,
  product: .unitTests,
  bundleId: "com.bendingspoonsapps.Tempura.Demo.UITests",
  deploymentTarget: .iOS(targetVersion: iOSTargetVersion, devices: [.iphone, .ipad]),
  infoPlist: .default,
  sources: ["Demo/UITests/**"],
  actions: actions,
  dependencies: [
    .cocoapods(path: "."),
    .target(name: demoTarget.name),
    .target(name: tempuraTestingTarget.name),
  ]
)

// MARK: - Project Definition

let project = Project(
  name: "Tempura",
  organizationName: "BendingSpoons",
  targets: [
    tempuraMainTarget,
    tempuraTestsTarget,
    tempuraTestingTarget,
    demoTarget,
    demoUITestTarget,
  ],
  schemes: [
    .init(
      name: "Demo",
      buildAction: .init(targets: [.init(stringLiteral: demoTarget.name)]),
      testAction: .init(targets: [.init(stringLiteral: demoUITestTarget.name)]),
      runAction: .init(executable: "\(demoTarget.name)")
    ),
    .init(
      name: "Tempura",
      buildAction: .init(targets: [.init(stringLiteral: tempuraMainTarget.name)]),
      testAction: .init(targets: [.init(stringLiteral: tempuraTestsTarget.name)]),
      runAction: .init(executable: "\(demoTarget.name)")
    ),
    .init(
      name: "TempuraTesting",
      buildAction: .init(targets: [.init(stringLiteral: tempuraTestingTarget.name)])
    ),
  ]
)
