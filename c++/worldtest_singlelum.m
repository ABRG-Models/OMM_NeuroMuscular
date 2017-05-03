% Short script to visualise the output of worldtest_singlelum.cpp, which
% makes clear the eyeframe to retinotopic population mapping.

%clf(1)
%clf(2)

load('eyeframe_single.dat');
load('eyeframe_neurons.dat');
load('eyeframe_neurons_pixel.dat');
% The neuron positions need to be shifted:
efn = eyeframe_neurons;% .+ 31;
efn_pix = eyeframe_neurons_pixel;% .+ 31;

figure(1)
hold off
z=repmat(1.01, 1, 2500);
% Present pixelised neuron locations:
scatter3(efn_pix(:,1),efn_pix(:,2), z, 2, 'red', 'filled');
hold on;
% Uncomment to show also the precise neuron positions:
scatter3(efn(:,1),efn(:,2), z, 2, 'green', 'filled');
surf([-30:30], [-30:30], eyeframe_single);
xlabel('ThetaY; rotn about y axis');
ylabel('ThetaX; rotn about x axis');
title('eyeframe');

load('corticalmap_single.dat');
figure(2)
surf(corticalmap_single); xlabel('radius'); ylabel('theta');
title('cortical map');
