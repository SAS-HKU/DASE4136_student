function result = run_control(planning,cfg)
%RUN_CONTROL Follow a mapped route using feedback, wheel commands and a plant.
% This teaching simulation supplies the true simulated pose as feedback;
% it studies motion control, not online localization while driving.
if nargin < 2, cfg = lab_config(); end
lab.prepare(cfg); p = cfg.control;
assert(planning.success && planning.pathValid,'DASE4136:Route', ...
    'Motion control requires a valid planned route.');
assert(p.speed>0 && p.lookahead>0 && p.dt>0 && p.wheelLimit>0, ...
    'DASE4136:ControlParameters','Control speed, lookahead, dt and wheel limit must be positive.');
path = planning.states(:,1:2);
controller = lab.pursuit_controller(path,p);
robot = differentialDriveKinematics('VehicleInputs','WheelSpeeds', ...
    'WheelRadius',p.wheelRadius,'TrackWidth',p.trackWidth);
% Collision checking uses the robot footprint. Planning additionally uses
% a safety margin; a controller can deviate from the geometric route.
collisionMap = copy(planning.freeMap); inflate(collisionMap,planning.robotRadius);
ss = stateSpaceSE2([collisionMap.XWorldLimits;collisionMap.YWorldLimits;-pi pi]);
validator = validatorOccupancyMap(ss); validator.Map = collisionMap;
validator.ValidationDistance = min(0.01,cfg.rrt.validationDistance);
pose = planning.start; goal = planning.goal(1:2);
assert(isStateValid(validator,pose),'DASE4136:ControlStart','Robot starts in blocked space.');
N = ceil(p.maxTime/p.dt);
poses = zeros(N+1,3); poses(1,:) = pose;
commands = zeros(N,7); errors = zeros(N+1,1);
errors(1) = lab.tracking_error(pose(1:2),path);
stopReason = 'Time limit'; collisionDetected = false; count = 0;

fig = figure('Visible',cfg.visible,'Color','w');
if isprop(fig,'Theme'), fig.Theme = 'light'; end
show(planning.freeMap); hold on;
routeLine = plot(path(:,1),path(:,2),'k--','LineWidth',1.3);
trackLine = plot(pose(1),pose(2),'b-','LineWidth',1.8);
phi = linspace(0,2*pi,40);
robotLine = plot(pose(1)+planning.robotRadius*cos(phi), ...
    pose(2)+planning.robotRadius*sin(phi),'r-','LineWidth',1.5);
headingLine = plot([pose(1),pose(1)+0.4*cos(pose(3))], ...
    [pose(2),pose(2)+0.4*sin(pose(3))],'r-','LineWidth',1.5);
plot(goal(1),goal(2),'go','MarkerFaceColor','g');
legend([routeLine,trackLine,robotLine],{'Reference route','Actual trajectory','Robot footprint'}, ...
    'Location','best'); xlim([-3 13]); ylim([-3 9]);
title('Differential-drive robot follows the route on the mapped environment');
for k = 1:N
    if norm(pose(1:2)-goal)<=p.goalTolerance
        stopReason = 'Goal reached'; break;
    end
    [requestedV,curvature] = controller(pose(:));
    requestedW = requestedV*curvature;
    wheelL = (requestedV-requestedW*p.trackWidth/2)/p.wheelRadius;
    wheelR = (requestedV+requestedW*p.trackWidth/2)/p.wheelRadius;
    wheels = max(-p.wheelLimit,min(p.wheelLimit,[wheelL wheelR]));
    actualV = p.wheelRadius*sum(wheels)/2;
    actualW = p.wheelRadius*(wheels(2)-wheels(1))/p.trackWidth;
    next = lab.drive_step(robot,pose,wheels,p.dt);
    % Check samples on the actual short curved motion, before accepting it.
    safe = true; previous = pose;
    for fraction = [0.25 0.5 0.75 1]
        sample = lab.drive_step(robot,pose,wheels,p.dt*fraction);
        if ~isMotionValid(validator,previous,sample), safe = false; break; end
        previous = sample;
    end
    if ~safe
        collisionDetected = true; stopReason = 'Collision guard'; break;
    end
    pose = next; count = count+1; poses(count+1,:) = pose;
    commands(count,:) = [requestedV,curvature,requestedW,wheels,actualV,actualW];
    errors(count+1) = lab.tracking_error(pose(1:2),path);
    if mod(k,10)==0 && strcmp(cfg.visible,'on')
        update_robot(); drawnow limitrate;
    end
