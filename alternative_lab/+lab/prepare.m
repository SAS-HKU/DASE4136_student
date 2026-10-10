function prepare(cfg)
%PREPARE Create the output directory without changing working directory.
if ~exist(cfg.outputDir, 'dir'), mkdir(cfg.outputDir); end
assert(any(strcmp(cfg.visible, {'on', 'off'})), ...
    'DASE4136:Visibility', 'cfg.visible must be on or off.');
end
