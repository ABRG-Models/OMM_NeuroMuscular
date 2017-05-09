function [bestweight, lastangle] = rotations_weight_finder_centroid_3d (targetTheta,weight,num_runs,insigneo,cleanup)
%% Explore the parameter space of SCdeep -> LLBN collicular mapping
%% weight for a single target saccade.
%%
%% This expects the oculomotor model to be tuned to saccade to a stable
%% final rotation for a single stimulus. It then records a rotation
%% error: (finalAngle - targetAngle).
%%
%% This aims to calculate the best weight for a given
%% targetThetaX/targetThetaY - it will carry out a gradient descent
%% algorithm to find two weights for any target saccade.
%%
%% It also aims to train rotational weights to keep RotZ to a value
%% 0 (noting that this may not fulfil Listing's Law).
%%
%% targetTheta is a row vector containing
%% [targetThetaX,targetThetaY]. weight is row vector containing
%% [initialWeightX,initialWeightY].
%%
%% Recall that targetThetaX is a rotation ABOUT the x axis.
%%
%% This version of the script is intended to be run on the centroid
%% output of SC_avg
%%
%% Author: Seb James.

    addpath ('./include');

    % A script parameter - passed to run_simulation_multi(). Reduce
    % when testing. 10 is typical for real work; 4 for testing.
    % num_runs = 4;

    % To get stdout scrolling past while this runs:
    page_screen_output(0);
    page_output_immediately(1);

    explicitDataBinaryFileLEFT = '/explicitDataBinaryFile50.bin';
    edbfNumLEFT = 50;
    explicitDataBinaryFileRIGHT = '/explicitDataBinaryFile52.bin';
    edbfNumRIGHT = 52;
    explicitDataBinaryFileUP = '/explicitDataBinaryFile53.bin';
    edbfNumUP = 53;
    explicitDataBinaryFileDOWN = '/explicitDataBinaryFile54.bin';
    edbfNumDOWN = 54;
    explicitDataBinaryFileZPLUS = '/explicitDataBinaryFile58.bin';
    edbfNumZPLUS = 58;
    explicitDataBinaryFileZMINUS = '/explicitDataBinaryFile57.bin';
    edbfNumZMINUS = 57;

    %weightsBinaryFile to be set here:

    display(['targetTheta: ' num2str(targetTheta)]);

    % In which direction are we saccading?
    if targetTheta(2) == 0 && targetTheta(1) == 0
        display (['One of targetTheta(1) or targetTheta(2) has to be >5 ' ...
                  'degrees.']);
        return
    end
    if targetTheta(2) <= 0 && targetTheta(1) <= 0
        % Saccade to right and down
        weightsBinaryFileY = explicitDataBinaryFileRIGHT;
        weightsBinaryFileYother = explicitDataBinaryFileLEFT;
        wbfY = edbfNumRIGHT;
        weightsBinaryFileX = explicitDataBinaryFileDOWN;
        weightsBinaryFileXother = explicitDataBinaryFileUP;
        wbfX = edbfNumDOWN;
    elseif targetTheta(2) <= 0 && targetTheta(1) >= 0
        % Saccade to right and up
        weightsBinaryFileY = explicitDataBinaryFileRIGHT;
        weightsBinaryFileYother = explicitDataBinaryFileLEFT;
        wbfY = edbfNumRIGHT;
        weightsBinaryFileX = explicitDataBinaryFileUP;
        weightsBinaryFileXother = explicitDataBinaryFileDOWN;
        wbfX = edbfNumUP;
    elseif targetTheta(2) >= 0 && targetTheta(1) <= 0
        % Saccade to left and down
        weightsBinaryFileY = explicitDataBinaryFileLEFT;
        weightsBinaryFileYother = explicitDataBinaryFileRIGHT;
        wbfY = edbfNumLEFT;
        weightsBinaryFileX = explicitDataBinaryFileDOWN;
        weightsBinaryFileXother = explicitDataBinaryFileUP;
        wbfX = edbfNumDOWN;
    elseif targetTheta(2) >= 0 && targetTheta(1) >= 0
        % Saccade to left and up
        weightsBinaryFileY = explicitDataBinaryFileLEFT;
        weightsBinaryFileYother = explicitDataBinaryFileRIGHT;
        wbfY = edbfNumLEFT;
        weightsBinaryFileX = explicitDataBinaryFileUP;
        weightsBinaryFileXother = explicitDataBinaryFileDOWN;
        wbfX = edbfNumUP;
    end

    logfile = fopen (['/fastdata/co1ssj/rotwfRX' num2str(targetTheta(1)) 'RY' num2str(targetTheta(2)) ...
                      '.log'], 'w');
    fprintf (logfile, 'TargetThetaX: %f, TargetThetaY: %f\n', ...
             targetTheta(1), targetTheta(2));

    error_threshold = [0.1,0.1,0.1]; % This should be larger than the scatter
                                 % in the output angle for repeat runs for
                                 % the same weight. About 0.1 is good?

    first_weight_step = [0.1,0.1,0.1]; % Not really used.

    learning_rate = [0.7,0.7,0.7];
    default_dedw = [70,70,70];

    nfs = 50; % neural field size.
    % The input model. Hardcoded.
    orig_model_dir = '/home/co1ssj/abrg_local/Oculomotor';
    % This codes makes a copy here:
    model_dir = '/fastdata/co1ssj/input_models/';
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

    lastweight = weight-first_weight_step;
    lasterror = [1000,1000,1000];
    error = [1,1,1];

    %
    % The first loop.
    %
    counter = 1;
    output_dirs = setup_model_directories (targetTheta, counter);

    % With centroids we can always write a plane weight.
    write_plane_weights ([model_dir weightsBinaryFileX], weight(1));
    write_plane_weights ([model_dir weightsBinaryFileY], weight(2));
    write_plane_weights ([model_dir weightsBinaryFileXother], 0);
    write_plane_weights ([model_dir weightsBinaryFileYother], 0);
    if (weight(3) >= 0)
        write_plane_weights ([model_dir explicitDataBinaryFileZPLUS], ...
                             weight(3));
        write_plane_weights ([model_dir explicitDataBinaryFileZMINUS], 0);
    else
        write_plane_weights ([model_dir explicitDataBinaryFileZPLUS], 0);
        write_plane_weights ([model_dir explicitDataBinaryFileZMINUS], ...
                             -weight(3));
    end

    [ eyeposAvg, eyeposSD, eyeposFinals, peakPos ] = run_simulation_multi (model_dir, ...
                                                      output_dirs, num_runs, insigneo, cleanup);

    %
    % New weight calculation
    %

    % Error for this calculation
    errorplus = eyeposAvg + 2*eyeposSD - targetTheta
    error = eyeposAvg - targetTheta
    errorminus = eyeposAvg - 2*eyeposSD - targetTheta

    % Cooked up dedw initial value.
    dedw = default_dedw

    % Calculate new weight, based on a cooked up dw/de:
    reallylastweight = lastweight;
    lastweight = weight;
    weight = lastweight - ((learning_rate.*error)./dedw);

    display ('weight check...')
    while any(weight<=0)
        display (['weight (' num2str(weight) ') has zero/negative component, so increase dedw from ' ...
                  num2str(dedw) ' to double that on that component.']);
        dedw = dedw .* (((weight<=0).*2) .+ (weight>0));
        weight = lastweight - ((learning_rate.*error)./dedw);
        display (['updated weight is now ' num2str(weight)]);
    end

    if norm(weight) < 0
        display ('Weight still negative - returning');
        return
    end

    lastangle = eyeposAvg;

    %
    % Report
    %
    rotations_report_vec (logfile, lastangle, eyeposAvg, eyeposSD, lasterror, error, ...
                          reallylastweight, lastweight, weight, dedw);

    counter = counter + 1;

    %input ('Got first set of numbers, press rtn to continue into the while loop.');

    %
    % Now start the looping
    %
    while norm(abs(error)) > norm(error_threshold) && counter < 50

        output_dirs = setup_model_directories (targetTheta, counter);
        system (['mkdir -p ' output_dirs.model]);

        % Write out the luminances file into the output model directory (to
        % make parallel running safe).
        if (write_single_luminance ([output_dirs.model '/luminances.json'], ...
                                    targetTheta(1), targetTheta(2))) < 1
            return
        end

        write_plane_weights ([model_dir weightsBinaryFileX], weight(1));
        write_plane_weights ([model_dir weightsBinaryFileY], weight(2));
        write_plane_weights ([model_dir weightsBinaryFileXother], 0);
        write_plane_weights ([model_dir weightsBinaryFileYother], 0);
        if (weight(3) >= 0)
            write_plane_weights ([model_dir explicitDataBinaryFileZPLUS], ...
                                 weight(3));
            write_plane_weights ([model_dir explicitDataBinaryFileZMINUS], 0);
        else
            write_plane_weights ([model_dir explicitDataBinaryFileZPLUS], 0);
            write_plane_weights ([model_dir explicitDataBinaryFileZMINUS], ...
                                 -weight(3));
        end

        [ eyeposAvg, eyeposSD, eyeposFinals, peakPos ] = run_simulation_multi (model_dir, ...
                                                          output_dirs, num_runs, insigneo, cleanup);

        display (['This is counter=' num2str(counter)]);
        if norm(eyeposAvg) > 0
            %
            % Calculate next weight.
            %
            lasterror = error
            errorplus = eyeposAvg + 2.*eyeposSD - targetTheta;
            error = eyeposAvg - targetTheta
            errorminus = eyeposAvg - 2.*eyeposSD - targetTheta;

            % Calculate rate of change of error per weight change.
            weight % debug
            lastweight % debug
            delta_weight = weight - lastweight

            error % debug
            lasterror % debug
            delta_error = error - lasterror

            dedw = delta_error ./ delta_weight

            if norm(dedw) == 0
                dedw = default_dedw;
            end

            % Calculate new weight, based on a calculated de/dw:
            reallylastweight = lastweight;
            lastweight = weight;
            weight = lastweight - ((learning_rate.*error)./dedw);

            % Check sanity of new weight and modify de/dw accordingly
            % to avoid going negative. Here is where we have to
            % treat the x/y error and the z errors slightly differently.
            display ('weight check...')
            while any(weight(1:2)<=0)
                display (['weight (' num2str(weight(1:2)) ...
                          ') has zero/negative component, so increase dedw from ' ...
                          num2str(dedw) ' to double that.']);
                dedw(1:2) = dedw(1:2) .* (((weight(1:2)<=0).*2) .+ (weight(1:2)>0));
                weight(1:2) = lastweight(1:2) - ((learning_rate(1:2).*error(1:2))./dedw(1:2));
                display (['updated weight is now ' num2str(weight)]);
            end

        else
            % norm(eyeposAvg) is 0. Set weight to the average of current
            % weight and last weight to attempt to get back to
            % having a saccade.
            lasterror = error
            error = -targetTheta
            reallylastweight = lastweight;
            lastweight = weight;
            display ('Setting weight as average of the last two...');
            weight = (lastweight + reallylastweight) ./ 2;
        end

        rotations_report_vec (logfile, lastangle, eyeposAvg, eyeposSD, lasterror, error, ...
                              reallylastweight, lastweight, weight, dedw);

        lastangle = eyeposAvg;
        display (['Finished with counter=' num2str(counter)]);

        if norm(error) < norm(eyeposSD)
            display ('Finishing because error is smaller than 1 SD.');
            break
        end

        counter = counter + 1;

        %input ('Press rtn to continue...'); display ('...continuing');

    end

    error
    abs(error)
    error_threshold

    if counter == 50
        display ('Failed to converge');
    end
    display (['Overall best weights for targetTheta=' num2str(targetTheta) ...
              ': ' num2str(lastweight) ' for which ' ...
              'angles were: ' num2str(lastangle)]);

    fprintf (logfile, ...
             '\nBest weights for %s, %s at position %d,%d: %f,%f,%f for which angles were: %f,%f.%f\n', ...
             weightsBinaryFileX,weightsBinaryFileY,peakPos(1), ...
             peakPos(2), lastweight(1),lastweight(2),lastweight(3), ...
             lastangle(1),lastangle(2),lastangle(3));

    fclose (logfile);

    % All weights columns are: weights file, axis number, target
    % angles x/y/z,
    % peakposn1(phi), peakposn2(r), bestweight, meanpeakposn1(phi),
    % meanpeakposn2(r), eyeposSD.
    allweightsfile = fopen (['/fastdata/co1ssj/allweights.log'], 'a');

    % RotX
    if counter == 50
        fprintf (allweightsfile, '#');
    end
    fprintf (allweightsfile, ...
             '%d,1,%f/%f/%f,%d,%d,%f,%f,%f,%f(%f)/%f(%f)/%f(%f)\n', ...
             wbfX, ...
             targetTheta(1), targetTheta(2), targetTheta(3), ...
             peakPos(1), peakPos(2), lastweight(1), peakPos(3), ...
             peakPos(4), eyeposAvg(1), eyeposSD(1), eyeposAvg(2), ...
             eyeposSD(2), eyeposAvg(3), eyeposSD(3));
    % RotY
    if counter == 50
        fprintf (allweightsfile, '#');
    end
    fprintf (allweightsfile, ...
             '%d,2,%f/%f/%f,%d,%d,%f,%f,%f,%f(%f)/%f(%f)/%f(%f)\n', wbfY, ...
             targetTheta(1), targetTheta(2), targetTheta(3), ...
             peakPos(1), peakPos(2), lastweight(2), peakPos(3), ...
             peakPos(4), eyeposAvg(1), eyeposSD(1), eyeposAvg(2), ...
             eyeposSD(2), eyeposAvg(3), eyeposSD(3));
    % RotZ
    if counter == 50
        fprintf (allweightsfile, '#');
    end
    if lastweight(3) >= 0
        fprintf (allweightsfile, ...
                 '%d,3,%f/%f/%f,%d,%d,%f,%f,%f,%f(%f)/%f(%f)/%f(%f)\n', ...
                 edbfNumZPLUS, ...
                 targetTheta(1), targetTheta(2), targetTheta(3), ...
                 peakPos(1), peakPos(2), ...
                 lastweight(3), peakPos(3), peakPos(4), ...
                 eyeposAvg(1), eyeposSD(1), eyeposAvg(2), ...
                 eyeposSD(2), eyeposAvg(3), eyeposSD(3));
    else
        fprintf (allweightsfile, ...
                 '%d,3,%f/%f/%f,%d,%d,%f,%f,%f,%f(%f)/%f(%f)/%f(%f)\n', ...
                 edbfNumZMINUS, ...
                 targetTheta(1), targetTheta(2), targetTheta(3), ...
                 peakPos(1), peakPos(2), ...
                 -lastweight(3), peakPos(3), peakPos(4), ...
                 eyeposAvg(1), eyeposSD(1), eyeposAvg(2), ...
                 eyeposSD(2), eyeposAvg(3), eyeposSD(3));
    end

    fclose (allweightsfile);

    bestweight = lastweight;

end
