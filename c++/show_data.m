% Octave script to view data from worldtest

% Original matrix has cols for ThetaY, rows for ThetaX. Increasing
% columns means ThetaY is moving left from the meridian
% ThetaX increasing (i.e. increasing rows) has the luminance moving
% upwards from the horizon.
load worldframe_lum_map.dat

% the surf() plot will show X along the cols and Y along the rows,
% so rotate the map 90 degrees.
worldframe_lum_map = rot90 (worldframe_lum_map);

figure(1)

% Create ThetaX/ThetaY series
ThetaX=[1:size(worldframe_lum_map)(1)] - 121;
ThetaY=[1:size(worldframe_lum_map)(1)] - 121;
ThetaY=ThetaY.*-1; % correct the direction of Y - Y +ve is left of meridian

% Surface plot.
surf (ThetaX, ThetaY, worldframe_lum_map)
xlabel('ThetaX')
ylabel('ThetaY')
title ('world frame luminance map');

%figure(2)
%surf(ThetaX(128:134), ThetaY(118:124), worldframe_lum_map(118:124,128:134))
%xlabel('ThetaX')
%ylabel('ThetaY')
%title ('world frame luminance map section of interest');

load eyeframe_lum_map.dat
eyeframe_lum_map = rot90 (eyeframe_lum_map);
ThetaX=[1:size(eyeframe_lum_map)(1)] - 76; % 76 is the matrix
                                           % offset 75 + 1 for the
                                           % fact that octave
                                           % indexes from 1 and
                                           % Eigen from 0.
ThetaY=[1:size(eyeframe_lum_map)(1)] - 76;
ThetaY=ThetaY.*-1; % correct the direction of Y - Y +ve is left of meridian
figure(3)
surf (ThetaX, ThetaY, eyeframe_lum_map)
xlabel('ThetaX')
ylabel('ThetaY')
title ('eye frame luminance map');

%figure(4)
%surf (eyeframe_lum_map(70:80,80:90))
%title ('eye frame luminance map region of interest');

load neuron_precise_w_lum.dat
figure(5)
% If we plot thetaX on x and thetaY on y, then we get a rotated
% image, so we plot thetaX on y and thetaY on x.
%scatter (neuron_precise_w_lum(:,1),neuron_precise_w_lum(:,2), neuron_precise_w_lum(:,3).*50);
scatter (-1.*neuron_precise_w_lum(:,2),neuron_precise_w_lum(:,1), neuron_precise_w_lum(:,3).*50);
xlabel('-ThetaY')
ylabel('ThetaX')
title ('precise neuron locations with activations; eye frame');

load neuron_pixels_w_lum.dat
figure(6)
scatter (-1.*neuron_pixels_w_lum(:,2),neuron_pixels_w_lum(:,1), neuron_pixels_w_lum(:,3).*50);
xlabel('-ThetaY')
ylabel('ThetaX')
title ('rounded neuron locations with activations; eye frame');

figure (7)
load cortical_sheet.dat
surf (cortical_sheet)
title ('Cortical sheet');

figure (8)
load eyeframe_lum_cart.dat
scatter3 (eyeframe_lum_cart(:,5), eyeframe_lum_cart(:,6), eyeframe_lum_cart(:,7), 6, eyeframe_lum_cart(:,4).*20, "filled")
title ('Luminances in eye frame in cartesian space');
xlabel('x')
ylabel('y')
zlabel('z')
% For each point, plot the luminance
for i= [1:size(eyeframe_lum_cart)(1)]
    text (eyeframe_lum_cart(i,5), eyeframe_lum_cart(i,6), ...
          eyeframe_lum_cart(i,7), num2str(eyeframe_lum_cart(i,4)), ...
          "fontsize", 9);
end
