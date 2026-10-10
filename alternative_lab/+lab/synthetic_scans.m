function data = synthetic_scans(cfg)
%SYNTHETIC_SCANS Ray-segment lidar simulation around one closed loop.
% Truth is used by the simulator and evaluation, NEVER as a SLAM pose input.
p = cfg.slam; segments = lab.room_geometry();
% Fixed heading simplifies the first teaching example. An omnidirectional
% platform may translate sideways; this is NOT a Dubins vehicle trajectory.
corners = [2 2;12 2;12 8;2 8;2 2];
xy = corners(1,:);
for i = 1:4
    a = corners(i,:); b = corners(i+1,:);
    count = ceil(norm(b-a)/0.25);
    alpha = (1:count)'/count;
    xy = [xy; a + alpha.*(b-a)]; %#ok<AGROW>
end
truth = [xy zeros(size(xy,1),1)];
indices = 1:p.scanStride:size(truth,1);
if indices(end) ~= size(truth,1), indices(end+1) = size(truth,1); end
truth = truth(indices,:);
angles = linspace(-pi, pi, p.beams+1)'; angles(end) = [];
scans = cell(size(truth,1),1);
for k = 1:size(truth,1)
    pose = truth(k,:); directions = [cos(angles+pose(3)), sin(angles+pose(3))];
    ranges = inf(p.beams,1);
    for j = 1:size(segments,1)
        a = segments(j,1:2); edge = segments(j,3:4)-a;
        delta = a-pose(1:2);
        den = directions(:,1)*edge(2) - directions(:,2)*edge(1);
        safeDen = den; safeDen(abs(den)<1e-12) = NaN;
        distance = (delta(1)*edge(2)-delta(2)*edge(1))./safeDen;
        fraction = (delta(1)*directions(:,2)-delta(2)*directions(:,1))./safeDen;
        valid = distance>0 & fraction>=0 & fraction<=1;
        distance(~valid) = Inf;
        ranges = min(ranges, distance);
    end
    hit = ranges < p.maxRange;
    % No-return beams are omitted, rather than mapped as fictitious walls.
    noisy = ranges(hit) + p.rangeNoiseStd*randn(sum(hit),1);
    valid = noisy>0 & noisy<p.maxRange;
    hitAngles = angles(hit);
    scans{k} = lidarScan(noisy(valid), hitAngles(valid));
end
data.scans = scans; data.truth = truth; data.segments = segments;
data.sourceIndices = indices;
end
