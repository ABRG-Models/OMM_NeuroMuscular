function showdata(oneby2500, thetitle, mapnum)
    map = reshape(oneby2500, 50, 50, []);
    figure (mapnum); surf(map);
    title (thetitle,'fontsize',28);
    xlabel ('r','fontsize',24);
    ylabel ('phi','fontsize',24);
    zlabel ('weight','fontsize',20);
    view([-65,30]);
end
