% Load the data generated by sacc_lat_vs_dop.sh runs

% Output for Veusz?
output_veusz = 1

% Which model?
modeldir = 'TModel4'

r = struct();
rr = [];
colours = {'r','b','g','k','c','m','r--','b--','g--','k--','c--','m--'};
markers = {'o','x','s','d','^','*','v'};

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

    % For expected size of rr, consult sacc_vs_targetpos.m
    size(rr);
    sz_2 = size(result.(resdatname))(2);

    if (sz_2 == 14)
        rr = [rr; result.(resdatname)];
    else
        display('Not the right size');
    end

end

% The rr array contains these columns:
% thetaX, thetaY, fix_lum, gap_ms, lumval, eyeRxAvg, eyeRyAvg, eyeRzAvg, eyeRxSD, eyeRySD, eyeRzSD, latmean, latsd, dopamine
%
% sort rr on dopamine
rr = sortrows(rr,14);

% Sort also by luminance (col 5) and separate out into lat vs. gap
% for differing luminances.
luminances = unique(rr(:,5));
fixlums = unique(rr(:,3));

fn = 40;

for f = fixlums'

    _rr = [];
    _rr = rr(find(rr(:,3)==f),:);

    luminances = unique(_rr(:,5));

    figure(fn);
    clf;
    legend_str='';
    colcount = 1;
    markcount = 1;

    for l = luminances'
    rr_ = [];
        rr_ = _rr(find(_rr(:,5)==l),:);

        gaps = unique(rr_(:,4));

        colcount = 1;
        for g = gaps'

            rr_1 = rr_(find(rr_(:,4)==g),:);
            ph = errorbar (rr_1(:,14),rr_1(:,12),rr_1(:,13));
            set(ph, 'marker', markers{markcount}, 'color', colours{colcount});
            hold on;
            % G is "gap"
            legend_str = [legend_str; 'G: ' num2str(rr_1(1,4)) ' L: ' num2str(l) ' FL: ' num2str(rr_1(1,3)) ];
            colcount = colcount + 1;

            if output_veusz
                datatosave = [rr_1(:,14),rr_1(:,12),rr_1(:,13)];
                f = fopen (['results/' modeldir '/lat_vs_dop_G_' num2str(rr_1(1,4)) '_L' num2str(l) '_F' num2str(rr_1(1,3))  '.csv'], 'w');
                fprintf (f, 'Dopamine,Latency,+-\n');
                dlmwrite (f, datatosave, '-append');
                fclose(f);
            end
        end
        markcount = markcount + 1;
    end

    xlabel('dopamine');
    ylabel('Latency (ms)');
    legend(legend_str);
    title([modeldir ' lat vs dop for X/Y ' num2str(rr(1,1)) '/' num2str(rr(1,2)) ' and FixLum ' num2str(_rr(1,3)) ]);

    fn = fn + 1;
end


return

% Accuracy vs dopamine
figure(43);
clf;
legend_str='';
colcount = 1;
for l = luminances'
    rr_1 = [];
    rr_1 = rr(find(rr(:,5)==l),:);
    xvecmag = abs(rr_1(:,6) - rr_1(:,1));
    yvecmag = abs(rr_1(:,7) - rr_1(:,2));
    zvecmag = abs(rr_1(:,8));
    hold on;
    % G is "gap"
    plot (rr_1(:,14),xvecmag, 'color', colours{colcount}, 'linestyle', '-', 'marker', 'o', 'markersize',12)
    legend_str = [legend_str; 'G: ' num2str(rr_1(1,4)) ' L: ' num2str(l) ' Xerr'];
    % I've plotted only x error, but can look at y, z too:
    %plot (rr_1(:,14),yvecmag, 'color', colours{colcount}, 'linestyle', '-', 'marker', 'd', 'markersize',12)
    %legend_str = [legend_str; 'G: ' num2str(rr_1(1,4)) ' L: ' num2str(l) ' Yerr'];
    %plot (rr_1(:,14),zvecmag, 'color', colours{colcount}, 'linestyle', '-', 'marker', '^', 'markersize',12)
    %legend_str = [legend_str; 'G: ' num2str(rr_1(1,4)) ' L: ' num2str(l) ' Zerr'];
    colcount = colcount + 1;
end
xlabel('dopamine');
ylabel('Error (degrees)');
legend(legend_str);
title(['X/Y ' num2str(rr(1,1)) '/' num2str(rr(1,2)) ]);
