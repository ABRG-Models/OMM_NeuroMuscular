% Do a plot of one of the time series
function omplot (fignum, data, field)
    figure(fignum)
    clf
    plot (data.(field), 'r')
    title (field)
end