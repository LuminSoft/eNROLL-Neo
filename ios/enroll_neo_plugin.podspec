#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint enroll_neo_plugin.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'enroll_neo_plugin'
  s.version          = '1.0.0'
  s.summary          = 'eNROLL Neo Flutter plugin for lightweight eKYC compliance.'
  s.description      = <<-DESC
eNROLL Neo is a lightweight compliance solution that prevents identity fraud and phishing.
                       DESC
  s.homepage         = 'https://github.com/LuminSoft/eNROLL-Neo'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'LuminSoft' => 'support@luminsoft.net' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*.{h,m,swift}'
  # TODO: iOS Developer - Replace with the correct eNROLL Neo iOS SDK dependency and version
  s.dependency 'EnrollFramework', '~> 1.0.0'
  s.dependency 'Flutter'
  s.platform = :ios, '13.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
