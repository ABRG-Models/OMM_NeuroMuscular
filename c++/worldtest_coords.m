% Short script to visualise the output of worldtest_coords.cpp, which
% makes clear the eyeframe to retinotopic population mapping.

clear
clf

load('eyeframe_right.dat');
load('eyeframe_left.dat');
load('eyeframe_up.dat');
load('eyeframe_down.dat');

load('eyeframe_neurons.dat');
load('eyeframe_neurons_pixel.dat');
% The neuron positions need to be shifted:
efn = eyeframe_neurons .+ 31;
efn_pix = eyeframe_neurons_pixel .+31;

figure(1)
hold off
z=repmat(1.01, 1, 2500);
% Present pixelised neuron locations:
scatter3(efn_pix(:,1),efn_pix(:,2), z, 2, 'red', 'filled');
hold on;
% Uncomment to show also the precise neuron positions:
%scatter3(efn(:,1),efn(:,2), z, 2, 'green', 'filled');
surf(eyeframe_right);
surf(eyeframe_left);
surf(eyeframe_up);
surf(eyeframe_down);
xlabel('X'); ylabel('Y');
title('9, 18, 27 degrees in each direction');

load('corticalmap_right.dat');
figure(2)
surf(corticalmap_right); xlabel('radius'); ylabel('theta');
title('9, 18, 27 degrees to the right');

load('corticalmap_left.dat');
figure(3)
surf(corticalmap_left); xlabel('radius'); ylabel('theta');
title('9, 18, 27 degrees to the left');

load('corticalmap_up.dat');
figure(4)
surf(corticalmap_up); xlabel('radius'); ylabel('theta');
title('9, 18, 27 degrees up');

load('corticalmap_down.dat');
figure(5)
surf(corticalmap_down); xlabel('radius'); ylabel('theta');
title('9, 18, 27 degrees down');

