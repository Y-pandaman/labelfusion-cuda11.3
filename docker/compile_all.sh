#!/bin/bash
#
# This script is run by the dockerfile during the docker build.
#

CMAKE_VERSION=3.22.1

set -exu

root_dir=$(pwd)
install_dir=$root_dir/install

build_director()
{
  cd $root_dir
  git clone https://github.com/RobotLocomotion/director.git
  cd director
  git remote add pf https://github.com/peteflorence/director.git
  git fetch pf
  git checkout pf/corl-master-2
  cd ..

  mkdir director-build
  cd director-build

  cmake ../director/distro/superbuild \
      -DUSE_EXTERNAL_INSTALL:BOOL=ON \
      -DUSE_DRAKE:BOOL=OFF \
      -DUSE_LCM:BOOL=ON \
      -DUSE_LIBBOT:BOOL=ON \
      -DUSE_SYSTEM_EIGEN:BOOL=ON \
      -DUSE_SYSTEM_LCM:BOOL=OFF \
      -DUSE_SYSTEM_LIBBOT:BOOL=OFF \
      -DUSE_SYSTEM_VTK:BOOL=ON \
      -DUSE_PCL:BOOL=ON \
      -DUSE_APRILTAGS:BOOL=ON \
      -DUSE_KINECT:BOOL=ON \
      -DCMAKE_INSTALL_PREFIX:PATH=$install_dir \
      -DCMAKE_BUILD_TYPE:STRING=Release

  make -j$(nproc)

  # cleanup to make the docker image smaller
  cd ..
  rm -rf director-build
}


build_elasticfusion()
{
  cd $root_dir
  git clone https://github.com/mp3guy/ElasticFusion.git
  cd ElasticFusion/
  git submodule update --init
  cd third-party/OpenNI2/
  make -j8
  cd ../Pangolin/
  mkdir build
  cd build
  cmake .. -DEIGEN_INCLUDE_DIR=$HOME/ElasticFusion/third-party/Eigen/ -DBUILD_PANGOLIN_PYTHON=false
  make -j8
  cd ../../..
  mkdir build
  cd build/
  cmake ..

  ln -s $(pwd)/ElasticFusion $install_dir/bin

  # cleanup to make the docker image smaller
  cd ../..
  find . -name \*.o | xargs rm
}


build_director

wget https://github.com/Kitware/CMake/releases/download/v${CMAKE_VERSION}/cmake-${CMAKE_VERSION}.tar.gz
tar -xzvf cmake-${CMAKE_VERSION}.tar.gz
cd cmake-${CMAKE_VERSION}/

# build cmake
./bootstrap --prefix=/usr/local # use system curl to enable SSL support
make
sudo make install

sudo update-alternatives --install /usr/bin/cmake cmake /usr/local/bin/cmake 1 --force

# show cmake version
cmake --version




build_elasticfusion
