# Instructor notes

The lab is designed for 90 minutes: setup 10, mapping and supporting route
20, motion control 30, controller comparison and report 30. The editable
sheet is four pages. The main learning task is following a route on the
estimated map with differential-drive feedback control. No scalar KF task
or planner parameter sweep is required.

Students run the connected baseline, identify the feedback loop in
`run_control.m`, calculate wheel speeds for one requested command, then
compare lookahead 0.25 and 0.8 m. The same map and route are reused, so changes
in tracking are not confounded by SLAM or random planning changes. Report
tracking RMSE, maximum tracking error, simulated travel time, final goal
distance and reach/collision status. A failed trial remains useful evidence.

The controller maps curvature to heading rate using `omega=v*curvature`,
then computes left/right wheel angular speeds. Wheel speeds are clipped
to the limit before the differential-drive plant is integrated. The
collision guard checks the actual footprint on the estimated map and stops
before accepting a blocked state. It does not steer around obstacles.

This is a simulation with ideal pose feedback. Mapping is offline, and the
simulator's fixed-heading survey can translate omnidirectionally. Driving
uses differential-drive kinematics. Neither the map nor the collision guard
is claimed to certify safety in the real environment. The planning margin
is additional to the physical robot radius used by the collision check.

MATLAB R2026a renamed the pure pursuit output and maximum-curvature property
without changing behavior. The helper chooses the property name using
`isprop`, and interprets the second output as curvature in all supported
releases. This avoids treating curvature as rad/s on older installations.

Suggested assessment: correct baseline and wheel-speed calculation 30%,
fair controller comparison and plots 40%, explanation and reproducibility
30%. The sheet does not introduce a deadline or inherit assignments from
the lecture slides. PDF page numbers include the title slide.

Before class, run `validate_lab` on a representative student Mac with both
toolboxes. The lab has been executed on this Windows PC; Mac compatibility
is reviewed against supported MATLAB APIs and platform requirements.
