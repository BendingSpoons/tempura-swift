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
    pod 'PinLayout'
    pod 'DeepDiff'
  end

  target 'DemoTests' do
    inherit! :search_paths
    pod 'Quick'
    pod 'Nimble'
  end
end

target 'TempuraTesting' do
  platform :ios, '9.0'
  pod 'Tempura', :path => '.'
end
