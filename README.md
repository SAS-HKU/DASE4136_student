# ROS Virtual Environment Setup

This setup is for the DASE4136 simulation labs on Ubuntu 22.04 (Jammy), including an Ubuntu virtual machine. Run the commands inside Ubuntu as your normal user with sudo access and an internet connection.

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

For the simulation-only setup, if ROS 2 and Fast DDS have already installed successfully as shown before this error, finish the remaining package installations with:

```bash
sudo apt update &&
sudo apt install -y ros-humble-turtlebot4-desktop 'ros-humble-turtlebot3*' &&
source ~/.bashrc
```

Then run the verification commands below. No Waterloo account or XML download is required.

## Installed packages and verification

The script installs ROS 2 Humble Desktop, ROS development tools, Fast DDS, TurtleBot4 desktop packages, and TurtleBot3 packages for the simulation exercises. It no longer downloads the Waterloo repository or copies its `.fastdds.xml` file; that custom communication profile is not required for local simulation.

After installation, check that ROS can find the packages:

```bash
ros2 pkg prefix turtlebot3_gazebo
ros2 pkg prefix turtlebot4_desktop
```

Each command should print an installed package path. TurtleBot4 desktop packages do not include the TurtleBot4 simulator. If an exercise specifically requires TurtleBot4 simulation, follow the Humble instructions in the [official TurtleBot4 simulator guide](https://turtlebot.github.io/turtlebot4-user-manual/software/turtlebot4_simulator.html).

## Remarks

### Ubuntu version

The supported version for these lab exercises is Ubuntu 22.04 with ROS 2 Humble. The script exits on other Ubuntu releases.

### For Mac users

Try this link for setting up Ubuntu on Mac OS: https://medium.com/@MinghaoNing/how-to-set-up-vmware-ubuntu-22-ros2-and-gazebo-on-arm64-like-apple-silicon-or-jetson-5bb4db6ff297

# DASE4136 Intelligent Transportation and Autonomous Driving 
## (BEng in DASE course, starting 2026 Spring)
## Department of Data and Systems Engineering, The University of Hong Kong
This repository contains the lab sheets and related resources for lab sessions available to students taking DASE4136, taught by Prof. Chen Sun. <br />
The ROS installation instructions and setup script are on the `setup` branch. Hands-on lab materials are available in the `Mapping` and `Navigation` branches; switch to the relevant branch to access its materials.

The hands-on lab sessions for this course include:
- ROS Virtual Machine Setups and basic operations
- Localization and Mapping in selected environments around campus using ROS2 robotic platforms
- Navigation using different path planning algorithms
- Feedback control trial in MATLAB and ROS 

### This repo is under continuous updating. Any technical issues, bugs found, and constructive feedback, please contact Teaching Assistant via email: peterwang.dase@connect.hku.hk
