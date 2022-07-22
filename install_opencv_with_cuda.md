# How to install OpenCV with CUDA and CUDNN using FFMPEG compiled with NVENC/CUVID Ubuntu 20.04

First of all install update and upgrade your system:

```
$ sudo apt update
$ sudo apt upgrade
```

## NVIDIA

* NVIDIA CUDA

https://developer.nvidia.com/cuda-downloads

check https://docs.nvidia.com/cuda/cuda-installation-guide-linux/index.html#post-installation-actions

```
$ export PATH=/usr/local/cuda-11.7/bin${PATH:+:${PATH}}
$ export LD_LIBRARY_PATH=/usr/local/cuda-11.7/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}
 ```
 
* NVIDIA CUDNN

https://developer.nvidia.com/rdp/cudnn-download

* NVIDIA Video Codec SDK

https://developer.nvidia.com/nvidia-video-codec-sdk/download


## FFMPEG

* Install depencies
	
```
$ sudo apt-get -y install autoconf automake build-essential cmake git-core libass-dev libfreetype6-dev libgnutls28-dev libmp3lame-dev libsdl2-dev libtool libva-dev libvdpau-dev libvorbis-dev libxcb1-dev libxcb-shm0-dev libxcb-xfixes0-dev meson ninja-build pkg-config texinfo wget yasm zlib1g-dev libunistring-dev libaom-dev nasm libunistring-dev
```

* Install relevant codecs libraries

```
$ sudo apt-get install libx264-dev libx265-dev libnuma-dev libvpx-dev libfdk-aac-dev libopus-dev
```

* Compile extra codecs 

Prepare directories 

```
$ mkdir -p ~/ffmpeg_sources ~/bin ~/ffmpeg_build
```

libvpx

```
$ cd ~/ffmpeg_sources
$ git -C libvpx pull 2> /dev/null || git clone --depth 1 https://chromium.googlesource.com/webm/libvpx.git
$ cd libvpx 
$ PATH="$HOME/bin:$PATH" ./configure  --enable-shared --enable-pic --prefix="$HOME/ffmpeg_build" --disable-examples --disable-unit-tests --enable-vp9-highbitdepth --as=yasm 
$ PATH="$HOME/bin:$PATH" make -j 12
$ make install
```

libaom (AV1)

```
$ cd ~/ffmpeg_sources
$ git -C aom pull 2> /dev/null || git clone --depth 1 https://aomedia.googlesource.com/aom 
$ mkdir -p aom_build
$ cd aom_build
$ PATH="$HOME/bin:$PATH" cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="$HOME/ffmpeg_build" -DENABLE_TESTS=OFF -DENABLE_NASM=on ../aom
$ PATH="$HOME/bin:$PATH" make -j 8
$ make install
```

libsvtav1 (AV1)

```
$ cd ~/ffmpeg_sources 
$ git -C SVT-AV1 pull 2> /dev/null || git clone https://gitlab.com/AOMediaCodec/SVT-AV1.git 
$ mkdir -p SVT-AV1/build 
$ cd SVT-AV1/build 
$ PATH="$HOME/bin:$PATH" cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="$HOME/ffmpeg_build" -DCMAKE_BUILD_TYPE=Release -DBUILD_DEC=OFF -DBUILD_SHARED_LIBS=OFF ..
$ PATH="$HOME/bin:$PATH" make -j 8 
$ make install
```

libdav1d (AV1)

```
$ cd ~/ffmpeg_sources
$ git -C dav1d pull 2> /dev/null || git clone --depth 1 https://code.videolan.org/videolan/dav1d.git
$ mkdir -p dav1d/build
$ cd dav1d/build
$ meson setup -Denable_tools=false -Denable_tests=false --default-library=static .. --prefix "$HOME/ffmpeg_build" --libdir="$HOME/ffmpeg_build/lib"
$ ninja -j 8
$ ninja install
```

libvmaf

```
$ cd ~/ffmpeg_sources
$ wget https://github.com/Netflix/vmaf/archive/v2.1.1.tar.gz
$ tar xvf v2.1.1.tar.gz
$ mkdir -p vmaf-2.1.1/libvmaf/build
$ cd vmaf-2.1.1/libvmaf/build
$ meson setup -Denable_tests=false -Denable_docs=false --buildtype=release --default-library=static .. --prefix "$HOME/ffmpeg_build"  --libdir="$HOME/ffmpeg_build/lib"
$ ninja -j 8
$ ninja install
```

