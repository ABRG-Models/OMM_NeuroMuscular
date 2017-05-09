% Load the data generated by sacc_vs_targetpos.sh runs
r = struct();
rr = [];

num_runs=6

figure(33);
clf;

colours = {'r','b','g','k','c','m','r--','b--','g--','k--','c--','m--'};
colcount = 1;
for i = [0.2 : 0.2 : 1.6]
    resname = ['r_0_7_' num2str(i) '.dat'];
    resdatname = ['r_0_7_' num2str(i)];
    resdatname = strrep (resdatname, '.', '_');

    load (resname); % loads struct variable called result
    r = struct_merge (r, result);

    rr = [rr; result.(resdatname)];

    % Also plot each trajectory from the model run data
    for j=1:num_runs
        filepath=['/fastdata/co1ssj/oculomotorRX0RY7_' num2str(i) '_' num2str(j)];
        A=load_ocm_min(filepath);
        figure(33);
        hold on;
        plot (A.eyeRy, colours{colcount})
    end
    colcount = colcount + 1;

end

% rr array contains these columns:
% lumval, eyeRxAvg, eyeRyAvg, eyeRzAvg, eyeRxSD, eyeRySD, eyeRzSD
rr

figure(32);
errorbar (rr(:,1),rr(:,3),rr(:,6),'o-')
