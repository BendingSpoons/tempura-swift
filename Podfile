source 'https://github.com/CocoaPods/Specs.git'

inhibit_all_warnings!
use_frameworks!

target 'Tempura' do
  platform :ios, '9.0'
  podspec
  
  pod 'Katana', :git => 'https://github.com/BendingSpoons/katana-swift.git', :branch => 'feature/documentation-and-tests'

  target 'TempuraTests' do
    inherit! :complete
    pod 'Quick', '~> 1.3'
    pod 'Nimble', '~> 7.3'
  end

  target 'Demo' do
    pod 'PinLayout'
    pod 'DeepDiff', '~> 2.0'
  end

  target 'DemoTests' do
    inherit! :complete
    pod 'Quick', '~> 1.3'
    pod 'Nimble', '~> 7.3'
  end
end

target 'TempuraTesting' do
  platform :ios, '9.0'
  # change this before releasing
  pod 'Tempura', :path => '.'
  # pod 'Tempura', '~> 3.0'
end

post_install do |installer|
  oldTargets = ['Quick', 'Nimble', 'DeepDiff']
 
  installer.pods_project.targets.each do |target|
    if oldTargets.include? target.name
      target.build_configurations.each do |config|
        config.build_settings['SWIFT_VERSION'] = '4.2'
      end
    end
  end
end
