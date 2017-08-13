% Load the data and plot the error surface.

% Do this all on one plot...

% Load the data
do_load = 1
if do_load
    [rr3, errs3, errmags3] = load_errorsurf ('TModel3', 14.5);
    [rr4, errs4, errmags4] = load_errorsurf ('TModel4', 14.5);
end

h_f = figure (1); clf;
h_f_pos = get(h_f, 'Position');
set(h_f, 'Position', [20, 1050, 2100, 1300]);

% Best viewing angle for the surfaces
viewx=90; viewy=90;

%text (0, 0, ['Time = ' num2str(t) ' ms']);

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

% Main fontsize
fs1 = 38;

targxtxt = 'Target X (\deg)';
targytxt = 'Target Y (\deg)';

%
% TModel4
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

function setaxprops (h, fs)
    set(h, 'fontsize', fs);
end

X=rr4(:,1);
Y=rr4(:,2);
Z=errmags4;

hax(1) = subaxis (2,2,1, 'SpacingVert', sa_spc, 'SpacingHoriz', sa_spc, ...
                  'PaddingLeft', 0, 'PaddingRight', sa_pad_mid, 'PaddingTop', 0, 'PaddingBottom', sa_pad, ...
                  'MarginLeft', sa_marg_sideout, 'MarginRight', sa_marg, 'MarginTop', sa_marg, 'MarginBottom', sa_marg_mid);

trisurf(delaunay(X,Y),X,Y,abs(errmags4));
hold on;
plot ([1,-15],[-1,15],'b','linewidth',lw,'markersize',ms)
plot ([-15,1],[-15,1],'b','linewidth',lw,'markersize',ms)
hold off;

setaxprops (hax(1), fs1);

hxl(1)=xlabel(targxtxt, 'fontsize', fs1);
offsetxlabel(hxl(1));
hyl(1)=ylabel(targytxt, 'fontsize', fs1);
offsetylabel(hyl(1));

zlabel('Error magnitude (\deg)');
title (['a) Error magnitude (total: ' num2str(sum(abs(errmags4))) ')'], 'fontsize', fs1);
view([viewx viewy]);
zlim([0 3]);
xlim([-15,1]);
hax(2) = subaxis (2,2,2, 'SpacingVert', sa_spc, 'SpacingHoriz', sa_spc, ...
                  'PaddingLeft', sa_pad_mid, 'PaddingRight', 0, 'PaddingTop', 0, 'PaddingBottom', sa_pad, ...
                  'MarginLeft', sa_marg, 'MarginRight', sa_marg_sideout, 'MarginTop', sa_marg, 'MarginBottom', sa_marg_mid);

trisurf(delaunay(X,Y),X,Y,abs(errs4(:,1)));
hold on;
plot ([1,-15],[-1,15],'b','linewidth',lw,'markersize',ms)
plot ([-15,1],[-15,1],'b','linewidth',lw,'markersize',ms)
hold off;

setaxprops (hax(2), fs1);

hxl(2)=xlabel(targxtxt, 'fontsize', fs1);
offsetxlabel(hxl(2));
hyl(2)=ylabel(targytxt, 'fontsize', fs1);
offsetylabel(hyl(2));

zlabel('|E_{RotX}|  (\deg)');
title (['b) X Error magnitude (total: ' num2str(sum(abs(errs4(:,1)))) ')'], 'fontsize', fs1);
view([viewx viewy]);
zlim([0 3]);
xlim([-15,1]);

hax(3) = subaxis (2,2,3, 'SpacingVert', sa_spc, 'SpacingHoriz', sa_spc, ...
                  'PaddingLeft', 0, 'PaddingRight', sa_pad_mid, 'PaddingTop', sa_pad, 'PaddingBottom', 0, ...
                  'MarginLeft', sa_marg_sideout, 'MarginRight', sa_marg, 'MarginTop', sa_marg_mid, 'MarginBottom', sa_marg);

trisurf(delaunay(X,Y),X,Y,abs(errs4(:,2)));
hold on;
plot ([1,-15],[-1,15],'b','linewidth',lw,'markersize',ms)
plot ([-15,1],[-15,1],'b','linewidth',lw,'markersize',ms)
hold off;

setaxprops (hax(3), fs1);

hxl(3)=xlabel(targxtxt, 'fontsize', fs1);
offsetxlabel(hxl(3));
hyl(3)=ylabel(targytxt, 'fontsize', fs1);
offsetylabel(hyl(3));

zlabel('mag. of errorRotY)');
title (['c) Y Error magnitude (total: ' num2str(sum(abs(errs4(:,2)))) ')'], 'fontsize', fs1);
view([viewx viewy]);
zlim([0 3]);
xlim([-15,1]);

hax(4) = subaxis (2,2,4, 'SpacingVert', sa_spc, 'SpacingHoriz', sa_spc, ...
                  'PaddingLeft', sa_pad_mid, 'PaddingRight', 0, 'PaddingTop', sa_pad, 'PaddingBottom', 0, ...
                  'MarginLeft', sa_marg, 'MarginRight', sa_marg_sideout, 'MarginTop', sa_marg_mid, 'MarginBottom', sa_marg);

trisurf(delaunay(X,Y),X,Y,abs(errs4(:,3)));
hold on;
plot ([1,-15],[-1,15],'b','linewidth',lw,'markersize',ms)
plot ([-15,1],[-15,1],'b','linewidth',lw,'markersize',ms)
hold off;

setaxprops (hax(4), fs1);

hxl(4)=xlabel(targxtxt, 'fontsize', fs1);
offsetxlabel(hxl(4));
hyl(4)=ylabel(targytxt, 'fontsize', fs1);
offsetylabel(hyl(4));

zlabel('mag. of errorRotZ)');
title (['d) Z Error magnitude (total: ' num2str(sum(abs(errs4(:,3)))) ')'], 'fontsize', fs1);
view([viewx viewy]);
zlim([0 3]);
xlim([-15,1]);

opos = get (hax(4), 'position'); % Original POSition
cbh = colorbar('position', [opos(1)+opos(3)+0.04  opos(2)  0.02  opos(2)+opos(3)*2.1])
set (hax(4), 'position', opos);
set(cbh,'linewidth', 0.5, 'tickdir', 'out', 'ticklength', [0.01,0.01], 'ytick', [0, 0.5, 1, 1.5, 2]);
%'yticklabel',{'zero','ten','23','42','fifty'},

set(cbh, 'position', [opos(1)+opos(3)+0.04  opos(2)  0.02 opos(2)+opos(3)*2.1], 'fontsize', fs1)
title(cbh, 'Error (\deg)');

display('Done. I just use a screenshot of this and then crop it for my png');