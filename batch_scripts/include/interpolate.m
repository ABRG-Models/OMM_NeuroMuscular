% Take testmap, and fill in the gaps, by doing linear
% interpolation. Interpolate in either direction or both as
% possible. If gaps are up to 2 wide, interpolate, but if the gap is 3
% wide (i.e. with 3 or more missing values) then DON'T interpolate.
function [ interpmap, finalmap ] = interpolate (testmap)

    iside = size(testmap)(1);
    jside = size(testmap)(2);
    
    interpmap = zeros(iside,jside);
    finalmap = zeros(iside,jside);
    
    for i=1:iside
        for j=1:jside
            %printf ('vvvvvvvvvvv\nI/J: %d, %d\n', i,j);
            if isnan(testmap(i,j))

                % Try to interpolate. First in i dirn
                i_interpolates = 1;
                ii = i-1;
                while ii>=1 && isnan(testmap(ii,j))
                    ii = ii-1;
                end
                if ii<1 || isnan(testmap(ii,j))
                    i_interpolates = 0;
                end
                
                iii=i+1;
                while iii <= iside && isnan(testmap(iii,j))
                    iii = iii+1;
                end
                if iii>iside || isnan(testmap(iii,j)) ...
                        || abs(iii-ii) > 3
                    i_interpolates = 0;
                end
                
                if i_interpolates
                    %printf ('i interpolates: ii:%d;  iii:%d.\n', ii, iii);
                    leftval = testmap(ii,j);
                    rightval = testmap(iii,j);
                    deltaval = rightval - leftval;
                    deltadist = iii-ii;
                    dvdd = deltaval./deltadist;
                    distii = i-ii;
                    newvalnum_i = testmap(ii,j) + (dvdd .* distii);
                end

                j_interpolates = 1;
                jj = j-1;
                while jj>=1 && isnan(testmap(i,jj))
                    jj = jj-1;
                end
                
                if jj<1 || isnan(testmap(i,jj)) ...
                        || abs(jjj-jj) > 3
                    j_interpolates = 0;
                end
                
                jjj=j+1;
                while jjj <= jside && isnan(testmap(i,jjj))
                    jjj = jjj+1;
                end
                if jjj>jside || isnan(testmap(i,jjj))
                    j_interpolates = 0;
                end
                
                % Second in j direction
                if j_interpolates
                    %printf ('j interpolates, jj:%d;  jjj:%d.\n', jj, jjj);
                    leftval = testmap(i,jj);
                    rightval = testmap(i,jjj);
                    deltaval = rightval - leftval;
                    deltadist = jjj-jj;
                    dvdd = deltaval./deltadist;
                    distjj = j-jj;
                    newvalnum_j = testmap(i,jj) + (dvdd .* distjj);
                end

                if (i_interpolates && j_interpolates)
                    interpmap(i,j) = (newvalnum_i + newvalnum_j) ./2;
                    %printf(['Interpolate with mean of i and j dirn at ' ...
                    %                    '%d,%d=%f\n'], ...
                    %       i, j, interpmap(i,j));
                elseif (i_interpolates && ~j_interpolates)
                    interpmap(i,j) = newvalnum_i;
                    %printf(['Interpolate with i dirn at ' ...
                    %                    '%d,%d=%f\n'], ...
                    %       i, j, interpmap(i,j));
                elseif (~i_interpolates && j_interpolates)
                    interpmap(i,j) = newvalnum_j;
                    %printf(['Interpolate with j dirn at ' ...
                    %                    '%d,%d=%f\n'], ...
                    %       i, j, interpmap(i,j));
                end % else do nothing
            else
                %printf ('not nan at %d,%d\n', i, j);
            end
            %printf ('^^^^^^^^^^^\n');
        end
    end

    testmap(isnan(testmap)) = 0;
    finalmap = testmap + interpmap;    

    % Revert zeros to nans:
    testmap(testmap==0) = nan;
    %finalmap(finalmap==0) = nan;
    interpmap(interpmap==0) = nan;

end
