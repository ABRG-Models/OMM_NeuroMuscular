% Load the data generated for oblique movements.
r = struct();
rro = [];

lumval=1;

colours = {'r','b','g','k','c','m','r--','b--','g--','k--','c--','m--'};
colcount = 1;

modeldir = 'TModel4'

flist = glob(['results/' modeldir '_oblq/r*.dat']);
llen = size(flist)(1);
for i = [1 : llen]

    rnm = flist{i};
    resdatname = substr(rnm, 14+length(modeldir)+1); % strips initial 'results' string
    resdatname = substr(resdatname, 1, size(resdatname)(2)-4); % Strips '.dat' off
    resdatname = strrep (resdatname, '.', 'p');
    resdatname = strrep (resdatname, '-', 'm');

    load (rnm); % loads struct variable called result
    r = struct_merge (r, result);

    % For expected size of rro, consult sacc_vs_targetpos.m
    sz_2 = size(result.(resdatname))(2);

    if (sz_2 == 16)
        rro = [rro; result.(resdatname)];
    end

end

% The rro array contains these columns:
% thetaX, thetaY, fix_lum, gap_ms, lumval, eyeRxAvg, eyeRyAvg, eyeRzAvg, eyeRxSD, eyeRySD, eyeRzSD, latmean, latsd, dopamine, durmean, dursd

%
% sort rro on target position value
rro = sortrows(rro,1); % or 2; doesn't matter for oblq

targr = -sqrt(rro(:,1).*rro(:,1) + rro(:,2).*rro(:,2));
achvr = -sqrt(rro(:,6).*rro(:,6) + rro(:,7).*rro(:,7));
achvrsd = sqrt(rro(:,9).*rro(:,9) + rro(:,10).*rro(:,10));

% Achieved position
figure(82);
errorbar (targr,achvr,achvrsd,'o-')
hold on;
plot ([-15,-5],[-15,-5], 'g--');
hold off;
xlabel('Target y');
ylabel('eyeRy');
legend(['Lum: ' num2str(rro(1,5)) ' Dopa: ' num2str(rro(1,14))])
title ('Oblique');

% Latency
figure(85);
errorbar (targr,rro(:,12),rro(:,13),'o-')
xlabel('Target y');
ylabel('Latency (ms)');
legend(['Lum: ' num2str(rro(1,5)) ' Dopa: ' num2str(rro(1,14))]);
title ('Oblique');

% Duration
figure(86);
errorbar (targr,rro(:,15),rro(:,16),'o-')
xlabel('Target y');
ylabel('Dur (ms)');
legend(['Lum: ' num2str(rro(1,5)) ' Dopa: ' num2str(rro(1,14))]);
ylim([80 160]);
title ('Oblique');

% Duration shared fig
figure(100);
hold on;
errorbar (-targr,rro(:,15),rro(:,16),'ro-')
%xlabel('Target y');
%ylabel('Dur (ms)');
%legend(['Lum: ' num2str(rro(1,5)) ' Dopa: ' num2str(rro(1,14))]);
%ylim([80 160]);
%title ('Oblique');

% Output for Veusz
output_veusz = 0
if output_veusz
    % REWRITE
    targrot = [rro(:,2),rro(:,7),rro(:,10)];
    f = fopen (['results/' modeldir '/sacc_eyery_vs_targ.csv'], 'w');
    fprintf (f, 'TargY,eyeRy,+-\n');
    dlmwrite (f, targrot, '-append');
    fclose(f);

    latrot = [rro(:,2),rro(:,12),rro(:,13)];
    f = fopen (['results/' modeldir '/sacc_lat_vs_targ.csv'], 'w');
    fprintf (f, 'TargY,Latency,+-\n');
    dlmwrite (f, latrot, '-append');
    fclose(f);
end
