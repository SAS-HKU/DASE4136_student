function summary = run_experiments(planning,cfg)
%RUN_EXPERIMENTS Compare two controller settings on exactly the same map/path.
if nargin < 2, cfg = lab_config(); end
if nargin < 1
    results = run_all(cfg); planning = results.planning;
end
root = setup_lab(); rows = cell(2,1);
lookaheads = [0.25 0.8];
for i = 1:2
    c = cfg; c.control.lookahead = lookaheads(i);
    c.outputDir = fullfile(root,'output','experiments',sprintf('lookahead_%g',lookaheads(i)));
    r = run_control(planning,c); rows{i} = r.metrics;
end
summary = vertcat(rows{:});
writetable(summary,fullfile(root,'output','experiments','comparison.csv'));
disp(summary);
end
