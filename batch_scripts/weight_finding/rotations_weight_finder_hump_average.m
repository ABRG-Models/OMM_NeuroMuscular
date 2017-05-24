function [bestweight, lastangle] = rotations_weight_finder_hump_average (targetThetaY,weight)
%% Explore the parameter space of SCdeep -> LLBN collicular mapping
%% weight for a single target saccade.
%%
%% This expects the oculomotor model to be tuned to saccade to a stable
%% final rotation for a single stimulus. It then records a rotation
%% error: (finalAngle - targetAngle).
%%
%% This aims to calculate the best weight for a given
%% targetThetaY. Other versions of this script could be used to obtain
%% the other collicular weight maps, but this is the first one.
%%
%% This version of the script (compare it with rotations_weight_finder.m)
%% will find the location of the hump of activity in SC deep, and
%% will determine weights for that "disc" of activity. THis will be
%% the approach to take when calculating weights across the surface
%% in 2-D, however, for now, this is still a 1-D finder.
%%
%% Author: Seb James.

    addpath ('./include');

    % To get stdout scrolling past while this runs:
    page_screen_output(0);
    page_output_immediately(1);

    weightsBinaryFile = '/explicitDataBinaryFile51.bin';
    exploratory_weight = 0.3 % This will need changing depending on
                             % b in LLBN popn.

    dbgfile = fopen (['/fastdata/' getenv('USER') '/dbgT' num2str(targetThetaY) ...
                      '.log'], 'w');

    %weight = 0.16; % starting weight. Hard coded.
    error_threshold = 0.1; % This should be larger than the scatter
                           % in the output angle for repeat runs for
                           % the same weight. About 0.1 is good?

    first_weight_step = 0.1; % Not really used.

    learning_rate = 0.7;
    default_dedw = 70;

    nfs = 50; % neural field size.
    % The input model. Hardcoded.
    orig_model_dir = [getenv('HOME') '/OMM_NeuroMuscular/Model1'];
    % This codes makes a copy here:
    model_dir = '/fastdata/' getenv('USER') '/input_models/';
    cmd = ['mkdir -p ' model_dir];
    system (cmd);
    model_dir = [model_dir 'OculomotorT' num2str(targetThetaY)];
    cmd = ['rm -rf ' model_dir];
    system (cmd);
    cmd = ['cp -Ra ' orig_model_dir ' ' model_dir];
    system (cmd);

    step_time = 0.12
    fix_lum = 0.5
    % Write luminances.json into model dir:
    if (write_step_luminance ([model_dir '/luminances.json'], 0, targetThetaY, step_time, fix_lum)) < 1
        return
    end

    % This counter is the iteration counter - it increments each
    % time the weight is changed for a new iteration
    counter = 0;
    output_dirs = setup_model_directories (targetThetaY, counter);

    lastweight = weight-first_weight_step;
    lasterror = 1000;
    error = 1;

    % The zeroth loop, where we find out the location of the hump although
    % we can't really say too much about its size from this. Note that
    % it's important that the weight isn't too large here, or there
    % may be an induced saccade from the noise alone.
    %%write_onedim_binary ([model_dir '/explicitDataBinaryFile11.bin'], 0.1);
    write_plane_weights ([model_dir weightsBinaryFile], exploratory_weight);
    cmd=['pushd ' getenv('HOME') '/SpineML_2_BRAHMS && ./convert_script_s2b  ' ...
         '-m ' model_dir ' -e0 -o ' output_dirs.root ' && popd'];
    system(cmd);

    % Load the SC deep data from the run, to find the location of
    % the hump. We don't do this in the loop, only here during the
    % "zeroth" run.
    [peak, peak_centroid, mask, points] = find_scd_mask ([output_dirs.log 'SC_deep_out_log.bin']);
    if isempty (mask)
        display ('error finding scd mask on zeroth run, reduce/change exploratory_weight');
        return
    else
        fprintf (dbgfile, 'Peak in scd occurs at time %d\n', peak);
        fprintf (dbgfile, 'Number of points in mask: %d\n', (size(points)(1)));
        fprintf (dbgfile, 'Centroid of the SC deep peak: %f,%f\n', peak_centroid(1), ...
                 peak_centroid(2));
    end

    figure (84+counter); surf (mask); title (['mask 0 If this is flat ' ...
                        'then update exploratory_weight!']);

    %input ('Did zeroth run, press rtn to continue.');

    %
    % The first loop.
    %
    counter = 1;
    output_dirs = setup_model_directories (targetThetaY, counter);

    write_mapped_weights ([model_dir weightsBinaryFile], weight, mask);

    [ eyeRyAvg, eyeRySD ] = run_simulation_multi (model_dir, output_dirs, 10);

    %
    % Calculate mask (and peak!) again (choose first run from the
    % run_simulation_multi above)
    %
    [peak, peak_centroid, mask, points] = find_scd_mask ([output_dirs.root '_1/log/SC_deep_out_log.bin']);

    figure (84+counter);
    surf (mask); title (['mask 1. If this is ' ...
                        'flat, then this isn''t going to work!']);
    if isempty (mask)
        display ('error finding scd mask on first run');
        return
    end
        if sum(mask) == 0
        display ('mask is zero, exiting!');
        return
    end

    %
    % New weight calculation
    %

    % Error for this calculation
    errorplus = eyeRyAvg + 2*eyeRySD - targetThetaY
    error = eyeRyAvg - targetThetaY
    errorminus = eyeRyAvg - 2*eyeRySD - targetThetaY
    eyeRySD

    if error > 0 && errorplus > 0 && errorminus > 0
        % Unambiguous
        display ('unambiguous');
    elseif error < 0 && errorplus < 0 && errorminus < 0
        % Unambiguous
        display ('unambiguous');
    else
        display ('ambiguous error sign');
    end

    % Cooked up dedw initial value.
    dedw = default_dedw

    % Calculate new weight, based on a cooked up dw/de:
    reallylastweight = lastweight;
    lastweight = weight;
    weight = lastweight - ((learning_rate*error)/dedw);
    while weight < 0 && weight > -100000
        display (['weight (' num2str(weight) ') is negative, so increase dedw from ' ...
                  num2str(dedw) ' to double that.']);
        dedw = dedw.*2;
        weight = lastweight - ((learning_rate*error)/dedw);
        display (['updated weight is now ' num2str(weight)]);
    end

    if weight < 0
        display ('Weight still negative - returning');
        return
    end

    lastangle = eyeRyAvg;

    %
    % Report
    %
    rotations_report (dbgfile, lastangle, eyeRyAvg, eyeRySD, lasterror, error, ...
                      reallylastweight, lastweight, weight, dedw);

    counter = counter + 1;

    %input ('Got first set of numbers, press rtn to continue into the while loop.');

    %
    % Now start the looping
    %
    while abs(error) > error_threshold

        output_dirs = setup_model_directories (targetThetaY, counter);
        system (['mkdir -p ' output_dirs.model]);

        % Write out the luminances file into the output model directory (to
        % make parallel running safe).
        if (write_step_luminance ([output_dirs.model '/luminances.json'], targetThetaY)) < 1
            return
        end

        write_mapped_weights ([model_dir weightsBinaryFile], weight, mask);

        [ eyeRyAvg, eyeRySD ] = run_simulation_multi (model_dir, output_dirs, 10);


        display (['This is counter=' num2str(counter)]);
        if eyeRyAvg > 0
            %
            % Calculate next weight.
            %
            lasterror = error
            errorplus = eyeRyAvg + 2*eyeRySD - targetThetaY
            error = eyeRyAvg - targetThetaY
            errorminus = eyeRyAvg - 2*eyeRySD - targetThetaY
            eyeRySD

            % Calculate rate of change of error per weight change.
            delta_weight = weight - lastweight
            delta_error = error - lasterror
            printf ('weight=%f - lastweight=%f = %f (delta_weight)', ...
                    weight, lastweight);
            printf ('error=%f - lasterror=%f = %f (delta_error)', ...
                    error, lasterror);
            dedw = delta_error / delta_weight
            if dedw == 0
                dedw = default_dedw;
            end

            % Calculate new weight, based on a calculated de/dw:
            reallylastweight = lastweight;
            lastweight = weight;
            weight = lastweight - ((learning_rate*error)/dedw);

            % Check sanity of new weight and modify de/dw accordingly
            % to avoid going negative.
            while weight < 0
                display (['weight (' num2str(weight) ') is negative, so increase dedw from ' ...
                          num2str(dedw) ' to double that.']);
                dedw = dedw.*2;
                weight = lastweight - ((learning_rate*error)/dedw);
                display (['updated weight is now ' num2str(weight)]);
            end

        else
            % eyeRyAvg is 0. Set weight to the average of current
            % weight and last weight to attempt to get back to
            % having a saccade.
            lasterror = error
            error = -targetThetaY
            reallylastweight = lastweight;
            lastweight = weight;
            display ('Setting weight as average of the last two...');
            weight = (lastweight + reallylastweight) / 2;
        end

        rotations_report (dbgfile, lastangle, eyeRyAvg, eyeRySD, lasterror, error, ...
                          reallylastweight, lastweight, weight, dedw);

        lastangle = eyeRyAvg;
        display (['Finished with counter=' num2str(counter)]);

        if abs(error) < eyeRySD
            display ('Finishing because error is smaller than 1 SD.');
            break
        end

        counter = counter + 1;

        %input ('Press rtn to continue...'); display ('...continuing');

    end

    display (['Overall best weight for targetThetaY=' num2str(targetThetaY) ...
              ': ' num2str(lastweight) ' for which ' ...
              'angle was: ' num2str(lastangle)]);
    fclose (dbgfile);

    bestweight = lastweight;

end
