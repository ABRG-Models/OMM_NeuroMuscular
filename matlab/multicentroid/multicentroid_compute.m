function [centroids, centroidmaps, rtnsheet] = multicentroid_compute (sheet,centroid_radius)
%% Find the localised centroids. Neural sheet is expected to be 50x50. Resize
%% if necessary before calling this function.

    % Note: this not necessary:
    % First blur out any bit noise in the peaks
    % smoothed_sheet = pv_multicentroid_smooth (sheet);
    % ...or just threshold it?
    % thresholded_sheet = pv_multicentroid_abvthresh (sheet);

    % Find locations of the peaks (pass smoothed_sheet or
    % thresholded_sheet if necessary)
    [ indices, fp_rtnsheet ] = pv_multicentroid_find_peaks (sheet);
    rtnsheet = fp_rtnsheet;

    % Turn these into "centroiding region maps"
    centroidmaps = pv_multicentroid_make_centroid_maps (indices, centroid_radius);

    % Centroid computation (do this for each map)
    x = 1:50;
    [Y X] = meshgrid(x,x);
    centroids = zeros(50,50);

    % How many maps in centroidmaps?
    num_maps = size(centroidmaps);
    sz_num_maps = size(num_maps);
    max_map = 0;
    if sz_num_maps(2) >= 3
        max_map = num_maps(3);
    elseif sz_num_maps(2) == 2 && num_maps == [50 50]
        max_map = 1;
    end

    iter = 1;
    while iter <= max_map
        partsheet = sheet .* centroidmaps(:,:,iter);
        sigma_r_dot_a_x = sum(sum(X.*partsheet));
        sigma_r_dot_a_y = sum(sum(Y.*partsheet));
        sigma_a = sum(sum(partsheet));
        centroid_x = round(sigma_r_dot_a_x./sigma_a);
        centroid_y = round(sigma_r_dot_a_y./sigma_a);
        centroids(centroid_x, centroid_y) = sigma_a;
        iter = iter + 1;
    end

end % multicentroid_compute

function smoothed_sheet = pv_multicentroid_smooth (sheet)
%% Smooth the incoming neural field, in particular to make the peaks of
%% the hills nice and smooth.
%%
%% Note: The pv_ prefix is a convention I use to indicate that
%% this is a private function.

    % Discard noise - extract peaks which are > twice the mean
    % value of the entire sheet.
    above_threshold = sheet .* gt(sheet - (2*mean(mean(sheet))), 0);

    % 2nd arg is size of gaussian; 3rd is spread.
    H = fspecial('gaussian', [10,10], 2);
    smoothed_sheet = imfilter (above_threshold, H);
    %figure(46); surf (smoothed_sheet);    

end % pv_multicentroid_smooth

function abvthresh_sheet = pv_multicentroid_abvthresh (sheet)
%% Ignore noise, select out peaks. ABoVe THRESHold.

    % Discard noise - extract peaks which are > twice the mean
    % value of the entire sheet.
    abvthresh_sheet = sheet .* gt(sheet - (2*mean(mean(sheet))), 0);
    %figure(46); surf (abvthresh_sheet);

end % pv_multicentroid_abvthresh

