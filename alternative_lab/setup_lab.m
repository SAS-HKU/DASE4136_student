function root = setup_lab()
%SETUP_LAB Make the repository available for this MATLAB session only.
root = fileparts(mfilename('fullpath'));
addpath(root);
end
