Pod::Spec.new do |s|
  s.name             = 'TempuraTesting'
  s.version          = File.read(".version")
  s.summary          = 'UI architecture for apps - Testing'

  s.homepage         = 'https://bendingspoons.com'
  s.license          = { :type => 'No License', :text => "Copyright 2017 BendingSpoons" }
  s.author           = { 'Bending Spoons' => 'team@bendingspoons.com' }
  s.source           = { :git => 'https://github.com/BendingSpoons/tempura-lib-swift.git', :tag => s.version.to_s }

  s.ios.deployment_target = '9.0'
  s.frameworks   = 'XCTest','UIKit','Foundation'
  
  s.dependency 'Tempura', '>= 0.4.0'
  s.dependency 'FBSnapshotTestCase', '~> 2.1'

  s.ios.source_files = [
    'Tempura/SnapshotTesting/**/*.swift'
  ]
end
