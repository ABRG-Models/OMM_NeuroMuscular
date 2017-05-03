function movieMakerImagesc (handle, data, thetitle)
    imagesc (data, 'Parent', handle, [0 0.1]);
    title (handle, thetitle);
    set (gcf,'colormap', hot);
    axis (handle, 'tight', 'square', 'off')
end
