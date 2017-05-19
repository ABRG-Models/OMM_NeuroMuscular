%% Used by sacc_vs_luminance.sh. Runs the model num_par_runs times
%% for a given lumval.
%%
%% Usage:
%%
%%   sacc_vs_targetpos (targetThetaX, targetThetaY, num_par_runs,
%%                      lumval)
%%
function sacc_vs_targetpos (targetThetaX, targetThetaY, num_par_runs, lumval)

    page_screen_output(0);
    page_output_immediately(1);

    cleanup = 0;
    p_str = platform_str();
    model_dir = [getenv('HOME') '/OMM_NeuroMuscular/Model3'];

    write_single_luminance ([model_dir '/luminances.json'], targetThetaX, targetThetaY, lumval);

    output_dirs = setup_model_directories ([targetThetaX, targetThetaY], lumval);
    [ eyeRyAvg, eyeRySD, eyeRyFinals ] = run_simulation_multi (model_dir, output_dirs, num_par_runs, cleanup);

    resname = ['r_' num2str(targetThetaX) '_' num2str(targetThetaY) '_' num2str(lumval) '.dat'];
    resdatname = ['r_' num2str(targetThetaX) '_' num2str(targetThetaY) '_' num2str(lumval)];
    resdatname = strrep (resdatname, '.', 'p');
    % You can't put minus signs in the resdat name, either.
    resdatname = strrep (resdatname, '-', 'm');

    vs = [targetThetaX, eyeRyAvg, eyeRySD];
    result = struct();
    result.(resdatname) = vs;

    save (['results/' resname], 'result');

end