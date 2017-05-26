% Save the results produced by the find_latencies script.

num_points = size(lat_mean)(2);


% Save the data to a dated file
res_file_name = sprintf ('%s_targlum%f_gap%f', datestr(now(), ...
                                                  'yyyymmdd_HHMMSS'), ...
                         params.targetLuminance, gap);

save ([res_file_name '.mat'], 'da', 'lat_mean', 'lat_sd', 'params', 'fa_mean', 'fa_sd');

csvwrite (['combined-' res_file_name '.csv'], [da' lat_mean' lat_sd']);

% Let's have some figures, too.
disp('figures')
figure(1)
errorbar (da, fa_mean(:,2), fa_sd(:,2), 'o-')
xlabel ('DA parameter value')
ylabel ('eyeRy (degrees)')

figure(2)
errorbar (da, lat_mean, lat_sd, 'ro-')
xlabel ('DA parameter value')
ylabel ('Latency (ms)')
