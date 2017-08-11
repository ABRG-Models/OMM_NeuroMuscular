% Short script to visualise the output of worldtest_coords.cpp, which
% makes clear the eyeframe to retinotopic population mapping.

clear
clf

load('eyeframe_right.dat');

load('eyeframe_neurons.dat');
load('eyeframe_neurons_pixel.dat');
% The neuron positions need to be shifted:
efn = eyeframe_neurons .+ 31;
efn_pix = eyeframe_neurons_pixel .+31;

figure(1)
clf;
hold off
z=repmat(1.01, 1, 2500);
% Present pixelised neuron locations:
%scatter3(efn_pix(:,1),efn_pix(:,2), z, 2, 'red', 'filled');
hold on;
% Uncomment to show also the precise neuron positions:
%scatter3(efn(:,1),efn(:,2), z, 2, 'green', 'filled');
surf(eyeframe_right);

xlabel('X'); ylabel('Y');
title('9, 18, 27 degrees in each direction');

load('corticalmap_right.dat');
figure(2)
clf;
surf(corticalmap_right); xlabel('radius'); ylabel('theta');
title('9, 18, 27 degrees to the right');
