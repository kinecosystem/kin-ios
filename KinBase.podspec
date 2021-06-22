#
# Be sure to run `pod lib lint KinBase.podspec' to ensure this is a
# valid spec before submitting.
#

#
# Spec for KinBase
#
Pod::Spec.new do |s|
  s.name             = 'KinBase'
  s.version          = '0.5.0'
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
  
  # s.info_plist = { 'CFBundleIdentifier' => 'org.kin.KinBase' }

  non_arc_files = 'KinBase/KinBase/Src/Storage/Gen/*.{h,m}'
  s.source_files = 'KinBase/KinBase/**/*.{h,c,swift}'
  
  # s.exclude_files = "KinBase/KinBase/*.plist"
  
  s.dependency 'PromisesSwift', '~> 1.2.8'
  s.dependency '!ProtoCompiler-gRPCPlugin', '~> 1.28.0'
  s.dependency 'Protobuf', '~> 3.11.4'
  s.dependency 'gRPC-ProtoRPC', '~> 1.28.0'
  
  s.subspec 'no-arc' do |sna|
      sna.requires_arc = false
      sna.source_files = non_arc_files
      sna.dependency 'Protobuf', '~> 3.11.4'
  end

  s.pod_target_xcconfig = {
      # This is needed by all pods that depend on Protobuf:
      'GCC_PREPROCESSOR_DEFINITIONS' => '$(inherited) GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS=1',
      # This is needed by all pods that depend on gRPC-RxLibrary:
      'CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES' => 'YES',
      # This is needed for the user Podfile to use_framework! https://github.com/CocoaPods/CocoaPods/issues/4605
      'USE_HEADERMAP' => 'NO',
      'ALWAYS_SEARCH_USER_PATHS' => 'NO',
      'USER_HEADER_SEARCH_PATHS' => '$(PODS_ROOT)/KinBase/KinBase/Src/Vendor/gen',
      'HEADER_SEARCH_PATHS' => '$(PODS_ROOT)/KinBase/KinBase/Src/Vendor/gen',
      'SWIFT_VERSION' => '5.0',
      # 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64',
      # 'PRODUCT_BUNDLE_IDENTIFIER': 'org.kin.KinBase',
      # 'VALID_ARCHS[sdk=iphonesimulator*]' => 'x86_64'
  }
  
  # s.test_spec 'KinBaseTests' do |t|
  #  t.source_files = 'KinBase/KinBaseTests/**/*.{h,c,swift}'
  #  t.dependency 'PromisesSwift', '~> 1.2.8'
  #  t.dependency '!ProtoCompiler-gRPCPlugin', '~> 1.28.0'
  #  t.dependency 'Protobuf', '~> 3.11.4'
  #  t.dependency 'gRPC-ProtoRPC', '~> 1.28.0'
  # end

  # s.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
  
end
