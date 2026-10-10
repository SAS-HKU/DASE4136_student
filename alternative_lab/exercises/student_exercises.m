%% Run from the lab root, which contains lab_config.m.
% Baseline: mapping -> supporting route -> robot motion control.
cfg = lab_config();
results = run_all(cfg);

%% Main exercise: predict, then compare lookahead 0.25 m and 0.8 m.
% Reuse the SAME mapped environment and route to isolate the controller.
summary = run_experiments(results.planning,cfg);

%% Optional: change desired speed on the same route.
% cfg.control.speed = 0.6;
% cfg.outputDir = fullfile(setup_lab(),'output','my_speed_test');
% trial = run_control(results.planning,cfg);
