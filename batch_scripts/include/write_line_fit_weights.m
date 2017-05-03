% Write out a line of weights specified in weightline into an
% explicitDataBinaryFile, so that the model can be trained.

% The weights are output along the given range of indices and
% should be a row vector. The indices should also be a row vector.

% The input to this script is the filepath of the target binary
% file.
function write_line_fit_weights (file_path, weightline, indices)

    d = zeros (50, 50);
    x = 1:50;
    fov_dist_offset = 12;
    sigmoid_narrowness = -4;

    % Sigmoid to dampen down weights around fovea:
    line = (1./(1 + exp(sigmoid_narrowness.*(x.-fov_dist_offset)))).*weightline;
    for i = indices
        d (i, :) = line;
    end
    
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
