Pod::Spec.new do |s|
  s.name             = 'TempuraTesting'
  s.version          = File.read(".version")
  s.summary          = 'UI Tests architecture for apps'

  s.homepage         = 'https://bendingspoons.com'
  s.license          = { :type => 'No License', :text => "Copyright 2018 BendingSpoons" }
  s.author           = { 'Bending Spoons' => 'team@bendingspoons.com' }
  s.source           = { :git => 'https://github.com/BendingSpoons/tempura-swift.git', :tag => s.version.to_s }

  s.ios.deployment_target = '9.0'
  s.weak_framework = "XCTest"
  s.user_target_xcconfig = { 'FRAMEWORK_SEARCH_PATHS' => '$(PLATFORM_DIR)/Developer/Library/Frameworks' }
  s.dependency 'Tempura', '>= 1.0', '< 2.0'

  s.ios.source_files = [
    'Tempura/UITests/**/*.swift',
  ]

  s.pod_target_xcconfig = {
    'OTHER_LDFLAGS' => '-weak-lswiftXCTest',
    'OTHER_SWIFT_FLAGS' => '$(inherited) -suppress-warnings',
    'FRAMEWORK_SEARCH_PATHS' => '$(inherited) "$(PLATFORM_DIR)/Developer/Library/Frameworks"',
  }
  
end
