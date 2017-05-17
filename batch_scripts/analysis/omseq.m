% Watch a sequence of graphs from startt
function omseq (data, startt, tinc=10, tend=1000)

    % To get stdout scrolling past while this runs:
    page_screen_output(0);
    page_output_immediately(1);

    %omsum(10, data, 'scd')
    %omsum(11, data, 'fef')
    %omsum(12, data, 'thal')

    t = startt;
    while t <= tend
        omview (data,t)
        pause(0.3)
        t = t + tinc
        %print (["t=" t])
    end
end
