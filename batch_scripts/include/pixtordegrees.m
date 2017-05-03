% Convert from the 1:50 pixel version of retinotopic radius to degrees.
function [rdeg] = pixtordegrees (rpix)
    % Here's the mapping from retinotopic radial component (r) and
    % angular component (phi) to the eyeframe map thetaX/thetaY
    % (rotation _about_ x and y axes)

    E2 = 2.5; % radial angle at which neural density has halved 
    nfs = 50; % 50x50 grid.
    fieldOfView = 61; % 0 and +/- 30 degrees
    % The Magnification factor
    Mf = nfs./(E2.*log(((fieldOfView./2)./E2)+1));

    rdeg = E2.*(-1+exp(rpix./(Mf.*E2)));
end
