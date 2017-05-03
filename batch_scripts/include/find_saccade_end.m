%% Author: Seb James <seb@PSY0001622>
%% Created: 2015-11-05
%%
%% Find the iterator at which the saccade ends based on the eye velocity.
function [endsacc] = find_saccade_end (eyeR, peaktime)
    
    % Find end of first saccade. Note the use of abs() - we don't
    % care which direction the saccade is in here.
    deyeR = diff(abs(eyeR(peaktime:end)));
    ddeyeR = diff(deyeR);

    %figure(50);
    %clf;
    %plot (abs(eyeR(peaktime:end)), 'b');
    %hold on;    
    %plot (deyeR, 'r');
    %plot (ddeyeR, 'g');
    
    % Start looking for the end of the saccade by finding the
    % peak velocity of the first saccade:
    max_vel_iter = min(find (ddeyeR < 0));
                                       
    % From this point, find the end, which is defined here as
    % the point where the vel drops below 0.0182 of the peak
    % vel. By this time, the position of the eye is fairly close to
    % where it will be at t=inf - the extra drift being about 0.4
    % degrees if the model runs to 1 second.
    endsacc = min (find (deyeR(max_vel_iter:end)<(deyeR(max_vel_iter).*0.0182))) ...
              + peaktime;

    % Check endsacc. What if there is no place where it gets that small?
    if (isempty(endsacc))
        % Set endsacc to peaktime+1, which for this function means "failed".
        endsacc = peaktime+1;
    end

    %final_eyeR = eyeR(endsacc)
end
