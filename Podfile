source 'https://github.com/CocoaPods/Specs.git'

inhibit_all_warnings!
use_frameworks!

target 'Tempura' do
  platform :ios, '9.0'
  podspec

  target 'TempuraTests' do
    inherit! :search_paths
    pod 'Quick', '~> 1.2'
    pod 'Nimble', '~> 7.1'
  end

  target 'Demo' do
    pod 'PinLayout'
    pod 'DeepDiff', '~> 1.2'
  end

  target 'DemoTests' do
    inherit! :search_paths
    pod 'Quick', '~> 1.2'
    pod 'Nimble', '~> 7.1'
  end
end

target 'TempuraTesting' do
  platform :ios, '9.0'
  pod 'Tempura', '~> 2.0'
end

post_install do |installer|
  oldTargets = ['Quick', 'Nimble', 'DeepDiff']
 
  installer.pods_project.targets.each do |target|
    if oldTargets.include? target.name
      target.build_configurations.each do |config|
        config.build_settings['SWIFT_VERSION'] = '4'
      end
    end
  end
end