# Validation of the motion control lab

Tested on 10 October 2026 using Windows 11, MATLAB R2026a Update 3
(26.1.0.3276743), Navigation Toolbox and Robotics System Toolbox 26.1.
Both product checks passed and the actual algorithms executed.
The final package was also executed from the course repository's
`alternative_lab` subfolder using the documented entry points. MATLAB
Code Analyzer reported zero messages across all 19 MATLAB source files.

## Connected baseline

The student workflow now has three stages: lidar mapping, one supporting
RRT route on the estimated map, and differential-drive feedback control.
`validate_lab(results)` passed **18/18 checks**, including a deliberately
unsafe reference that was stopped by the collision guard before accepting
a blocked robot pose.

| Baseline measurement | Observed result |
| --- | --- |
| Mapping scans accepted | 129/129 |
| Mapping position RMSE | 0.020660 m |
| Supporting RRT route | Motion valid, about 19.472 m |
| Control goal / collision status | Reached / no collision |
| Final goal distance | 0.14925 m, within 0.15 m tolerance |
| Tracking RMSE / maximum error | 0.012536 / 0.039570 m |
| Simulated travel time | 48.05 s |

## Main controller comparison

Both trials reused the same mapped environment and route, with desired
speed 0.4 m/s and sample period 0.05 s. Only lookahead changed.

| Lookahead | Goal reached | Collision detected | Tracking RMSE | Maximum error | Simulated time |
| --- | --- | --- | --- | --- | --- |
| 0.25 m | Yes | No | 0.0057904 m | 0.020364 m | 48.25 s |
| 0.80 m | Yes | No | 0.069244 m | 0.15826 m | 46.80 s |

The larger lookahead cut corners more and travelled a shorter path in this
experiment. These measurements describe this route and model rather than
guaranteeing the same ordering for every environment. Timing above is
simulated travel time, not MATLAB execution time. Selected CSV evidence
is included in `reference_results/`.

The checks cover scan acceptance/error, map reuse and unknown-space policy,
coordinate-frame consistency, route validity, goal arrival, tracking error,
wheel limits and conversions, sample-log alignment, footprint validity,
and the collision guard. The guard uses sampled poses during each RK4
integration step; this is a discrete simulation check, not a continuous
or real-world safety certificate. Control uses ideal simulated-pose feedback
after the map has been built; online localization is outside the exercise.

## Mac compatibility and release differences

The MATLAB package contains no Windows paths, shell commands, ROS,
compiled binaries, GPU requirements or external data downloads. Paths
use `fullfile` and are discovered from the source location. The
`controllerPurePursuit` property rename in R2026a is handled using `isprop`.
Its second output is interpreted as curvature and converted with
`omega=v*curvature`, in accordance with the [MathWorks version history](https://www.mathworks.com/help/robotics/ref/controllerpurepursuit-system-object.html).

Both required toolboxes are available on Mac. Native Apple-silicon MATLAB
is available from R2023b; R2025b is the final Intel Mac release. Follow
[MathWorks Mac requirements](https://www.mathworks.com/support/requirements/apple-silicon.html)
for the chosen MATLAB release and macOS. A physical Mac has not been
tested in this session. Run `validate_lab` on a representative student Mac
before class; this distinction also applies to the earliest supported release.

The local R2025b installation lacks the required toolboxes and therefore
stops at the environment diagnostic. The full execution pass is on R2026a.
No installation or user MATLAB preferences were changed.

The revised Word handout has four pages, branch-specific Git commands,
editable text/tables and a small submission checklist. It is rendered and
visually reviewed before publication. The earlier eight-page lab is not part
of this student branch.
