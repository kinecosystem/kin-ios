#
# Spec for KinUX
#
Pod::Spec.new do |s|
  s.name             = 'KinUX'
  s.version          = '0.4.5'
  s.summary          = 'UX Library for Kin SDK iOS'

  s.description      = <<-DESC
    The KinUX library provides an out of the box model UI for spending Kin within an iOS application. Specificy what you're buying, your account, tap confirm. Success.
                       DESC

  s.homepage         = 'https://github.com/kinecosystem/kin-ios'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Kik Enginerring' => 'engineering@kik.com' }
  s.source           = { :git => 'https://github.com/kinecosystem/kin-ios.git'}

  s.ios.deployment_target = '9.0'
  s.swift_version = '5.0'

  s.source_files = 'KinUX/KinUX/Src/**/*'

  s.dependency 'KinBase', '~> 0.4.5'
  s.dependency 'KinDesign', '~> 0.4.5'

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

