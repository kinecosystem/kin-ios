## KinGrpcApi.podspec
**Location**

The podspec file needs to be stored at the root directory of a repo to be pulled by Cocoapods.

**Support `use_frameworks!`**

Add these to `s.pod_target_xcconfig` on top the two grpc objc configs: 
`'USE_HEADERMAP' => 'NO',`
`'ALWAYS_SEARCH_USER_PATHS' => 'NO',`
`'USER_HEADER_SEARCH_PATHS' => '$(PODS_ROOT)/KinGrpcApi/KinGrpcApi/gen',`
`'HEADER_SEARCH_PATHS' => '$(PODS_ROOT)/KinGrpcApi/KinGrpcApi/gen'`

**Reference**

Sample podspec: https://github.com/grpc/grpc/tree/master/src/objective-c 
`use_framework!` issue: https://github.com/CocoaPods/CocoaPods/issues/4605 

## KinBase.podspec
Because KinBase depends on KinGrpcApi, all `pod_target_xcconfig` in KinGrpcApi.podspec also need to present in KinBase.podspec. On top of them, add `GPB_GRPC_FORWARD_DECLARE_MESSAGE_PROTO=1'` to `'GCC_PREPROCESSOR_DEFINITIONS'`.

## generate_proto.sh
What happens in `generate_proto.sh`:
1. The script pulls 
 - `kin-api` proto files from `git@github.com:kinecosystem/kin-api.git`
 - `validate` proto from `git@github.com:envoyproxy/protoc-gen-validate.git` which kin-api depends on

2. Uses `protoc` and `grpc_objective_c_plugin` to generate objc `.h` and `.m` files. 
 - Either use locally stored `protoc` and `grpc_objective_c_plugin` executables OR
 - Modify `PROTOC` and `PLUGIN` paths in the script to point to executables under `${PODS_ROOT}/!ProtoCompiler` and `${PODS_ROOT}/!ProtoCompiler-gRPCPlugin`
 
 Note: `google/protobuf/descriptor.proto` is needed by `validate`

 **Usage**
 - Manually run `./generate_proto.sh`  to fetch updated kin-api
 - Commit updated files under `/gen` 
 - This is script will stay private. For public release, we will include generated objc files in the pod repo


