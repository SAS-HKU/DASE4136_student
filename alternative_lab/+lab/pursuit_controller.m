function controller = pursuit_controller(waypoints,p)
%PURSUIT_CONTROLLER Support the property rename in MATLAB R2026a.
controller = controllerPurePursuit;
controller.Waypoints = waypoints;
controller.DesiredLinearVelocity = p.speed;
controller.LookaheadDistance = p.lookahead;
if isprop(controller,'MaxCurvature')
    controller.MaxCurvature = p.maxCurvature;
else
    % MathWorks renamed this property in R2026a without changing behavior.
    controller.MaxAngularVelocity = p.maxCurvature;
end
% The second output is geometric curvature, including on older releases
% where its name was angvel. Convert it to heading rate: omega = v*curvature.
end
