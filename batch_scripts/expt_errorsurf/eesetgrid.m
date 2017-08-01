function [posx, posy] = eesetgrid (g, starty)
    startx = 20;

    widx = 560; widy = 420;

    spacex = 20; spacey = 80;

    posx = startx + g(1)*(widx + spacex);
    posy = starty + g(2)*(widy + spacey);

    set(gcf, 'Position', [posx posy widx widy])
end
