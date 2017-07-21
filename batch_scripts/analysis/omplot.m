% Do a plot of one of the time series
%
% Usage: omplot (fignum, data, field)
%
% Where fignum is a figure number, data is the object returned by
% load_ocm() and field is a string
function omplot (fignum, data, field)
    figure(fignum)
    clf
    plot (data.(field), 'r')
    title (field)
end