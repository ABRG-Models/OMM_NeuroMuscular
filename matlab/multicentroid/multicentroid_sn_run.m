function multicentroid_sn_run ()
%% Communicate with model to do multiple centroiding. Copy SD_deep
%% data from model; apply multiple centroid algorithm; 
    
    % start the interface thread
    display ('SpineMLNet mcent: initialising...');
    context = spinemlnetStart (50091);
    display ('SpineMLNet mcent: initialised.');

    % Specify a cleanup function.
    cleanupObj = onCleanup(@() spinemlnetCleanup(context));

    % loop until the spinemlnet system has finished.
    escaped = false;

    % holding variable for our neural sheet, stored as a vector.
    sheet = zeros(2500,1);
    
    % Is the spinemlnet main thread preventing octave from getting
    % any further at this point? Perhaps spinemlnet main thread
    % needs to allow some time for the main octave thread.
    
    display ('SpineMLNet mcent: Going into loop...');
    while escaped == false
   
        % query for current state.
        qrtn = spinemlnetQuery (context);
        
        % qrtn(1,1): threadFinished (possibly failure)
        % qrtn(1,2): connectionsFinished - this means you can go ahead
        % and collect data with spinemlnetGetData().
        if qrtn(1,1) == 1
            % The thread failed, so set escaped to true.
            display ('SpineMLNet mcent: The TCP/IP I/O thread seems to have failed. Finishing.');
            escaped = true;
        elseif qrtn(1,2) == 1
            % The connections completed, so we can collect any
            % remaining data and then escape
            %display (['SpineMLNet mcent: Finished; collect any ' ...
            %          'remaining data...']);
            sheet = spinemlnetGetData (context, 'SC_deep');
            sz = size(sheet);
            for i=1:sz(:,2)
                [artn errormsg] = spinemlnetAddData (context, 'SC_deep_output', sheet(:,i));
                if length(errormsg) > 0
                    display (errormsg);
                    escaped = true;
                end
            end
            % Don't escape when connections are finished; allow
            % another run of the model.
            % escaped = true;
        else
            % Get data from model - this will be the SC_deep neural sheet.
            sheet = spinemlnetGetData (context, 'SC_deep');

            % use the result of spinemlnetGetData to determine
            % whether there was data or no. We should get two zeros
            % if the connection isn't yet ready.
            sz = size(sheet);
            if sz(1) == 1
                % size sheet is [1 2] in this case
                % display ('SpineMLNet mcent: No data yet from spinemlnetGetData...');
            else
                %display (['SpineMLNet mcent: Got data from ' ...
                %          'SC_deep. NOW call spinemlnetAddData...']);

                % loop through data...
                sz = size(sheet);
                centroid_radius = 8;
                for i=1:sz(:,2)

                    % So, compute it...
                    sqsheet = reshape (sheet, 50, 50, []);
                    [ sqsheet, a ] = multicentroid_compute (sqsheet, centroid_radius);
                    sheet(:,i) = reshape (sqsheet, 2500, 1, []);
                    
                    % ...and add it back in to the model.
                    [artn errormsg] = spinemlnetAddData (context, 'SC_deep_output', sheet(:,i));
                    if length(errormsg) > 0
                        display (errormsg);
                        escaped = true;
                    end
                end
            end
        end
        %pause (1);
    end

    display ('SpineMLNet mcent: Script finished');
end

function spinemlnetCleanup (context)
    disp('SpineMLNet mcent: spinemlnetCleanup: Calling spinemlnetStop');
    spinemlnetStop(context);
    disp('SpineMLNet mcent: cleanup complete.');
end
