# DASE4136 Robot Motion Control Using a Lidar Map

A 90-minute MATLAB lab centered on differential-drive robot feedback control.
Students build a lidar SLAM map, generate one supporting RRT route on that map,
and control a robot along the route. The main exercise compares two pure
pursuit look-ahead settings on the **same map and route**.

The editable student sheet is [docs/DASE4136_MATLAB_Lab_Sheet.docx](docs/DASE4136_MATLAB_Lab_Sheet.docx).
Kalman filtering and standalone planning comparisons are outside this lab.

## Download from the course repository

Run in Terminal, PowerShell or Git Bash:

```sh
git clone -b alternative_lab https://github.com/SAS-HKU/DASE4136_student.git
cd DASE4136_student/alternative_lab
```

If Git is unavailable, [download the branch ZIP](https://github.com/SAS-HKU/DASE4136_student/archive/refs/heads/alternative_lab.zip),
extract it, and open the `alternative_lab` subfolder in MATLAB. Students do
not need to run the repository's ROS setup script for this MATLAB lab.

## MATLAB on Mac or Windows

Use MATLAB R2023b or newer, **Navigation Toolbox** and **Robotics System
Toolbox**, all installed and licensed. On Apple silicon use native MATLAB
R2023b or newer. Intel Mac users need a supported Intel release from R2023b
through R2025b. Follow MathWorks' requirements for your macOS and MATLAB
release. No ROS, Simulink, GPU, compiler or robot hardware is required.

Set MATLAB Current Folder to `DASE4136_student/alternative_lab`, containing
`lab_config.m`, then run:

```matlab
setup_lab;
results = run_all;
summary = run_experiments(results.planning);
```

`run_all` creates the map, route, animated robot run and result files.
The comparison reuses the same route and tests lookahead 0.25 m and 0.8 m.
Set `cfg.visible = 'off'` for a nonanimated batch run; exported plots remain.

## Main outputs and exercise

- `output/baseline/slam.png`: mapping result.
- `output/baseline/route.png`: supporting route on the estimated map.
- `output/baseline/control_trajectory.png`: actual robot trajectory and footprint.
- `output/baseline/control_signals.png`: tracking error, speed and wheel commands.
- `output/baseline/control_metrics.csv`: reach status, tracking error and simulated time.
- `output/experiments/comparison.csv`: two look-ahead trials.

Predict what look-ahead distance will change, compare the two runs, and
explain the difference between a valid route and successfully following it.
Submit a 1-2 page report, the two control plots per trial, the comparison CSV
and your experiment script. Full instructions are in the Word sheet.

Each run replaces files with the same names in its output folder. Preserve
additional trials by setting `cfg.outputDir` to a new `fullfile` path.

## Code to inspect

| File | Purpose |
| --- | --- |
| `run_all.m` | Connected map -> route -> control workflow |
| `run_slam.m` | Locally generated scans and lidar mapping |
| `run_planning.m` | One supporting RRT route on that map |
| `run_control.m` | Feedback, wheel commands, robot model and collision guard |
| `lab_config.m` | Controller parameters and SI units |
| `run_experiments.m` | Two runs sharing the same map/path |
| `exercises/student_exercises.m` | Short student workspace |
| `validate_lab.m` | Baseline and collision-guard validation |

## Modeling assumptions

The mapping stage is completed before the robot driving simulation. Ground
truth generates/evaluates the scans but is never passed to `addScan`. During
driving, the true simulated pose is supplied as feedback; online localization
is outside this control exercise. All navigation uses the SLAM first-scan
frame. Only observed free cells are traversable; unknown cells are blocked.

The planner inflates obstacles by the robot radius plus a safety margin.
The controller independently checks the actual robot footprint at sampled
poses along each integration step, and stops before accepting a blocked
motion. This guard is a collision detector, not an obstacle-avoidance
controller. RRT finds a feasible route rather than a guaranteed shortest one.
The controller stops on goal position tolerance; final heading is not regulated.

The controller's second output is curvature, converted using `omega = v*curvature`.
MATLAB R2026a renamed `MaxAngularVelocity` to `MaxCurvature` without changing
behavior; `+lab/pursuit_controller.m` handles both property names.

## Validation and references

Run `validate_lab(results)` to check an existing baseline, or `validate_lab`
to create a fresh run. See [docs/VALIDATION.md](docs/VALIDATION.md) for actual
Windows results and the Mac portability review. Exact paths and timings
can differ across MATLAB releases and machines.

- [MathWorks mobile robot kinematics example](https://ww2.mathworks.cn/help/robotics/ug/simulate-different-kinematic-models-for-mobile-robots.html)
- [MathWorks lidar SLAM example](https://ww2.mathworks.cn/help/nav/ug/implement-simultaneous-localization-and-mapping-with-lidar-scans.html)
- [MathWorks RRT example](https://ww2.mathworks.cn/help/nav/ug/plan-mobile-robot-paths-using-rrt.html)
- [Pure pursuit reference and version history](https://www.mathworks.com/help/robotics/ref/controllerpurepursuit-system-object.html)
- [MATLAB on Apple Silicon and Intel Mac release support](https://www.mathworks.com/support/requirements/apple-silicon.html)

Lecture connections: D5 pages 2-7 (kinematics/odometry), D7 pages 2-6
(sensor observations) and D8 pages 7-8, 22 (motion planning, feedback control
and vehicle constraints). Slide assignments are separate from this lab.
Lecture PDFs and MathWorks assets are not redistributed.
