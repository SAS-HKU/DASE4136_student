#!/bin/sh

set -e

# The lab's Gazebo Classic binaries are available only for Ubuntu Jammy amd64.
# Check before changing packages or shell configuration.
architecture=$(dpkg --print-architecture)
if [ "$architecture" != "amd64" ]; then
    echo "ERROR: This Gazebo Classic simulation lab requires amd64 (Intel/AMD)." >&2
    echo "Detected architecture: $architecture. ROS 2 Humble can run on ARM64," >&2
    echo "but the standard Jammy repositories lack this lab's ARM64 simulator packages." >&2
    echo "Keep your current VM and use an Ubuntu 22.04 Intel/AMD lab PC or remote desktop." >&2
    echo "Reinstalling ROS in the same ARM64 VM will not resolve this." >&2
    exit 1
fi

if [ ! -r /etc/os-release ]; then
    echo "ERROR: Run this installer inside Ubuntu 22.04 (Jammy)." >&2
    exit 1
fi
. /etc/os-release
if [ "${ID:-}" != "ubuntu" ] || [ "${VERSION_ID:-}" != "22.04" ]; then
    echo "ERROR: This installer requires Ubuntu 22.04 (Jammy)." >&2
    exit 1
fi

echo "....installing ros2 humble...."

sleep 2

sudo apt update
sudo apt install -y git wget vim build-essential
sudo apt install -y lsb-core lsb-release
sudo apt-get install -y net-tools iputils-ping

sleep 1

sudo apt install -y locales
sudo locale-gen en_US en_US.UTF-8
sudo update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8

export LANG=en_US.UTF-8

locale
echo "--------------------------------"
echo "....locales configs successful!...."
echo "--------------------------------"

sudo apt install -y software-properties-common
sudo add-apt-repository --yes universe


sudo apt update && sudo apt install curl -y

sudo curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | sudo tee /etc/apt/sources.list.d/ros2.list > /dev/null

sudo apt update

sudo apt install -y ros-humble-desktop

echo "--------------------------------"
echo "....ros successfully installed...."
echo "--------------------------------"

sleep 1

sudo apt install -y ros-dev-tools


ros_bashrc_line="source /opt/ros/humble/setup.bash"

if ! grep -qF "$ros_bashrc_line" /home/$USER/.bashrc ; then echo "$ros_bashrc_line" >> /home/$USER/.bashrc ; fi

tb3_bashrc_line="export TURTLEBOT3_MODEL=burger"

if ! grep -qF "$tb3_bashrc_line" /home/$USER/.bashrc ; then echo "$tb3_bashrc_line" >> /home/$USER/.bashrc ; fi

echo "--------------------------------"
echo "....ros env successfully set!...."
echo "--------------------------------"

sleep 1


# Local simulation uses the standard ROS packages below.
# No Waterloo checkout or custom Fast DDS profile is needed.

sudo apt install -y ros-humble-rmw-fastrtps-cpp

sleep 1

sudo apt install -y ros-humble-turtlebot4-desktop

sleep 1

sudo apt install -y gazebo ros-humble-gazebo-ros-pkgs \
    ros-humble-turtlebot3 ros-humble-turtlebot3-gazebo

# Verify the files and packages used by the lab's Step 16 before reporting success.
if ! command -v gazebo >/dev/null 2>&1 || [ ! -r /usr/share/gazebo/setup.sh ]; then
    echo "ERROR: Gazebo Classic is missing; simulation setup is incomplete." >&2
    exit 1
fi
if [ ! -r /opt/ros/humble/setup.sh ]; then
    echo "ERROR: ROS 2 Humble setup.sh is missing; setup is incomplete." >&2
    exit 1
fi
. /opt/ros/humble/setup.sh
for package in turtlebot3_gazebo gazebo_ros turtlebot4_desktop; do
    if ! ros2 pkg prefix "$package"; then
        echo "ERROR: Required ROS package $package is missing; setup is incomplete." >&2
        exit 1
    fi
done
turtlebot3_prefix=$(ros2 pkg prefix turtlebot3_gazebo)
if [ ! -r "$turtlebot3_prefix/share/turtlebot3_gazebo/launch/turtlebot3_house.launch.py" ]; then
    echo "ERROR: The Step 16 TurtleBot3 house launch file is missing." >&2
    exit 1
fi

echo "--------------------------------"
echo "Required ROS and Gazebo Classic packages verified."
echo "--------------------------------"
echo "Open a new terminal or run: source ~/.bashrc"
echo "Then run the Step 16 simulation test to check graphics and runtime behavior."
