%% Used by sacc_vs_luminance.sh. Runs the model num_par_runs times
%% for a step paradigm single saccade target of the given
%% lumval. The fixation luminance value is hardcoded here as 0.5.
%%
%% It's possible to pass in additional preflight options for the
%% convert_script_s2b call.
%%
%% Results are saved in ./results/
%%
%% Usage:
%%
%%   sacc_vs_targetpos (targetThetaX, targetThetaY, num_par_runs, lumval)
%%
function sacc_vs_targetpos (targetThetaX, targetThetaY, num_par_runs, lumval, dop=-1)

    page_screen_output(0);
    page_output_immediately(1);

    if ~(floor(targetThetaX) == targetThetaX) || ~(floor(targetThetaY) == targetThetaY)
        display ('Integers only for targetThetaX/targetThetaY')
        return;
    end

    % Configure params object for run_simulation_multi
    params.cleanup = 0;
    params.num_runs = num_par_runs;
    params.dopamine = dop;

    [d, msg, msgid] = mkdir (['/fastdata/' getenv('USER')])
    [d, msg, msgid] = mkdir (['/fastdata/' getenv('USER') '/OMM_NeuroMuscular'])
    model_dir = ['/fastdata/' getenv('USER') '/OMM_NeuroMuscular/SVTP' num2str(targetThetaX) '_' num2str(targetThetaY) '_' num2str(lumval)]

    model_tag = getenv('OMMODEL');
    if isempty(model_tag)
        display('Please set the environment variable OMMODEL to something like "Model3"')
        return
    end
    origin_model_dir = [getenv('HOME') '/OMM_NeuroMuscular/' model_tag];

    % Copy origin_model_dir into model_dir
    copyfile (origin_model_dir, model_dir);

    % This writes into the origin model directory. When running
    % many in parallel, these get mixed up. So make a copy of the
    % model.
    step_time=0.18;
    fix_lum=0.5
    write_step_luminance ([model_dir '/luminances.json'], targetThetaX, targetThetaY, lumval, step_time, fix_lum);

    output_dirs = setup_model_directories ([targetThetaX, targetThetaY], lumval);
    [ eyeRyAvg, eyeRySD, eyeRyFinals, peakPos, startMove ] = run_simulation_multi (model_dir, output_dirs, params)

    % This is the standard results filename format, with G0 because this
    % is only carried out with steps and D-1 means dopamine was
    % unchanged from the value encoded in the model.
    resname = ['r_' num2str(targetThetaX) '_' num2str(targetThetaY) '_G0_L' num2str(lumval) '_D' num2str(dop) '.dat'];
    resdatname = ['r_' num2str(targetThetaX) '_' num2str(targetThetaY) '_G0_L' num2str(lumval) '_D' num2str(dop)];
    resdatname = strrep (resdatname, '.', 'p');
    % You can't put minus signs in the resdat name, either.
    resdatname = strrep (resdatname, '-', 'm');

    step_time_ms = step_time*1000; % latency is time of movement
                                   % starting - step time.

    % The format of vs, and therefore result, is standard between
    % thsi script and sacc_lat_vs_gap.m.
    gap_ms = 0;
    vs = [targetThetaX, targetThetaY, fix_lum, gap_ms, lumval, eyeRyAvg, eyeRySD, mean(startMove)-step_time_ms, std(startMove), dop];

    result = struct();
    result.(resdatname) = vs;

    save (['results/' resname], 'result');

end