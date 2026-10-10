function export_figure(fig, cfg, name)
%EXPORT_FIGURE Export portable PNG evidence; leave interactive figures open.
% Keep exported evidence readable regardless of the user's MATLAB theme.
% Theme is available only in recent releases; earlier releases use axes colors.
if isprop(fig, 'Theme'), fig.Theme = 'light'; end
if isprop(fig, 'Scrollable'), fig.Scrollable = 'off'; end
set(fig, 'Color', 'w');
axesList = findall(fig, 'Type', 'axes');
for i = 1:numel(axesList)
    set(axesList(i), 'Color','w', 'XColor','k', 'ZColor','k');
    if isscalar(axesList(i).YAxis), axesList(i).YColor = 'k'; end
end
set(findall(fig, 'Type', 'text'), 'Color','k');
legends = findall(fig, 'Type', 'legend');
set(legends, 'Color','w', 'TextColor','k');
exportgraphics(fig, fullfile(cfg.outputDir, [name '.png']), ...
    'Resolution', 150, 'BackgroundColor','white');
if strcmp(cfg.visible, 'off'), close(fig); end
end
