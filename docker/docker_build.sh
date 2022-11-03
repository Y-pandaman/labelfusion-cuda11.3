#!/bin/bash
#
# This script runs docker build to create the labelfusion docker image.
#

set -exu

root_dir=$(cd $(dirname $0)/../ && pwd)

tag_name="robotlocomotion/labelfusion:cudagl-11.3.0-devel-ubuntu16.04"

docker build -f $root_dir/docker/labelfusion.dockerfile \
	--build-arg "HTTP_PROXY=http://192.168.89.100:7890" \
    --build-arg "HTTPS_PROXY=http://192.168.89.100:7890" \
    --build-arg "NO_PROXY=localhost,127.0.0.1,.example.com" -t ${tag_name} $root_dir/docker