function [ indices, rtnsheet ] = pv_multicentroid_find_peaks (smoothed_sheet)
%% Find the indices (as a matrix of two vectors) of the peaks in
%% smoothed_sheet.
%%
%% Do this by first finding those regions which are above twice the mean
%% value of of the field, then finding where their derivative is
%% near zero.
    
    % abs value of first derivative, wrt dim1
    sec_deriv1 = [ zeros(1,50); diff(smoothed_sheet, 2, 1) ; zeros(1,50) ];
    %figure(50); surf (sec_deriv1);

    rtnsheet = sec_deriv1;
    
    % Find points where the second deriviative is minimum.
    sec_deriv_max = max(max(sec_deriv1));
    sec_deriv_min = min(min(sec_deriv1));
    min_sec_deriv1 = lt (sec_deriv1, sec_deriv_min + (0.5*(sec_deriv_max-sec_deriv_min)));
    %figure(54); surf (min_sec_deriv1.*1.0001);

    % Multiply the "min second deriv points" by the region of the sheet
    % which is above a value threshold. This gives regions of the map
    % where there is a hill above a threshold, but the derivative of
    % the hill is near zero - i.e. the peak.
    peaks1 = smoothed_sheet.*min_sec_deriv1;

    % Now find min of second derivative, but using the derivatives in
    % the 2nd dimension.
    sec_deriv2 = [ diff(smoothed_sheet, 2, 2) , zeros(50,2) ];
    %figure(56); surf (sec_deriv2);
    sec_deriv_max = max(max(sec_deriv2));
    sec_deriv_min = min(min(sec_deriv2));
    min_sec_deriv2 = lt (sec_deriv2, sec_deriv_min + (0.5*(sec_deriv_max-sec_deriv_min)));
    %figure(58); surf (min_sec_deriv2.*1.0001);
    peaks2 = smoothed_sheet.*min_sec_deriv2;

    % Add the two and raise to a power.
    %peaks = (peaks2 + peaks1) .^ 3;
    peaks = (min_sec_deriv1 + min_sec_deriv2) .^ 2;
    figure(60); surf(peaks);
 
    % with this map, find points above 50% of full range.
    peaksthresh = max(max(peaks)) .* 0.5
    peaksfinal = gt(peaks, peaksthresh);
    figure(62); surf(peaksfinal.*1.001);
    
    % peaksfinal now has the locations of the peaks. Need these as indices
    % to make subsheets of sheet to do multiple centroids now.
    [ i_x, i_y ] = find (peaksfinal);
    indices = [ i_x, i_y ];

end % pv_multicentroid_find_peaks

function centroidmaps = pv_multicentroid_make_centroid_maps (indices,centroid_radius)
%% Using a list of the locations of the peaks in the neural field, make a
%% series of centroid region maps.
%%
%% centroid_radius is the "radius over which neurons in the SC_deep
%% communicate". If two peaks are within centroid_radius units of each other,
%% then they are grouped together in one "centroiding map". If
%% they're further than this distance apart, they'll lead to two
%% separate centroiding maps.
    
    x = 1:50;
    [Y X] = meshgrid(x,x);

    % Can now create a circular map around each centroid centre -
    % the centre of the hill of activity.
    map_j = zeros(50,50);
    map_i = map_j;
    centroidmaps = map_j;
    iter = 1;
    sz = size(indices);
    i = 1;
    while i <= sz(1)
    
        x_sq = power(abs(X-indices(i,1)), 2);
        y_sq = power(abs(Y-indices(i,2)), 2);
        D = sqrt (x_sq + y_sq);
        map_i = lt(D, centroid_radius);
        sum_i = sum(sum(map_i));

        % From this index, i, check if ANY of the other maps touch
        % this one and merge those which do. New index j to count
        % from i to the end of the indices matrix.
        j = i + 1;
        while j <= sz(1)
        
            x_sq = power(abs(X-indices(j,1)), 2);
            y_sq = power(abs(Y-indices(j,2)), 2);
            D = sqrt (x_sq + y_sq);
            map_j = lt(D, centroid_radius);
            sum_j = sum(sum(map_j));

            % Work out if two maps are touching by adding them together and
            % seeing if that sums to the same as the two individual
            % maps. If so, they're separate and so treat them as two
            % separate maps. Otherwise; merge.
            U = gt(map_i + map_j, 0);
            sum_both = sum(sum(U));
            
            if sum_i > 0 && sum_j > 0 && sum_i + sum_j == sum_both
                % j is a separate mask from i, so move on to the next j.
                j = j + 1; % next j
            else
                % They're touching, so add map_j to map_i, remove
                % indices element j and then reset j to i+1 and
                % restart this algorithm.
                map_i = gt(map_i + map_j, 0);
                sum_i = sum(sum(map_i));
                indices(j, :) = [];
                sz = size(indices);
                j = i + 1; % back to i
            end
        end

        centroidmaps(:,:,iter) = map_i;
        iter = iter + 1;
        i = i + 1;
    end

end % pv_multicentroid_make_centroid_maps
