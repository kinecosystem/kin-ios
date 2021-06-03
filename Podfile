workspace 'kin-ios'
platform :ios, '10.0'

install! 'cocoapods', :deterministic_uuids => false
use_frameworks!

def kin_base_dependencies
    pod 'PromisesSwift', '~> 1.2.8'
    pod '!ProtoCompiler-gRPCPlugin', '~> 1.28.0'
    pod 'Protobuf', '~> 3.11.4'
    pod 'gRPC-ProtoRPC', '~> 1.28.0'
end

def kin_base_compat_dependencies
  kin_base_dependencies
  pod 'Sodium', '0.8.0'
end

target 'KinBase' do
  project 'KinBase/KinBase'

  kin_base_dependencies

  target 'KinBaseTests' do
    inherit! :search_paths
    # Pods for testing
    kin_base_dependencies
  end
end

target 'KinUX' do
  project 'KinUX/KinUX'

  kin_base_dependencies

  target 'KinUXTests' do
    inherit! :search_paths
    # Pods for testing
    kin_base_dependencies
  end
end

target 'KinSampleApp' do
  project 'KinSampleApp/KinSampleApp'

  # For local development, comment out this and pull KinBase framework locally into project framework dependency, and reinstall pod
  kin_base_dependencies

  target 'KinSampleAppTests' do
    inherit! :search_paths
    # Pods for testing
  end
end
