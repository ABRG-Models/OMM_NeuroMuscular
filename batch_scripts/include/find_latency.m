function [eyeRyAvg, eyeRySD, eyeRyFinals, latency] = find_latency (params)
%% Run the model num_par_runs times for a given targetThetaX/Y
%% and collect the time to first eye movement each time.
%% Investigate fixation-target overlaps/gaps by
%% controlling the fixation_off and target_on parameters and
%% dopamine level via the da_param argument.
%%
%% Author: Seb James.

    page_screen_output(0);
    page_output_immediately(1);

    % Ranges: -22<=x<=-6 and 6<=x<=22 -22<=y<=-6 and 6<=y<=22

    % The input model. Hardcoded.
    model_tag = getenv('OMMODEL');
    if isempty(model_tag)
        display('Please set the environment variable OMMODEL to something like "Model3"')
        return
    end
    model_dir = [getenv('HOME') '/OMM_NeuroMuscular/' model_tag];

    % Add a write-out of the luminances file:
    write_single_luminance_with_fix ([model_dir '/luminances.json'], params);

    output_dirs = setup_model_directories ([params.targetThetaX, params.targetThetaY], 1);

    [ eyeRyAvg, eyeRySD, eyeRyFinals, peakPos, startMove ] = run_simulation_multi (model_dir, output_dirs, params);

    latency = startMove.-(1000.*params.targetOn);
    lat_mean = mean(latency);
    lat_std = std(latency);
    display (['Latency mean: ' num2str(lat_mean) ' SD: ' num2str(lat_std) ...
             ' Final angle mean: ' num2str(eyeRyAvg) ' SD: ' num2str(eyeRySD)]);

end
