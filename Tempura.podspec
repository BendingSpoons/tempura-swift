Pod::Spec.new do |s|
  s.name             = 'Tempura'
  s.version          = File.read(".version-tempura")
  s.summary          = 'UI architecture for apps'

  s.homepage         = 'https://bendingspoons.com'
  s.license          = { :type => 'No License', :text => "Copyright 2018 BendingSpoons" }
  s.author           = { 'Bending Spoons' => 'team@bendingspoons.com' }
  s.source           = { :git => 'https://github.com/BendingSpoons/tempura-swift.git', :tag => s.version.to_s }

  s.ios.deployment_target = '9.0'
  s.dependency 'Katana', '4.0.3-beta2'
  s.swift_version = '5.0'

  s.ios.source_files = [
    'Tempura/Core/**/*.swift',
    'Tempura/Navigation/**/*.swift',
    'Tempura/SupportingFiles/**/*.swift',
    'Tempura/Utilities/**/*.swift',
  ]

end
