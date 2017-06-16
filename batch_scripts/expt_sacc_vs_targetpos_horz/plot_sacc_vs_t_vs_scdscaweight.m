% Load the data generated by sacc_vs_targetpos.sh runs
r = struct();
rr = [];
r2 = struct();
rr2 = [];

lumval=1;

% Plot lots of trajectories? If you want that set plottraj to 1
plottraj=0;

colours = {'r','b','g','k','c','m','r--','b--','g--','k--','c--','m--'};
colcount = 1;

for j = [0.04 0.05 0.06]
    display(['j:' num2str(j)]);

    % Rotation about Y results
    globstr = sprintf('results/single_exp_g0.2_offs-39_scdsca%.2f/r*.dat', j);
    flist = glob(globstr);
    llen = size(flist)(1);
    for i = [1 : llen]

        rnm = flist{i};
        resdatname = substr(rnm, 44); % strips initial 'results/blah/' string
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
    end
end

%
% For comparison, plot the results from Model1
%
show_model1 = 0;
if show_model1
    flist = glob(['../expt_sacc_vs_targetpos_M1/results/r*.dat']);
    llen = size(flist)(1);
    for i = [1 : llen]
        rnm = flist{i};
        resdatname = substr(rnm, 38); % strips initial 'results/' string
        resdatname = substr(resdatname, 1, size(resdatname)(2)-4); % Strips '.dat' off
        resdatname = strrep (resdatname, '.', 'p');
        resdatname = strrep (resdatname, '-', 'm');
        load (rnm); % loads struct variable called result
        r = struct_merge (r, result);
        % For expected size of rr, consult sacc_vs_targetpos.m
        sz_2 = size(result.(resdatname))(2);
        if (sz_2 >= 14)
            rr = [rr; result.(resdatname), 0];
        end
    end
end

% The rr array contains these columns:
% thetaX, thetaY, fix_lum, gap_ms, lumval, eyeRxAvg, eyeRyAvg, eyeRzAvg, eyeRxSD, eyeRySD, eyeRzSD, latmean, latsd, dopamine

%
% sort rr on target position value
rr = sortrows(rr,2);

weights = unique(rr(:,15))

% Achieved position (Rot Y)
figure(102);
clf;
hold on;
colcount = 1;
legend_str='';
for w = weights'
    rr_1 = [];
    rr_1 = rr(find(rr(:,15)==w),:);
    errorbar (rr_1(:,2),rr_1(:,7),rr_1(:,10), colours{colcount})
    legend_str = [legend_str; 'L: ' num2str(rr_1(1,5)) ' DA: ' num2str(rr_1(1,14)) ' w: ' num2str(w)];
    colcount = colcount + 1;
end
plot ([-20,-6],[-20,-6], 'k--');
if show_model1
    legend_str = [legend_str; 'Perfect linear response'];
end
hold off;
xlabel('Target y');
ylabel('eyeRy');
legend(legend_str);

% Latency
figure(105);
clf;
hold on;
colcount = 1;
legend_str='';
for w = weights'
    rr_1 = [];
    rr_1 = rr(find(rr(:,15)==w),:);
    errorbar (rr_1(:,2),rr_1(:,12),rr_1(:,13), colours{colcount})
    legend_str = [legend_str; 'L: ' num2str(rr_1(1,5)) ' DA: ' num2str(rr_1(1,14)) ' scd-sca w: ' num2str(w)];
    colcount = colcount + 1;
end
xlabel('Target y');
ylabel('Latency (ms)');
legend(legend_str);
