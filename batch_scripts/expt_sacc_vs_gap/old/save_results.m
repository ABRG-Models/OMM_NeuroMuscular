% Save the results produced by the find_latencies script.

num_points = size(lat_mean)(2);
% Make sure we save only the relevant content of fixtarg
fixation_off = fixtarg(1,1:num_points);
target_on = fixtarg(2,1:num_points);
gap = target_on-fixation_off;

% Save the data to a dated file
res_file_name = sprintf ('%s_results_da_%f.mat', datestr(now(), 'yyyymmdd_HHMMSS'), params.dopamine);

save (res_file_name, 'fixation_off', 'target_on', 'gap', 'lat_mean', 'lat_sd', 'params');
