Pod::Spec.new do |s|
  s.name             = 'Tempura'
  s.version          = File.read(".version-tempura")
  s.summary          = 'UI architecture for apps'

  s.homepage         = 'https://bendingspoons.com'
  s.license          = { :type => 'No License', :text => "Copyright 2018 BendingSpoons" }
  s.author           = { 'Bending Spoons' => 'team@bendingspoons.com' }
  s.source           = { :git => 'https://github.com/BendingSpoons/tempura-swift.git', :tag => s.version.to_s }

  s.ios.deployment_target = '11.0'

  s.swift_version = '5.0'

  s.dependency 'HydraAsync', '>= 2.0.6', '< 3'
  # s.dependency 'Katana', '>= 6.0', '< 7' # TODO: Restore me

  s.ios.source_files = [
    'Tempura/Sources/**/*.swift',
  ]

end
