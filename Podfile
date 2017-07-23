source "https://github.com/BendingSpoons/kss-cocoapods"
source 'https://github.com/CocoaPods/Specs.git'

inhibit_all_warnings!
use_frameworks!

target 'Tempura' do
  platform :ios, '9.0'
  podspec

  target 'TempuraTests' do
    inherit! :search_paths
    pod 'Quick'
    pod 'Nimble'
  end

  target 'Demo' do
  pod 'Tempura', :path => './'
  end
end


post_install do |installer|
  installer.pods_project.targets.each do |target|
    if target.name == 'Tempura'
      target.build_configurations.each do |config|
        if config.name == 'Debug'
          config.build_settings['OTHER_SWIFT_FLAGS'] = '-DDEBUG'
        else
          config.build_settings['OTHER_SWIFT_FLAGS'] = ''
        end
      end
    end
  end
end
