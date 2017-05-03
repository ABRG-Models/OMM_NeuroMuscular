function [eyeRyAvg, eyeRySD, eyeRyFinals, latency] = find_latency_dual (params)
%% Get latency, avg position, final position for given params. This
%% produces dual luminances on either side of the fovea.
%%
%% Author: Seb James.

    page_screen_output(0);
    page_output_immediately(1);

    % Ranges: -22<=x<=-6 and 6<=x<=22 -22<=y<=-6 and 6<=y<=22

    % The input model. Hardcoded.

    % Add a write-out of the luminances file:
    write_mirrored_luminances_with_fix ([params.model_dir '/luminances.json'], params);
    output_dirs = setup_latency_directories (params, 1);
    [ eyeRyAvg, eyeRySD, eyeRyFinals, peakPos, startMove ] = ...
        run_sim_multi_for_latency (params.model_dir, output_dirs, params.num_par_runs, ...
                                   params.use_insigneo, params.cleanup, params.dopamine);

    latency = startMove.-(1000.*params.targetOn);
    lat_mean = mean(latency);
    lat_std = std(latency);
    display (['Latency mean: ' num2str(lat_mean) ' SD: ' num2str(lat_std) ...
             ' Final angle mean: ' num2str(eyeRyAvg) ' SD: ' num2str(eyeRySD)]);

end
