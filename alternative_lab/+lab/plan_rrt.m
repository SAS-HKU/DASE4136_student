function result = plan_rrt(map, start, goal, cfg)
%PLAN_RRT Return explicit failure and validate every continuous Dubins edge.
p = cfg.rrt; inflated = copy(map);
inflate(inflated, p.robotRadius+p.safetyMargin);
bounds = [inflated.XWorldLimits; inflated.YWorldLimits; -pi pi];
ss = stateSpaceDubins(bounds); ss.MinTurningRadius = p.minTurningRadius;
validator = validatorOccupancyMap(ss);
validator.Map = inflated; validator.ValidationDistance = p.validationDistance;
assert(all(isStateValid(validator,[start;goal])), 'DASE4136:InvalidEndpoint', ...
    'Start or goal is occupied after inflation, or outside map bounds.');
planner = plannerRRT(ss,validator);
planner.MaxConnectionDistance = p.connectionDistance;
planner.MaxIterations = p.maxIterations; planner.GoalBias = p.goalBias;
% The default goal region is relatively broad. Use a tight Dubins-distance
% tolerance so a successful teaching run also reaches the requested pose.
planner.GoalReachedFcn = @(pl,current,goalState) ...
    pl.StateSpace.distance(current,goalState)<0.02;
elapsed = tic; [path, info] = plan(planner,start,goal); runtime = toc(elapsed);
result.success = info.IsPathFound; result.runtime = runtime;
result.pathLength = NaN; result.states = zeros(0,3); result.pathValid = false;
result.tree = info.TreeData; result.inflatedMap = inflated;
result.iterations = info.NumIterations;
result.goalPositionError = NaN; result.goalHeadingError = NaN;
if result.success
    nodes = path.States; valid = true;
    for i = 1:size(nodes,1)-1
        valid = valid && isMotionValid(validator,nodes(i,:),nodes(i+1,:));
    end
    result.pathValid = valid;
    result.pathLength = pathLength(path);
    % Dense display samples also preserve curved Dubins connections.
    interpolate(path, max(300,ceil(result.pathLength/p.validationDistance)+1));
    result.states = path.States;
    result.goalPositionError = norm(result.states(end,1:2)-goal(1:2));
    result.goalHeadingError = abs(lab.wrap_angle(result.states(end,3)-goal(3)));
end
end
