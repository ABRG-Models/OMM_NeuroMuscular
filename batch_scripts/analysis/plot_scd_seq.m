% Plot a sequence of plots of the SCdeep population spaced 20 ms apart
% (or change tinc to the increment you need) starting from
% t. Optionally state which fignum you want.
function plot_scd_seq (data, t, fignum)

    if nargin < 2
       display ('at least 2 args required (data and time t)');
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

    tinc = 20;
    
    h_one = subaxis (1,3,1, 'Spacing', sa_spc, 'Padding', sa_pad, 'Margin', sa_marg);
    surf (data.scd(:,:,t));
    %colormap(h_one, 'autumn')
    zlim([0 1]);
    view([view_azi view_elev]);
    title(['SCd @ ' num2str(t) ' ms']);
    xlabel('radius')
    ylabel('phi')

    t = t + tinc;
    h_two = subaxis (1,3,2, 'Spacing', sa_spc, 'Padding', sa_pad, 'Margin', sa_marg);
    surf (data.scd(:,:,t));
    %colormap(h_one, 'autumn')
    zlim([0 1]);
    view([view_azi view_elev]);
    title(['SCd @ ' num2str(t) ' ms']);
    xlabel('radius')
    ylabel('phi')

    t = t + tinc;
    h_three = subaxis (1,3,3, 'Spacing', sa_spc, 'Padding', sa_pad, 'Margin', sa_marg);
    surf (data.scd(:,:,t));
    %colormap(h_one, 'autumn')
    zlim([0 1]);
    view([view_azi view_elev]);
    title(['SCd @ ' num2str(t) ' ms']);
    xlabel('radius')
    ylabel('phi')
    
end
