function result = run_planning(mapping,cfg)
%RUN_PLANNING Supporting RRT route on the estimated SLAM map.
if nargin < 2, cfg = lab_config(); end
lab.prepare(cfg); rng(cfg.seed,'twister');
map = mapping.map;
% Only confidently observed free cells are traversable. Unknown is blocked.
blocked = occupancyMatrix(map)>=map.FreeThreshold;
freeMap = binaryOccupancyMap(blocked,map.Resolution);
freeMap.GridLocationInWorld = map.GridLocationInWorld;
result = lab.plan_rrt(freeMap,cfg.rrt.start,cfg.rrt.goal,cfg);
result.freeMap = freeMap;
result.start = cfg.rrt.start; result.goal = cfg.rrt.goal;
result.robotRadius = cfg.rrt.robotRadius;
result.metrics = table(result.success,result.pathValid,result.pathLength, ...
    result.iterations,result.goalPositionError,'VariableNames', ...
    {'Success','MotionValid','PathLength_m','Iterations','GoalPositionError_m'});
disp(result.metrics);
fig = figure('Visible',cfg.visible,'Color','w');
show(result.inflatedMap); hold on;
if result.success
    plot(result.states(:,1),result.states(:,2),'b-','LineWidth',2);
else
    warning('DASE4136:NoPath','No route through observed free space within the budget.');
end
plot(result.start(1),result.start(2),'go','MarkerFaceColor','g');
plot(result.goal(1),result.goal(2),'ro','MarkerFaceColor','r');
xlim([-3 13]); ylim([-3 9]);
title('Supporting route on the estimated map with unknown space blocked');
lab.export_figure(fig,cfg,'route');
writetable(result.metrics,fullfile(cfg.outputDir,'route_metrics.csv'));
writematrix(result.states,fullfile(cfg.outputDir,'route_waypoints.csv'));
save(fullfile(cfg.outputDir,'planning_results.mat'),'result','cfg');
end
