# ROS Virtual Environment Setup

This setup is for the DASE4136 simulation labs on **Ubuntu 22.04 (Jammy), amd64 (Intel/AMD)**, including a virtual machine on an Intel/AMD computer. Run the commands inside Ubuntu as your normal user with sudo access and an internet connection.

## Check the platform first

```bash
dpkg --print-architecture
lsb_release -ds
```

The required outputs are `amd64` and Ubuntu 22.04. If the architecture is `arm64`, use an Intel/AMD lab computer or remote desktop into an Ubuntu 22.04 amd64 machine for this lab. Run both the installer and Gazebo on that machine; an SSH terminal alone does not provide the graphical Gazebo desktop.

ROS 2 Humble itself supports ARM64, but the standard Jammy repositories do not provide the Gazebo Classic and ROS simulation binaries needed for Step 16 on ARM64. [Gazebo's official installation notes](https://get.gazebosim.org/tutorials?tut=install_ubuntu) document this limitation. Reinstalling ROS in the same ARM64 VM does not fix it. The installer now stops on unsupported architectures before making changes.

## New installation

Open a terminal and run these commands in order:

```bash
sudo apt update &&
sudo apt install -y git &&
git clone https://github.com/SAS-HKU/DASE4136_student.git &&
cd DASE4136_student &&
git checkout setup &&
bash setup_dase4136.sh &&
source ~/.bashrc
```

Run the script without a leading `sudo`; it requests sudo when installing system packages. Installation may take some time because it downloads ROS 2 and simulation packages. Continue only after each command succeeds.

Use the [`setup` branch](https://github.com/SAS-HKU/DASE4136_student/tree/setup) for installation. Older lab handouts may refer to `DASE7505_student` or `setup_dase7505.sh`. For DASE4136, use the repository and script named above.

## Existing checkout or a previous failed installation

From inside your existing `DASE4136_student` directory, run:

```bash
git fetch origin &&
git checkout setup &&
git pull --ff-only origin setup &&
bash setup_dase4136.sh &&
source ~/.bashrc
```

If Git reports local changes, save or commit your edits before updating. A previous failed Waterloo download does not require deleting the repository or reinstalling Ubuntu; rerun the updated script.

### Missing `.fastdds.xml` after a previous installation attempt

If an old script prints `already made the glone` and then `cp: cannot stat .../robohub/turtlebot4/configs/.fastdds.xml`, it has stopped at the obsolete Waterloo configuration step. The folder check does not prove that the earlier clone succeeded. The corrected `setup_dase4136.sh` does not perform this copy.

On Ubuntu 22.04 **amd64**, if ROS 2 and Fast DDS have already installed successfully as shown before this error, finish the remaining package installations with:

```bash
sudo apt update &&
sudo apt install -y ros-humble-turtlebot4-desktop gazebo \
  ros-humble-gazebo-ros-pkgs ros-humble-turtlebot3 ros-humble-turtlebot3-gazebo &&
source ~/.bashrc
```

Then run the verification commands below. No Waterloo account or XML download is required.

## Installed packages and verification

The script installs ROS 2 Humble Desktop, ROS development tools, Fast DDS, TurtleBot4 desktop packages, TurtleBot3, and the required Gazebo Classic simulation packages by explicit name. It no longer downloads the Waterloo repository or copies its `.fastdds.xml` file; that custom communication profile is not required for local simulation.

Older versions used a wildcard that could install available TurtleBot3 packages without the simulator and still print a success message. The updated installer verifies the Gazebo executable, setup files, ROS packages, and the TurtleBot3 house launch file before reporting that the required packages are verified. This does not test the VM's graphics or a running simulation.

After installation, check that ROS can find the packages:

```bash
source /opt/ros/humble/setup.bash &&
ros2 pkg prefix turtlebot3_gazebo &&
ros2 pkg prefix gazebo_ros &&
ros2 pkg prefix turtlebot4_desktop
```

Each package check should print an installed package path. Then run the Step 16 test in the graphical desktop of the supported machine:

```bash
source /opt/ros/humble/setup.bash &&
source /usr/share/gazebo/setup.sh &&
export TURTLEBOT3_MODEL=burger &&
ros2 launch turtlebot3_gazebo turtlebot3_house.launch.py
```

If a setup file or package is missing, stop and check the platform and installer error before continuing. TurtleBot4 desktop packages do not include the TurtleBot4 simulator. If an exercise specifically requires TurtleBot4 simulation, follow the Humble instructions in the [official TurtleBot4 simulator guide](https://turtlebot.github.io/turtlebot4-user-manual/software/turtlebot4_simulator.html).

## Remarks

### Ubuntu version

The supported platform for these lab exercises is Ubuntu 22.04 amd64 with ROS 2 Humble. The script exits on other Ubuntu releases or architectures before installing anything.

### For Mac users

On an Intel Mac, use an Ubuntu 22.04 amd64 VM and verify graphics support with Step 16. On Apple Silicon (M-series), a native Ubuntu VM is ARM64 and does not meet this lab's Gazebo Classic binary requirements. Use an Intel/AMD lab PC or remote desktop to an Ubuntu 22.04 amd64 machine. Keep the existing ARM64 VM and coursework; no uninstall is needed.

This repository contains the lab sheets and related resources for lab sessions available to students taking DASE4136, taught by Prof. Chen Sun. <br />
The ROS installation instructions and setup script are on the `setup` branch. Hands-on lab materials are available in the `Mapping` and `Navigation` branches; switch to the relevant branch to access its materials.

The hands-on lab sessions for this course include:
- ROS Virtual Machine Setups and basic operations
- Localization and Mapping in selected environments around campus using ROS2 robotic platforms
- Navigation using different path planning algorithms
- Feedback control trial in MATLAB and ROS 

### This repo is under continuous updating. Any technical issues, bugs found, and constructive feedback, please contact Teaching Assistant via email: peterwang.dase@connect.hku.hk
