% Load the data generated by sacc_vs_luminance.sh runs
r = struct();
rr = [];

% These should match the values used in sacc_vs_luminance.sh
thetax=0;
thetay=-10;

% Should veusz-friendly csv files be written out?
output_veusz = 1

% Which model?
modeldir = 'TModel4'

plottraj = 0;
if plottraj
    num_runs=6; % to show
    figure(23);
    clf;
end

colours = {'r','b','g','k','c','m','r','b','g','k','c','m'};
colcount = 1;
% Search files in results directory and select all:
flist = glob(['results/' modeldir '/r*.dat']);
llen = size(flist)(1);
for i = [1 : llen]

    rnm = flist{i};
    resdatname = substr(rnm, 9+length(modeldir)+1); % strips initial 'results/' string
    resdatname = substr(resdatname, 1, size(resdatname)(2)-4); % Strips '.dat' off
    resdatname = strrep (resdatname, '.', 'p');
    resdatname = strrep (resdatname, '-', 'm');

    load (rnm); % loads struct variable called result

    r = struct_merge (r, result);

    if (size(result.(resdatname))(2) == 14)
        rr = [rr; result.(resdatname)];
    end

    % Also plot each trajectory from the model run data
    if plottraj
        for j=1:num_runs
            filepath=['/fastdata/' getenv('USER') '/oculomotorRX' num2str(thetax) 'RY' num2str(thetay) '_' num2str(i) '_' num2str(j)];
            if exist(filepath, 'dir') == 7
                A=load_ocm_min(filepath);
                figure(23);
                hold on;
                plot (A.eyeRy, colours{colcount})
            end
        end
    end
    colcount = colcount + 1;

end

% The rr array contains these columns:
% thetaX, thetaY, fix_lum, gap_ms, lumval, eyeRxAvg, eyeRyAvg, eyeRzAvg, eyeRxSD, eyeRySD, eyeRzSD, latmean, latsd, dopamine
%
% sort rr on luminance value
rr = sortrows(rr,5);

% Sort also by luminance (col 5) and separate out into lat vs. lum
% for differing gaps.
gaps = unique(rr(:,4));

% And for different Fixation luminances


% Achieved position (Rot X)
figure(22); clf; hold on;
colcount=1;
legstr = '';
for g = gaps'
    rr_=[];
    rr_ = rr(find(rr(:,4)==g),:);

    fixes = unique(rr_(:,3));
    for f=fixes'
        rr__=[];
        rr__ = rr_(find(rr_(:,3)==f),:);

        gph = errorbar (rr__(:,5),rr__(:,6),rr__(:,9),'o-');
        set(gph,'color',colours{colcount});
        colcount = colcount + 1;
        legstr = [legstr; 'G: ' num2str(rr_(1,4)) ' FL: ' num2str(rr__(1,3))];
    end
end
xlabel('Luminance');
ylabel('eyeRx');
legend(legstr);
title(['Rot X vs luminance for TargX/Y: ' num2str(thetax) '/' num2str(thetay)]);

% Achieved position (Rot Y)
figure(23); clf; hold on;
colcount=1;
legstr = '';
for g = gaps'
    rr_=[];
    rr_ = rr(find(rr(:,4)==g),:);
    gph = errorbar (rr_(:,5),rr_(:,7),rr_(:,10),'o-');
    set(gph,'color',colours{colcount});
    colcount = colcount + 1;
    legstr = [legstr; 'G: ' num2str(rr_(1,4))];
end
xlabel('Luminance');
ylabel('eyeRy');
legend(legstr);
title(['Rot Y vs luminance for TargX/Y: ' num2str(thetax) '/' num2str(thetay)]);

% Achieved position (Rot Z)
figure(24); clf; hold on;
colcount=1;
legstr = '';
for g = gaps'
    rr_=[];
    rr_ = rr(find(rr(:,4)==g),:);
    gph = errorbar (rr_(:,5),rr_(:,8),rr_(:,11),'o-');
    set(gph,'color',colours{colcount});
    colcount = colcount + 1;
    legstr = [legstr; 'G: ' num2str(rr_(1,4))];
end
xlabel('Luminance');
ylabel('eyeRz');
legend(legstr);
title(['Rot Z vs luminance for TargX/Y: ' num2str(thetax) '/' num2str(thetay)]);

% Latency
figure(25); clf; hold on;
colcount=1;
legstr = '';
for g = gaps'
    rr_=[];
    rr_ = rr(find(rr(:,4)==g),:);
    fixes = unique(rr_(:,3));
    for f=fixes'
        rr__=[];
        rr__ = rr_(find(rr_(:,3)==f),:);
        gph = errorbar (rr__(:,5),rr__(:,12),rr__(:,13),'o-');
        set(gph,'color',colours{colcount});
        colcount = colcount + 1;
        legstr = [legstr; 'G: ' num2str(rr__(1,4)) ' FL: '  num2str(rr__(1,3))];

        if output_veusz
            datatosave = [rr__(:,5),rr__(:,12),rr__(:,13)];
            f = fopen (['results/' modeldir '/lat_vs_lum_G_' num2str(rr__(1,4)) '_FL' num2str(rr__(1,3)) '.csv'], 'w');
            fprintf (f, 'Luminance,Latency,+-\n');
            dlmwrite (f, datatosave, '-append');
            fclose(f);
        end

    end
end
xlabel('Luminance');
ylabel('Latency (ms)');
legend(legstr);
title(['Latency vs luminance for TargX/Y: ' num2str(thetax) '/' num2str(thetay)]);
