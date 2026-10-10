function a = wrap_angle(a)
%WRAP_ANGLE Wrap radians without needing Mapping Toolbox.
a = atan2(sin(a), cos(a));
end
