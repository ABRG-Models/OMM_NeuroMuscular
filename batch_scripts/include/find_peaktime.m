% Find the time of the first peak in activity in the LLBNs. This
% will be the time of the peak in activity in SCa/SCdeep. This
% "time" is actually an index into the time series. At the
% time of writing 1 timestep = 1 ms.
%
% Also return the llbn data as a matrix [llbn_l; llbn_r; llbn_u; llbn_d]
%
function [peaktime llbn] = find_peaktime (basepath)
    peaktime = -1;
    [llbn_left, count] = load_sc_data ([basepath '/log/LLBN_left_a_log.bin'], 1);
    display(['Loaded ' num2str(count) ' data points from llbn_l']);

    % We expect the run to have 450 datapoints - 0.45 s runtime
    % with 1 ms per step.
    if count < 450
        display (['Only ' num2str(count) ' data points, won''t search for peak.']);
        return
    end

    % Load the rest
    [llbn_right, count] = load_sc_data ([basepath '/log/LLBN_right_a_log.bin'], 1);
    [llbn_up, count] = load_sc_data ([basepath '/log/LLBN_up_a_log.bin'], 1);
    [llbn_down, count] = load_sc_data ([basepath '/log/LLBN_down_a_log.bin'], 1);

    peaktime_l = min (find (llbn_left>0));
    peaktime_r = min (find (llbn_right>0));
    peaktime_u = min (find (llbn_up>0));
    peaktime_d = min (find (llbn_down>0));
    % If any of the above are empty, then there will be
    % correspondingly fewer entries in peaktimes:
    peaktimes = [peaktime_l peaktime_r peaktime_u peaktime_d];
    % So min(peaktimes) should be safe:
    peaktime = min(peaktimes);

    display (['peaktime = ' num2str(peaktime)]);

    llbn = [llbn_left; llbn_right; llbn_up; llbn_down];
end
