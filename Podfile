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
    pod 'DeepDiff', '~> 1.1'
  end
end