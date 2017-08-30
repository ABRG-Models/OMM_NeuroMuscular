% Load the data generated for oblique movements.
r = struct();
rr = [];

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

    % For expected size of rr, consult sacc_vs_targetpos.m
    sz_2 = size(result.(resdatname))(2);

    if (sz_2 == 16)
        rr = [rr; result.(resdatname)];
    end

end

% The rr array contains these columns:
% thetaX, thetaY, fix_lum, gap_ms, lumval, eyeRxAvg, eyeRyAvg, eyeRzAvg, eyeRxSD, eyeRySD, eyeRzSD, latmean, latsd, dopamine, durmean, dursd

%
% sort rr on target position value
rr = sortrows(rr,1); % or 2; doesn't matter for oblq

targr = -sqrt(rr(:,1).*rr(:,1) + rr(:,2).*rr(:,2));
achvr = -sqrt(rr(:,6).*rr(:,6) + rr(:,7).*rr(:,7));
achvrsd = sqrt(rr(:,9).*rr(:,9) + rr(:,10).*rr(:,10));

% Achieved position
figure(82);
errorbar (targr,achvr,achvrsd,'o-')
hold on;
plot ([-15,-5],[-15,-5], 'g--');
hold off;
xlabel('Target y');
ylabel('eyeRy');
legend(['Lum: ' num2str(rr(1,5)) ' Dopa: ' num2str(rr(1,14))])
title ('Oblique');

% Latency
figure(85);
errorbar (targr,rr(:,12),rr(:,13),'o-')
xlabel('Target y');
ylabel('Latency (ms)');
legend(['Lum: ' num2str(rr(1,5)) ' Dopa: ' num2str(rr(1,14))]);
title ('Oblique');

% Duration
figure(86);
errorbar (targr,rr(:,15),rr(:,16),'o-')
xlabel('Target y');
ylabel('Dur (ms)');
legend(['Lum: ' num2str(rr(1,5)) ' Dopa: ' num2str(rr(1,14))]);
ylim([80 160]);
title ('Oblique');

% Duration shared fig
figure(100);
hold on;
errorbar (targr,rr(:,15),rr(:,16),'ro-')
%xlabel('Target y');
%ylabel('Dur (ms)');
%legend(['Lum: ' num2str(rr(1,5)) ' Dopa: ' num2str(rr(1,14))]);
%ylim([80 160]);
%title ('Oblique');

% Output for Veusz
output_veusz = 0
if output_veusz
    % REWRITE
    targrot = [rr(:,2),rr(:,7),rr(:,10)];
    f = fopen (['results/' modeldir '/sacc_eyery_vs_targ.csv'], 'w');
    fprintf (f, 'TargY,eyeRy,+-\n');
    dlmwrite (f, targrot, '-append');
    fclose(f);

    latrot = [rr(:,2),rr(:,12),rr(:,13)];
    f = fopen (['results/' modeldir '/sacc_lat_vs_targ.csv'], 'w');
    fprintf (f, 'TargY,Latency,+-\n');
    dlmwrite (f, latrot, '-append');
    fclose(f);
end
