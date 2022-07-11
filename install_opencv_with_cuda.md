# How to install OpenCV with CUDA and CUDNN in Ubuntu 20.04

First of all install update and upgrade your system:
    
        $ sudo apt update
        $ sudo apt upgrade
   

* NVIDIA CUDA

https://developer.nvidia.com/cuda-downloads

check https://docs.nvidia.com/cuda/cuda-installation-guide-linux/index.html#post-installation-actions
  
    $ export PATH=/usr/local/cuda-11.7/bin${PATH:+:${PATH}}
    $ export LD_LIBRARY_PATH=/usr/local/cuda-11.7/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}
    
* NVIDIA CUDNN

https://developer.nvidia.com/rdp/cudnn-download

* NVIDIA Video Codec SDK

https://developer.nvidia.com/nvidia-video-codec-sdk/download

Then, install required libraries:

* Generic tools:

        $ sudo apt install build-essential cmake pkg-config unzip yasm git checkinstall
    
* Image I/O libs
    ``` 
    $ sudo apt install libjpeg-dev libpng-dev libtiff-dev
    ``` 
* Video/Audio Libs - FFMPEG, GSTREAMER, x264 and so on.
    ```
    $ sudo apt install libavcodec-dev libavformat-dev libswscale-dev libavresample-dev
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

    $ cd ~/Downloads
    $ wget -O opencv.zip https://github.com/opencv/opencv/archive/refs/tags/4.6.0.zip
    $ wget -O opencv_contrib.zip  https://github.com/opencv/opencv_contrib/archive/refs/tags/4.6.0.zip

    $ unzip opencv.zip
    $ unzip opencv_contrib.zip
    
    $ echo "Procced with the installation"
    $ cd opencv-4.5.2
    $ mkdir build
    $ cd build
    
    cmake -D CMAKE_BUILD_TYPE=RELEASE \
	-D CMAKE_INSTALL_PREFIX=/usr/local \
	-D WITH_TBB=ON \
	-D ENABLE_FAST_MATH=1 \
	-D CUDA_FAST_MATH=1 \
	-D WITH_CUBLAS=1 \
	-D WITH_CUDA=ON \
	-D BUILD_opencv_cudacodec=ON \
	-D WITH_CUDNN=ON \
	-D CUDNN_INCLUDE_DIR=/usr/local/cuda/include \
	-D CUDNN_LIBRARY=/usr/local/cuda/lib64/libcudnn.so \
	-D OPENCV_DNN_CUDA=ON \
	-D CUDNN_VERSION=8.4 \
	-D CUDA_ARCH_BIN=8.6 \
	-D WITH_V4L=ON \
	-D WITH_QT=OFF \
	-D WITH_OPENGL=ON \
	-D WITH_GSTREAMER=ON \
	-D OPENCV_GENERATE_PKGCONFIG=ON \
	-D OPENCV_PC_FILE_NAME=opencv.pc \
	-D OPENCV_ENABLE_NONFREE=ON \
	-D PYTHON_EXECUTABLE=/usr/bin/python3 \
	-D PYTHON_DEFAULT_EXECUTABLE=/usr/bin/python3 \
	-D OPENCV_PYTHON3_INSTALL_PATH=/usr/lib/python3/dist-packages \
	-D OPENCV_PYTHON3_INSTALL_PATH=/usr/lib/python2.7/dist-packages \
	-D OPENCV_EXTRA_MODULES_PATH=/home/martin/opencv_contrib-4.6.0/modules \
	-D INSTALL_PYTHON_EXAMPLES=ON \
	-D INSTALL_C_EXAMPLES=ON \
	-D BUILD_EXAMPLES=OFF ..
	
To set the correct value of CUDA_ARCH_BIN you must visit https://developer.nvidia.com/cuda-gpus and find the Compute Capability CC of your graphic card)

Before the compilation you must check that CUDA has been enabled in the configuration summary printed on the screen. (If you have problems with the CUDA Architecture go to the end of the document).

```
--   NVIDIA CUDA:                   YES (ver 11.2, CUFFT CUBLAS FAST_MATH)
--     NVIDIA GPU arch:             75
--     NVIDIA PTX archs:
-- 
--   cuDNN:                         YES (ver 8.2.0)

```

If it is fine proceed with the compilation (Use nproc to know the number of cpu cores):
    
    $ nproc
    $ make -j8
    $ sudo make install

Include the libs in your environment
    
    $ sudo /bin/bash -c 'echo "/usr/local/lib" >> /etc/ld.so.conf.d/opencv.conf'
    $ sudo ldconfig

