% A test of find_saccade_end(). The code here is taken from
% run_simulation_multi.m and modified to run standalone on some
% pre-existing data.

% Run the sim somewhere and then modify this line:
logdir = '/home/co1ssj/SpineML_2_BRAHMS/temp/TModel0';

sslogfilepath = [logdir '/run/saccsim_side.log'];
if ~exist(sslogfilepath)
    display (['We have a problem accessing ' sslogfilepath]);
    return
end

% Read the data
SS = csvread (sslogfilepath, 1 , 0);
eyeRx = SS(:,8);
eyeRy = SS(:,9);
eyeRz = SS(:,10);
clear SS;

% Find the peaktime
peaktime = find_peaktime (logdir);

% Find the saccade end
if (peaktime != -1)
    display('Running find_saccade_end(eyeRx, peaktime)...');
    endsacc_x = find_saccade_end (eyeRx, peaktime)
    display('Running find_saccade_end(eyeRy, peaktime)...');
    endsacc_y = find_saccade_end (eyeRy, peaktime)

    % Now try to find the best value for the end saccade iterator
    endsacc = 0;
    if (endsacc_x == peaktime+1 && endsacc_y == peaktime+1)
        % Then we have no endsacc.
        endsacc = 0;
    elseif (endsacc_x > peaktime+1 && endsacc_y == peaktime+1)
        endsacc = endsacc_x;
    elseif (endsacc_x == peaktime+1 && endsacc_y > peaktime+1)
        endsacc = endsacc_y;
    else
        % If one component movement is larger than the other, then use the
        % endsacc for that component:
        if abs(eyeRx(endsacc_x)) > abs(eyeRy(endsacc_y))
            endsacc = endsacc_x
        else
            endsacc = endsacc_y
        end
        % Previously, I used the average of endsacc_x and y:
        % endsacc = round((endsacc_x + endsacc_y) ./ 2);
    end
    display(['endsacc: ' num2str(endsacc)]);

    if (endsacc > 0)
        display ('The number that would be placed in eyeposFinals:');
        display (['eyeRx(endsacc): ' num2str(eyeRx(endsacc))]);
        display (['eyeRy(endsacc): ' num2str(eyeRy(endsacc))]);
        display (['eyeRz(endsacc): ' num2str(eyeRz(endsacc))]);
    else
        display ('Warning: Couldn''t find end saccade');
    end

else
    display('peaktime was -1, can''t find_saccade_end()');
end