% This is a curve fitting script. It attempts to fit a curve of the
% form:
%
% y(r,theta) = (a .* exp(k.*r) .- b .* exp(l.*r)) ...
%               .* cos (2.*pi .* (wg.*(theta-os)./50));
%
% to data found in "e53" which is loaded with the load_allweights.m
% script.
%
% Simulated annealing is used to search the parameter space of
% y(r,theta) (a,k,b,l,wg and os).

% First run the load_allweights.m script to ensure that the working
% environment contains e50, e50map, etc etc.

%% FIXME: Make this work with fitcurve.m

% You will need the include dir containing weight_surface_one.m
% (OMM_NeuroMuscular/batch_scripts/include) to be in your
% matlab/octave path.

% To get stdout scrolling past while this runs:
page_screen_output(0);
page_output_immediately(1);

%
% Algorithm parameters
%

% The fit threshold. If the objective function returns a value
% below this number, then the fit is considered acceptable and the
% algorithm ends.
fit_threshold = 0.1;

% Temperature parameters
temp = 1;
coolrate = 0.02;
low_temp_threshold = 0.000000001;

%
% Parameter ranges. Parameters are discretized here, to give the
% system many possible states.
%

% All iterators in range 1 to 1024.
rangesz = 1024;

[a, ai, afit] = make_param (0.005, 5, rangesz);

[k, ki, kfit] = make_param (0.01, 0.1, rangesz);

[b, bi, bfit] = make_param (2, 4, rangesz);
%b = zeros(1,rangesz); bi = 40; bfit = b(bi);

[l, li, lfit] = make_param (0.005, 0.10, rangesz);

[os, osi, osfit] = make_param (23.4, 26.0, rangesz);

[wg, wgi, wgfit] = make_param (1, 1.1, rangesz);

% Full region for the surface; 50x50 grid
r = 1:50;
theta = 1:50;
[R, THETA] = meshgrid (r, theta);


% Function can start here.

%
% Compute first iteration and goodness of fit. Note our curve for
% fitting in in weight_surface_one.m
%

v = weight_surface_one (R, THETA, a(ai), k(ki), b(bi), l(li), os(osi), wg(wgi));
vfit = v;

afiti = ai;
kfiti = ki;
bfiti = bi;
lfiti = li;
osfiti = osi;
wgfiti = wgi;

% Display this starting attempt
figure(1); hold off; sh = mesh (v); hold on;
scatter3(e53means(:,2),e53means(:,1),e53means(:,3),'filled');
zlim([-5,15]);

% A number for goodness of fit:

% mask off half the map
mm = [nan(25,50);ones(25,50)];
mm_opp = [ones(25,50);nan(25,50)];
masked = e53map .* mm;
masked_opp = e53map .* mm_opp;
diffsq = power(masked .- v, 2); % errors squared
diffsz = size(diffsq)(1).*size(diffsq)(2);
gf = sqrt(sum(nansum(diffsq))/diffsz);

figure(7);
surf (masked);

% initialise lastgf (and bestgf)
lastgf = gf;
bestgf = gf;

%
% Start the algorithm.
%

finished = 0;
count = 0;
while finished == 0

    % Generate new numbers. Randomly select a param, then just
    % increment/decrement the params? Or randomly select a new value?
    paramnum = ceil(unifrnd(0,6)); % 1 to n

    % +/- rangesz./10:
    itershift = ceil(unifrnd(0,rangesz./10))-ceil(rangesz./20);
    switch paramnum
      case 1
        ai = shiftiter (ai, itershift, rangesz);
      case 2
        ki = shiftiter (ki, itershift, rangesz);
      case 3
        bi = shiftiter (bi, itershift, rangesz);
      case 4
        li = shiftiter (li, itershift, rangesz);
      case 5
        osi = shiftiter (osi, itershift, rangesz);
      case 6
        wgi = shiftiter (wgi, itershift, rangesz);
      otherwise
        display ('error!')
    end

    v = weight_surface_one (R, THETA, a(ai), k(ki), b(bi), l(li), os(osi), wg(wgi));

    % Compute a number for goodness of fit:
    diffsq = power(masked .- v, 2); % errors squared
    diffsz = size(diffsq)(1).*size(diffsq)(2);
    gf = sqrt(sum(nansum(diffsq))/diffsz);

    % opposite side:
    diffsq_opp = power(masked_opp .- v, 2); % errors squared
    gf_opp = sqrt(sum(nansum(diffsq_opp))/diffsz);

    % The simulated annealing algorithm
    if gf < lastgf
        % accept this one for sure
        acc_prob = 1;
    else
        acc_prob = exp ((lastgf - gf)/temp);
    end

    % Do we accept it?
    if acc_prob > unifrnd(0,1)
        if gf<2
            display (['accept gf=' num2str(gf) ' at temp ' ...
                      num2str(temp) ' (gf_opp=' num2str(gf_opp) ')']);
            figure(1); delete(sh); sh = mesh (v);
            drawnow
        end
        afiti = ai;
        kfiti = ki;
        bfiti = bi;
        lfiti = li;
        osfiti = osi;
        wgfiti = wgi;
        vfit = v;
        lastgf = gf;
        if gf < bestgf
            bestgf = gf;
            abesti = afiti;
            kbesti = kfiti;
            bbesti = bfiti;
            lbesti = lfiti;
            osbesti = osfiti;
            wgbesti = wgfiti;
            vbest = vfit;
        end
    else
        % Don't accept it.
        %display (['reject gf=' num2str(gf) ' at temp '
        %num2str(temp)]);
        ai = afiti;
        ki = kfiti;
        bi = bfiti;
        li = lfiti;
        osi = osfiti;
        wgi = wgfiti;
    end

    if gf < fit_threshold
        finished = 1
    end

    if ~mod(count,10)
        temp = temp .* (1-coolrate);
    end

    if temp < low_temp_threshold
        finished = 1;
    end

    count = count + 1;

end % while

% Last, display!
figure(1); hold off; mesh (vfit); hold on;
scatter3(allweights(e53,5), allweights(e53,4), allweights(e53,6), ...
         'filled');
title ('Final fit');
display (['a=' num2str(a(afiti)) ', k=' num2str(k(kfiti)) ', b=' num2str(b(bfiti)) ...
          ', l=' num2str(l(lfiti)) ', os=' num2str(os(osfiti)) ', wg=' num2str(wg(wgfiti))]);
if bestgf == gf
    display ('This was the best fit found!');
    figure(2); clf;
else
    display (['Stopped as the temperature dropped to its final ' ...
              'value'])
    display(['bestgf was ' num2str(bestgf) ', count was ' ...
             num2str(count)]);
    figure(2); hold off; mesh (vbest); hold on;
    scatter3(allweights(e53,5), allweights(e53,4), allweights(e53,6),'filled');
    display (['best values: a=' num2str(a(abesti)) ', k=' num2str(k(kbesti))  ', b=' num2str(b(bbesti)) ...
              ', l=' num2str(l(lbesti)) ', os=' num2str(os(osbesti)) ', wg=' num2str(wg(wgbesti))]);
    title ('Best (not final) fit');
end