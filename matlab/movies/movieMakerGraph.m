function movieMakerGraph (handle, xdata, ydata, thetitle)
    plot (handle, xdata, ydata, '.w','MarkerSize', 18);
    title (handle, thetitle);
    set (handle, 'Color', 'k', 'YTickLabel', [])
end