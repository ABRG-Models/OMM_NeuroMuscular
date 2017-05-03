function worldDataMaker_sn_run (L)
% start the interface thread
display ('SpineMLNet ML: initialising...');
context = spinemlnetStart (50091);
display ('SpineMLNet ML: initialised.');

% Specify a cleanup function.
cleanupObj = onCleanup(@() spinemlnetCleanup(context));

% Add model input luminance data to the 'World Input' connection
[artn errormsg] = spinemlnetAddData (context, 'World Input', L);
if length(errormsg) > 0
    display (errormsg);
end

% loop until the spinemlnet system has finished.
escaped = false;

display ('SpineMLNet ML: Going into loop...');
while escaped == false
   
    % query for current state.
    qrtn = spinemlnetQuery (context);
    
    % qrtn(1,1): threadFinished (possibly failure)
    % qrtn(1,2): connectionsFinished - this means you can go ahead
    % and collect data with spinemlnetGetData().
    if qrtn(1,1) == 1
        % The thread failed, so set escaped to true.
        display ('SpineMLNet ML: The TCP/IP I/O thread seems to have failed. Finishing.');
        escaped = true;
    elseif qrtn(1,2) == 1
        % The connections completed, so we can collect data and escape
        display ('SpineMLNet ML: Finished');
        escaped = true;
    else
        % Pass no data back to worldDataMaker - use the
        % SpineCreator files for that; it's safer.
    end
    pause (3);
end

display ('SpineMLNet ML: Script finished');
end

function spinemlnetCleanup (context)
    disp('SpineMLNet ML: spinemlnetCleanup: Calling spinemlnetStop');
    spinemlnetStop(context);
    disp('SpineMLNet ML: cleanup complete.');
end
