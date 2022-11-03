#!/bin/bash
#
# Usage:  ./docker_run.sh [/path/to/data]
#
# This script calls `nvidia-docker run` to start the labelfusion
# container with an interactive bash session.  This script sets
# the required environment variables and mounts the labelfusion
# source directory as a volume in the docker container.  If the
# path to a data directory is given then the data directory is
# also mounted as a volume.
#

# image_name=robotlocomotion/labelfusion:latest
# image_name=robotlocomotion/labelfusion:test
image_name=pandaman666/labelfusion:cudagl-11.3.0-devel-ubuntu16.04


source_dir=$(cd $(dirname $0)/.. && pwd)

if [ ! -z "$1" ]; then

  data_dir=$1
  if [ ! -d "$data_dir" ]; then
    echo "directory does not exist: $data_dir"
    exit 1
  fi

  data_mount_arg="-v $data_dir:/root/labelfusion/data"
fi

# xhost +local:docker;
# docker run --runtime=nvidia -it --env="NVIDIA_VISIBLE_DEVICES=all" --env="NVIDIA_DRIVER_CAPABILITIES=all" -e DISPLAY=$DISPLAY -e QT_X11_NO_MITSHM=1 -v /tmp/.X11-unix:/tmp/.X11-unix:rw -v $source_dir:/root/labelfusion $data_mount_arg --privileged -v /dev/bus/usb:/dev/bus/usb $image_name
# xhost -local:root;

xhost +local:docker
docker run -it \
  --name labelfusion \
  --ipc=host \
  --network=host \
  --runtime=nvidia \
  --env="NVIDIA_VISIBLE_DEVICES=all" \
  --env="NVIDIA_DRIVER_CAPABILITIES=all" \
  --env="DISPLAY=$DISPLAY" \
  --env="QT_X11_NO_MITSHM=1" \
  --volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" \
  -v $source_dir:/root/labelfusion \
  $data_mount_arg \
  --privileged \
  -v /dev/bus/usb:/dev/bus/usb \
  $image_name
