workspace 'kin-ios'
platform :ios, '10.0'

install! 'cocoapods', :deterministic_uuids => false
use_frameworks!

def kin_base_dependencies
    pod 'kin-stellar-ios-mac-sdk', '~> 1.7.5'
    pod 'PromisesSwift', '~> 1.2.8'
    pod 'KinGrpcApi', :git => 'git@github.com:kinecosystem/kin-ios.git', :branch => 'agoraApiUpdateV0_23_0'
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

target 'KinUX' do
  project 'KinUX/KinUX'

  kin_base_dependencies

  target 'KinUXTests' do
    inherit! :search_paths
    # Pods for testing
    kin_base_dependencies
  end
end

target 'KinSDKSampleApp' do
  project 'KinSDKSampleApp/KinSDKSampleApp'
  kin_base_compat_dependencies
end

target 'KinBackupRestoreSampleApp' do
  project 'KinBackupRestoreSampleApp/KinBackupRestoreSampleApp'
  kin_base_compat_dependencies
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