end
if norm(pose(1:2)-goal)<=p.goalTolerance, stopReason = 'Goal reached'; end
poses = poses(1:count+1,:); commands = commands(1:count,:);
errors = errors(1:count+1); times = (0:count)'*p.dt;
update_robot();
title(sprintf('Motion control: %s, lookahead %.2f m',stopReason,p.lookahead));
lab.export_figure(fig,cfg,'control_trajectory');

% Command row k acts on the interval [state time k, state time k+1].
stateLog = table(times,poses(:,1),poses(:,2),poses(:,3),errors, ...
    sqrt(sum((poses(:,1:2)-goal).^2,2)), 'VariableNames', ...
    {'Time_s','X_m','Y_m','Heading_rad','TrackingError_m','GoalDistance_m'});
commandLog = array2table([times(1:end-1),commands],'VariableNames', ...
    {'Time_s','RequestedSpeed_m_s','Curvature_1_m','RequestedHeadingRate_rad_s', ...
    'LeftWheel_rad_s','RightWheel_rad_s','ActualSpeed_m_s','ActualHeadingRate_rad_s'});
reached = strcmp(stopReason,'Goal reached');
traveled = sum(sqrt(sum(diff(poses(:,1:2)).^2,2)));
metrics = table(p.lookahead,p.speed,reached,collisionDetected,{stopReason}, ...
    times(end),stateLog.GoalDistance_m(end),sqrt(mean(errors.^2)),max(errors), ...
    traveled,'VariableNames', {'Lookahead_m','DesiredSpeed_m_s','ReachedGoal', ...
    'CollisionDetected','StopReason','SimulatedTime_s','FinalGoalDistance_m', ...
    'TrackingRMSE_m','MaxTrackingError_m','TravelDistance_m'});
disp(metrics);
fig = figure('Visible',cfg.visible,'Color','w','Position',[100 100 900 650]);
tiledlayout(3,1); nexttile; plot(times,errors,'b-'); grid on;
ylabel('Tracking error (m)'); title('Feedback control measurements');
nexttile; plot(commandLog.Time_s,[commandLog.RequestedSpeed_m_s commandLog.ActualSpeed_m_s]);
grid on; ylabel('Speed (m/s)'); legend('Requested','Actual','Location','best');
ylim([0 max(0.1,1.2*max([p.speed;commandLog.ActualSpeed_m_s]))]);
nexttile; plot(commandLog.Time_s,[commandLog.LeftWheel_rad_s commandLog.RightWheel_rad_s]);
grid on; ylabel('Wheel speed (rad/s)'); xlabel('Simulated time (s)');
legend('Left','Right','Location','best'); lab.export_figure(fig,cfg,'control_signals');
result.metrics = metrics; result.states = stateLog; result.commands = commandLog;
result.poses = poses; result.collisionMap = collisionMap;
writetable(metrics,fullfile(cfg.outputDir,'control_metrics.csv'));
writetable(stateLog,fullfile(cfg.outputDir,'control_states.csv'));
writetable(commandLog,fullfile(cfg.outputDir,'control_commands.csv'));
save(fullfile(cfg.outputDir,'control_results.mat'),'result','cfg');

    function update_robot()
        set(trackLine,'XData',poses(1:count+1,1),'YData',poses(1:count+1,2));
        set(robotLine,'XData',pose(1)+planning.robotRadius*cos(phi), ...
            'YData',pose(2)+planning.robotRadius*sin(phi));
        set(headingLine,'XData',[pose(1),pose(1)+0.4*cos(pose(3))], ...
            'YData',[pose(2),pose(2)+0.4*sin(pose(3))]);
    end
end
