function [centroid_x, centroid_y, sigma_a] = centroid_linear (sheet)
%% Find simple linear centroid. Neural sheet is expected to be 50x50. Resize
%% if necessary before calling this function.

    % Linear centroid computation
    x = 1:50;
    [Y X] = meshgrid(x,x);
    %centroids = zeros(50,50);

    sigma_r_dot_a_x = sum(sum(X.*sheet))
    sigma_r_dot_a_y = sum(sum(Y.*sheet));
    sigma_a = sum(sum(sheet))
    centroid_x = sigma_r_dot_a_x./double(sigma_a);
    centroid_y = sigma_r_dot_a_y./double(sigma_a);
    %centroids(round(centroid_x), round(centroid_y)) = sigma_a;

end % multicentroid_compute
