function report = validate_lab(results)
%VALIDATE_LAB Verify the connected baseline and the controller's safety guard.
root = setup_lab();
if nargin < 1
    cfg = lab_config(); cfg.visible = 'off'; results = run_all(cfg);
end
cfg = results.cfg; cfg.visible = 'off';
cfg.outputDir = fullfile(root,'output','validation'); lab.prepare(cfg);
labels = {}; passed = [];
m = results.mapping; route = results.planning; control = results.control;
check(all(isfinite(m.poses(:))), 'SLAM poses are finite');
check(m.metrics.AcceptedScans>=0.8*m.metrics.InputScans, 'SLAM accepts the baseline scans');
check(m.metrics.PositionRMSE_m<0.5, 'Estimated map trajectory has acceptable baseline error');
check(isequal(occupancyMatrix(route.freeMap), ...
    double(occupancyMatrix(m.map)>=m.map.FreeThreshold)), ...
    'Planning uses the SLAM map and blocks unknown cells');
check(isequal(route.freeMap.GridLocationInWorld,m.map.GridLocationInWorld), ...
    'Mapping and navigation share the same coordinate frame');
check(route.success && route.pathValid, 'RRT returns a motion-valid supporting route');
check(route.goalPositionError<0.1, 'Route reaches the requested goal region');
check(control.metrics.ReachedGoal && ~control.metrics.CollisionDetected, ...
    'Baseline controller reaches the goal without a collision guard stop');
check(control.metrics.FinalGoalDistance_m<=cfg.control.goalTolerance, ...
    'Final control position satisfies the stopping tolerance');
check(control.metrics.TrackingRMSE_m<0.1, 'Baseline tracking RMSE is below 0.1 m');
cmd = control.commands; state = control.states; p = cfg.control;
check(all(abs([cmd.LeftWheel_rad_s;cmd.RightWheel_rad_s])<=p.wheelLimit+1e-12), ...
    'Applied wheel speeds obey the limit');
check(all(abs(cmd.RequestedHeadingRate_rad_s-cmd.RequestedSpeed_m_s.*cmd.Curvature_1_m)<1e-12), ...
    'Controller curvature is converted to heading rate');
check(all(abs(cmd.ActualSpeed_m_s-p.wheelRadius*(cmd.LeftWheel_rad_s+cmd.RightWheel_rad_s)/2)<1e-12), ...
    'Wheel speeds produce the recorded vehicle speed');
check(all(abs(cmd.ActualHeadingRate_rad_s-p.wheelRadius*(cmd.RightWheel_rad_s-cmd.LeftWheel_rad_s)/p.trackWidth)<1e-12), ...
    'Wheel speeds produce the recorded heading rate');
check(height(state)==height(cmd)+1 && all(abs(diff(state.Time_s)-p.dt)<1e-10), ...
    'Command and state logs have consistent sample times');
ss = stateSpaceSE2([control.collisionMap.XWorldLimits;control.collisionMap.YWorldLimits;-pi pi]);
v = validatorOccupancyMap(ss); v.Map = control.collisionMap; v.ValidationDistance = 0.01;
check(all(isStateValid(v,control.poses)), 'Recorded robot poses are footprint-valid on the map');

% A deliberately unsafe reference verifies that a valid-looking route flag
% cannot hide a controller collision. Unknown and occupied cells stay blocked.
unsafe = route; unsafe.states = [0 0 0;6 3 0]; unsafe.goal = [6 3 0];
cfg.outputDir = fullfile(root,'output','validation','collision_guard');
guard = run_control(unsafe,cfg);
check(guard.metrics.CollisionDetected && ~guard.metrics.ReachedGoal, ...
    'Unsafe reference is stopped by the collision guard');
check(all(isStateValid(v,guard.poses)), 'Collision guard does not accept a blocked pose');
report = table(labels',logical(passed'),'VariableNames',{'Check','Passed'});
writetable(report,fullfile(root,'output','validation','validation_checks.csv'));
disp(report); fprintf('PASS: %d/%d checks.\n',height(report),height(report));
    function check(condition,label)
        assert(condition,'DASE4136:Validation','Validation failed: %s',label);
        labels{end+1} = label; passed(end+1) = true;
    end
end
