Pod::Spec.new do |s|
  s.name             = 'TempuraHelpers'
  s.version          = File.read(".version")
  s.summary          = 'Tempura UI Helpers'

  s.homepage         = 'https://bendingspoons.com'
  s.license          = { :type => 'No License', :text => "Copyright 2017 BendingSpoons" }
  s.author           = { 'Bending Spoons' => 'team@bendingspoons.com' }
  s.source           = { :git => 'https://github.com/BendingSpoons/tempura-lib-swift.git', :tag => s.version.to_s }

  s.ios.deployment_target = '9.0'
  s.frameworks   = 'UIKit','Foundation'
  
  s.dependency 'Tempura', '>= 0.6.0'
  s.dependency 'BonMot', '~> 5.0'

  s.ios.source_files = [
    'TempuraHelpers/**/*.swift'
  ]
end
