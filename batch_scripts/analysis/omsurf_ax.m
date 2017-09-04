% Plot a surface plot with some standard views.
function omsurf_ax (ax, data, field, time, surf_view=1, toplim=1, botlim=0)
    surf (ax, data.(field)(:,:,time))
    title (ax, field)
    zlim(ax, [botlim, toplim])
    % Add some useful views here:
    if (surf_view==1)
        view(ax, [30,60])
    elseif (surf_view==2) % To be good for a negative hump
        view(ax, [30,10])
    else
        view(ax, [20,89])
    end
    xlabel(ax,'r')
    ylabel(ax,'\phi')
end
