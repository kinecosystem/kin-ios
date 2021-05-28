#!/bin/bash
#
# Ensure we're excuting from script directory
cd "$(dirname ${BASH_SOURCE[0]})"

# exit when any command fails
set -e

GEN_PATH="gen"

GIT_TEMP_PATH=$(mktemp -d -t 'kinprotosgittmp')
KIN_API_GIT_PATH="${GIT_TEMP_PATH}/kin-api"
VALIDATE_GIT_PATH="${GIT_TEMP_PATH}/validate"

MODEL_TEMP_PATH=$(mktemp -d -t 'kinprotostmp')

IMPORT_PATHS="${MODEL_TEMP_PATH}/proto:${MODEL_TEMP_PATH}"

PODS_ROOT="../Pods"
PROTOC="${PODS_ROOT}/!ProtoCompiler/protoc"
PLUGIN="${PODS_ROOT}/!ProtoCompiler-gRPCPlugin/grpc_objective_c_plugin"
#PROTOC="protoc"
#PLUGIN="grpc_objective_c_plugin"

function cleanup {
  rm -rf ${GIT_TEMP_PATH}
  rm -rf ${MODEL_TEMP_PATH}
}

# register the cleanup function to be called on the EXIT signal
trap cleanup EXIT

echo "Cloning kin-api into ${KIN_API_GIT_PATH}"
git clone -b master --single-branch git@github.com:kinecosystem/agora-api-internal.git ${KIN_API_GIT_PATH}

echo "Cloning protoc-gen-validate into ${VALIDATE_GIT_PATH}"
git clone -b main --single-branch git@github.com:envoyproxy/protoc-gen-validate.git $VALIDATE_GIT_PATH

# Find only the protos under /v3/.
for path in $(find ${KIN_API_GIT_PATH}/proto -name 'v3' -type d -print0 | xargs -0 -n1); do
  path_folder_name=$(echo ${path} | sed 's/.*\(proto\)/\1/g')
  
  source_folder_name=$(echo ${KIN_API_GIT_PATH}/${path_folder_name})
  dest_folder_name=$(dirname ${MODEL_TEMP_PATH}/${path_folder_name})

  mkdir -p ${dest_folder_name}
  cp -r ${source_folder_name} ${dest_folder_name}

  echo "Copying to ${dest_folder_name}"
done

# Find only the protos under /v4/.
for path in $(find ${KIN_API_GIT_PATH}/proto -name 'v4' -type d -print0 | xargs -0 -n1); do
  path_folder_name=$(echo ${path} | sed 's/.*\(proto\)/\1/g')
  
  source_folder_name=$(echo ${KIN_API_GIT_PATH}/${path_folder_name})
  dest_folder_name=$(dirname ${MODEL_TEMP_PATH}/${path_folder_name})

  mkdir -p ${dest_folder_name}
  cp -r ${source_folder_name} ${dest_folder_name}

  echo "Copying to ${dest_folder_name}"
done

# Copy validate.proto
path_folder_name=$(echo "validate")

source_folder_name=$(echo ${VALIDATE_GIT_PATH}/${path_folder_name})
dest_folder_name=$(dirname ${MODEL_TEMP_PATH}/${path_folder_name})

mkdir -p ${dest_folder_name}
cp -r ${source_folder_name} ${dest_folder_name}

echo "Copying from ${source_folder_name} to ${dest_folder_name}"

# Clean GEN_PATH
rm -rf ${GEN_PATH}
mkdir -p ${GEN_PATH}

# Build kin-api
KIN_API_MOBILE_IMPORT_PATHS=${IMPORT_PATHS}
KIN_API_GEN_PATH=${GEN_PATH}
mkdir -p ${KIN_API_GEN_PATH}
for i in $(find ${MODEL_TEMP_PATH} -name '*.proto' -print0 | xargs -0 -n1 dirname | sort | uniq); do

  echo $(PWD)
  echo "Building ${i}"

  ${PROTOC} -I${KIN_API_MOBILE_IMPORT_PATHS} \
    ${i}/*.proto \
    --proto_path=. \
    --objc_out=${KIN_API_GEN_PATH} \
    --grpc_out=${KIN_API_GEN_PATH} \
    --plugin=protoc-gen-grpc=${PLUGIN}
done

# Build google
GOOGLE_MODEL_COMMON_GEN_PATH="${GEN_PATH}"
mkdir -p ${GOOGLE_MODEL_COMMON_GEN_PATH}
for i in $(find google -name '*.proto' -print0 | xargs -0 -n1 dirname | sort | uniq); do

  echo "Building ${i}"

  ${PROTOC} \
    $i/*.proto \
    --proto_path=. \
    --objc_out=${GOOGLE_MODEL_COMMON_GEN_PATH} \
    --grpc_out=${GOOGLE_MODEL_COMMON_GEN_PATH} \
    --plugin=protoc-gen-grpc=${PLUGIN}
done
