project.name = "Tempura"


tempura = target do |target|
    target.name = "Tempura"
    target.platform = :ios
    target.deployment_target = 9.0
    target.language = :swift
    target.type = :framework
    target.include_files = [
        "Tempura/**/*.swift",
    ]

    target.all_configurations.each do |configuration|
        configuration.settings["INFOPLIST_FILE"] = "Tempura/SupportingFiles/Info.plist"
        configuration.settings["PRODUCT_NAME"] = "Tempura"
	configuration.settings["SWIFT_VERSION"] = "4.0"
    end

    target.headers_build_phase do |phase|
        phase.public << "Tempura/SupportingFiles/Tempura.h"
    end

    unit_tests_for target do |unit_test|
        unit_test.linked_targets = [target]
        unit_test.include_files = [
            "TempuraTests/**/*.swift",
        ]

        unit_test.all_configurations.each do |configuration|
            configuration.settings["INFOPLIST_FILE"] = "TempuraTests/Info.plist"
	    configuration.settings["SWIFT_VERSION"] = "4.0"
        end

    end

    target.scheme(target.name)
end

tempuraHelpers = target do |target|
    target.name = "TempuraHelpers"
    target.platform = :ios
    target.deployment_target = 9.0
    target.language = :swift
    target.type = :framework
    target.include_files = [
        "TempuraHelpers/**/*.swift",
    ]

    target.all_configurations.each do |configuration|
        configuration.settings["INFOPLIST_FILE"] = "TempuraHelpers/SupportingFiles/Info.plist"
        configuration.settings["PRODUCT_NAME"] = "TempuraHelpers"
    configuration.settings["SWIFT_VERSION"] = "4.0"
    end

    target.headers_build_phase do |phase|
        phase.public << "TempuraHelpers/SupportingFiles/TempuraHelpers.h"
    end

    unit_tests_for target do |unit_test|
        unit_test.linked_targets = [target]
        unit_test.include_files = [
            "TempuraHelpersTests/**/*.swift",
        ]

        unit_test.all_configurations.each do |configuration|
            configuration.settings["INFOPLIST_FILE"] = "TempuraHelpersTests/Info.plist"
        configuration.settings["SWIFT_VERSION"] = "4.0"
        end

    end

    target.scheme(target.name)
end

demo = target do |target|
    target.name = "Demo"
    target.platform = :ios
    target.deployment_target = 9.0
    target.language = :swift
    target.type = :application
    target.linked_targets = [tempura]
    
    target.include_files = [
        "Demo/**/*.swift",
	"Demo/Resources/photo.png"
    ]

    target.all_configurations.each do |configuration|
        configuration.product_bundle_identifier = "dk.bendingspoons.AppStation"
        configuration.settings["INFOPLIST_FILE"] = "Demo/Info.plist"
        configuration.settings["PRODUCT_NAME"] = "Demo"
	configuration.settings["SWIFT_VERSION"] = "4.0"
    end

    target.scheme(target.name)
end

project.targets.each do |target|
    target.shell_script_build_phase "Lint", <<-SCRIPT 
    if which swiftlint >/dev/null; then
        swiftlint
    else
        echo "warning: SwiftLint not installed, download from https://github.com/realm/SwiftLint"
    fi
    SCRIPT
end
