%% Used by sacc_vs_luminance.sh. Runs the model num_par_runs times
%% for a given lumval.
%%
%% Usage:
%%
%%   sacc_vs_targetpos (targetThetaX, targetThetaY, num_par_runs, lumval)
%%
function sacc_vs_targetpos (targetThetaX, targetThetaY, num_par_runs, lumval)

    page_screen_output(0);
    page_output_immediately(1);

    if ~(floor(targetThetaX) == targetThetaX) || ~(floor(targetThetaY) == targetThetaY)
        display ('Integers only for targetThetaX/targetThetaY')
        return;
    end

    cleanup = 0;
    [d, msg, msgid] = mkdir (['/fastdata/' getenv('USER')])
    [d, msg, msgid] = mkdir (['/fastdata/' getenv('USER') '/OMM_NeuroMuscular'])
    model_dir = ['/fastdata/' getenv('USER') '/OMM_NeuroMuscular/SVTP' num2str(targetThetaX) '_' num2str(targetThetaY) '_' num2str(lumval)]
    origin_model_dir = [getenv('HOME') '/OMM_NeuroMuscular/Model3'];
    % Copy origin_model_dir into model_dir
    copyfile (origin_model_dir, model_dir)

    % This writes into the origin model directory. When running
    % many in parallel, these get mixed up. So make a copy of the
    % model.
    step_time=0.18;
    fix_lum=0.5
    write_single_luminance ([model_dir '/luminances.json'], targetThetaX, targetThetaY, lumval, step_time, fix_lum);

    output_dirs = setup_model_directories ([targetThetaX, targetThetaY], lumval);
    [ eyeRyAvg, eyeRySD, eyeRyFinals ] = run_simulation_multi (model_dir, output_dirs, num_par_runs, cleanup);

    resname = ['r_' num2str(targetThetaX) '_' num2str(targetThetaY) '_' num2str(lumval) '.dat'];
    resdatname = ['r_' num2str(targetThetaX) '_' num2str(targetThetaY) '_' num2str(lumval)];
    resdatname = strrep (resdatname, '.', 'p');
    % You can't put minus signs in the resdat name, either.
    resdatname = strrep (resdatname, '-', 'm');

    vs = [targetThetaX, targetThetaY, lumval, eyeRyAvg, eyeRySD]; % Add lumval (and targetThetaY)
    result = struct();
    result.(resdatname) = vs;

    eyeRyAvg
    eyeRySD
    save (['results/' resname], 'result');

end