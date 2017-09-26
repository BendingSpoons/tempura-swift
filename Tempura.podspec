Pod::Spec.new do |s|
  s.name             = 'Tempura'
  s.version          = File.read(".version")
  s.summary          = 'UI architecture for apps'

  s.homepage         = 'https://bendingspoons.com'
  s.license          = { :type => 'No License', :text => "Copyright 2017 BendingSpoons" }
  s.author           = { 'Bending Spoons' => 'team@bendingspoons.com' }
  s.source           = { :git => 'https://github.com/BendingSpoons/tempura-lib-swift.git', :tag => s.version.to_s }

  s.ios.deployment_target = '9.0'
  s.default_subspec = 'Core'

  s.subspec 'Core' do |sp|
    sp.dependency 'Katana', '>= 0.8.3', '< 0.9'
  
    sp.ios.source_files = [
      'Tempura/Core/**/*.swift',
      'Tempura/Extensions/**/*.swift',
      'Tempura/LiveReload/**/*.swift',
      'Tempura/Navigation/**/*.swift'
    ]
  end

  s.subspec 'Testing' do |sp|
    sp.frameworks   = 'XCTest','UIKit','Foundation'
    
    sp.dependency 'FBSnapshotTestCase', '~> 2.1'
    sp.dependency 'Tempura/Core'
  
    sp.ios.source_files = [
      'Tempura/SnapshotTesting/**/*.swift'
    ]
  end

end
