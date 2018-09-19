project.name = "Tempura"

# Tempura Framework target
tempura = target do |target|
    target.name = "Tempura"
    target.platform = :ios
    target.deployment_target = 9.0
    target.language = :swift
    target.type = :framework
    target.include_files = [
        "Tempura/Core/**/*.swift",
        "Tempura/Navigation/**/*.swift",
        "Tempura/SupportingFiles/**/*.swift",
        "Tempura/Utilities/**/*.swift",
    ]

    target.all_configurations.each do |configuration|
        configuration.settings["INFOPLIST_FILE"] = "Tempura/SupportingFiles/Info.plist"
        configuration.settings["PRODUCT_NAME"] = "Tempura"
	    configuration.settings["SWIFT_VERSION"] = "4.2"
        configuration.settings["FRAMEWORK_SEARCH_PATHS"] = "$(inherited) $(PLATFORM_DIR)/Developer/Library/Frameworks"
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
	    configuration.settings["SWIFT_VERSION"] = "4.2"
        end

    end

    target.scheme(target.name)
end

# TempuraTesting Framework target
tempuraTesting = target do |target|
    target.name = "TempuraTesting"
    target.platform = :ios
    target.deployment_target = 9.0
    target.language = :swift
    target.type = :framework
    target.include_files = [
        "Tempura/UITests/**/*.swift",
    ]

    target.all_configurations.each do |configuration|
        configuration.settings["INFOPLIST_FILE"] = "Tempura/SupportingFiles/Info.plist"
        configuration.settings["PRODUCT_NAME"] = "TempuraTesting"
        configuration.settings["SWIFT_VERSION"] = "4.2"
        configuration.settings["FRAMEWORK_SEARCH_PATHS"] = "$(inherited) $(PLATFORM_DIR)/Developer/Library/Frameworks"
    end

    target.headers_build_phase do |phase|
        phase.public << "Tempura/SupportingFiles/Tempura.h"
    end

    target.scheme(target.name)
end


# Demo target
demo = target do |target|
    target.name = "Demo"
    target.platform = :ios
    target.deployment_target = 10.0
    target.language = :swift
    target.type = :application
    target.linked_targets = [tempura]
    
    target.include_files = [
        "Demo/**/*.swift",
	   "Demo/Resources/**/*.*"
    ]

    target.all_configurations.each do |configuration|
        configuration.product_bundle_identifier = "dk.bendingspoons.AppStation"
        configuration.settings["INFOPLIST_FILE"] = "Demo/Info.plist"
        configuration.settings["PRODUCT_NAME"] = "Demo"
	configuration.settings["SWIFT_VERSION"] = "4.2"
    end

    unit_tests_for target do |unit_test|
        unit_test.linked_targets = [target]
        unit_test.include_files = [
            "DemoTests/**/*.swift",
        ]

        unit_test.all_configurations.each do |configuration|
            configuration.settings["INFOPLIST_FILE"] = "DemoTests/Info.plist"
	    configuration.settings["SWIFT_VERSION"] = "4.2"
        end

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
