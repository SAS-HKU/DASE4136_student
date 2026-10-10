function report = check_environment()
%CHECK_ENVIRONMENT Diagnose installed products and license availability.
root = setup_lab();
report.release = version('-release');
report.version = version;
report.platform = computer;
report.repoRoot = root;
names = {'Navigation Toolbox'; 'Robotics System Toolbox'};
features = {'Navigation_Toolbox'; 'Robotics_System_Toolbox'};
symbols = {'plannerRRT'; 'differentialDriveKinematics'};
installed = false(2,1); licensed = false(2,1);
for i = 1:2
    installed(i) = ~isempty(which(symbols{i}));
    licensed(i) = license('test', features{i}) == 1;
end
report.products = table(names, installed, licensed, ...
    'VariableNames', {'Product', 'Installed', 'LicenseAvailable'});
report.ok = all(installed & licensed) && ~isMATLABReleaseOlderThan('R2023b');
fprintf('MATLAB %s (%s), %s\n', report.release, report.version, report.platform);
disp(report.products);
if isMATLABReleaseOlderThan('R2023b')
    warning('DASE4136:Release', 'Use MATLAB R2023b or newer for this lab.');
end
if ~all(installed & licensed)
    warning('DASE4136:Products', ...
        'Install and license Navigation Toolbox and Robotics System Toolbox.');
end
end
