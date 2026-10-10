function cfg = lab_config()
%LAB_CONFIG Parameters for mapping, a supporting route, and motion control.
root = setup_lab();
cfg.outputDir = fullfile(root,'output','baseline');
cfg.visible = 'on';
cfg.seed = 4136;
cfg.slam.resolution = 10;          % cells/m
cfg.slam.maxRange = 12;            % m
cfg.slam.beams = 360;
cfg.slam.rangeNoiseStd = 0.01;     % m
cfg.slam.loopThreshold = 100;
cfg.slam.loopSearchRadius = 3;     % m
cfg.slam.enableLoopClosure = true;
cfg.slam.scanStride = 1;
% All navigation coordinates are in the SLAM first-scan frame.
cfg.rrt.start = [0 0 0];           % [m m rad]
cfg.rrt.goal = [10 6 pi/2];        % [m m rad]
cfg.rrt.robotRadius = 0.2;         % m, circular robot footprint
cfg.rrt.safetyMargin = 0.15;       % m, additional planning clearance
cfg.rrt.minTurningRadius = 0.6;    % m
cfg.rrt.connectionDistance = 2;    % m
cfg.rrt.validationDistance = 0.02; % m
cfg.rrt.maxIterations = 10000;
cfg.rrt.goalBias = 0.1;
% These are the parameters students change in the main exercise.
cfg.control.lookahead = 0.35;     % m
cfg.control.speed = 0.4;          % m/s
cfg.control.maxCurvature = 2;     % 1/m
cfg.control.wheelRadius = 0.1;    % m
cfg.control.trackWidth = 0.4;     % m
cfg.control.wheelLimit = 8;       % rad/s
cfg.control.dt = 0.05;            % s
cfg.control.maxTime = 150;        % s of simulated time
cfg.control.goalTolerance = 0.15; % m, position only
end
