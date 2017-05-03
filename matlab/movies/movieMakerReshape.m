function reshaped = movieMakerReshape (data, nfs)
    reshaped = data;
    reshaped(1) = 0; reshaped(2) = 1;
    reshaped = reshape (reshaped, nfs, nfs);
end
