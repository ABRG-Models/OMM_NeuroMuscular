% Load the data generated by sacc_vs_targetpos.sh runs
r = struct();
rr = [];

lumval=1;

% Plot lots of trajectories? If you want that set plottraj to 1
plottraj=0;

if plottraj
    % Decide how many of the runs you want to show:
    num_runs_to_show = 4
    fa = 13; figure(fa); clf;
    fb = 14; figure(fb); clf;
end

colours = {'r','b','g','k','c','m','r--','b--','g--','k--','c--','m--'};
colcount = 1;

flist = glob('results/TModel2/r*.dat');
llen = size(flist)(1);
for i = [1 : llen]

    rnm = flist{i};
    resdatname = substr(rnm, 9+8); % strips initial 'results/' string
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

    if plottraj
        % Also plot each trajectory from the model run data
        for j=1:num_runs_to_show
            % F is fix off - that's 0.2s-gap; T is target on; that
            % is 0.2s. The 0.2 is found in perform_saccade.m
            filepath=['/fastdata/' getenv('USER') '/ocmRX' num2str(result.params.targetThetaX) 'RY' num2str(result.params.targetThetaY) ...
                      '_F' num2str(result.params.fixOff) '_T' num2str(result.params.targetOn) '_L' num2str(result.params.targetLuminance) ...
                      '_D'  num2str(result.params.dopamine) '_1_' num2str(j)]
            % If file exists...
            if exist(filepath, 'dir') == 7
                A=load_ocm_min(filepath);
                figure(fa);
                hold on;
                plot (A.eyeRx(1:450), colours{colcount})
                title ([num2str(i) ' degrees - x vs t']);
                xlabel('time (ms)');
                ylabel('RotX degrees');
                figure(fb);
                hold on;
                plot (A.eyeRx(1:450), A.eyeRy(1:450), 'b')
                title ([num2str(i) ' degrees - x/y traj'])
                xlabel('RotX degrees');
                ylabel('RotY degrees');
            end
        end
        colcount = colcount + 1;

        fa = fa + 2;
        fb = fb + 2;
    end
end

% The rr array contains these columns:
% thetaX, thetaY, fix_lum, gap_ms, lumval, eyeRxAvg, eyeRyAvg, eyeRzAvg, eyeRxSD, eyeRySD, eyeRzSD, latmean, latsd, dopamine

%
% sort rr on target position value
rr = sortrows(rr,1);

% Achieved position (Rot X)
figure(12);
errorbar (rr(:,1),rr(:,6),rr(:,9),'o-')
hold on;
plot ([-15,-8],[-15,-8], 'g--');
hold off;
xlabel('Target x');
ylabel('eyeRx');
legend(['Lum: ' num2str(rr(1,5)) ' Dopa: ' num2str(rr(1,14))])
title('Vertical');

% Latency
figure(15);
errorbar (rr(:,1),rr(:,12),rr(:,13),'o-')
xlabel('Target x');
ylabel('Latency (ms)');
legend(['Lum: ' num2str(rr(1,5)) ' Dopa: ' num2str(rr(1,14))]);
title('Vertical');

% Output for Veusz
output_veusz = 0
if output_veusz
    targrot = [rr(:,1),rr(:,6),rr(:,9)];
    f = fopen ('results/sacc_eyerx_vs_targ.csv', 'w');
    fprintf (f, 'TargX,eyeRx,+-\n');
    dlmwrite (f, targrot, '-append');
    fclose(f);

    latrot = [rr(:,1),rr(:,12),rr(:,13)];
    f = fopen ('results/sacc_lat_vs_targ.csv', 'w');
    fprintf (f, 'TargX,Latency,+-\n');
    dlmwrite (f, latrot, '-append');
    fclose(f);
end
