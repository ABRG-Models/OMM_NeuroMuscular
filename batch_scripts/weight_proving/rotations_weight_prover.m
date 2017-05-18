function [eyeposAvg, eyeposSD] = rotations_weight_prover (targetTheta,num_runs,insigneo,cleanup)
%% Run the model with run_simulation_multi() then write the results
%% out to a file.
%%
%% Author: Seb James.

    addpath ('./include');

    % To get stdout scrolling past while this runs:
    page_screen_output(0);
    page_output_immediately(1);

    display(['targetTheta: ' num2str(targetTheta)]);

    logfile = fopen (['/fastdata/' getenv('USER') '/rotwfRX' num2str(targetTheta(1)) 'RY' num2str(targetTheta(2)) ...
                      '.log'], 'w');
    fprintf (logfile, 'TargetThetaX: %f, TargetThetaY: %f\n', ...
             targetTheta(1), targetTheta(2));

    % The input model. Hardcoded.
    orig_model_dir = [getenv('HOME') '/OMM_NeuroMuscular/Model1'];
    % This codes makes a copy here (so target X/Y can be written out):
    model_dir = ['/fastdata/' getenv('USER') '/input_models/'];
    cmd = ['mkdir -p ' model_dir];
    system (cmd);
    model_dir = [model_dir 'OculomotorRX' num2str(targetTheta(1)) 'RY' ...
                 num2str(targetTheta(2))];
    cmd = ['rm -rf ' model_dir];
    system (cmd);
    cmd = ['cp -Ra ' orig_model_dir ' ' model_dir];
    system (cmd);

    % Write luminances.json into model dir:
    if (write_single_luminance ([model_dir '/luminances.json'], ...
                                targetTheta(1), targetTheta(2))) < 1
        return
    end

    counter = 1;
    output_dirs = setup_model_directories (targetTheta, counter);

    [ eyeposAvg, eyeposSD, eyeposFinals, peakPos ] = run_simulation_multi (model_dir, ...
                                                      output_dirs, num_runs, insigneo, cleanup);
    fclose (logfile);

    % columns are: target x, target y, target z,
    % x avg, x sd, y avg, y sd, z avg, z sd,
    % peakposn1(phi), peakposn2(r), meanpeakposn1(phi), meanpeakposn2(r)
    weightproving = fopen (['/fastdata/' getenv('USER') '/weightproving.log'], 'a');

    fprintf (weightproving, ...
             '%f,%f,%f,%f,%f,%f,%f,%f,%f,%d,%d,%f,%f\n', ...
             targetTheta(1), targetTheta(2), targetTheta(3), ...
             eyeposAvg(1), eyeposSD(1), eyeposAvg(2), ...
             eyeposSD(2), eyeposAvg(3), eyeposSD(3), ...
             peakPos(1), peakPos(2), peakPos(3), peakPos(4));

    fclose (weightproving);

end
