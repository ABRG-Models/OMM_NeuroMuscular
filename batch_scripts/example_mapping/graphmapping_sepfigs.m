clear
clf

load('eyeframe_right.dat');

figure(1)
clf;
hold off
%z=repmat(1.01, 1, 2500);
hold on;
surf(eyeframe_right);


xlabel('-Y'); ylabel('X');
title('Fixation and -12 degrees in RotY (i.e. rightwards target)');

load('corticalmap_right.dat');
figure(2)
clf;
surf(corticalmap_right); xlabel('radius'); ylabel('\phi');
view([117,80])
title('Cortical map');

load('modelframes.oct');

figure(3); clf;
surf(world_frame);
view([117,80])
figure(4); clf;
surf(fef_add_noise_frame);
view([117,80])
figure(5); clf;
surf(fef_frame);
view([117,80])