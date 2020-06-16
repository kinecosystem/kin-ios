workspace 'kin-ios'
platform :ios, '10.0'

install! 'cocoapods', :deterministic_uuids => false
use_frameworks!

def kin_base_dependencies
    pod 'kin-stellar-ios-mac-sdk', '~> 1.7.4'
    pod 'PromisesSwift', '~> 1.2.8'
    pod 'Protobuf', '~> 3.0'
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

target 'KinSDK' do
  project 'KinBaseCompat/KinBaseCompat'

  kin_base_compat_dependencies

  target 'KinBaseCompatTests' do
    inherit! :search_paths
    # Pods for testing
    kin_base_compat_dependencies
  end
end
