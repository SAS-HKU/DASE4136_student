# ROS Virtual Environment Setup

This setup is for the DASE4136 simulation labs on Ubuntu 22.04 (Jammy), including an Ubuntu virtual machine. Run the commands inside Ubuntu as your normal user with sudo access and an internet connection.

## New installation

Open a terminal and run these commands in order:

```bash
sudo apt update
sudo apt install -y git
git clone --branch setup https://github.com/SAS-HKU/DASE4136_student.git
cd DASE4136_student
bash setup_dase4136.sh
source ~/.bashrc
```

Run the script without a leading `sudo`; it requests sudo when installing system packages. Installation may take some time because it downloads ROS 2 and simulation packages. Continue only after each command succeeds.

## Existing checkout or a previous failed installation

From inside your existing `DASE4136_student` directory, run:

```bash
git checkout setup
git pull --ff-only origin setup
bash setup_dase4136.sh
source ~/.bashrc
```

If Git reports local changes, save or commit your edits before updating. A previous failed Waterloo download does not require deleting the repository or reinstalling Ubuntu; rerun the updated script.

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
![DASE](/assests/DASE.png)
# DASE4136 Intelligent Transportation and Autonomous Driving 
## (BEng in DASE course, starting 2026 Spring)
## Department of Data and Systems Engineering, The University of Hong Kong
This repository contains the lab sheets and related resources for lab sessions available to students taking DASE4136, taught by Prof. Chen Sun. <br />
In this repository, various hands-on lab exercises are available in different branches (e.g., setup, Mapping). You may change the branch to the respective exercises and access the materials. In each branch, the lab instruction sheet in pdf is also available for downloading apart from the readme instructions.

The hands-on lab sessions for this course include:
- ROS Virtual Machine Setups and basic operations
- Localization and Mapping in selected environments around campus using ROS2 robotic platforms
- Navigation using different path planning algorithms
- Feedback control trial in MATLAB and ROS 

### This repo is under continuous updating. Any technical issues, bugs found, and constructive feedback, please contact Teaching Assistant via email: peterwang.dase@connect.hku.hk
