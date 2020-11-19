#
# Be sure to run `pod lib lint KinBase.podspec' to ensure this is a
# valid spec before submitting.
#

#
# Spec for KinBase
#
Pod::Spec.new do |s|
  s.name             = 'KinBase'
  s.version          = '0.4.0'
  s.summary          = 'Kin SDK for iOS'

  s.description      = <<-DESC
    Use the Kin SDK for iOS to enable the use of Kin inside of your app. Include only the functionality you need to provide the right experience to your users. Use just the base library to access the lightest-weight wrapper over the Kin crytocurrency.
                       DESC

  s.homepage         = 'https://github.com/kinecosystem/kin-ios'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Kik Engineering' => 'engineering@kik.com' }
  s.source           = { :git => 'https://github.com/kinecosystem/kin-ios.git', :tag => "#{s.version}" }

  s.ios.deployment_target = '9.0'
  s.swift_version = '5.0'

  non_arc_files = 'KinBase/KinBase/Src/Storage/Gen/*.{h,m}'
  s.source_files = 'KinBase/KinBase/**/*.{h,swift}'

  s.dependency 'kin-stellar-ios-mac-sdk', '~> 1.7.5'
  s.dependency 'PromisesSwift', '~> 1.2.8'
  s.dependency 'KinGrpcApi', '~> 0.4.0'
  s.dependency 'Base58Swift', '~> 2.1.10'
  s.dependency 'Sodium', '~> 0.8.0'

  # Dependencies needed for KinGrpcApi
  s.dependency 'gRPC-ProtoRPC'
  s.dependency 'Protobuf'

  s.requires_arc = true

  s.subspec 'no-arc' do |sna|
    sna.requires_arc = false
    sna.source_files = non_arc_files
    sna.dependency 'Protobuf', '~> 3.0'
  end

  s.pod_target_xcconfig = {
      # This is needed by all pods that depend on Protobuf:
      'GCC_PREPROCESSOR_DEFINITIONS' => '$(inherited) GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS=1 GPB_GRPC_FORWARD_DECLARE_MESSAGE_PROTO=1',
      # This is needed by all pods that depend on gRPC-RxLibrary:
      'CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES' => 'YES',
      # This is needed for the user Podfile to use_framework! https://github.com/CocoaPods/CocoaPods/issues/4605
      'USE_HEADERMAP' => 'NO',
      'ALWAYS_SEARCH_USER_PATHS' => 'NO',
      'USER_HEADER_SEARCH_PATHS' => '$(PODS_ROOT)/KinGrpcApi/KinGrpcApi/gen',
      'HEADER_SEARCH_PATHS' => '$(PODS_ROOT)/KinGrpcApi/KinGrpcApi/gen'
  }
end
