% Load the data and plot the error surface.

% Do this all on one plot...

% Load the data
do_load = 1
if do_load
    %[rr3, errs3, targmags3, errmags3, errpcnt3] = load_errorsurf ('TModel3', 14.5);
    [rr4, errs4, targmags4, errmags4, errpcnt4] = load_errorsurf ('TModel4', 14.5);
end

h_f = figure (1); clf;
h_f_pos = get(h_f, 'Position');
set(h_f, 'Position', [20, 1050, 2100, 1300]);

% Best viewing angle for the surfaces
viewx=90; viewy=90;
%viewx=230; viewy=30;

% max limit for colour map
zmax = 25;

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

colormap('hot')

hax(1) = subaxis (2,2,1, 'SpacingVert', sa_spc, 'SpacingHoriz', sa_spc, ...
                  'PaddingLeft', 0, 'PaddingRight', sa_pad_mid, 'PaddingTop', 0, 'PaddingBottom', sa_pad, ...
                  'MarginLeft', sa_marg_sideout, 'MarginRight', sa_marg, 'MarginTop', sa_marg, 'MarginBottom', sa_marg_mid);

trisurf(delaunay(X,Y),X,Y,abs(errpcnt4));
hold on;
plot ([1,-15],[-1,15],'k','linewidth',lw,'markersize',ms)
plot ([-15,1],[-15,1],'k','linewidth',lw,'markersize',ms)
hold off;

setaxprops (hax(1), fs1);

hxl(1)=xlabel(targxtxt, 'fontsize', fs1);
offsetxlabel(hxl(1));
hyl(1)=ylabel(targytxt, 'fontsize', fs1);
offsetylabel(hyl(1));

% Compute mean percentage error:
meanpcnterr = sum(abs(errpcnt4)) ./ length(errpcnt4);

zlabel('Error magnitude (%)');
title (['a) Error magnitude (mean:' sprintf('%5.1f', meanpcnterr) '%)'], 'fontsize', fs1);
view([viewx viewy]);
zlim([0 zmax]);
xlim([-15,1]);

%
% X
%
hax(2) = subaxis (2,2,2, 'SpacingVert', sa_spc, 'SpacingHoriz', sa_spc, ...
                  'PaddingLeft', sa_pad_mid, 'PaddingRight', 0, 'PaddingTop', 0, 'PaddingBottom', sa_pad, ...
                  'MarginLeft', sa_marg, 'MarginRight', sa_marg_sideout, 'MarginTop', sa_marg, 'MarginBottom', sa_marg_mid);

trisurf(delaunay(X,Y),X,Y,abs(errs4(:,1))./abs(targmags4).*100);
hold on;
plot ([1,-15],[-1,15],'k','linewidth',lw,'markersize',ms)
plot ([-15,1],[-15,1],'k','linewidth',lw,'markersize',ms)
hold off;

setaxprops (hax(2), fs1);

hxl(2)=xlabel(targxtxt, 'fontsize', fs1);
offsetxlabel(hxl(2));
hyl(2)=ylabel(targytxt, 'fontsize', fs1);
offsetylabel(hyl(2));

zlabel('|E_{RotX}|  (%)');
title (['b) X Error magnitude (mean:' sprintf('%5.1f', sum(abs(errs4(:,1))./abs(targmags4).*100) ./ length(errs4(:,1)) ) '%)'], 'fontsize', fs1);
view([viewx viewy]);
zlim([0 zmax]);
xlim([-15,1]);

%
% Y
%
hax(3) = subaxis (2,2,3, 'SpacingVert', sa_spc, 'SpacingHoriz', sa_spc, ...
                  'PaddingLeft', 0, 'PaddingRight', sa_pad_mid, 'PaddingTop', sa_pad, 'PaddingBottom', 0, ...
                  'MarginLeft', sa_marg_sideout, 'MarginRight', sa_marg, 'MarginTop', sa_marg_mid, 'MarginBottom', sa_marg);

trisurf(delaunay(X,Y),X,Y,abs(errs4(:,2))./abs(targmags4).*100);
hold on;
plot ([1,-15],[-1,15],'k','linewidth',lw,'markersize',ms)
plot ([-15,1],[-15,1],'k','linewidth',lw,'markersize',ms)
hold off;

setaxprops (hax(3), fs1);

hxl(3)=xlabel(targxtxt, 'fontsize', fs1);
offsetxlabel(hxl(3));
hyl(3)=ylabel(targytxt, 'fontsize', fs1);
offsetylabel(hyl(3));

zlabel('mag. of errorRotY)');
title (['c) Y Error magnitude (mean:' sprintf('%5.1f', sum(abs(errs4(:,2))./abs(targmags4).*100) ./ length(errs4(:,2)) ) '%)'], 'fontsize', fs1);
view([viewx viewy]);
zlim([0 zmax]);
xlim([-15,1]);

%
% Z
%
hax(4) = subaxis (2,2,4, 'SpacingVert', sa_spc, 'SpacingHoriz', sa_spc, ...
                  'PaddingLeft', sa_pad_mid, 'PaddingRight', 0, 'PaddingTop', sa_pad, 'PaddingBottom', 0, ...
                  'MarginLeft', sa_marg, 'MarginRight', sa_marg_sideout, 'MarginTop', sa_marg_mid, 'MarginBottom', sa_marg);

trisurf(delaunay(X,Y),X,Y,abs(errs4(:,3))./abs(targmags4).*100);
hold on;
plot ([1,-15],[-1,15],'k','linewidth',lw,'markersize',ms)
plot ([-15,1],[-15,1],'k','linewidth',lw,'markersize',ms)
hold off;

setaxprops (hax(4), fs1);

hxl(4)=xlabel(targxtxt, 'fontsize', fs1);
offsetxlabel(hxl(4));
hyl(4)=ylabel(targytxt, 'fontsize', fs1);
offsetylabel(hyl(4));

zlabel('mag. of errorRotZ)');
title (['d) Z Error magnitude (mean:' sprintf('%5.1f', sum(abs(errs4(:,3))./abs(targmags4).*100) ./ length(errs4(:,3)) ) '%)'], 'fontsize', fs1);
view([viewx viewy]);
zlim([0 zmax]);
xlim([-15,1]);

clim=[0 80]; % Data range matching that for TModel3
caxis(clim);
set(hax,'CLim',clim);

opos = get (hax(4), 'position'); % Original Position
cbh = colorbar('position', [opos(1)+opos(3)+0.04  opos(2)  0.02  opos(2)+opos(3)*2.1])
set (hax(4), 'position', opos);
set(cbh,'linewidth', 0.5, 'tickdir', 'out', 'ticklength', [0.01,0.01], 'ytick', [0, 5, 10, 15, 30, 50, 70]);
%'yticklabel',{'zero','ten','23','42','fifty'},

set(cbh, 'position', [opos(1)+opos(3)+0.04  opos(2)  0.02 opos(2)+opos(3)*2.1], 'fontsize', fs1)
title(cbh, 'Error (%)');

display('Done. I just use a screenshot of this and then crop it for my png');