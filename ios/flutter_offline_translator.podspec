#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_offline_translator.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_offline_translator'
  s.version          = '0.0.1'
  s.summary          = 'A new Flutter plugin for offline translation.'
  s.description      = <<-DESC
A new Flutter plugin for offline translation using ML Kit.
                       DESC
  s.homepage         = 'https://mohammedbakali.dev/'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Mohammed Bakali' => 'mohammedbakali96623@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '11.0'

  # Add this line to include ML Kit Translate
  s.dependency 'GoogleMLKit/Translate', '~> 3.2.0'
  s.static_framework = true

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
