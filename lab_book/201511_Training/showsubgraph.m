function fiftyby50 = showsubgraph(fiftyby50, thetitle, mapnum, axishandle)
    h = surf(axishandle, fiftyby50);
    %set(h,'LineStyle','none')
    set(h,'LineWidth', 0.1)
    title (thetitle,'fontsize',12);
    xlabel ('r','fontsize',12);
    ylabel ('phi','fontsize',12);
    zlabel ('weight','fontsize',12);
    view([-65,30]);
end
