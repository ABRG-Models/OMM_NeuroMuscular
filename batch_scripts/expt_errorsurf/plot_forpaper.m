% Load the data and plot the error surface.

% Do this all on one plot...

% Load the data
[rr3, errs3, errmags3] = load_errorsurf ('TModel3', 14.5);
[rr4, errs4, errmags4] = load_errorsurf ('TModel4', 14.5);

h_f = figure (1); clf;
h_f_pos = get(h_f, 'Position');
set(h_f, 'Position', [300, 500, 1200, 800]);

% Best viewing angle for the surfaces
viewx=90; viewy=90;

%text (0, 0, ['Time = ' num2str(t) ' ms']);

% Spacing for subaxes
sa_spc = 0.03;
sa_pad = 0.01;
sa_pad_2d = 0.03;
sa_marg = 0.04;

% Your favoured line width and marker size:
lw = 2;
ms = 20;

if 0
h_errTM3 = subaxis (2,3,1, 'Spacing', sa_spc, 'Padding', sa_pad, 'Margin', sa_marg);
trisurf(delaunay(X,Y),X,Y,Z);
hold on;
plot ([1,-15],[-1,15],'b','linewidth',lw,'markersize',ms)
plot ([-15,1],[-15,1],'b','linewidth',lw,'markersize',ms)
hold off;
xlabel('Target X');
ylabel('Target Y');
zlabel('mag. of error vector');
title (['TModel3: Error magnitude (total: ' num2str(sum(Z)) ')']);
view([viewx viewy]);
zlim([0 7]);
xlim([-15,1]);
end

X=rr3(:,1);
Y=rr3(:,2);
Z=errmags3;

h_xerrTM3 = subaxis (2,3,1, 'Spacing', sa_spc, 'Padding', sa_pad, 'Margin', sa_marg);
trisurf(delaunay(X,Y),X,Y,abs(errs3(:,1)));
hold on;
plot ([1,-15],[-1,15],'b','linewidth',lw,'markersize',ms)
plot ([-15,1],[-15,1],'b','linewidth',lw,'markersize',ms)
hold off;
xlabel('Target X');
ylabel('Target Y');
zlabel('mag. of errorRotX)');
title (['X Error magnitude (total: ' num2str(sum(abs(errs3(:,1)))) ')']);
view([viewx viewy]);
zlim([0 7]);
xlim([-15,1]);

h_yerrTM3 = subaxis (2,3,2, 'Spacing', sa_spc, 'Padding', sa_pad, 'Margin', sa_marg);
trisurf(delaunay(X,Y),X,Y,abs(errs3(:,2)));
hold on;
plot ([1,-15],[-1,15],'b','linewidth',lw,'markersize',ms)
plot ([-15,1],[-15,1],'b','linewidth',lw,'markersize',ms)
hold off;
%xlabel('Target X');
ylabel('Target Y');
zlabel('mag. of errorRotY)');
title (['Y Error magnitude (total: ' num2str(sum(abs(errs3(:,2)))) ')']);
view([viewx viewy]);
zlim([0 7]);
xlim([-15,1]);

h_zerrTM3 = subaxis (2,3,3, 'Spacing', sa_spc, 'Padding', sa_pad, 'Margin', sa_marg);
trisurf(delaunay(X,Y),X,Y,abs(errs3(:,3)));
hold on;
plot ([1,-15],[-1,15],'b','linewidth',lw,'markersize',ms)
plot ([-15,1],[-15,1],'b','linewidth',lw,'markersize',ms)
hold off;
%xlabel('Target X');
ylabel('Target Y');
zlabel('mag. of errorRotZ)');
title (['Z Error magnitude (total: ' num2str(sum(abs(errs3(:,3)))) ')']);
view([viewx viewy]);
zlim([0 7]);
xlim([-15,1]);


%
% TModel4
%

X=rr4(:,1);
Y=rr4(:,2);
Z=errmags4;

h_xerrTM4 = subaxis (2,3,4, 'Spacing', sa_spc, 'Padding', sa_pad, 'Margin', sa_marg);
trisurf(delaunay(X,Y),X,Y,abs(errs4(:,1)));
hold on;
plot ([1,-15],[-1,15],'b','linewidth',lw,'markersize',ms)
plot ([-15,1],[-15,1],'b','linewidth',lw,'markersize',ms)
hold off;
xlabel('Target X');
ylabel('Target Y');
zlabel('mag. of errorRotX)');
title (['X Error magnitude (total: ' num2str(sum(abs(errs4(:,1)))) ')']);
view([viewx viewy]);
zlim([0 7]);
xlim([-15,1]);

h_yerrTM4 = subaxis (2,3,5, 'Spacing', sa_spc, 'Padding', sa_pad, 'Margin', sa_marg);
trisurf(delaunay(X,Y),X,Y,abs(errs4(:,2)));
hold on;
plot ([1,-15],[-1,15],'b','linewidth',lw,'markersize',ms)
plot ([-15,1],[-15,1],'b','linewidth',lw,'markersize',ms)
hold off;
%xlabel('Target X');
ylabel('Target Y');
zlabel('mag. of errorRotY)');
title (['Y Error magnitude (total: ' num2str(sum(abs(errs4(:,2)))) ')']);
view([viewx viewy]);
zlim([0 7]);
xlim([-15,1]);

h_zerrTM4 = subaxis (2,3,6, 'Spacing', sa_spc, 'Padding', sa_pad, 'Margin', sa_marg);
trisurf(delaunay(X,Y),X,Y,abs(errs4(:,3)));
hold on;
plot ([1,-15],[-1,15],'b','linewidth',lw,'markersize',ms)
plot ([-15,1],[-15,1],'b','linewidth',lw,'markersize',ms)
hold off;
%xlabel('Target X');
ylabel('Target Y');
zlabel('mag. of errorRotZ)');
title (['Z Error magnitude (total: ' num2str(sum(abs(errs4(:,3)))) ')']);
view([viewx viewy]);
zlim([0 7]);
xlim([-15,1]);
