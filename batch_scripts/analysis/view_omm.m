function view_omm (data, t, fignum)
%% View the model output 'data' in a customised multiple plot at time t. fignum
%% is an optional argument so you can show several timesteps in
%% different figures.

    if nargin < 2
       display ('at least 2 args required (data and time t)');
       return;
    end
    
    if nargin < 3
        fignum = 75;
    end

    h_f = figure (fignum); clf;
    
    %set (h_f,'units','normalized','outerposition', [ 0 0.4 0.7 0.5]);
    text (0, 0, ['Time = ' num2str(t) ' ms']);

    % Spacing for subaxes
    sa_spc = 0.03;
    sa_pad = 0.01;
    sa_pad_2d = 0.03;
    sa_marg = 0.03;
    
    % Parameters for the view for 3D surf plots:
    view_azi = 30;
    view_elev = 20;

    % Your favoured line width and marker size:
    lw = 2;
    ms = 20;
    
    h_world = subaxis (2,5,1, 'Spacing', sa_spc, 'Padding', sa_pad, 'Margin', sa_marg);
    surf (data.world(:,:,t));
    %colormap(h_world, 'autumn')
    zlim([0 1]);
    view([view_azi view_elev]);
    title(['World @ ' num2str(t) ' ms']);

    h_fef = subaxis (2,5,2, 'Spacing', sa_spc, 'Padding', sa_pad, 'Margin', sa_marg);
    surf (data.fef(:,:,t));
    %colormap(h_fef, 'winter')
    zlim([0 1]);
    view([view_azi view_elev]);
    title('FEF');

    subaxis (2,5,3, 'Spacing', sa_spc, 'Padding', sa_pad, 'Margin', sa_marg);
    surf (data.thal(:,:,t));
    %colormap('hot')
    zlim([0 1]);
    view([view_azi view_elev]);
    title('Thalamus');

    subaxis (2,5,6, 'Spacing', sa_spc, 'Padding', sa_pad, 'Margin', sa_marg);
    surf (data.stn(:,:,t));
    %colormap('hot')
    zlim([0 1]);
    view([view_azi view_elev]);
    title('STN');
    
    subaxis (2,5,7, 'Spacing', sa_spc, 'Padding', sa_pad, 'Margin', sa_marg);
    surf (data.snr(:,:,t));
    %colormap('hot')
    zlim([0 1]);
    view([view_azi view_elev]);
    title('SNr');

    subaxis (2,5,8, 'Spacing', sa_spc, 'Padding', sa_pad, 'Margin', sa_marg);
    surf (data.scd(:,:,t));
    %colormap('hot')
    zlim([0 1]);
    view([view_azi view_elev]);
    title('SCd');

    subaxis (2,5,4, 'Spacing', sa_spc, 'Padding', sa_pad_2d, 'Margin', sa_marg);
    h_eyery = plot (data.eyeRy, 'b-');
    set (h_eyery, 'linewidth', lw, 'markersize', ms);
    hold on;
    plot (t, data.eyeRy(t), 'b.');
    mn_multiplier = 20;
    h_mn = plot (data.mn.*mn_multiplier, 'r-');
    set (h_mn, 'linewidth', lw, 'markersize', ms);
    plot (t, data.mn(t).*mn_multiplier, 'r.');
    h_mn_r = plot (data.mn_r.*mn_multiplier, 'g-');
    set (h_mn_r, 'linewidth', lw, 'markersize', ms);
    plot (t, data.mn_r(t).*mn_multiplier, 'g.');
    maxes = [ max(data.eyeRy) max(data.mn) max(data.mn_r) ];
    mins = [ min(data.eyeRy) min(data.mn) min(data.mn_r) ];
    plot ([t,t], [min(mins),max(maxes)], 'k--');
    title('Rotation Y');
    xlabel('t (ms)');
    hl = legend([h_eyery, h_mn, h_mn_r], 'Rotation', 'MN left', ['MN ' ...
                        'right']);
    legend location northwest;
    set (hl, 'fontsize', 10);

    subaxis (2,5,5, 'Spacing', sa_spc, 'Padding', sa_pad_2d, 'Margin', sa_marg);
    h_ebn = plot (data.ebn, 'r-');
    hold on;
    set (h_ebn, 'linewidth', lw, 'markersize', ms);
    plot (t, data.ebn(t), 'r.');
    h_ebn_r = plot (data.ebn_r, 'g-');
    set (h_ebn_r, 'linewidth', lw, 'markersize', ms);
    plot (t, data.ebn_r(t), 'g.');
    plot ([t,t], [0,1], 'k--');
    title('EBN');
    xlabel('t (ms)');
    hl = legend([h_ebn, h_ebn_r], 'EBN left', 'EBN right');
    legend location northwest;
    set (hl, 'fontsize', 10);

    h_ibn = subaxis (2,5,9, 'Spacing', sa_spc, 'Padding', sa_pad_2d, 'Margin', sa_marg);
    h_ibn = plot (data.ibn, 'b-');
    set (h_ibn, 'linewidth', lw, 'markersize', ms);
    hold on;
    plot (t, data.ibn(t), 'b.');
    h_llbn = plot (data.llbn, 'g-');
    set (h_llbn, 'linewidth', lw, 'markersize', ms);
    plot (t, data.llbn(t), 'g.');
    plot ([t,t], [0,1], 'k--');
    ylim ([0 1]);
    title('IBN & LLBN Left');
    xlabel('t (ms)');
    hl = legend([h_ibn, h_llbn], 'IBN left', 'LLBN left');
    legend location northwest;
    set (hl, 'fontsize', 10);

    h_ibn = subaxis (2,5,10, 'Spacing', sa_spc, 'Padding', sa_pad_2d, 'Margin', sa_marg);
    h_ibn = plot (data.ibn_r, 'b-');
    set (h_ibn, 'linewidth', lw, 'markersize', ms);
    hold on;
    plot (t, data.ibn_r(t), 'bo');
    h_llbn = plot (data.llbn_r, 'g-');
    set (h_llbn, 'linewidth', lw);
    plot (t, data.llbn_r(t), 'g.');
    plot ([t,t], [0,1], 'k--');
    ylim ([0 1]);
    title('IBN & LLBN Right');
    xlabel('t (ms)');
    hl = legend([h_ibn, h_llbn], 'IBN right', 'LLBN right');
    legend location northwest;
    set (hl, 'fontsize', 10);
    
end
