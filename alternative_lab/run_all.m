function results = run_all(cfg)
%RUN_ALL Build a map, plan on that map, then control the robot along the route.
if nargin < 1, cfg = lab_config(); end
env = check_environment();
assert(env.ok,'DASE4136:Environment','Resolve the environment diagnostics first.');
lab.prepare(cfg);
results.environment = env;
results.mapping = run_slam(cfg);
results.planning = run_planning(results.mapping,cfg);
assert(results.planning.success && results.planning.pathValid, ...
    'DASE4136:NoValidRoute','No valid route on the estimated map. Inspect the planning output.');
results.control = run_control(results.planning,cfg);
results.cfg = cfg;
save(fullfile(cfg.outputDir,'all_results.mat'),'results','cfg');
fprintf('Map -> route -> motion control completed. Results: %s\n',cfg.outputDir);
end
