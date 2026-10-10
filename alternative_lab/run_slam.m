function result = run_slam(cfg)
%RUN_SLAM Estimate a pose graph and occupancy map from locally made scans.
if nargin < 1, cfg = lab_config(); end
lab.prepare(cfg); rng(cfg.seed, 'twister'); p = cfg.slam;
assert(p.scanStride>=1 && p.scanStride==floor(p.scanStride), ...
    'DASE4136:Stride', 'scanStride must be a positive integer.');
data = lab.synthetic_scans(cfg);
slam = lidarSLAM(p.resolution, p.maxRange);
slam.MovementThreshold = [0.1 0.1];
slam.LoopClosureThreshold = p.loopThreshold;
slam.LoopClosureSearchRadius = p.loopSearchRadius;
if ~p.enableLoopClosure
    slam.LoopClosureThreshold = 1e12; % Reject all candidate loop matches.
end
N = numel(data.scans); accepted = false(N,1); optimized = false(N,1);
loopEdges = zeros(N,1); elapsed = tic;
for k = 1:N
    [accepted(k), lc, opt] = addScan(slam, data.scans{k});
    optimized(k) = opt.IsPerformed;
    loopEdges(k) = numel(lc.EdgeIDs);
    if mod(k,32)==0 || k==N
        fprintf('SLAM processed %d/%d scans; accepted %d\n', k,N,sum(accepted));
    end
end
runtime = toc(elapsed);
[scans, poses] = scansAndPoses(slam);
assert(size(poses,1)==sum(accepted), 'DASE4136:ScanIndex', ...
    'Accepted scan count and estimated poses must agree.');
map = buildMap(scans, poses, p.resolution, p.maxRange);
% lidarSLAM anchors the first scan at [0 0 0]. Express simulator truth in
% that same frame before calculating position errors.
origin = data.truth(1,:); R = [cos(origin(3)) -sin(origin(3)); ...
    sin(origin(3)) cos(origin(3))];
truth = data.truth(accepted,:);
truth(:,1:2) = (truth(:,1:2)-origin(1:2))*R;
truth(:,3) = lab.wrap_angle(truth(:,3)-origin(3));
positionRMSE = sqrt(mean(sum((poses(:,1:2)-truth(:,1:2)).^2,2)));
returnDistance = norm(poses(end,1:2)-poses(1,1:2));
metrics = table(N, sum(accepted), sum(loopEdges), sum(optimized), ...
    positionRMSE, returnDistance, runtime, 'VariableNames', ...
    {'InputScans','AcceptedScans','LoopEdges','Optimizations','PositionRMSE_m', ...
    'ReturnDistance_m','Runtime_s'});
disp(metrics);
fig = figure('Visible',cfg.visible,'Color','w','Position',[100 100 1000 460]);
tiledlayout(1,2); nexttile;
show(map); hold on;
plot(poses(:,1),poses(:,2),'b-', 'LineWidth',1.4);
plot(truth(:,1),truth(:,2),'r--');
xlim([-3 13]); ylim([-3 9]);
title('SLAM occupancy map and trajectory'); xlabel('x (m)'); ylabel('y (m)');
nexttile; show(slam.PoseGraph, 'IDs','off'); axis equal;
title('Estimated pose graph'); xlabel('x (m)'); ylabel('y (m)');
lab.export_figure(fig,cfg,'slam');
samples = table((1:N)', data.sourceIndices', accepted, loopEdges, optimized, ...
    'VariableNames', {'InputScan','SourceScan','Accepted','LoopEdges','Optimized'});
result.metrics = metrics; result.poses = poses; result.truth = truth;
result.map = map; result.accepted = accepted; result.samples = samples;
result.slam = slam;
writetable(metrics, fullfile(cfg.outputDir,'slam_metrics.csv'));
writetable(samples, fullfile(cfg.outputDir,'slam_scan_log.csv'));
writematrix(poses, fullfile(cfg.outputDir,'slam_poses.csv'));
save(fullfile(cfg.outputDir,'slam_results.mat'),'result','cfg');
end
