% Load the data and plot the error surface.

r = struct();
rr = [];

lumval=1;

colours = {'r','b','g','k','c','m','r--','b--','g--','k--','c--','m--'};
colcount = 1;

flist = glob('results/TModel1/r*.dat');
llen = size(flist)(1);
for i = [1 : llen]

    rnm = flist{i};
    resdatname = substr(rnm, 9+8); % strips initial 'results' string
    resdatname = substr(resdatname, 1, size(resdatname)(2)-4); % Strips '.dat' off
    resdatname = strrep (resdatname, '.', 'p');
    resdatname = strrep (resdatname, '-', 'm');

    load (rnm); % loads struct variable called result
    r = struct_merge (r, result);

    % For expected size of rr, consult sacc_vs_targetpos.m
    sz_1 = size(result.(resdatname))(1);
    sz_2 = size(result.(resdatname))(2);

    if (sz_2 == 14)
        rr = [rr; result.(resdatname)];
    end

end

% The rr array contains these columns:
% thetaX, thetaY, fix_lum, gap_ms, lumval, eyeRxAvg, eyeRyAvg, eyeRzAvg, eyeRxSD, eyeRySD, eyeRzSD, latmean, latsd, dopamine

%
% sort rr on target position value
rr = sortrows(rr,1);

% First plot error magnitude vs position on a 3D plot

% Achieved position (Rot Y)
figure(83);

targs = [rr(:,1),rr(:,2),zeros(size(rr)(1),1)];
actuals = rr(:,6:8);
errs = targs - actuals;
errmags = sqrt(errs(:,1).*errs(:,1) + errs(:,2).*errs(:,2) + errs(:,3).*errs(:,3));

X=rr(:,1);
Y=rr(:,2);
Z=errmags;
trisurf(delaunay(X,Y),X,Y,Z);

%plot3 (rr(:,1),rr(:,2),errmags,'o')

%surf((rr(:,1),rr(:,2),errmags)

hold on;
%plot ([-15,-8],[-15,-8], 'g--');
hold off;
xlabel('Target X');
ylabel('Target Y');
zlabel('mag. of error vector');
title ('Error magnitude');

% Latency
%figure(65);
%errorbar (rr(:,2),rr(:,12),rr(:,13),'o-')
%xlabel('Target y');
%ylabel('Latency (ms)');
%legend(['Lum: ' num2str(rr(1,5)) ' Dopa: ' num2str(rr(1,14))]);
%title ('Horizontal');