* NVENC/NVDEC (see https://docs.nvidia.com/video-technologies/video-codec-sdk/ffmpeg-with-nvidia-gpu/)

```
$ cd ~/ffmpeg_sources
$ git clone https://git.videolan.org/git/ffmpeg/nv-codec-headers.git
$ cd nv-codec-headers && sudo make install
```

* Download and compile ffmpeg: you need to use shared libraries (--enable-shared --enable-pic) to use with opencv
* 
NOTE:  
When the configure script of FFmpeg 4 checks nvcc, it uses compute  
capability of 30 (3.0) by default. CUDA 11, however, does not support  
compute capability 30.  

```
$ export ccap=86
$ cd ~/ffmpeg_sources
$ git clone https://github.com/FFmpeg/FFmpeg.git
$ cd FFmpeg
$ PATH="$HOME/bin:$PATH" PKG_CONFIG_PATH="$HOME/ffmpeg_build/lib/pkgconfig" ./configure \
 --prefix="$HOME/ffmpeg_build" \
 --extra-cflags="-I$HOME/ffmpeg_build/include" \
 --extra-ldflags="-L$HOME/ffmpeg_build/lib" \
 --extra-libs="-lpthread -lm" \
 --nvccflags="-gencode arch=compute_${ccap},code=sm_${ccap} -O2" \
 --ld="g++" \
 --bindir="$HOME/bin" \
 --enable-gpl \
 --enable-gnutls \
 --enable-libaom \
 --enable-libass \
 --enable-libfdk-aac \
 --enable-libfreetype \
 --enable-libmp3lame \
 --enable-libopus \
 --enable-libsvtav1 \
 --enable-libdav1d \
 --enable-libvorbis \
 --enable-libvpx \
 --enable-libx264 \
 --enable-libx265 \
 --enable-libnpp \
 --enable-cuda-nvcc \
 --enable-cuda \
 --enable-cuvid \
 --enable-nvdec \
 --enable-nvenc \
 --extra-cflags=-I/usr/local/cuda/include \
 --extra-ldflags=-L/usr/local/cuda/lib64 \
 --extra-cflags=-I/usr/local/cuda-11.7/targets/x86_64-linux/include \
 --extra-ldflags=-L/usr/local/cuda-11.7/targets/x86_64-linux/lib \
 --enable-nonfree \
 --enable-shared \
 --enable-pic
$ PATH="$HOME/bin:$PATH" make -j 12
$ sudo make install
```

* tell location of shared libraries to the system

```
$ sudo /bin/bash -c 'echo "$HOME/ffmpeg_build/lib" >> /etc/ld.so.conf.d/ffmpeg.conf'
$ sudo ldconfig
```
	
## OPENCV

* Generic tools:

```
$ sudo apt install build-essential cmake pkg-config unzip yasm git checkinstall
```
 
* Image I/O libs

``` 
$ sudo apt install libjpeg-dev libpng-dev libtiff-dev
``` 

* Video/Audio Libs -  GSTREAMER, x264 and so on.

```
$ sudo apt install libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev
$ sudo apt install libxvidcore-dev x264 libx264-dev libfaac-dev libmp3lame-dev libtheora-dev 
$ sudo apt install libfaac-dev libmp3lame-dev libvorbis-dev
```

* GTK lib for the graphical user functionalites coming from OpenCV highghui module 

```
$ sudo apt-get install libgtk-3-dev
```
    
* Python libraries for python3:

```
$ sudo apt-get install python3-dev python3-pip
$ sudo -H pip3 install -U pip numpy
$ sudo apt install python3-testresources
```
    
* Parallelism library C++ for CPU

```
$ sudo apt-get install libtbb-dev
```
    
* Optimization libraries for OpenCV

```
$ sudo apt-get install libatlas-base-dev gfortran
```
    
* Optional libraries:

```
$ sudo apt-get install libprotobuf-dev protobuf-compiler
$ sudo apt-get install libgoogle-glog-dev libgflags-dev
$ sudo apt-get install libgphoto2-dev libeigen3-dev libhdf5-dev doxygen
```

We will now proceed with the installation (see the Qt flag that is disabled to do not have conflicts with Qt5.0).

copy cuviddec.h, nvcuvid.h and nvEncodeAPI.h from the Video Codec SDK to /usr/local/cuda-11.7/include/ or /usr/local/cuda/include (Not sure which)

NOT SURE IF THIS IS NECESSARY. For some reason LIBAVCODEC_VERSION_INT is not properly detected, comment out the #if (LIBAVCODEC_VERSION_INT <= AV_VERSION_INT(54, 51, 100)) block in opencv-4.6.0/modules/videoio/src/ffmpeg_codecs.hpp

Add to opencv_contrib-4.6.0/modules/cudacodec/src/ffmpeg_video_source.cpp
```
case CV_FOURCC_MACRO('X', '2', '6', '4'): return H264;
```

```
$ cd ~/Downloads
$ wget -O opencv.zip https://github.com/opencv/opencv/archive/refs/tags/4.6.0.zip
$ wget -O opencv_contrib.zip  https://github.com/opencv/opencv_contrib/archive/refs/tags/4.6.0.zip

$ unzip opencv.zip
$ unzip opencv_contrib.zip

$ echo "Procced with the installation"
$ cd opencv-4.6.0
$ mkdir build
$ cd build

$ export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$HOME/ffmpeg_build/lib/
$ export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:$HOME/ffmpeg_build/lib/pkgconfig
$ export PKG_CONFIG_LIBDIR=$PKG_CONFIG_LIBDIR:$HOME/ffmpeg_build/lib/

$ cmake -D CMAKE_BUILD_TYPE=RELEASE \
-D CMAKE_INSTALL_PREFIX=/usr/local \
-D WITH_TBB=ON \
-D ENABLE_FAST_MATH=1 \
-D CUDA_FAST_MATH=1 \
-D WITH_CUBLAS=1 \
-D WITH_CUDA=ON \
-D WITH_FFMPEG=ON \
-D BUILD_opencv_cudacodec=ON \
-D CUDA_nvcuvid_LIBRARY=/usr/local/cuda/lib64/stubs/libnvcuvid.so \
-D WITH_CUDNN=ON \
-D CUDNN_INCLUDE_DIR=/usr/local/cuda/include \
-D CUDNN_LIBRARY=/usr/local/cuda/lib64/libcudnn.so \
-D OPENCV_DNN_CUDA=ON \
-D CUDNN_VERSION=8.4 \
-D CUDA_ARCH_BIN=8.6 \
-D WITH_V4L=ON \
-D WITH_QT=OFF \
-D WITH_NVCUVID=ON \
-D WITH_OPENGL=ON \
-D WITH_GSTREAMER=ON \
-D OPENCV_GENERATE_PKGCONFIG=ON \
-D OPENCV_PC_FILE_NAME=opencv.pc \
-D OPENCV_ENABLE_NONFREE=ON \
-D PYTHON_EXECUTABLE=/usr/bin/python3 \
-D PYTHON_DEFAULT_EXECUTABLE=/usr/bin/python3 \
-D OPENCV_PYTHON3_INSTALL_PATH=/usr/lib/python3/dist-packages \
-D OPENCV_PYTHON2_INSTALL_PATH=/usr/lib/python2.7/dist-packages \
-D OPENCV_EXTRA_MODULES_PATH=/home/martin/opencv_contrib-4.6.0/modules \
-D INSTALL_PYTHON_EXAMPLES=ON \
-D INSTALL_C_EXAMPLES=ON \
-D BUILD_EXAMPLES=OFF ..
```

To set the correct value of CUDA_ARCH_BIN you must visit https://developer.nvidia.com/cuda-gpus and find the Compute Capability CC of your graphic card)

Before the compilation you must check that CUDA and NVCUVID have been enabled in the configuration summary printed on the screen.

```
--   NVIDIA CUDA:                   YES (ver 11.7, CUFFT CUBLAS NVCUVID FAST_MATH)
--     NVIDIA GPU arch:             86
--     NVIDIA PTX archs:
-- 
--   cuDNN:                         YES (ver 8.4)

```

If it is fine proceed with the compilation (Use nproc to know the number of cpu cores):
    
```
$ nproc
$ make -j12
$ sudo make -j12 install
```

Include the libs in your environment
    
```
$ sudo /bin/bash -c 'echo "/usr/local/lib" >> /etc/ld.so.conf.d/opencv.conf'
$ sudo ldconfig
```

## How to use 

``` python
import os
import cv2
import time 
cv2.__version__

use_gpu = False
prev_frame_time = 0
curr_frame_time = 0

if use_gpu:
	os.environ["OPENCV_FFMPEG_CAPTURE_OPTIONS"]="video_codec;h264_cuvid"
	
cv2.namedWindow('Display')
cap = cv2.VideoCapture("/home/martin/Desktop/forEmi/2021_07_26_B.avi", cv2.CAP_FFMPEG)
while True:
    rval, frame = cap.read()
    new_frame_time = time.time()
    fps = 1/(new_frame_time-prev_frame_time)
    prev_frame_time = new_frame_time
    
    if not rval:
        break
    
    cv2.putText(frame,str(int(fps)), (7, 70), cv2.FONT_HERSHEY_SIMPLEX, 3, (100, 255, 0), 3, cv2.LINE_AA)
    cv2.imshow('Display',frame)
    
    key = cv2.waitKey(1)
    if key == ord('q'):
        break

cap.release()
cv2.destroyAllWindows():
```

```
python2.7 -m cProfile -s tottime test_opencv_hw.py
```
