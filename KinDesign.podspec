#
# Spec for KinDesign
#
Pod::Spec.new do |s|
  s.name             = 'KinDesign'
  s.version          = '2.1.3'
  s.summary          = 'Kin Design Library for iOS'

  s.description      = <<-DESC
    The shared KinDesign library components for creating consistent Kin user experiences. When creating a custom Kin experience, this library can be used to include standard UI components for displaying Kin prices, transactions, etc.
                       DESC

  s.homepage         = 'https://github.com/kinecosystem/kin-ios'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Kin Developers' => 'dev@kin.org' }
  s.source           = { :git => 'https://github.com/kinecosystem/kin-ios.git' }

  s.ios.deployment_target = '9.0'
  s.swift_version = '5.0'

  s.source_files = 'KinDesign/KinDesign/Classes/**/*'
  s.resources = 'KinDesign/KinDesign/*.{xcassets}'
  s.frameworks = 'UIKit'
end

