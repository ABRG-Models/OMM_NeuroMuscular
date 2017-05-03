function [ COORDINATES ] = all_grid_coordinates (square_grid_width)
%ALL_GRID_COORDINATES Return a two col matrix containing all x,y positions
% on a square grid of width square_grid_width.

% create grid of positions of each neuron i.e. locations on the 50x50 grid
% Use of meshgrid would be alternative here.
COORDINATES = nchoosek(1:square_grid_width,2);
% Following does 1) R itself, 2) then R with columns reversed (2 first, then 1,
% which gives the mirrored locations, 3) then 1 1; 2 2; 3 3; etc (diag
% elements).
COORDINATES = [ COORDINATES; COORDINATES(:,[2 1]); [(1:square_grid_width)' (1:square_grid_width)'] ];

% This code is useful for the visualisation but is not needed when
% communicating with spineCreator.
[s,I] = sort(COORDINATES(:,2));
COORDINATES = COORDINATES(I,:);

end

