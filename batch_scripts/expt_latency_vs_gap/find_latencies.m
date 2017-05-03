% Run find_latency several times to explore latency vs the
% fixation-target gap.

% Fixed parameters
params.targetThetaY = -12;
params.targetThetaX = 0;
params.num_par_runs = 8;
params.dopamine = 0.3;
params.targetCross=0; % 1 if target should be the cross shape.
params.targetLuminance=1.8;
params.targetWidthX=4;
params.targetWidthY=4;
params.fixCross=0;
params.fixLuminance=0.2;
params.fixWidthX=2;
params.fixWidthY=2;
params.fixOn=0;
params.targetOff=1;
params.use_insigneo=1; % Set to 1 to use Insigneo queues on Iceberg
params.cleanup=1; % Set to 1 to clean up used files.

% Here are the fixation off/target on numbers:
fixtarg = [
    0.5 0.15;
    0.45 0.15;
    0.4 0.15;
    0.35 0.15;
    0.30 0.15;
    0.26 0.15;
    0.22 0.15;
    0.2 0.17;
    0.2 0.2;
    0.2 0.25;
    0.2 0.29;
    0.2 0.31;
    0.2 0.35;
    0.2 0.39;
    0.2 0.5;
          ];
% Turn the matrix round now (better for the loop and matches
% lat_mean and friends):
fixtarg = fixtarg';

% At the end of the script you'll have a vector of mean latencies a
% vector of latency SDs, a vector of final angle means and one of
% SDs, and of course your fixation/target matrix which you set up.
lat_mean = [];
lat_sd = [];
fa_mean = [];
fa_sd = [];

for ft = fixtarg
    
    printf ('Finding latency for fixation off: %f  target on: %f', ft(1), ft(2));
    
    params.fixOff = ft(1);
    params.targetOn = ft(2);
    [avg, sd, finals, sm] = find_latency (params);
    lm = mean(sm);
    ls_ = std(sm);
    lat_mean = [lat_mean lm];
    lat_sd = [lat_sd ls_];
    fa_mean = [fa_mean avg];
    fa_sd = [fa_sd sd];
end

% Call the save results script
save_results
