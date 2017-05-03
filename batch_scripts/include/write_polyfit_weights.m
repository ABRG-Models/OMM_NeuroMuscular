% Write out a line of weights into an explicitDataBinaryFile, so
% that the model can be trained.

% The weights are output along indices 37 and 38.

% The input to this script is the filepath of the target binary
% file.
function write_polyfit_weights (file_path, polyparams)

    d = zeros (50, 50);
    x = 1:50;
    fov_dist_offset = 12;
    sigmoid_narrowness = -4;

    F = polyval (polyparams, x);

    % Sigmoid to dampen down weights around fovea:
    line = (1./(1 + exp(sigmoid_narrowness.*(x.-fov_dist_offset)))).*F;
    d (37, :) = line;
    d (38, :) = line;

    d = reshape (d, 2500, 1, []);

    [fid, errmsg] = fopen (file_path, 'w');
    if fid == -1
        display (errmsg);
        return
    end

    for i = 0:2499
        fwrite (fid, i, 'int32');
        fwrite (fid, d(i+1), 'double');    
    end

    fclose (fid);

end
