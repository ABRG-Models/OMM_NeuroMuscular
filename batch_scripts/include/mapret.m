function [r, phi] = mapret (thetax, thetay)
    % mapping from eyeframe map to retinotopic coordinates.

    E2 = 2.5; % radial angle at which neural density has halved 
    nfs = 50.0; % 50x50 grid.
    fieldOfView = 61.0; % 0 and +/- 30 degrees
    % The Magnification factor
    Mf = nfs/(E2.*log(((fieldOfView./2)./E2)+1));

    % From atan alone, you can only get a value for phi between -pi/2 to pi/2 (or 
    % from 0 to pi). To cover the full range of phi, you have to make use of the
    % quadrant information and add +/-pi. atan2 does this for you, but it returns
    % a value between -pi and pi, whereas I want a value between 0 and 2pi, hence the
    % test for phi<0.
    phi = (nfs./(2*pi))*atan2 (thetay, thetax);
    if phi < 0
        phi = phi + nfs;
    end

    % Calculate r
    r = Mf.*E2.*log( (1./E2) * sqrt(thetax.*thetax + thetay.*thetay) + 1 );
    
end
