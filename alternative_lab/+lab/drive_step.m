function next = drive_step(robot,pose,wheelSpeeds,dt)
%DRIVE_STEP Integrate differential-drive kinematics using a fixed RK4 step.
q = pose(:); u = wheelSpeeds(:);
k1 = derivative(robot,q,u);
k2 = derivative(robot,q+dt*k1/2,u);
k3 = derivative(robot,q+dt*k2/2,u);
k4 = derivative(robot,q+dt*k3,u);
next = (q+dt*(k1+2*k2+2*k3+k4)/6)';
next(3) = lab.wrap_angle(next(3));
end
