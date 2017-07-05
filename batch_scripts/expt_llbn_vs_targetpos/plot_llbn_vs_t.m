% Load the data generated by llbn_vs_targetpos.sh runs for
% horizontal movements.
r = struct();
rr = [];
llbn_ar = [];
llbn_sing = [];
lumval=1;

colours = {'r','b','g','k','c','m','r--','b--','g--','k--','c--','m--'};
colcount = 1;

flist = glob('results/r*.dat');
llen = size(flist)(1);
for i = [1 : llen]

    rnm = flist{i};
    resdatname = substr(rnm, 9); % strips initial 'results' string
    resdatname = substr(resdatname, 1, size(resdatname)(2)-4); % Strips '.dat' off
    resdatname = strrep (resdatname, '.', 'p');
    resdatname = strrep (resdatname, '-', 'm');

    load (rnm); % loads struct variable called result
    r = struct_merge (r, result);

    % For expected size of rr, consult sacc_vs_targetpos.m
    sz_2 = size(result.(resdatname))(2);

    if (sz_2 == 14)
        rr = [rr; result.(resdatname)];
    end

    llbn = result.([resdatname '_llbn']);

    % Select all the "2"s - the right llbns.
    llbn_red = llbn(2:4:size(llbn)(1),:);

    llbn_mean = mean(llbn_red); % 1 x 600

    % Mean llbn values - note I put the target position value in
    % col 1 for later sorting.
    llbn_ar = [llbn_ar; result.(resdatname)(2), llbn_mean];

    % Choose row 3 for no strong reason. 1 to 6 is range:
    llbn_sing = [llbn_sing; result.(resdatname)(2), llbn_red(3,:)];
end

% The rr array contains these columns:
% thetaX, thetaY, fix_lum, gap_ms, lumval, eyeRxAvg, eyeRyAvg, eyeRzAvg, eyeRxSD, eyeRySD, eyeRzSD, latmean, latsd, dopamine

%
% sort rr on target position value
rr = sortrows(rr,2);

%  Sort on target position value then discard that column:
llbn_ar = sortrows(llbn_ar,1);
llbn_ar = llbn_ar(:,2:end);

llbn_sing = sortrows(llbn_sing,1);
llbn_sing = llbn_sing(:,2:end);

% Achieved position (Rot Y)
figure(62);
errorbar (rr(:,2),rr(:,7),rr(:,10),'o-')
hold on;
plot ([-15,-8],[-15,-8], 'g--');
hold off;
xlabel('Target y');
ylabel('eyeRy');
legend(['Lum: ' num2str(rr(1,5)) ' Dopa: ' num2str(rr(1,14))])

% Latency
figure(65);
errorbar (rr(:,2),rr(:,12),rr(:,13),'o-')
xlabel('Target y');
ylabel('Latency (ms)');
legend(['Lum: ' num2str(rr(1,5)) ' Dopa: ' num2str(rr(1,14))]);

% Means of llbn activity for each target
figure(66);
x = [rr(:,2)];
xx = repmat(x, 1, 600);
size(xx)
z = [1:600];
zz = repmat(z, size(x), 1);
size(zz)
size(llbn_ar)
plot3(xx',zz',llbn_ar');
title ('Mean LLBN activity')
xlabel ('TargY');
ylabel ('time (ms)');
zlabel ('LLBN activity');

% Selected index activity plot - single LLBN; just to match with
% the mean plot in figure(66).
figure(67);
plot3(xx',zz',llbn_sing');
title ('Single llbn activity (not means)')
xlabel ('TargY');
ylabel ('time (ms)');
zlabel ('LLBN activity');

% Sum plot - sum of llbn activity.
llbn_ar2 = llbn_ar(:,200:450);
lsums = sum(llbn_ar2,2);
figure(68);
plot (x,lsums,'bo-');
title ('summed mean llbn activity');
xlabel ('TargY');
ylabel ('summed mean llbn activity');
