function [allc_x, allc_y, alla, allb] = find_saccade_location ...
        (output_dirs, run_number, allc_x, allc_y, alla, allb)
    % Find out where a single saccade occurred. Return coordinates

    % First we need to find out what time the saccade occurred. Do this by
    % looking at the llbn neurons
    peaktime = find_peaktime ([output_dirs.root '_' ...
                        num2str(run_number)]); % the time of the "peak in the superior
                                               % colliculus" in ms.

    % We expect the run to have 450 datapoints - 0.45 s runtime
    % with 1 ms per step.
    if peaktime == -1 || peaktime == 0
        display (['No peak.' ...
                  'Returning saccade location vectors (alla, etc) unmodified']);
        return
    end

    % ok, we have a peak time, now find location of the
    % peak
    model = 'Model1';
    if model == 'Model2'
        [sca, count] = load_sc_data ([ output_dirs.root '_' ...
                            num2str(run_number) '/log/' ...
                            'SC_avg_out_log.bin'], 2500);
        sca = reshape (sca, 50, 50, []);
        %display (['find in sca for time ' num2str(peaktime)]);
        [a,b] = find (sca(:,:,peaktime));
        alla = [ alla, a ];
        allb = [ allb, b ];
    end

    % How about centroid location of scd?
    [scd, count] = load_sc_data ([output_dirs.root '_' ...
                        num2str(run_number) '/log/SC_deep_out_log.bin'], 2500);
    scd = reshape (scd, 50, 50, []);
    m = find(max(max(scd(:,:,:)))<1);
    % Of the above, the last one as you count up before it
    % stops.
    saturate = find (diff(m)>2) % should be 1x1
    if isempty(saturate) == 0
        saturate = saturate(1) - 1
    else
        saturate = 1
    end
    [c_x, c_y, sigma_a] = centroid_linear (scd(:,:, saturate));
    c_x
    c_y
    % etc etc; do something with c_x and c_y
    allc_x = [ allc_x, c_x ];
    allc_y = [ allc_y, c_y ];

end % function find_saccade_location
