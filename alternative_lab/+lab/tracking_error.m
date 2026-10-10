function error = tracking_error(xy,path)
%TRACKING_ERROR Distance to the closest polyline segment, in meters.
a = path(1:end-1,:); d = path(2:end,:)-a;
length2 = sum(d.^2,2);
fraction = sum((xy-a).*d,2)./max(length2,eps);
fraction = max(0,min(1,fraction));
closest = a+fraction.*d;
error = sqrt(min(sum((closest-xy).^2,2)));
end
