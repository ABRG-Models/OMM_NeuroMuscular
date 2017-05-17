% Plot a time series of the summed activity in a population sheet
% Useful for scd analysis
function omsum (fignum, data, field)
    figure(fignum)
    clf
    plot (sum(sum(data.(field)(:,:,:))))
    title (field)
end
