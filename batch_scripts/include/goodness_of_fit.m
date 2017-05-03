% This is the "goodness of fit" function - just computes the root
% of the mean of the squares of the difference between the surface
% and the data. datamap is a (50x50) map of data. Locations in this
% map which contain no data should have the value NaN.
function gf = goodness_of_fit (datamap, surfacemap)
    diffsq = power(datamap .- surfacemap, 2); % errors squared
    diffsz = size(diffsq)(1).*size(diffsq)(2);
    gf = sqrt(sum(nansum(diffsq))/diffsz);
end