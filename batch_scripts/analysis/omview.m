% Visualise several OM plots at once.
function omview (data, t)
    omsurf(1, data, 'snr', t, 2)
    omsurf(2, data, 'fef', t, 1)
    omsurf(3, data, 'scd', t, 1)
    omsurf(4, data, 'scs', t, 1)
    omsurf(5, data, 'strd1', t, 1)
    omsurf(6, data, 'strd2', t, 1)
    omsurf(7, data, 'gpe', t, 2)
    omsurf(8, data, 'stn', t, 1)
    omsurf(9, data, 'thal', t, 1)
    omsurf(10, data, 'world', t, 1)
end