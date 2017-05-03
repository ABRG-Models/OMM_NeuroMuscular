% Parameter search script. This is analogous to fit_curve_up.m

% First run the load_allweights.m script to ensure that the working
% environment contains e50, e50map, etc etc.

addpath('include');

% To get stdout scrolling past while this runs:
page_screen_output(0);
page_output_immediately(1);

%
% Algorithm parameters
%

% The fit threshold. If the objective function returns a value
% below this number, then the fit is considered acceptable and the
% algorithm ends.
algo_params.fit_threshold = 0.2;

% Temperature parameters
algo_params.temp = 1;
algo_params.coolrate = 0.02;
algo_params.low_temp_threshold = 0.000000001;

%
% Parameter ranges. Parameters are discretized here, to give the
% system many possible states.
%

% All iterators in range 1 to 1024.
op.rangesz = 1024;

% objective function parameters
coarse_search = 1;
if coarse_search>0
    [op.a, op.ai] = make_param (0.005, 5, op.rangesz);
    [op.k, op.ki] = make_param (0.001, 0.5125, op.rangesz);
    [op.b, op.bi] = make_param (0.001, 5, op.rangesz);
    [op.l, op.li] = make_param (0.001, 0.12, op.rangesz);
    [op.os, op.osi] = make_param (23.4, 25.4, op.rangesz);
    [op.wg, op.wgi] = make_param (0.8, 1.2, op.rangesz);
else % finer search alternative
    [op.a, op.ai] = make_param (0.005, 5, op.rangesz);
    [op.k, op.ki] = make_param (0.01, 0.1, op.rangesz);
    [op.b, op.bi] = make_param (2, 4, op.rangesz);
    [op.l, op.li] = make_param (0.005, 0.1, op.rangesz);
    [op.os, op.osi] = make_param (23.4, 24.4, op.rangesz);
    [op.wg, op.wgi] = make_param (1, 1.1, op.rangesz);
end

% Group params here.
fitcurve (e54map, e54means, op, algo_params);
