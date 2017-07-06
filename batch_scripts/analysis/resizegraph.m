function resizegraph (g, w, h)
    ps = get(g, 'position');
    ps(3) = w;
    ps(4) = h;
    set(g, 'position', ps);
end