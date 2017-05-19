% Run find_latency several times to explore latency vs dopamine.

% Sensible luminances for express and reflexive saccades
%
% With fix luminance at 0.5 and fix widths at 2, a target (of widths
% 4x4) luminance >0.5 gives express saccades, with 100ms time
% scales for luminance around 1.8 and a 0.05 ms gap.
%
% For reflexive saccades tune the target luminance down to 0.2 which
% pushes saccade reaction times to about 200 ms.


% Fixed parameters
params.targetThetaY = -8;
params.targetThetaX = 0;
params.num_par_runs = 8;
params.dopamine = 0.3; % Will be overridden

params.fixCross=0;
params.fixLuminance=0.5;
params.fixWidthX=2;
params.fixWidthY=2;
params.fixOn=0;
params.fixOff=0.45

params.targetCross=0; % 1 if target should be the cross shape.
params.targetLuminance=0.2;
params.targetWidthX=4;
params.targetWidthY=4;
params.targetOn=0.35; % Then 0.35
params.targetOff=1;

params.cleanup=0; % Set to 1 to clean up used files.

%da = [0.01 0.05 0.1 0.15 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9];
da = [0.05 0.1 0.15 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9];
%da = [0.15];

% At the end of the script you'll have a vector of mean latencies a
% vector of latency SDs, a vector of final angle means and one of
% SDs, and of course your dopamine vector (da) which you set up.
lat_mean = [];
lat_sd = [];
fa_mean = [];
fa_sd = [];

% We'll vary gap and targetLuminance
gap = params.targetOn - params.fixOff;

for d = da
    % Change dopamine for this run:
    params.dopamine = d;
    [avg, sd, finals, sm] = find_latency (params);
    lm = mean(sm);
    ls_ = std(sm)
    if isempty(lm) == 0 && isempty(ls_) == 0 && isempty (avg) == 0 && isempty(sd) == 0
        lat_mean = [lat_mean lm];
        lat_sd = [lat_sd ls_];
        fa_mean = [fa_mean; avg];
        fa_sd = [fa_sd; sd];
    else
        lat_mean = [lat_mean 0];
        lat_sd = [lat_sd 0];
        fa_mean = [fa_mean; [0 0 0]];
        fa_sd = [fa_sd; [0 0 0]];
    end
end

save_results
