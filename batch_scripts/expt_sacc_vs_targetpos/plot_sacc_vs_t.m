% Load the data generated by sacc_vs_targetpos.sh runs
r = struct();
rr = [];

num_runs=12
lumval=1

plottraj=0
if plottraj
    fa = 33; figure(fa); clf;
    fb = 34; figure(fb); clf;
end

colours = {'r','b','g','k','c','m','r--','b--','g--','k--','c--','m--'};
colcount = 1;
for i = [-10 : 1 : -7]
    resname = ['results/r_' num2str(i) '_0_' num2str(lumval) '.dat']
    resdatname = ['r_' num2str(i) '_0_1'];
    resdatname = strrep (resdatname, '.', 'p');
    resdatname = strrep (resdatname, '-', 'm')

    load (resname); % loads struct variable called result
    r = struct_merge (r, result)

    size(rr)
    sz_2 = size(result.(resdatname))(2)

    if (sz_2 == 7)
        rr = [rr; result.(resdatname)];
    end


    if plottraj
        % Also plot each trajectory from the model run data
        for j=1:num_runs
            filepath=['/fastdata/' getenv('USER') '/oculomotorRX' num2str(i) 'RY0_1_' num2str(j)]
            A=load_ocm_min(filepath);
            figure(fa);
            hold on;
            plot (A.eyeRy(1:450), colours{colcount})
            figure(fb);
            hold on;
            plot (A.eyeRx(1:450), A.eyeRy(1:450), 'b')
        end
        colcount = colcount + 1;

        fa = fa + 2;
        fb = fb + 2;
    end
end

% rr array contains these columns:
% thetaX, eyeRxAvg, eyeRyAvg, eyeRzAvg, eyeRxSD, eyeRySD, eyeRzSD
rr

figure(32);
errorbar (rr(:,1),rr(:,2),rr(:,5),'o-')
