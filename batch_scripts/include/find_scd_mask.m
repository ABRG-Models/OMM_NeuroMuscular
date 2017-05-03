function [peak, peak_centroid, mask, points] = find_scd_mask (scd_log_bin_path)

    nfs = 50;
    display (['scd_log_bin_path: ' scd_log_bin_path]);
    [scd, count] = load_sc_data (scd_log_bin_path, 2500);
    scd = reshape (scd, nfs, nfs, []);
    % Find maxima in activity wrt time in scd:
    scd_time = sum(sum(scd));
    % Ignore first 100 ms
    scd_time_shifted = scd_time(100:end);
    peak_s = find (scd_time_shifted == max(scd_time_shifted));
    if scd_time_shifted(peak_s) > 4
        % Then this is a reasonably big peak.
        display (['Large peak in scd at time ' num2str(100+peak_s)]);
    else
        display ('No peak in scd found!');
        peak = 0;
        peak_centroid = [0,0];
        mask = [];
        points = [];
        return;
    end
    peak = peak_s + 100;
    points = find (scd(:,:,peak) > 0.2);
    % Create a mask for setting the weights
    mask = zeros(nfs,nfs);
    mask(points) = 1;
    display (['Number of points in the mask: ' ...
              num2str(size(points)(1))]);
    
    % Show the mask like this:
    % figure(84);
    % surf (mask)
    % title (['Location of SC deep activity at time ' num2str(peak) 'ms']);

    % Compute centroid
    R = nchoosek(1:nfs,2);
    % add on the mirrored locations... and the diagonal elements.
    R = [R;R(:,[2 1]);[(1:nfs)' (1:nfs)']];
    % sort so that it lines up with the data in scd.
    [s,I] = sort(R(:,2));
    R = R(I,:);
    [s,I] = sort(R(:,1));
    R = R(I,:);
    peak_centroid = centroid (R, scd (:,:,peak));

end
