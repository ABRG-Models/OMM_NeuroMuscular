function fiftyby50 = showdata(oneby2500, thetitle, mapnum, zrange)
    fiftyby50 = reshape(oneby2500, 50, 50, []);
    figure (mapnum); surf(fiftyby50);
    title (thetitle,'fontsize',28);
    xlabel ('r','fontsize',24);
    ylabel ('phi','fontsize',24);
    zlabel ('weight','fontsize',20);
    view([-65,30]);
    if nargin > 3
        zlim(zrange);
    end
end
