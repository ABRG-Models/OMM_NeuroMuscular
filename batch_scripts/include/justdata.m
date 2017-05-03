function [ map, means, cols ] = justdata (allweights, direction_identifier)
    selected_rows = find (allweights(:,1) == direction_identifier);
    means = [];
    map = nan(50);
    tlist = allweights(selected_rows,4:6);
    for i = tlist'
        if isnan(map(i(1),i(2)))
            % Find all points in tlist which have the same x/y coords and
            % compute a mean (there may only be 1):
            i1 = find (tlist(:,1)==i(1));
            i2 = find (tlist(:,2)==i(2));
            points = intersect (i1,i2);
            mp = mean(tlist(points,:), 1);
            % Write the mean value into e54map
            map(i(1),i(2)) = mp(3);
            means = [means; i(1), i(2), mp(3)];
        end
    end
    cols = allweights(selected_rows,4:6);
end
