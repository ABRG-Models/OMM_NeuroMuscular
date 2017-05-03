% Make graphs of the world at time t and 1 ms afterwards.
function plot_world_targets (data, t=150, fignum)

    if nargin < 1
       display ('at least 1 arg required (data)');
       return;
    end
    
    if nargin < 3
        fignum = 75;
    end

    h_f = figure (fignum); clf;

    % Parameters for the view for 3D surf plots:
    view_azi = 30;
    view_elev = 20;
    % Spacing for subaxes
    sa_spc = 0.03;
    sa_pad = 0.01;
    sa_pad_2d = 0.03;
    sa_marg = 0.03;

    h_one = subaxis (1,2,1, 'Spacing', sa_spc, 'Padding', sa_pad, 'Margin', sa_marg);
    surf (data.world(:,:,t));
    %colormap(h_one, 'autumn')
    zlim([0 0.2]);
    view([view_azi view_elev]);
    title(['World @ ' num2str(t) ' ms']);
    xlabel('radius')
    ylabel('phi')

    t = t + 1;
    h_two = subaxis (1,2,2, 'Spacing', sa_spc, 'Padding', sa_pad, 'Margin', sa_marg);
    surf (data.world(:,:,t));
    %colormap(h_one, 'autumn')
    zlim([0 0.2]);
    view([view_azi view_elev]);
    title(['World @ ' num2str(t) ' ms']);
    xlabel('radius')
    ylabel('phi')
    
end
