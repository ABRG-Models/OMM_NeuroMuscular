function [ eyeposAvg, eyeposSD, eyeposFinals, peakPos, startMove ] = run_sim_multi_for_latency ...
        (model_dir, output_dirs, num_runs, insigneo, cleanup, da_param)
%% Run a simulation specified in model_dir, sending results to
%% output_dirs.root num_runs times. Do this by submitting using the
%% qsub system and use calls to Qstat to determine when the runs
%% have completed. Return the mean and sd of the result (at time of
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
        display(['Starting sim run ' tag{i} ' in output dir: ' output_dirs.root '_' num2str(i)]);
        scriptname=['/fastdata/pc1ssj/' tag{i} '_run_sim.sh'];
        script=['pushd /home/pc1ssj/SpineML_2_BRAHMS && ./convert_script_s2b -g ' ...
                '-p "Str_D1:da:' num2str(da_param) '" -p "Str_D2:da:' ...
                num2str(da_param) '" ' ...
                '-p "Mirror to FEF Synapse 0 postsynapse:w:0" ' ...
                '-p "FEF_add_noise to FEF Synapse 0 postsynapse:w:1" ' ...
                '-m ' model_dir ' -e4 -o ' output_dirs.root '_' num2str(i) ' && popd'];

        fid = fopen (scriptname, 'w');
        fprintf (fid, '#!/bin/sh\n%s\n', script);
        fclose (fid);

        % For requests for two processors, use -pe openmp 2 and
        % change mem to 1G (so that you get 1G * 2 = 2G per job)

        % Insigneo version
        if insigneo
            cmd=['mkdir -p ' output_dirs.qlog '_' num2str(i) ' && ' ...
                 'qsub -o '  output_dirs.qlog '_' num2str(i) ...
                 '/qsub.out -m a -M seb.james@sheffield.ac.uk ' ...
                 '-j y -l mem=2G -l rmem=2G -l arch=intel* ' ...
                 '-P insigneo-notremor ' scriptname];
        else
            % General submission:
            cmd=['mkdir -p ' output_dirs.qlog '_' num2str(i) ' && ' ...
                 'qsub -o '  output_dirs.qlog '_' num2str(i) ...
                 '/qsub.out -j y -l mem=2G -l rmem=2G ' scriptname];
        end
        %display (['qsub command: ' cmd]);
        [status, output] = system (cmd);
    end

    % Run this several times at once with qsub scheme and wait on jobs to
    % finish using Qstat: Qstat| grep rotations_| awk -F ' ' '{print $1}'

    % First, wait until at least one job is running:
    running = 0;
    errqsub = 0; % Set to 1 if there was a problem qsubbing the job
    while running == 0 && errqsub == 0
        concatenated_output = [];
        for i = 1:num_runs
            cmd = ['qstat -u pc1ssj | grep ' tag{i}  ' | awk -F '' '' ''{print $5}'''];
            [status, output] = system (cmd);
            %cmd = ['qstat | grep ' tag{i}];
            %[status2, output2] = system (cmd);
            %display (['qstat output: ' output2]);
            if ~isempty(output)
                errstate = find (output == 'E');
                if ~isempty(errstate)
                    display (['Error qsubbing job ' tag{i} '! Exiting...'])
                    errqsub = 1;
                else
                    concatenated_output = [concatenated_output output];
                end
            else
                %display (['No job yet for tag ' tag{i}]);
            end
        end
        if isempty(concatenated_output)
            display ('No job started yet...');
        else
            running = 1;
        end
    end

    % Now wait until all jobs have completed.
    if (errqsub == 1)
        running = 0;
    end
    while running > 0
        concatenated_output = [];
        for i = 1:num_runs
            cmd = ['qstat -u pc1ssj | grep pc1ssj | grep ' tag{i}  ' | awk -F '' '' ''{print $5}'''];
            [status, output] = system (cmd);
            %cmd = ['qstat| grep ' tag{i}];
            %[status2, output2] = system (cmd);
            %display (['qstat output: ' output2]);
            if ~isempty(output)
                %display (['qstat output: ' output]);
                errstate = find (output == 'E');
                if ~isempty(errstate)
                    display (['Job ' tag{i} 'has an error!'])
                else
                    concatenated_output = [concatenated_output output];
                end
            else
                display (['No process for tag ' tag{i}]);
            end
        end
        %display (concatenated_output);
        if isempty(concatenated_output)
            display ('Finished; concatenated output is zero');
            cmd = ['qstat -u pc1ssj | grep ' tag{i}];
            [status2, output2] = system (cmd);
            display (['qstat output at finished time: ' output2]);
            running = 0;
        else
            % Should have caught any errors above.
            errstate = find (output == 'E');
            if ~isempty(errstate)
                display ('Uh oh, error')
                running = 0;
            else
                %display ('Sleeping 5...');
                pause (5);
            end
        end
    end

    % Clean up the run scripts
    display ('Clean up run scripts...');
    for i = 1:num_runs
        scriptname=['/fastdata/pc1ssj/' tag{i} '_run_sim.sh'];
        unlink (scriptname);
    end

    display ('Read output...');
    eyeposFinals = [];
    startMove = [];
    alla = [];
    allb = [];
    allc_x = [];
    allc_y = [];
    for i = 1:num_runs
        % Eye rotations. This csvread may fail with an error. If it does, then
        % try again a few times, in case it's a fastdata
        % problem. So, first ensure we can access the file.
        sslogfilepath = [output_dirs.root '_' num2str(i) '/run/saccsim_side.log'];
        existcount = 0;
        while ~exist(sslogfilepath) && existcount < 10
            pause(5)
            existcount = existcount + 1;
        end
        if exist(sslogfilepath)
            SS = csvread (sslogfilepath, 1 , 0);
        else
            display (['We have a problem accessing ' ...
                      sslogfilepath]);
            continue;
        end
        eyeRx = SS(:,8);
        eyeRy = SS(:,9);
        eyeRz = SS(:,10);
        clear SS;
        eyeposFinals = [eyeposFinals [eyeRx(end);eyeRy(end);eyeRz(end)]];
        save('eyeR.oct','eyeRx','eyeRy','eyeRz');
        tmp = min([min(find(eyeRx~=0)), min(find(eyeRy~=0)), min(find(eyeRz~=0))]);
        if isempty(tmp) == 0
            startMove = [ startMove tmp ];
        end

        % Check size of eyeposFinals here, and continue on if it's
        % short. Alternatively, check find_saccade_location's
        % return values and if they're wrong, i.e. peak pos
        % couldn't be found, then continue on, ignoring the run.

        % Determine the pixel which is active in the sc deep output
        % layer sca.
        [allc_x, allc_y, alla, allb] = ...
            find_saccade_location (output_dirs, i, allc_x, allc_y, alla, allb);

        % Clean up the log data directory:
        if cleanup
            rmcmd = ['rm -rf ' output_dirs.root '_' num2str(i)];
            display (['Calling ' rmcmd]);
            [status, output] = system (rmcmd);
        end
    end

    eyeposFinals;
    eyeposAvg = mean (eyeposFinals');
    eyeposSD = std (eyeposFinals');

    % co-ordinates of the location of the peak from the median of
    % alla, allb.
    debug_it = 1
    if debug_it
        display(['mean centroid x/y position: ' ...
                 num2str(mean(allc_x)) '/' num2str(mean(allc_y)) ' from ' ...
                 num2str(size(allc_x)(2)) ' entries with sd '  ...
                 num2str(std(allc_x)) '/' num2str(std(allc_y))]);
        allc_x
        allc_y
        display(['mean sca x/y position: ' ...
                 num2str(mean(alla)) '/' num2str(mean(allb)) ' from ' ...
                 num2str(size(alla)(2)) ' entries with sd '  ...
                 num2str(std(alla)) '/' num2str(std(allb))]);
        alla
        allb
    end
    if ~isempty(alla) && ~isempty(allb)
        peakPos = [median(alla), median(allb), mean(allc_x), mean(allc_y)];
    else
        display('Bad peakPos information, setting peakPos to zeros...');
        peakPos = [0, 0, 0, 0];
    end
    % Clean up model copy
    if cleanup
        rmcmd = ['rm -rf ' output_dirs.model];
        display (['Calling ' rmcmd]);
        [status, output] = system (rmcmd);
    end

    display ('run_simulation_multi() finished.');
end
