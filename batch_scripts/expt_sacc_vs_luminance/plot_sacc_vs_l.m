% Load the data generated by sacc_vs_luminance.sh runs
r = struct();
rr = [];

num_runs=6

thetax=0
thetay=-10

figure(33);
clf;

plottraj = 0;

colours = {'r','b','g','k','c','m','r--','b--','g--','k--','c--','m--'};
colcount = 1;
for i = [0.5 : 0.2 : 2.1]
    resname = ['r_' num2str(thetax) '_' num2str(thetay) '_' num2str(i) '.dat'];
    resdatname = ['r_' num2str(thetax) '_' num2str(thetay) '_' num2str(i)];
    resdatname = strrep (resdatname, '.', 'p');
    resdatname = strrep (resdatname, '-', 'm');

    rnm = ['results/' resname];
    display(['Loading file ' rnm])
    load (rnm); % loads struct variable called result

    r = struct_merge (r, result);

    if (size(result.(resdatname))(2) == 9)
        rr = [rr; result.(resdatname)];
    end

    % Also plot each trajectory from the model run data
    if plottraj
        for j=1:num_runs
            filepath=['/fastdata/' getenv('USER') '/oculomotorRX0RY' num2str(thetay) '_' num2str(i) '_' num2str(j)];
            A=load_ocm_min(filepath);
            figure(33);
            hold on;
            plot (A.eyeRy, colours{colcount})
        end
    end
    colcount = colcount + 1;

end

% rr array contains these columns:
% thetax, thetay, lumval, eyeRxAvg, eyeRyAvg, eyeRzAvg, eyeRxSD, eyeRySD, eyeRzSD
% rr

figure(32);
% rr(:,3) is lumval
errorbar (rr(:,3),rr(:,5),rr(:,8),'o-')
