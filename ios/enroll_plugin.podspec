#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint enroll_plugin.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'enroll_plugin'
  s.version          = '0.0.1'
  s.summary          = 'A new Flutter plugin project.'
  s.description      = <<-DESC
A new Flutter plugin project.
                       DESC
  s.homepage         = 'https://github.com/LuminSoft/eNROLL-iOS'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*.{h,m,swift}'
  #s.vendored_frameworks = 'Frameworks/EnrollFramework.xcframework'
  #s.dependency 'Flutter'
  #s.dependency 'dot-face-detection-fast', '= 8.10.0'
  #s.dependency 'dot-face-background-uniformity', '= 8.10.0'
  #s.dependency 'dot-face-expression-neutral', '= 8.10.0'
  #s.dependency 'dot-document', '= 8.10.0'
  s.dependency 'EnrollFramework', '~> 1.4.0'
  s.dependency 'Flutter'
  s.platform = :ios, '13.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
