%% Load the data and plot the error surface. Only plot up to maxr.
function [rr, errs, targmags, errmags, errpcnt] = load_errorsurf (ommodel, maxr=100)

r = struct();
rr = [];

globstr = ['results/' ommodel '/r*.dat'];
flist = glob(globstr);
llen = size(flist)(1);
for i = [1 : llen]

    rnm = flist{i};
    resdatname = substr(rnm, 9+length(ommodel)+1); % strips initial 'results' string
    resdatname = substr(resdatname, 1, size(resdatname)(2)-4); % Strips '.dat' off
    resdatname = strrep (resdatname, '.', 'p');
    resdatname = strrep (resdatname, '-', 'm');

    load (rnm); % loads struct variable called result
    r = struct_merge (r, result);

    % For expected size of rr, consult sacc_vs_targetpos.m
    sz_1 = size(result.(resdatname))(1);
    sz_2 = size(result.(resdatname))(2);

    if (sz_2 == 14)
        resx = result.(resdatname)(1,1);
        resy = result.(resdatname)(1,2);
        ecc = sqrt ((resx*resx) + (resy*resy));
        if (ecc < maxr)
            rr = [rr; result.(resdatname)];
        end
    end

end

% The rr array contains these columns:
% thetaX, thetaY, fix_lum, gap_ms, lumval, eyeRxAvg, eyeRyAvg, eyeRzAvg, eyeRxSD, eyeRySD, eyeRzSD, latmean, latsd, dopamine

%
% sort rr on target position value
rr = sortrows(rr,1);

targs = [rr(:,1),rr(:,2),zeros(size(rr)(1),1)];
targmags = sqrt(rr(:,1).*rr(:,1) + rr(:,2).*rr(:,2));
actuals = rr(:,6:8);
errs = targs - actuals;
errmags = sqrt(errs(:,1).*errs(:,1) + errs(:,2).*errs(:,2) + errs(:,3).*errs(:,3));
% Also compute error percentage:
errpcnt = errmags ./ targmags .* 100;
end