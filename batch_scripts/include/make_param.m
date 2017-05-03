function [param, paramiter, randomvalue] = make_param (param_min, param_max, numpoints)
    pointsize = (param_max - param_min) ./ numpoints;
    param = [param_min:pointsize:param_max-pointsize];
    paramiter = ceil(unifrnd(0,numpoints));
    randomvalue = param(paramiter);
end
