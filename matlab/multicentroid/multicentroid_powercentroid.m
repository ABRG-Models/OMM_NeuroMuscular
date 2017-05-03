function centroid = multicentroid_powercentroid (sheet,power_degree)
%% Do a "power centroid" across the entire map. Pass power_degree =
%% 1 for a linear centroid.

    % Centroid computation
    x = 1:50;
    [Y X] = meshgrid(x,x);
    centroid = zeros(50,50);

    sigma_r_dot_a_x_to_pow = sum(sum(power(X.*sheet, power_degree)));
    sigma_r_dot_a_y_to_pow = sum(sum(power(Y.*sheet, power_degree)));
    sigma_a_to_pow = sum(sum(power(sheet, power_degree)));
    centroid_x = round(power(sigma_r_dot_a_x_to_pow./sigma_a_to_pow, 1/power_degree));
    centroid_y = round(power(sigma_r_dot_a_y_to_pow./sigma_a_to_pow, 1/power_degree));
    centroid(centroid_x, centroid_y) = sigma_a_to_pow;

end % multicentroid_powercentroid
