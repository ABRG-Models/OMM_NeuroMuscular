% Find the time of the first peak in activity in the LLBNs. This
% will be the time of the peak in activity in SCa/SCdeep. This
% "time" is actually an index into the time series. At the
% time of writing 1 timestep = 1 ms.
%
function peaktime = find_peaktime (basepath)
    peaktime = -1;
    [llbn_left, count] = load_sc_data ([basepath '/log/LLBN_left_a_log.bin'], 1);

    % We expect the run to have 450 datapoints - 0.45 s runtime
    % with 1 ms per step.
    if count < 450
        display (['Only ' num2str(count) ' data points, won''t search for peak.']);
        return
    end

    if isempty(peaktime = min (find (llbn_left>0)))
        [llbn_right, count] = load_sc_data ([basepath '/log/LLBN_right_a_log.bin'], 1);
        if isempty(peaktime = min (find (llbn_right>0)))
            [llbn_up, count] = load_sc_data ([basepath '/log/LLBN_up_a_log.bin'], 1);
            if isempty(peaktime = min (find (llbn_up>0)))
                [llbn_down, count] = load_sc_data ([basepath '/log/LLBN_down_a_log.bin'], 1);
                peaktime = min (find (llbn_down>0));
            end
        end
    end
    display (['peaktime = ' num2str(peaktime)]);
end
