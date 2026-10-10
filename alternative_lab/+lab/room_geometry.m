function segments = room_geometry()
%ROOM_GEOMETRY Asymmetric 14 by 10 m room, with three polygonal obstacles.
polygons = {[0 0;14 0;14 10;0 10], ...
    [4.5 3.5;6 3.5;6 6.5;4.5 6.5], ...
    [8 4;10 4;10 5.5;8 5.5], ...
    [10.5 6.5;11.5 6.5;11.5 7.2;10.5 7.2]};
segments = zeros(0,4);
for i = 1:numel(polygons)
    a = polygons{i}; b = a([2:end 1],:);
    segments = [segments; a b]; %#ok<AGROW>
end
end
