#
# Be sure to run `pod lib lint KinBaseCompat.podspec' to ensure this is a
# valid spec before submitting.
#

#
# Spec for KinBaseCompat
#
Pod::Spec.new do |s|
  s.name             = 'KinBaseCompat'
  s.version          = '0.1.3'
  s.summary          = 'Kin SDK for iOS'

  s.description      = <<-DESC
  The compatibility library implements the public surface layer to be a drop in replacement of the, now deprecated, kin-sdk-ios library.
                     DESC

  s.homepage         = 'https://github.com/kinecosystem/kin-ios'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Kik Engineering' => 'engineering@kik.com' }
  s.source           = { :git => 'https://github.com/kinecosystem/kin-ios.git', :tag => "#{s.version}"  }

  s.module_name = 'KinSDK'
  s.swift_version = '5.0'
  s.ios.deployment_target = '9.0'

  s.source_files = 'KinBaseCompat/KinBaseCompat/Src/**/*.swift'
  s.resources = 'KinBaseCompat/KinBaseCompat/Src/KinBackupRestoreModule/*.{strings,xcassets}'

  s.dependency 'KinBase', '~> 0.1.3'
  s.dependency 'Sodium', '0.8.0'
end
