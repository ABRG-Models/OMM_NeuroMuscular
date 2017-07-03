% Load the data generated by llbn_vs_targetpos.sh runs for
% horizontal movements.
r = struct();
rr = [];
llbn_ar = [];
llbn_sing = [];
lumval=1;

colours = {'r','b','g','k','c','m','r--','b--','g--','k--','c--','m--'};
colcount = 1;

for j = [0 4 8 10 12 15]

     globstr = sprintf('results/WF%0.0f/r*.dat', j);
     %display(globstr);
     flist = glob(globstr);
     llen = size(flist)(1);
     for i = [1 : llen]

         rnm = flist{i};
         if j<10
             resdatname = substr(rnm, 13); % strips initial
                                           % 'results' string
         else
             resdatname = substr(rnm, 14);
         end

         resdatname = substr(resdatname, 1, size(resdatname)(2)-4); % Strips '.dat' off
         resdatname = strrep (resdatname, '.', 'p');
         resdatname = strrep (resdatname, '-', 'm');

         load (rnm); % loads struct variable called result
         r = struct_merge (r, result);

         % For expected size of rr, consult sacc_vs_targetpos.m
         sz_2 = size(result.(resdatname))(2);

         if (sz_2 >= 14)
             rr = [rr; result.(resdatname), j];
         end

         llbn = result.([resdatname '_llbn']);

         % Select all the "2"s - the right llbns.
         llbn_red = llbn(2:4:size(llbn)(1),:);

         llbn_mean = mean(llbn_red); % 1 x 600

         % Mean llbn values - note I put the target position value in
         % col 1 for later sorting.
         llbn_ar = [llbn_ar; result.(resdatname)(2), llbn_mean, j];

         % Choose row 3 for no strong reason. 1 to 6 is range:
         llbn_sing = [llbn_sing; result.(resdatname)(2), llbn_red(3,:), j];
     end
end

% The rr array contains these columns:
% thetaX, thetaY, fix_lum, gap_ms, lumval, eyeRxAvg, eyeRyAvg, eyeRzAvg, eyeRxSD, eyeRySD, eyeRzSD, latmean, latsd, dopamine

%
% sort rr on target position value
rr = sortrows(rr,2);

wfs = unique(rr(:,15))'

%  Sort on target position value then discard that column
llbn_ar = sortrows(llbn_ar,1);
llbn_ar = llbn_ar(:,2:end);

llbn_sing = sortrows(llbn_sing,1);
llbn_sing = llbn_sing(:,2:end);

% Achieved position (Rot Y)
figure(62);
clf;
hold on;
legend_str = '';
for w = wfs
    rr_1 = [];
    rr_1 = rr(find(rr(:,15)==w),:);
    errorbar (rr_1(:,2),rr_1(:,7),rr_1(:,10),'o-')
    legend_str = [legend_str; 'L: ' num2str(rr_1(1,5)) ' DA: ' num2str(rr_1(1,14)) ' WF: ' num2str(w)];
end
plot ([-15,-8],[-15,-8], 'g--');
xlabel('Target y');
ylabel('eyeRy');
legend(legend_str);

% Latency
figure(65);
clf;
hold on;

for w = wfs
    rr_1 = [];
    rr_1 = rr(find(rr(:,15)==w),:);
    errorbar (rr_1(:,2),rr_1(:,12),rr_1(:,13),'o-')
    legend_str = [legend_str; 'Lum: ' num2str(rr_1(1,5)) ' Dopa: ' num2str(rr_1(1,14)) ' WF: ' num2str(w)];
end
xlabel('Target y');
ylabel('Latency (ms)');
legend(legend_str);

% Means of llbn activity for each target
figure(66);
clf;
hold on;
legend_str = '';
colcount = 0;
for w = wfs
    colcount = colcount + 1;
    rr_1 = [];
    rr_1 = rr(find(rr(:,15)==w),:);
    llbn_1 = [];
    llbn_1 = llbn_ar(find(llbn_ar(:,601)==w),1:end-1);
    x = [rr_1(:,2)];
    xx = repmat(x, 1, 600);
    %size(xx)
    z = [1:600];
    zz = repmat(z, size(x), 1);
    %size(zz)
    %size(llbn_1)
    plot3(xx',zz',llbn_1','color',colours{colcount});
    %legend_str = [legend_str; 'WF:' num2str(j)]; % fails
end
title ('Mean LLBN activity')
xlabel ('TargY');
ylabel ('time (ms)');
zlabel ('LLBN activity');
legend ('Red is WF 15');

% Selected index activity plot - single LLBN; just to match with
% the mean plot in figure(66).
figure(67);
clf;
hold on;
legend_str = '';
colcount = 0;
for w = wfs
    colcount = colcount + 1;
    rr_1 = [];
    rr_1 = rr(find(rr(:,15)==w),:);
    llbn_1 = [];
    llbn_1 = llbn_sing(find(llbn_sing(:,601)==w),1:end-1);
    x = [rr_1(:,2)];
    xx = repmat(x, 1, 600);
    %size(xx)
    z = [1:600];
    zz = repmat(z, size(x), 1);
    %size(zz)
    %size(llbn_1)
    plot3(xx',zz',llbn_1','color',colours{colcount});
    %legend_str = [legend_str; 'WF:' num2str(j)];
end
title ('Single llbn activity (not means)')
xlabel ('TargY');
ylabel ('time (ms)');
zlabel ('LLBN activity');
legend ('Red is WF 15');

% Sum plot - sum of llbn activity.
figure(68);
clf;
hold on;
legend_str = '';
colcount = 0;
for w = wfs
    colcount = colcount + 1;
    llbn_1 = [];
    llbn_1 = llbn_ar(find(llbn_ar(:,601)==w),1:end-1);

    llbn_ar2 = llbn_1(:,200:450);
    lsums = sum(llbn_ar2,2);

    plot (x,lsums,'color',colours{colcount}, 'o-');
    legend_str = [legend_str; 'WF: ' num2str(w)];
end
title ('summed mean llbn activity');
xlabel ('TargY');
ylabel ('summed mean llbn activity');
legend(legend_str);