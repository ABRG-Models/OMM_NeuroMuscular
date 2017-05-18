function C = centroid_test (targetThetaY)
    [scd, c] = load_sc_data(['/fastdata/' getenv('USER') '/oculomotorT' num2str(targetThetaY) '_1/log/SC_deep_out_log.bin'], 2500);
    scd = reshape (scd, 50, 50, []);
    scd_time = sum(sum(scd));
    scd_time_shifted = scd_time(100:end);
    peak_s =  find (scd_time_shifted == max(scd_time_shifted));
    peak = peak_s + 100;
    points = find (scd(:,:,peak) > 0.2);
    mask = zeros(50,50);
    mask(points) = 1;
    surf (scd (:,:,peak))

    nfs=50;
    R = nchoosek(1:nfs,2);
    % add on the mirrored locations... and the diagonal elements.
    R = [R;R(:,[2 1]);[(1:nfs)' (1:nfs)']];
    % sort so that it lines up with the data in scd.
    [s,I] = sort(R(:,2));
    R = R(I,:);
    [s,I] = sort(R(:,1));
    R = R(I,:);
    C = centroid (R, scd (:,:,peak));
end
