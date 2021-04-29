source 'https://cdn.cocoapods.org/'

inhibit_all_warnings!
use_frameworks!

target 'Tempura' do
  platform :ios, '11.0'
  podspec
  
  target 'TempuraTests' do
    inherit! :complete
  end

  target 'Demo' do
    inherit! :complete
    pod 'PinLayout'
    pod 'DeepDiff', '~> 2.3'
  end

  target 'DemoTests' do
    inherit! :complete
  end
end

target 'TempuraTesting' do
  platform :ios, '11.0'
  podspec :path => "TempuraTesting.podspec"
end