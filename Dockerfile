# Base image: Ubuntu 20.04 (Focal Fossa) for ROS Noetic
FROM ubuntu:20.04

# Avoid interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

ENV CATKIN_WS=/catkin_ws

# Set up locales
RUN apt-get update && apt-get install -y bash locales \
    && locale-gen en_US.UTF-8 \
    && update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 \
    && rm -rf /var/lib/apt/lists/*

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Add the ROS repository
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget unzip git build-essential cmake ca-certificates gnupg lsb-release\
    libusb-1.0-0-dev libgtk-3-dev udev sudo \
    curl ca-certificates gnupg  iputils-ping  v4l-utils libspdlog-dev \
    libxcb-cursor0 cmake \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* 


# Download the ROS GPG key and store it in the keyring directory
RUN curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg
# Add the ROS repository, referencing the GPG key
RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list

# Install ROS Noetic Desktop Full
RUN apt-get update && apt-get install -y --no-install-recommends \
    ros-noetic-desktop-full \
    ros-noetic-usb-cam \
    ros-noetic-image-transport \
    ros-noetic-camera-info-manager \
    ros-noetic-dynamic-reconfigure \
    ros-noetic-cv-bridge \
    ros-noetic-roslint \
    ros-noetic-tf2-eigen \
    ros-noetic-pcl-conversions \
    ros-noetic-tf2-ros \
    ros-noetic-diagnostic-updater \
    libspdlog-dev  \
    libeigen3-dev \
    libpcl-dev \
    ros-noetic-cv-bridge \
    python3-rosdep \
    python3-rosinstall \
    python3-rosinstall-generator \
    python3-wstool \
    python3-catkin-tools \
    && rm -rf /var/lib/apt/lists/*



WORKDIR $CATKIN_WS
COPY tmp/usr/include/m3api/* /usr/include/m3api/
COPY tmp/usr/lib/* /usr/lib/

# Initialize rosdep
RUN rosdep init && rosdep update


# Source ROS environment in .bashrc
RUN echo "source /opt/ros/noetic/setup.bash" >> ~/.bashrc

# Set a working directory (optional)
WORKDIR $CATKIN_WS

# Default command (optional, provides a bash shell)
CMD ["/bin/bash"]