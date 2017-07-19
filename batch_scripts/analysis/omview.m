% Visualise several OM plots at once.
%
% Usage: omview (data, t)
function omview (data, t)

    omsurf(1, data, 'snr', t, 2)
    omsetgrid ([2 1]);

    omsurf(2, data, 'fef', t, 1)
    omsetgrid ([1 2]);

    omsurf(11, data, 'fef_add_noise', t, 1)
    omsetgrid ([0 2]);

    omsurf(3, data, 'scd', t, 1)
    omsetgrid ([2 0]);

    omsurf(4, data, 'scs', t, 1)
    omsetgrid ([1 0]);

    omsurf(5, data, 'strd1', t, 1)
    omsetgrid ([3 2]);

    omsurf(6, data, 'strd2', t, 1)
    omsetgrid ([4 2]);

    omsurf(7, data, 'gpe', t, 2)
    omsetgrid ([4 1]);

    omsurf(8, data, 'stn', t, 1)
    omsetgrid ([3 1]);

    omsurf(9, data, 'thal', t, 1)
    omsetgrid ([2 2]);

    omsurf(10, data, 'world', t, 1)
    omsetgrid ([1 1]);

    omplot(11, data, 'eyeRy')
    omsetgrid ([3 0]);

    omplot(12, data, 'eyeRx')
    omsetgrid ([4 0]);

    omplot(13, data, 'eyeRz')
    omsetgrid ([4 -1]);

end