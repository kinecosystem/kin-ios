#
# Be sure to run `pod lib lint KinBaseCompat.podspec' to ensure this is a
# valid spec before submitting.
#

#
# Spec for KinBaseCompat
#
Pod::Spec.new do |s|
  s.name             = 'KinBaseCompat'
  s.version          = '0.4.5'
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

  s.dependency 'KinBase', '~> 0.4.5'
  s.dependency 'Sodium', '0.8.0'

  # Dependencies needed for KinGrpcApi
  s.dependency 'gRPC-ProtoRPC'
  s.dependency 'Protobuf'

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
