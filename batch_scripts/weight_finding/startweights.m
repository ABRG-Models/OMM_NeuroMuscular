function startweights (thetax, thetay, map_path)

    addpath ('analysis');
    addpath ('analysis/include');
    addpath ('include');
    
    xweight = 0;
    yweight = 0;
    zweight = 0;
    
    % Problem with this scheme - r and phi within the model are
    % skewed away from r and phi from the pure geometry. This is ok
    % within the context of the model running, but it makes this
    % conversion less useful.
    %
    % A solution to this would be to take the data directly from
    % allweights.log, for which I will need to have the
    % thetax/thetay data in each row of allweights.log. I hadn't
    % implemented that with the 201509_RotZ runs, so this'll have
    % to wait.
    [ r, phi ] = mapret (thetax, thetay);
    r = ceil (r)
    phi = floor (phi)
    
    
    % Load up the data
    e50 = load_neural_sheet ([map_path '/explicitDataBinaryFile50.bin']);
    e52 = load_neural_sheet ([map_path '/explicitDataBinaryFile52.bin']);
    e53 = load_neural_sheet ([map_path '/explicitDataBinaryFile53.bin']);
    e54 = load_neural_sheet ([map_path '/explicitDataBinaryFile54.bin']);
    e57 = load_neural_sheet ([map_path '/explicitDataBinaryFile57.bin']);
    e58 = load_neural_sheet ([map_path '/explicitDataBinaryFile58.bin']);
    
    e50 = reshape (e50, 50, 50, []);
    e52 = reshape (e52, 50, 50, []);
    e53 = reshape (e53, 50, 50, []);
    e54 = reshape (e54, 50, 50, []);
    e57 = reshape (e57, 50, 50, []);
    e58 = reshape (e58, 50, 50, []);
    
    
    if thetax >= 0 && thetay >= 0
        % Up and left; e53 and e50
        xweight = e53(phi,r);
        figure(53); surf (e53); zlim([0,2]);
        zweight = e58(phi,r);
        yweight = e50(phi,r);
        figure(50); surf (e50); zlim([0,2]);
    elseif thetax >= 0 && thetay < 0
        % Up and right; e53 and e52
        xweight = e53(phi,r);
        zweight = e58(phi,r);
        yweight = e52(phi,r);
    elseif thetax < 0 && theta y >= 0
        % Down and left; e54 and e50
        xweight = e54(phi,r);
        zweight = e57(phi,r);
        yweight = e50(phi,r);
    else
        % Down and right; e54 and e52
        xweight = e54(phi,r);
        zweight = e57(phi,r);
        yweight = e52(phi,r);
    end
    
    printf ('%f,%f,%f\n', xweight, yweight, zweight);
end
