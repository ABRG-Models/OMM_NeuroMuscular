% matlab version of the retmap function in RetinotopicMapping.ipynb
function [thetax,thetay] = retmap (r, phi)
    % Here's the mapping from retinotopic radial component (r) and
    % angular component (phi) to the eyeframe map thetaX/thetaY
    % (rotation _about_ x and y axes)

    E2 = 2.5; % radial angle at which neural density has halved 
    nfs = 50; % 50x50 grid.
    fieldOfView = 61; % 0 and +/- 30 degrees
    % The Magnification factor
    Mf = nfs./(E2.*log(((fieldOfView./2)./E2)+1));

    %_r = float(r)
    %_phi = float(phi)
    
    thetax = E2.*(-1+exp(r./(Mf.*E2))).*cos(phi.*2.*pi./nfs);
    thetay = E2.*(-1+exp(r./(Mf.*E2))).*sin(phi.*2.*pi./nfs);

    %printf 'RotX:',thetax,'RotY:',thetay
end
