source 'https://cdn.cocoapods.org/'

inhibit_all_warnings!
use_frameworks!

target 'Tempura' do
  platform :ios, '11.0'

  # TODO: Remove me
  pod 'Katana', :git => 'https://github.com/BendingSpoons/katana-swift', :branch => 'release/6.0.0'

  podspec

  target 'TempuraTests' do
    inherit! :complete
  end
end  

target 'TempuraTesting' do
  platform :ios, '11.0'
  podspec
end
   
target 'Demo' do
  platform :ios, '11.0'

  # TODO: fix me
  pod 'Katana', :git => 'https://github.com/BendingSpoons/katana-swift', :branch => 'release/6.0.0'
  
  pod 'DeepDiff', '= 2.3.1'
  pod 'PinLayout', '= 1.9.2'

  target 'DemoUITests' do
    inherit! :complete
  end
end
