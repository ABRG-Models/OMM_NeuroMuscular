% This is the script with which to load and linearly interpolate
% the weight training data.
%
% Load data, then interpolate to fill in gaps in the data, then
% write out weight maps (explicitDataBinaryFiles).
%
% This version of load_interp.m will exclude some of the outlier
% data points from this training run.

show_figures = 1

% First:
load_justdata

% Can now exclude any data points I want to from the maps, prior to
% the interpolation process.
%
% Note that these are dataset-specific exclusions - points that are
% way off the general trend.
e53map(16,40) = nan;
e53map(20,24) = nan;
e53map(18,25) = nan;
e53map(21,27) = nan;
e53map(30,29) = nan;

e52map(37,42) = nan;

e50map(30,29) = nan;
e50map(40,34) = nan;
e50map(45,35) = nan;
e50map(47,40) = nan;
e50map(47,42) = nan;

e54map(28,43) = nan;

% region 2
e58map(18,25) = nan;
e58map(20,24) = nan;
e58map(16,40) = nan;

% region 1
e58map(47,41) = nan;
e58map(44,38) = nan;
e58map(48,32) = nan;

e57map(31,39) = nan;



% Use these to work on a portion of the map
%mapside = 8;
%mapstarttheta = 16;
%mapstartr = 25;

% Full map:
mapside = 50;
mapstarttheta = 1;
mapstartr = 1;

% For use in scatter graphs below
[XX, YY] = meshgrid (1:mapside, 1:mapside);

testmap = e57map(mapstarttheta:mapstarttheta+mapside-1,
                 mapstartr:mapstartr+mapside-1);
[interpmap, finalmap] = interpolate (testmap);
if show_figures
figure(1); scatter3(XX,YY,testmap,5,'filled'); title('initialmap e57');
%%figure(2); scatter3(XX,YY,interpmap,5,'filled'); title('interp');
figure(3); scatter3(XX,YY,finalmap,5,'filled'); title('finalmap e57');
end
final_e57 = finalmap;

% For e58map, I need to interpolate over two rectangular regions.
% Region 1:
thetaside = 15;
rside = 50;
mapstarttheta = 35;
mapstartr = 1;
testmap = e58map(mapstarttheta:mapstarttheta+thetaside-1, ...
                 mapstartr:mapstartr+rside-1);
[interpmap, finalmap1] = interpolate (testmap);
[XR, YR] = meshgrid (1:rside, mapstarttheta:mapstarttheta+thetaside-1);
if show_figures
figure(4); scatter3(XR,YR,testmap,5,'filled');
title('initialmap e58 region 1');
%%figure(5); scatter3(XR,YR,interpmap,5,'filled'); title('interp');
figure(6); scatter3(XR,YR,finalmap1,5,'filled');
title('finalmap e58 region 1');
end
% Region 2:
thetaside2 = 20;
mapstarttheta2 = 1;
testmap = e58map(mapstarttheta2:mapstarttheta2+thetaside2-1, ...
                 mapstartr:mapstartr+rside-1);
[interpmap, finalmap2] = interpolate (testmap);
[XR, YR] = meshgrid (1:rside, mapstarttheta2:mapstarttheta2+thetaside2-1);
if show_figures
figure(7); scatter3(XR,YR,testmap,5,'filled');
title('initialmap e58 region 2');
%%figure(8); scatter3(XR,YR,interpmap,5,'filled'); title('interp');
figure(9); scatter3(XR,YR,finalmap2,5,'filled');
title('finalmap e58 region 2');
end
% Glue Regions 1 and 2 together
final_e58 = zeros(50);
final_e58 (mapstarttheta:mapstarttheta+thetaside-1, ...
           mapstartr:mapstartr+rside-1) = finalmap1;
final_e58 (mapstarttheta2:mapstarttheta2+thetaside2-1, ...
           mapstartr:mapstartr+rside-1) = finalmap2;
%figure(90); scatter3(XX,YY,final_e58,5,'filled');
%title('finalmap_glued');
% This shows I got the placement correct, as the diff of the wings
% is mostly zero:
%figure(91); scatter3(XX,YY,e58map-final_e58,5,'filled');
%title('finalmap_glued_diff');

testmap = e54map;
[interpmap, finalmap] = interpolate (testmap);
if show_figures
figure(10); scatter3(XX,YY,testmap,5,'filled'); title('initialmap e54');
%%figure(11); scatter3(XX,YY,interpmap,5,'filled'); title('interp');
figure(12); scatter3(XX,YY,finalmap,5,'filled'); title('finalmap e54');
end
final_e54 = finalmap;

testmap = e50map;
[interpmap, finalmap] = interpolate (testmap);
if show_figures
figure(13); scatter3(XX,YY,testmap,5,'filled'); title('initialmap e50');
%%figure(14); scatter3(XX,YY,interpmap,5,'filled'); title('interp');

%[XXx , YYy] = retmap (XX, YY);
%%figure(15); scatter3(XXx,YYy,finalmap,5,'filled');
%title('finalmap');
%final_e50 = flipud(finalmap);
%final_e50 = rot90(finalmap, 2);
%final_e50 = rot90(flipud (finalmap), 3);
figure(15); scatter3(XX,YY,finalmap,5,'filled');
title ('finalmap e50');
end
final_e50 = finalmap;

testmap = e52map;
[interpmap, finalmap] = interpolate (testmap);
if show_figures
figure(16); scatter3(XX,YY,testmap,5,'filled'); title('initialmap e52');
%%figure(17); scatter3(XX,YY,interpmap,5,'filled'); title('interp');
figure(18); scatter3(XX,YY,finalmap,5,'filled'); title('finalmap e52');
end
final_e52 = finalmap;

testmap = e53map;
[interpmap, finalmap] = interpolate (testmap);
if show_figures
    figure(19); scatter3(XX,YY,testmap,5,'filled');
    title('initialmap e53');
%figure(20); scatter3(XX,YY,interpmap,5,'filled'); title('interp');
    figure(21); scatter3(XX,YY,finalmap,5,'filled');
    title('finalmap e53');
end
final_e53 = finalmap;

% Since I coded in the "Fill no more than 2 gaps with linear
% interpolation", it actually ISN'T necessary to interpolate with
% two regions.
testmap = e58map;
[interpmap, finalmap] = interpolate (testmap);
%figure(22); scatter3(XX,YY,testmap,5,'filled'); title('initialmap');
%%figure(23); scatter3(XX,YY,interpmap,5,'filled'); title('interp');
%
% Possibly apply a gaussian blur to the image? e.g.:
H = fspecial('gaussian',[2,2],0.5);
finalmap(finalmap==0) = nan;
final_e58_2 = imfilter(finalmap,H);
%figure(24); scatter3(XX,YY,final_e58_2,5,'filled'); title('finalmap');


% Finally, let's write out the values into weight maps so we can
% try the model out!!
write_neural_sheet(final_e50, 'explicitDataBinaryFile50.bin');
write_neural_sheet(final_e52, 'explicitDataBinaryFile52.bin');
write_neural_sheet(final_e53, 'explicitDataBinaryFile53.bin');
write_neural_sheet(final_e54, 'explicitDataBinaryFile54.bin');
write_neural_sheet(final_e57, 'explicitDataBinaryFile57.bin');
write_neural_sheet(final_e58, 'explicitDataBinaryFile58.bin');
