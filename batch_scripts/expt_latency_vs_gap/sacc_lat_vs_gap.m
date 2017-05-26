%% Run the model to find the saccade latency and end position for a
%% given target location, gap, target luminance and model dopamine level. Fixation
%% luminance is hardcoded in this function.
%%
%% Results are saved in ./results/
%%
%% Usage:
%%
%%   sacc_lat_vs_gap (targetThetaX, targetThetaY, num_par_runs,
%%   gap_ms, lum, dop)
%%
function sacc_lat_vs_gap (targetThetaX, targetThetaY, num_par_runs, gap_ms, lum, dop=-1)

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
    model_dir = ['/fastdata/' getenv('USER') '/OMM_NeuroMuscular/SVG' num2str(targetThetaX) '_' num2str(targetThetaY) '_' num2str(gap_ms) '_' num2str(lum) '_' num2str(dop) ]

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
    params.targetCross=0; % 1 if target should be the cross shape.
    params.targetLuminance=lum;
    params.targetWidthX=4;
    params.targetWidthY=4;
    params.fixCross=0;
    params.fixLuminance=0.5;
    params.fixWidthX=2;
    params.fixWidthY=2;
    params.fixOn=0;
    params.targetOff=1;
    params.cleanup=1; % Set to 1 to clean up used files.

    % Determined by the gap argument:
    params.targetOn = 0.2;
    params.fixOff = 0.2-gap_ms;
    % Also from args:
    params.targetThetaX=targetThetaX;
    params.targetThetaY=targetThetaY;
    params.dopamine = dop;

    write_single_luminance_with_fix ([model_dir '/luminances.json'], params);

    output_dirs = setup_latency_directories (params, 1);

    [ eyeRyAvg, eyeRySD, eyeRyFinals, peakPos, startMove ] = run_simulation_multi (model_dir, output_dirs, params)

    resname = ['r_' num2str(targetThetaX) '_' num2str(targetThetaY) '_G' num2str(gap_ms) '_L' num2str(lum) '_D' num2str(dop) '.dat'];
    resdatname = ['r_' num2str(targetThetaX) '_' num2str(targetThetaY) '_G' num2str(gap_ms) '_L' num2str(lum) '_D' num2str(dop)];
    resdatname = strrep (resdatname, '.', 'p');
    % You can't put minus signs in the resdat name, either.
    resdatname = strrep (resdatname, '-', 'm');

    vs = [targetThetaX, targetThetaY, params.fixLuminance, gap_ms, lum, eyeRyAvg, eyeRySD, mean(startMove)-(1000.*params.targetOn), std(startMove), dop];

    result = struct();
    result.params = params;
    result.(resdatname) = vs;

    save (['results/' resname], 'result');

end