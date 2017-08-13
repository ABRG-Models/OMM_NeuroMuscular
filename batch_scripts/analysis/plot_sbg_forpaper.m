% Script to plot weight maps for a paper.

model_path = '/home/seb/models/OMM_NeuroMuscular/TModel4'
[left, right, up, down, zplus, zminus] = load_sbgmaps (model_path, 0);

h_f = figure (1); clf;
h_f_pos = get(h_f, 'Position');
set(h_f, 'Position', [20, 1000, 2100, 1400]);

% Best viewing angle for the surfaces
viewx=320; viewy=32;

% Spacing for subaxes
sa_spc = 0.03;
sa_pad = 0.03;
sa_pad_mid = 0.04;
sa_pad_2d = 0.03;
sa_marg = 0.08;
sa_marg_mid = 0.1;
sa_marg_sideout = 0.1;

% Your favoured line width and marker size:
lw = 2;
ms = 20;

% Main fontsize
fs1 = 32;

zmax = 0.1;

%
% Utility functions
%

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

function offsetzlabel (h)
    xpos = get(h, 'position');
    xpos(1) = xpos(1)-3;
    halfwidth = 0.03;
    xpos(3) = xpos(3)+halfwidth;
    set(h, 'position', xpos);
end

function setaxprops (h, fs)
    set(h, 'fontsize', fs);
end

targxtxt = 'r';
targytxt = '\phi';

% LEFT
hax(1) = subaxis (2,3,1, 'SpacingVert', sa_spc, 'SpacingHoriz', sa_spc, ...
                  'PaddingLeft', sa_pad, 'PaddingRight', sa_pad, 'PaddingTop', sa_pad, 'PaddingBottom', sa_pad, ...
                  'MarginLeft', sa_marg, 'MarginRight', sa_marg, 'MarginTop', sa_marg, 'MarginBottom', sa_marg);

surf (left);
setaxprops (hax(1), fs1);

hxl(1)=xlabel(targxtxt, 'fontsize', fs1);
hyl(1)=ylabel(targytxt, 'fontsize', fs1);
%hzl(1)=zlabel('Weight', 'fontsize', fs1);
%offsetzlabel(hzl(1));

title (['a) Left'], 'fontsize', fs1);
view([viewx viewy]);
zlim([0 zmax]);


% DOWN
hax(2) = subaxis (2,3,2, 'SpacingVert', sa_spc, 'SpacingHoriz', sa_spc, ...
                  'PaddingLeft', sa_pad, 'PaddingRight', sa_pad, 'PaddingTop', sa_pad, 'PaddingBottom', sa_pad, ...
                  'MarginLeft', sa_marg, 'MarginRight', sa_marg, 'MarginTop', sa_marg, 'MarginBottom', sa_marg);


surf (down);
setaxprops (hax(2), fs1);

hxl(2)=xlabel(targxtxt, 'fontsize', fs1);
hyl(2)=ylabel(targytxt, 'fontsize', fs1);
%hzl(2)=zlabel('Weight', 'fontsize', fs1);
%offsetzlabel(hzl(2));

title (['b) Down'], 'fontsize', fs1);
view([viewx viewy]);
zlim([0 zmax]);


% ZPLUS
hax(3) = subaxis (2,3,3, 'SpacingVert', sa_spc, 'SpacingHoriz', sa_spc, ...
                  'PaddingLeft', sa_pad, 'PaddingRight', sa_pad, 'PaddingTop', sa_pad, 'PaddingBottom', sa_pad, ...
                  'MarginLeft', sa_marg, 'MarginRight', sa_marg, 'MarginTop', sa_marg, 'MarginBottom', sa_marg);

surf (zplus);
setaxprops (hax(3), fs1);

hxl(3)=xlabel(targxtxt, 'fontsize', fs1);
hyl(3)=ylabel(targytxt, 'fontsize', fs1);
%hzl(3)=zlabel('Weight', 'fontsize', fs1);
%offsetzlabel(hzl(3));

title (['c) Z+'], 'fontsize', fs1);
view([viewx viewy]);
zlim([0 zmax]);


% RIGHT
hax(4) = subaxis (2,3,4, 'SpacingVert', sa_spc, 'SpacingHoriz', sa_spc, ...
                  'PaddingLeft', sa_pad, 'PaddingRight', sa_pad, 'PaddingTop', sa_pad, 'PaddingBottom', sa_pad, ...
                  'MarginLeft', sa_marg, 'MarginRight', sa_marg, 'MarginTop', sa_marg, 'MarginBottom', sa_marg);

surf (right);
setaxprops (hax(4), fs1);

hxl(4)=xlabel(targxtxt, 'fontsize', fs1);
hyl(4)=ylabel(targytxt, 'fontsize', fs1);
%hzl(4)=zlabel('Weight', 'fontsize', fs1);
%offsetzlabel(hzl(4));

title (['d) Right'], 'fontsize', fs1);
view([viewx viewy]);
zlim([0 zmax]);


% UP
hax(5) = subaxis (2,3,5, 'SpacingVert', sa_spc, 'SpacingHoriz', sa_spc, ...
                  'PaddingLeft', sa_pad, 'PaddingRight', sa_pad, 'PaddingTop', sa_pad, 'PaddingBottom', sa_pad, ...
                  'MarginLeft', sa_marg, 'MarginRight', sa_marg, 'MarginTop', sa_marg, 'MarginBottom', sa_marg);

surf (up);
setaxprops (hax(5), fs1);

hxl(5)=xlabel(targxtxt, 'fontsize', fs1);
hyl(5)=ylabel(targytxt, 'fontsize', fs1);
%hzl(5)=zlabel('Weight', 'fontsize', fs1);
%offsetzlabel(hzl(5));

title (['d) Up'], 'fontsize', fs1);
view([viewx viewy]);
zlim([0 zmax]);


% ZMINUS
hax(6) = subaxis (2,3,6, 'SpacingVert', sa_spc, 'SpacingHoriz', sa_spc, ...
                  'PaddingLeft', sa_pad, 'PaddingRight', sa_pad, 'PaddingTop', sa_pad, 'PaddingBottom', sa_pad, ...
                  'MarginLeft', sa_marg, 'MarginRight', sa_marg, 'MarginTop', sa_marg, 'MarginBottom', sa_marg);

surf (zminus);
setaxprops (hax(6), fs1);

hxl(6)=xlabel(targxtxt, 'fontsize', fs1);
hyl(6)=ylabel(targytxt, 'fontsize', fs1);
%hzl(6)=zlabel('Weight', 'fontsize', fs1);
%offsetzlabel(hzl(6));

title (['e) Z-'], 'fontsize', fs1);
view([viewx viewy]);
zlim([0 zmax]);
