% Load the file which contains the weights determined by the
% rotations_weight_finder_centroid_3d.m
%
% /fast/${USER}/allweights.log
%
% This file has the following format:
%
% /var/spool/sge/node162/job_scripts/1048650 - Theta X range: -22 to 22; Theta Y range:  -22 to 22
% /var/spool/sge/node162/job_scripts/1048650 - explicitDataBinaryFileN.bin: L:50 R:52 U:53 D:54 Z+:58 Z-:57
% 53,1,11.000000,42,28,0.816035,40.807996,26.815072
% 50,2,10.000000,42,28,0.698534,40.807996,26.815072
%
% Lines starting with a script path signify the "run set" range.
%
% Other lines have this format:
%
% weight_file_number, axis(X/Y/Z), target angle, map positionX, map
% positionY, best weight, scd centroid X, scd centroid Y.
%
% weight_file_number is the number in,
% e.g. explicitDataBinaryFile50.bin. axis(X/Y/Z) is a number - 1 for
% X, 2 for Y, 3 for Z.

% 50,2,10.000000,32,27,0.643945,31.282605,25.800921
allweights = dlmread ('allweights_mod.log');

% Up
[ e53map, e53means, e53 ] = justdata (allweights, 53);
% Left
[ e50map, e50means, e50 ] = justdata (allweights, 50);
% Right
[ e52map, e52means, e52 ] = justdata (allweights, 52);
% Down
[ e54map, e54means, e54 ] = justdata (allweights, 54);
% Z-
[ e57map, e57means, e57 ] = justdata (allweights, 57);
% Z+
[ e58map, e58means, e58 ] = justdata (allweights, 58);
