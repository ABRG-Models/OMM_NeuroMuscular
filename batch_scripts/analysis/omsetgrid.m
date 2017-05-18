function [posx, posy] = omsetgrid (g)
    startx = 610; starty = 360;
    %    widx = 450; widy = 380;
    widx = 350; widy = 280;
    spacex = 20; spacey = 80;

    posx = startx + g(1)*(widx + spacex);
    posy = starty + g(2)*(widy + spacey);
    set(gcf, 'Position', [posx posy widx widy])
end
