%% Run the model to find the saccade latency and end position for a
%% given target location, gap, target luminance and model dopamine
%% level.
%%
%% Fixation luminance is hardcoded in this function, as are
%% numerous parameters such as shape (cross or rectangle), cross
%% dimensions, fixation location and so on.
%%
%% The model to be used is obtained from an environment variable
%% OMMMODEL. The experiment to be used is the default used in
%% run_simulation_multi - expt 2.
%%
%% Results are saved in resultdir and there is no return
%% value. Used by scripts in expt_sacc_vs_*
%%
%% Usage:
%%
%%   perform_saccade (targetThetaX, targetThetaY, num_par_runs,
%%   gap_ms, lum, dop)
%%
function perform_saccade (resultdir, targetThetaX, targetThetaY, num_par_runs, gap_ms, lum, dop, fixlum=0.2, exptnum=0)

    page_screen_output(0);
    page_output_immediately(1);

    if ~(floor(targetThetaX) == targetThetaX) || ~(floor(targetThetaY) == targetThetaY)
        display ('Integers only for targetThetaX/targetThetaY')
        return;
    end

    % Configure params object for run_simulation_multi
    params.cleanup = 0;
    params.num_runs = num_par_runs;
    if (dop != -1)
        params.dopamine = dop;
    end

    [d, msg, msgid] = mkdir (['/fastdata/' getenv('USER')])
    [d, msg, msgid] = mkdir (['/fastdata/' getenv('USER') '/OMM_NeuroMuscular'])
    model_dir = ['/fastdata/' getenv('USER') '/OMM_NeuroMuscular/PFSC_X' num2str(targetThetaX) '_Y' num2str(targetThetaY) '_G' num2str(gap_ms) '_F' num2str(fixlum) '_L' num2str(lum) '_D' num2str(dop)]

    model_tag = getenv('OMMODEL');
    if isempty(model_tag)
        display('Please set the environment variable OMMODEL to something like "Model3"')
        return
    end
    origin_model_dir = [getenv('HOME') '/OMM_NeuroMuscular/' model_tag];

    % Copy origin_model_dir into model_dir.
    if exist (model_dir) == 7
        copyfile ([origin_model_dir '/*'], [model_dir '/'], 'f');
    else
        copyfile (origin_model_dir, model_dir, 'f');
    end

    % This writes into the origin model directory. When running
    % many in parallel, these get mixed up. So make a copy of the
    % model.
    params.targetCross=1; % 1 if target should be the cross shape.
    params.targetLuminance=lum;
    params.targetWidthX=6;
    params.targetWidthY=2;
    params.fixCross=1;
    params.fixLuminance=fixlum;
    params.fixWidthX=6;
    params.fixWidthY=2;
    params.fixOn=0;
    params.targetOff=1;

    % Determined by the gap argument:
    if (exptnum > 0) % expt 0 has 0.6 sec duration; expts 5,6,7 have
                     % 1 sec duration.
        params.targetOn = 0.4;
        params.fixOff = 0.4-(gap_ms./1000);
    else
        params.targetOn = 0.2;
        params.fixOff = 0.2-(gap_ms./1000);
    end
    % Also from args:
    params.targetThetaX=targetThetaX;
    params.targetThetaY=targetThetaY;
    params.dopamine = dop;

    params.exptnum = exptnum; % 0 gives extra logging. default is 2.

    write_single_luminance_with_fix ([model_dir '/luminances.json'], params);

    output_dirs = setup_latency_directories (params, 1);

    [ eyeRAvg, eyeRSD, eyeRFinals, peakPos, startMove ] = run_simulation_multi (model_dir, output_dirs, params)

    resname = ['r_' num2str(targetThetaX) '_' num2str(targetThetaY) '_G' num2str(gap_ms) '_F' num2str(fixlum) '_L' num2str(lum) '_D' num2str(dop) '.dat'];
    resdatname = ['r_' num2str(targetThetaX) '_' num2str(targetThetaY) '_G' num2str(gap_ms) '_F' num2str(fixlum) '_L' num2str(lum) '_D' num2str(dop)];
    resdatname = strrep (resdatname, '.', 'p');
    % You can't put minus signs in the resdat name, either.
    resdatname = strrep (resdatname, '-', 'm');

    vs = [targetThetaX, targetThetaY, params.fixLuminance, gap_ms, lum, eyeRAvg, eyeRSD, mean(startMove)-(1000.*params.targetOn), std(startMove), dop];

    result = struct();
    result.params = params;
    result.(resdatname) = vs;

    save ([resultdir '/' resname], 'result');

end