% Explore antisaccades with two luminances each side of the eye.

% You set these:
target_angle_y = 12; % +ve.
target_angle_x = 0;
num_runs_per_point = 8;
da = 0.3;

% Here are the fixation off/target on numbers:
fixtarg = [
    0.30 0.15;
    0.28 0.15;
    0.26 0.15;
    0.24 0.15;
    0.22 0.15;
    0.2 0.15;
    0.2 0.17;
    0.2 0.19;
    0.2 0.21;
    0.2 0.23;
    0.2 0.25;
    0.2 0.27;
    0.2 0.29;
    0.2 0.31;
    0.2 0.33;
    0.2 0.35;
    0.2 0.37;
    0.2 0.39;
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
    
    [avg, sd, finals, sm] = find_latency (target_angle_x,target_angle_y,num_runs_per_point,...
                                          da,ft(1),ft(2));
    lm = mean(sm);
    ls = std(sm);
    lat_mean = [lat_mean lm];
    lat_sd = [lat_sd ls];
    fa_mean = [fa_mean avg];
    fa_sd = [fa_sd sd];
end
