clear
clf

% Load data:
load('eyeframe_right.dat');
load('corticalmap_right.dat');
load('modelframes.oct');

h_f = figure (1); clf;
h_f_pos = get(h_f, 'Position');
set(h_f, 'Position', [20, 1000, 2100, 1400]);

% Best viewing angle for the surfaces
vx=117; vy=80;

% Spacing for subaxes
sa_spc = 0.03;
sa_pad = 0.03;
sa_pad_mid = 0.04;
sa_pad_2d = 0.03;
sa_marg = 0.08;
sa_marg_mid = 0.13;
sa_marg_sideout = 0.1;

% Your favoured line width and marker size:
lw = 2;
ms = 20;

textxlabel = '\theta_y';
textylabel = '\theta_x';

% Main fontsize
fs1 = 38;

function offsetxlabel (h)
    xpos = get(h, 'position');
    xpos(2) = xpos(2)+2;
    halfwidth = 2.5;
    xpos(1) = xpos(1)-halfwidth;
    set(h, 'position', xpos);
end

function offsetylabel (h)
    xpos = get(h, 'position');
    xpos(1) = xpos(2)+2.2;
    halfwidth = 2.5;
    %xpos(1) = xpos(1)-halfwidth;
    set(h, 'position', xpos);
end

function setaxprops (h, fs)
    set(h, 'fontsize', fs);
    hxl=xlabel('r', 'fontsize', fs);
    hyl=ylabel('\phi', 'fontsize', fs);
    set(h, 'ztick', [0 1 1]);
end

[ RY, RX ] = meshgrid([-30:1:30],[-30:1:30]);

hax(1) = subaxis (2,2,1, 'SpacingVert', sa_spc, 'SpacingHoriz', sa_spc, ...
                  'PaddingLeft', 0, 'PaddingRight', sa_pad_mid, 'PaddingTop', 0, 'PaddingBottom', sa_pad, ...
                  'MarginLeft', sa_marg_sideout, 'MarginRight', sa_marg, 'MarginTop', sa_marg, 'MarginBottom', sa_marg_mid);
surf(RY,RX,eyeframe_right);
title('a) Cartesian co-ordinates', 'fontsize', fs1);
view([180,90]);
zlim([0 1]);
hxl(1) = xlabel('\theta_y', 'fontsize', fs1);
hyl(1) = ylabel('\theta_x', 'fontsize', fs1);
set(hax(1), 'fontsize', fs1, 'ztick', [0 1 1]);



hax(2) = subaxis (2,2,2, 'SpacingVert', sa_spc, 'SpacingHoriz', sa_spc, ...
                  'PaddingLeft', sa_pad_mid, 'PaddingRight', 0, 'PaddingTop', 0, 'PaddingBottom', sa_pad, ...
                  'MarginLeft', sa_marg, 'MarginRight', sa_marg_sideout, 'MarginTop', sa_marg, 'MarginBottom', sa_marg_mid);
surf(corticalmap_right);
title('b) Retinotopic co-ordinates (World)', 'fontsize', fs1);
view([vx,vy])
zlim([0 1])
setaxprops (hax(2), fs1);

hax(3) = subaxis (2,2,3, 'SpacingVert', sa_spc, 'SpacingHoriz', sa_spc, ...
                  'PaddingLeft', 0, 'PaddingRight', sa_pad_mid, 'PaddingTop', sa_pad, 'PaddingBottom', 0, ...
                  'MarginLeft', sa_marg_sideout, 'MarginRight', sa_marg, 'MarginTop', sa_marg_mid, 'MarginBottom', sa_marg);
surf(fef_add_noise_frame);
title('c) With noise added...', 'fontsize', fs1);
view([vx,vy])
zlim([0 1])
setaxprops (hax(3), fs1);

hax(4) = subaxis (2,2,4, 'SpacingVert', sa_spc, 'SpacingHoriz', sa_spc, ...
                  'PaddingLeft', sa_pad_mid, 'PaddingRight', 0, 'PaddingTop', sa_pad, 'PaddingBottom', 0, ...
                  'MarginLeft', sa_marg, 'MarginRight', sa_marg_sideout, 'MarginTop', sa_marg_mid, 'MarginBottom', sa_marg);
surf(fef_frame);
title('d) ...and gaussian blur (FEF)', 'fontsize', fs1);
view([vx,vy])
zlim([0 1])
setaxprops (hax(4), fs1);

display('Done. Screenshot and crop to make a png for the paper...');