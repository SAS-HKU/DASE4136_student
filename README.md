# DASE4136 Intelligent Transportation and Autonomous Driving 
## Lab: Localization and Mapping with LIMO and MentorPi
In this lab, you will have the experiences of using LIMO and MentorPi (robotic platforms powered by ROS2) to localize themselves and conduct mapping through keyboard/joystick control

# Introduction
Before heading to a destination, whether we have a map or not, we certainly need to know our current location. Humans achieve this through eyes, while robots use sensors like LiDAR and camera. SLAM refers to Simultaneous Localization and Mapping.
- Localization is determining the position and orientation (pose) of the robot body within a coordinate system. The origin and orientation of the coordinate system can be obtained from the first keyframe, an existing global map or landmark points, or GPS.
- Mapping refers to creating a map of the environment perceived by the robot. The basic geometric elements of the map are points. The main purposes of the map are localization and navigation. Navigation can be broken down into guidance and motion: guidance includes global planning and local planning, and motion refers to controlling the robot's movement after the plan is made.

## Core Mapping Process
- Preprocessing: Raw LiDAR point cloud data is filtered and optimized. A laser pulse reflects off obstacles; the measured return time calculates distances, generating a set of 3D points (a point cloud) representing the immediate surroundings.
- Matching: The current local point cloud is aligned (matched) against the existing global map. This comparison calculates the robot's relative movement, updating its estimated pose.
- Fusion: The newly processed and matched data is integrated into the global map, incrementally expanding and refining it.

## Map Quality Evaluation
A usable map must have: clear obstacle boundaries; consistency with the real environment (proper loop closures); no unscanned "gray" zones in operational areas; minimal artifacts from transient objects (e.g., people); and full perceptual coverage from any point within the active region.

# Step-by-step Instructions:


## Demonstration of RTAB mapping:
[![Watch the demo](https://i9.ytimg.com/vi/D1kEoad1aVk/mq2.jpg?sqp=CPji_csG-oaymwEmCMACELQB8quKqQMa8AEB-AHUBoAC4AOKAgwIABABGGUgZShlMA8=&rs=AOn4CLDrAZt6JgY2sK5EMefUHxxCmuVrHg)](https://youtu.be/D1kEoad1aVk)
