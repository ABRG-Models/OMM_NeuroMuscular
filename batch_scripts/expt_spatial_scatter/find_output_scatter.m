function [eyeRyAvg, eyeRySD, eyeRyFinals] = find_output_scatter ...
        (targetThetaX, targetThetaY, num_par_runs)
%% Run the model n times for a given target
%% and collect the output angle each time. Use run_simulation_multi()
%%
%% Author: Seb James.

    page_screen_output(0);
    page_output_immediately(1);

    % The input model. Hardcoded.
    model_dir = [getenv('HOME') '/OMM_NeuroMuscular/Model3'];
    % Add a write-out of the luminances file:
    step_time=0.12;
    fix_lum=0.5;
    lumval=1.8;
    write_step_luminance ([model_dir '/luminances.json'], targetThetaX, targetThetaY, lumval, step_time, fix_lum);
    output_dirs = setup_model_directories ([targetThetaX, targetThetaY], 1);
    cleanup = 1;
    [ eyeRyAvg, eyeRySD, eyeRyFinals ] = run_simulation_multi (model_dir, output_dirs, num_par_runs, cleanup);

end
