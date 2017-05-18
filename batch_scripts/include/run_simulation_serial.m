function [ eyeRyAvg, eyeRySD, eyeRyFinals ] = run_simulation_serial ...
        (model_dir, output_dirs, num_runs)
%% Run a simulation specified in model_dir, sending results to
%% output_dirs.root num_runs times.
%%
%% This differs from run_simulation_multi.m in that it runs the
%% sims in serial rather than using qsub to run them in parallel. I
%% did this because it means I don't have to implement multiple
%% concurrent connections to the networkserver
%%
%% Return the mean and sd of the result (at time of
%% writing, this is the final rotation around the y axis of the
%% biomechanical eye model). Note: Application, model and
%% seb-specific code.

    if ~exist (model_dir, 'dir')
        display ('Uh oh - model directory doesn''t exist!');
        return
    end

    tag = {};
    for i = 1:num_runs

        tag{i} = ['r' num2str(i-1) '_' num2str(round(rand * ...
                                                   999999))];
        display(['Starting sim run ' tag{i}]);
        scriptname=['/fastdata/' getenv('USER') '/' tag{i} '_run_sim.sh'];
        script=['pushd ' getenv('HOME') '/SpineML_2_BRAHMS && ./convert_script_s2b  ' ...
                '-m ' model_dir ' -e3 -o ' output_dirs.root '_' num2str(i) ' && popd'];

        fid = fopen (scriptname, "w");
        fprintf (fid, '#!/bin/sh\n%s\n', script);
        fclose (fid);

        % Now execute the script "scriptname"
        cmd = [ 'bash ' scriptname ];
        [status, output] = system (cmd);

        pause (3);
    end

    % Clean up the run scripts
    display ('Clean up run scripts...');
    for i = 1:num_runs
        scriptname=['/fastdata/' getenv('USER') '/' tag{i} '_run_sim.sh'];
        unlink (scriptname);
    end

    display ('Read output...');
    eyeRyFinals = [];
    for i = 1:num_runs
        % Eye rotations
        SS = csvread ([output_dirs.root '_' num2str(i) '/run/saccsim_side.log'], 1 , 0);
        eyeRy = SS(:,9);
        clear SS;
        eyeRyFinals = [eyeRyFinals eyeRy(end)];
    end

    eyeRyAvg = mean (eyeRyFinals);
    eyeRySD = std (eyeRyFinals);

    display ('Finished.');
end
