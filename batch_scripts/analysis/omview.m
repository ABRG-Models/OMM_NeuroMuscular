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

    omsurf(10, data, 'world', t, 1, 6)
    omsetgrid ([1 1]);

    omplot(11, data, 'eyeRy')
    omsetgrid ([3 0]);

    omplot(12, data, 'eyeRx')
    omsetgrid ([4 0]);

    omplot(13, data, 'eyeRz')
    omsetgrid ([4 -1]);

    omplot(14, data, 'llbn_r')
    omsetgrid ([3 -1]);

    omplot(15, data, 'llbn_d')
    omsetgrid ([2 -1]);

    omplot(16, data, 'llbn_l')
    omsetgrid ([1 -1]);

    omplot(17, data, 'llbn_u')
    omsetgrid ([0 -1]);

    tmodel2=0
    if tmodel2
        omsurf(18, data, 'scd2', t, 1)
        omsetgrid ([0 0]);

        %omsurf(19, data, 'scd3', t, 1)
        %omsetgrid ([0 1]);
    end

    a = 1
    multsurf = data.sca; % or scd
    if a
        % These'll cover over some of the BG graphs
        figure(18); clf;
        surf (data.wm_d.*multsurf(:,:,t));
        view([30,60])
        title ('wm\_d x multsurf');
        omsetgrid ([0 1]);

        figure(19); clf;
        % These'll cover over some of the BG graphs
        surf (data.wm_r.*multsurf(:,:,t));
        view([30,60])
        title ('wm\_r x multsurf');
        omsetgrid ([0 2]);

        figure(20); clf;
        % These'll cover over some of the BG graphs
        surf (data.wm_l.*multsurf(:,:,t));
        view([30,60])
        title ('wm\_l x multsurf');
        omsetgrid ([-1 2]);
    end

    figure(21); clf;
    surf (data.sca(:,:,t));
    view([30,60])
    title ('sca');
    omsetgrid ([0 0]);

end