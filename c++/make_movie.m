direction=[0 0 1];
basedir='/home/seb/analysis/oculomotor/';
b = csvread ([basedir 'wdm/cortmap0.dat']);
fg1 = figure (1);
set (fg1, 'position', [150 150 600 600]);
h = surf (b);
rotate (h, direction, 90);
axis tight manual;
ax = gca;
ax.NextPlot = 'replaceChildren';


loops = 600;
F(loops) = struct('cdata',[],'colormap',[]);
for i = 0:loops-1
    a = [basedir 'wdm/cortmap' num2str(i)  '.dat'];
    b = csvread (a);
    h = surf (b);
    rotate (h, direction, 90);
    drawnow
    F(i+1) = getframe;
end

[h, w, ~] = size (F(1).cdata);  % use 1st frame to get dimensions
hf = figure;
% resize figure based on frame's w x h, and place at (150, 150)
set (hf, 'position', [150 150 w h]);
axis off
movie (hf, F);
implay (F)
movie2avi(F,'/home/seb/analysis/oculomotor/eyeframe_cortical_rep.avi')