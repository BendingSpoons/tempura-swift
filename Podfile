source "https://github.com/BendingSpoons/kss-cocoapods"
source 'https://github.com/CocoaPods/Specs.git'

inhibit_all_warnings!
use_frameworks!

target 'Tempura' do
  platform :ios, '9.0'
  podspec

  target 'TempuraTests' do
    inherit! :search_paths
    pod 'Quick', '~> 1.2'
    pod 'Nimble', '~> 7.0'
  end

  target 'Demo' do
    pod 'PinLayout'
    pod 'BonMot', '~> 5.0'
    pod 'Hero', '1.0.0-alpha.4'
  end

  target 'DemoTests' do
    inherit! :search_paths
    pod 'Quick', '~> 1.2'
    pod 'Nimble', '~> 7.0'
  end

  target 'TempuraHelpers' do
    pod 'BonMot', '~> 5.0'
  end

  target 'TempuraHelpersTests' do
    inherit! :search_paths
    pod 'Quick', '~> 1.2'
    pod 'Nimble', '~> 7.0'
  end

end


post_install do |installer|
  # Your list of targets here.
  legacyTargets = ['Hero']
  
  installer.pods_project.targets.each do |target|
    if legacyTargets.include? target.name
      target.build_configurations.each do |config|
        config.build_settings['SWIFT_VERSION'] = '3.2'
      end
    end
  end
end
