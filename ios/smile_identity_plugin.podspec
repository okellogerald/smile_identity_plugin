#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint smile_identity_plugin.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'smile_identity_plugin'
  s.version          = '0.0.1+2'
  s.summary          = 'A new Flutter plugin project.'
  s.description      = <<-DESC
A new Flutter plugin project.
                       DESC
  s.homepage         = 'https://github.com/okellogerald/smile-identity-plugin'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Company' => 'okellogeralddev@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '13.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
  s.dependency "Smile_Identity_SDK","2.1.23"
end
