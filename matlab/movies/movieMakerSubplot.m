function movieMakerSubplot (subplot_title, data, subplot_index)
    sz = size(data);
    subplot (3,4,subplot_index)
    if (sz(1) == 2500)
        plot (data(2181,:));
    else
        plot (data(1,:));
    end
    title (subplot_title);
    set (gcf,'colormap',hot)
    axis tight square
end