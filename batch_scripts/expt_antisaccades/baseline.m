% Explore antisaccades with two luminances each side of the eye.  This
% "baseline" run just plonks two luminances in the field of view with
% a "step" from fixation to targets and allows the model to saccade to
% one of them. Runs the expt numerous times and finds out the number
% of lefts vs. rights and the latencies.

% Fixed parameters
params.targetThetaY = -12;
params.targetThetaX = 0;
params.num_par_runs = 8;
params.dopamine = 0.3;
params.targetCross=0; % 1 if target should be the cross shape.
params.targetLuminance=4;
params.targetWidthX=4;
params.targetWidthY=4;
params.fixCross=0;
params.fixLuminance=0.2;
params.fixWidthX=2;
params.fixWidthY=2;
params.fixOn=0.0;
params.fixOff=0.2
params.targetOn=0.2
params.targetOff=1.0;
params.use_insigneo=1; % Set to 1 to use Insigneo queues on Iceberg
params.cleanup=1; % Set to 1 to clean up used files.
params.model_dir = '/home/pc1ssj/abrg_local/Oculomotor';

% At the end of the script you'll have a vector of mean latencies a
% vector of latency SDs, a vector of final angle means and one of
% SDs, and of course your fixation/target matrix which you set up.
lat_mean = [];
lat_sd = [];
fa_mean = [];
fa_sd = [];

%for ft = fixtarg
    
    printf ('Finding latency for fixation off: %f  target on: %f', ft(1), ft(2));
    
    [avg, sd, finals, sm] = find_latency_dual (params);
    lm = mean(sm);
    ls_ = std(sm);
    lat_mean = [lat_mean lm];
    lat_sd = [lat_sd ls_];
    fa_mean = [fa_mean avg];
    fa_sd = [fa_sd sd];
%end

% Call the save results script
%save_results
