% matlab version of the retmap function in RetinotopicMapping.ipynb
function phideg = pixtophidegrees (phipix)
    % Here's the mapping from retinotopic radial component (r) and
    % angular component (phi) to the eyeframe map thetaX/thetaY
    % (rotation _about_ x and y axes)

    E2 = 2.5; % radial angle at which neural density has halved 
    nfs = 50; % 50x50 grid.
    fieldOfView = 61; % 0 and +/- 30 degrees
    % The Magnification factor
    Mf = nfs./(E2.*log(((fieldOfView./2)./E2)+1));

    % Produces output which gives us 0=U,90=L,180=D,270=R
    phideg = (phipix.*360./nfs);
    
    %phideg = (phipix.*360./nfs)+90;
    %indices = find(phideg > 360);
    %phideg(indices) = phideg(indices)-360;
end
