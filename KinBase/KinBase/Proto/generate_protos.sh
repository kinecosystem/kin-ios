#!/bin/bash
#
PODS_ROOT="../../../Pods"
PROTOC="${PODS_ROOT}/!ProtoCompiler/protoc"
PLUGIN="${PODS_ROOT}/!ProtoCompiler-gRPCPlugin/grpc_objective_c_plugin"

${PROTOC} ./storage.proto --objc_out=../Src/Storage/Gen/
