% Visualise several OM plots at once.
%
% Usage: retview (data, t)
function retview (data, t)

    h_f = figure (1); clf;
    h_f_pos = get(h_f, 'Position');
    set(h_f, 'Position', [20, 1000, 2100, 600]);

    % Best viewing angle for the surfaces
    viewx=120; viewy=45;

    % Spacing for subaxes
    sa_spc = 0.03;
    sa_pad = 0.03;
    sa_pad_mid = 0.04;
    sa_pad_2d = 0.03;
    sa_marg = 0.08;
    sa_marg_mid = 0.1;
    sa_marg_sideout = 0.1;

    % Your favoured line width and marker size:
    lw = 2;
    ms = 20;

    % Main fontsize
    fs1 = 28;

    zmax = 0.5;

    hax(1) = subaxis (1,3,1, 'SpacingVert', sa_spc, 'SpacingHoriz', sa_spc, ...
                  'PaddingLeft', sa_pad, 'PaddingRight', sa_pad, 'PaddingTop', sa_pad, 'PaddingBottom', sa_pad, ...
                  'MarginLeft', sa_marg, 'MarginRight', sa_marg, 'MarginTop', sa_marg, 'MarginBottom', sa_marg);

    surf (data.ret2(:,:,t));
    setaxprops (hax(1), fs1);
    title (['Ret2'], 'fontsize', fs1);
    xlabel ('r'); ylabel ('\phi');
    zlim([0, zmax])
    view([viewx,viewy])

    hax(2) = subaxis (1,3,2, 'SpacingVert', sa_spc, 'SpacingHoriz', sa_spc, ...
                  'PaddingLeft', sa_pad, 'PaddingRight', sa_pad, 'PaddingTop', sa_pad, 'PaddingBottom', sa_pad, ...
                  'MarginLeft', sa_marg, 'MarginRight', sa_marg, 'MarginTop', sa_marg, 'MarginBottom', sa_marg);

    surf (data.ret1(:,:,t));
    setaxprops (hax(2), fs1);
    title (['Ret1'], 'fontsize', fs1);
    xlabel ('r'); ylabel ('\phi');
    zlim([0, zmax])
    view([viewx,viewy])

    hax(3) = subaxis (1,3,3, 'SpacingVert', sa_spc, 'SpacingHoriz', sa_spc, ...
                  'PaddingLeft', sa_pad, 'PaddingRight', sa_pad, 'PaddingTop', sa_pad, 'PaddingBottom', sa_pad, ...
                  'MarginLeft', sa_marg, 'MarginRight', sa_marg, 'MarginTop', sa_marg, 'MarginBottom', sa_marg);

    surf (data.scs(:,:,t));


    setaxprops (hax(3), fs1);
    title (['Superficial SC'], 'fontsize', fs1);
    xlabel ('r'); ylabel ('\phi');
    zlim([0, zmax])
    view([viewx,viewy])

end

function setaxprops (h, fs)
    set(h, 'fontsize', fs);
end
